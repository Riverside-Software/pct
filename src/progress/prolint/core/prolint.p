/* ==========================================================================================
    file    : prolint/core/prolint.p
    purpose : scan sourcefile(s), look for sloppy programming and common mistakes
              see prolint/help/index.htm
    -----------------------------------------------------------------------------------------
    
    Copyright (C) 2001-2008 Jurjen Dijkstra

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   ========================================================================================== */
                                    
{prolint/core/dlc-version.i}

DEFINE INPUT PARAMETER pSourcefile     AS CHARACTER NO-UNDO. /* a single filename to lint */
DEFINE INPUT PARAMETER hSourcefileList AS HANDLE    NO-UNDO. /* handle to a list of filenames to lint */
DEFINE INPUT PARAMETER pCustomprofile  AS CHARACTER NO-UNDO. /* name of subdir in prolint/settings */
DEFINE INPUT PARAMETER pClearOutput    AS LOGICAL   NO-UNDO. /* add to existing output, or start new log */
             
/* TODO: idea for future version: accept wildcards in pSourcefile and/or in records in hSourcefileList.
         this current version expects specific filenames, wildcards are not supported */

DEFINE VARIABLE ProfileDirectory AS CHAR      NO-UNDO.
DEFINE VARIABLE MaxSeverity      AS INTEGER   NO-UNDO.
DEFINE VARIABLE listingfile      AS CHAR      NO-UNDO.
DEFINE VARIABLE xreffile         AS CHAR      NO-UNDO.
DEFINE VARIABLE hparser          AS HANDLE    NO-UNDO.
DEFINE VARIABLE topnode          AS INTEGER   NO-UNDO.
DEFINE VARIABLE NeedProparse     AS LOGICAL   NO-UNDO INITIAL NO.
DEFINE VARIABLE HasProparse      AS LOGICAL   NO-UNDO INITIAL YES.
DEFINE VARIABLE HasJpplus        AS LOGICAL   NO-UNDO INITIAL NO.
DEFINE VARIABLE needCompilerStreamIO AS LOGICAL NO-UNDO INITIAL NO.
DEFINE VARIABLE NeedListing      AS LOGICAL   NO-UNDO INITIAL NO.
DEFINE VARIABLE NeedXref         AS LOGICAL   NO-UNDO INITIAL NO.
DEFINE VARIABLE NeedProclist     AS LOGICAL   NO-UNDO INITIAL NO.
DEFINE VARIABLE hLintSuper       AS HANDLE    NO-UNDO.
DEFINE VARIABLE grandchild       AS INTEGER   NO-UNDO.
DEFINE VARIABLE tempdir          AS CHARACTER NO-UNDO.
DEFINE VARIABLE hpFilterPlugins  AS HANDLE    NO-UNDO.
DEFINE VARIABLE filemasks        AS CHARACTER NO-UNDO.
DEFINE STREAM rulemanifest.

{prolint/proparse-shim/api/proparse.i hparser}
   
{prolint/core/tt_rules.i}

DEFINE TEMP-TABLE tt_output NO-UNDO
   FIELD progname     AS CHARACTER
   FIELD DlcVersion   AS INTEGER
   FIELD WindowSystem AS CHARACTER 
   INDEX idx_progname AS PRIMARY UNIQUE progname.

DEFINE TEMP-TABLE tt_files NO-UNDO
   FIELD sourcefile   AS CHARACTER
   INDEX idx_sourcefile AS PRIMARY UNIQUE sourcefile.

define temp-table tt_Error no-undo
  field LineNumber   as integer
  field ErrorMessage as character
  index idx_linenumber is primary LineNumber.

   DEFINE VARIABLE propsrunning AS LOGICAL NO-UNDO INITIAL FALSE.
   PUBLISH "IsProlintPropertiesRunning":U (OUTPUT propsrunning).
   IF NOT propsrunning THEN
     RUN prolint/core/propsuper.p PERSISTENT.
   RUN IncrementProlintPropertySubscribers.
   filemasks = DYNAMIC-FUNCTION ("ProlintProperty", "compilationunit.filename.mask").

   /* make sure hParser is invalid. We will use function VALID-HANDLE() later, in GetProparseHandle */
   ASSIGN 
     hParser     = ?.
                     
   /* did the user install (purchase) proparse yet? If not most rules won't work. 
      Add a warning to the logfile to say proparse is required */
   hasProparse = true.  /* TODO: test if proparse.net assembly is available and defined in assemblies.txt, then show instructions when false */
                                            
   /* pick a dir for temporary files */
   RUN MakeTempdir.

   /* the place to read your custom settings from */                     
   RUN GetProfileDirectory.

   /* We need to subscribe to "Prolint_AddResult" because we want to set MaxSeverity */
   SUBSCRIBE TO "Prolint_AddResult" ANYWHERE.
   
   /* Initialize a place to store results: a logfile, the 'Prolint result window', whatever */     
   RUN InitializeOutputhandler.
   IF RETURN-VALUE="no handlers":U THEN DO:
      {&_proparse_ prolint-nowarn(message)}
      MESSAGE "prolint: no valid outputhandlers specified":U VIEW-AS ALERT-BOX.   
      RUN DeleteTempdir.
      RUN DecrementProlintPropertySubscribers.
      RETURN.
   END.
   
   PUBLISH "Prolint_Status_Action" ("initializing...").
   PUBLISH "Prolint_Status_Profile" (pCustomProfile).

   /* Initialize the set of rules, eg populate tt_rules.
      If there are no rules there is no point in continuing */
   RUN InitializeRules.
      
      /* TODO GQU Init rules */
      
   /* are there any rules that need proparse but proparse isn't installed? */   
   IF NeedProparse AND (NOT HasProparse) THEN
      PUBLISH "Prolint_AddResult":U ("":U, "":U,"0":U, "proparse required but not found":T, "noproparse":U, 0).

   /* are there any rules at all? If not, close logfile and stop. */  
   IF NOT CAN-FIND(FIRST tt_rules) THEN DO:
      PUBLISH "Prolint_FinalizeResults".
      RUN DeleteTempdir.
      RUN DecrementProlintPropertySubscribers.
      RETURN STRING(MaxSeverity).
   END.   

   RUN PublishRuleList.

   /* show hourglass cursor */
   RUN set-hourglass(TRUE).
   
   /* load and initialize proparse.dll */
   IF NeedProparse AND HasProparse THEN DO:
      RUN GetProparseHandle.
   END.

   /* start a super procedure, to be used by every rule */
   RUN prolint/core/filterplugins.p PERSISTENT SET hpFilterPlugins (ProfileDirectory).
   RUN prolint/core/lintsuper.p PERSISTENT SET hLintSuper (hParser,hpFilterPlugins).
   RUN SethLintSuper in hpFilterPlugins (hLintSuper). /* ugly circular reference, sorry */
   
   /* Lint files: the file specified in pSourceFile plus the contents of hSourcefileList */
   IF VALID-HANDLE(hSourcefileList) THEN 
      CASE hSourcefileList:TYPE :                                    
         WHEN "TEMP-TABLE":U THEN RUN AddTemptableSourceFiles.
         WHEN "PROCEDURE":U  THEN RUN AddIPProvidedSourceFiles.
         OTHERWISE           DO:   /* other types not supported. Suggestions? */ END.
      END CASE.
      
   IF NOT(pSourceFile="":U OR pSourceFile=?) THEN 
      RUN AddOneSourceItem(pSourceFile).

   RUN CheckMultipleSetups.

   /* load all procedures in directory rules/persist  */
   FOR EACH tt_rules NO-LOCK :
       IF SEARCH("prolint/custom/rules/persist/":U + tt_rules.ruleid + ".p":U)<>? THEN
          RUN VALUE("prolint/custom/rules/persist/":U + tt_rules.ruleid + ".p":U) PERSISTENT SET tt_rules.hpRulePersist(INPUT hLintSuper).
       ELSE
          IF SEARCH("prolint/rules/persist/":U + tt_rules.ruleid + ".p":U)<>? THEN
             RUN VALUE("prolint/rules/persist/":U + tt_rules.ruleid + ".p":U) PERSISTENT SET tt_rules.hpRulePersist(INPUT hLintSuper).
          ELSE 
             IF SEARCH("prolint/contribs/rules/persist/":U + tt_rules.ruleid + ".p":U)<>? THEN
                RUN VALUE("prolint/contribs/rules/persist/":U + tt_rules.ruleid + ".p":U) PERSISTENT SET tt_rules.hpRulePersist(INPUT hLintSuper).
   END.

   /* lint all sourcefiles */
   RUN LintAllSourcefiles.

   /* unload rules/persist */
   FOR EACH tt_rules NO-LOCK :
       IF VALID-HANDLE(tt_rules.hpRulePersist) THEN DO:
          DELETE PROCEDURE tt_rules.hpRulePersist.
          tt_rules.hpRulePersist = ?.
       END.
   END.

   /* tell the logfile/result-window we are done with it */
   PUBLISH "Prolint_FinalizeResults".
   
   /* release resources */
   RUN ClearProparseResources.
   APPLY "CLOSE":U TO hLintSuper.
   hLintSuper = ?.
   APPLY "CLOSE":U TO hpFilterPlugins.
   hpFilterPlugins = ?.
   RUN ReleaseProparseHandle.
   RUN DeleteTempdir.
   RUN DecrementProlintPropertySubscribers.

   /* stop hourglass cursor */
   RUN set-hourglass(FALSE).
                       
   /* return highest severity to the caller */                    
   /* the calling application might need to know that we found something,
      for example: Roundtable might decide NOT to complete this task */   
RETURN STRING(MaxSeverity).  


/* =======================================================================================   
   internal procedures
   ======================================================================================= */

PROCEDURE GetProfileDirectory :
   /* purpose: determine the location of configuration settings.
               this would be "local-prolint/settings/" + pCustomProfile
                          or "prolint/settings/ + pCustomProfile
                     or just "prolint/settings" */

   define variable foundlocally      AS LOGICAL NO-UNDO.
   define variable no-override       AS LOGICAL NO-UNDO.
   run prolint/core/getprofiledir.p (input pCustomProfile, output ProfileDirectory, output foundlocally, output no-override).
   
END PROCEDURE.



PROCEDURE InitializeRules :                    
   /* purpose : make a list of rules to run (populate tt_rules).
                first import tt_rules from rules.d
                then override them with configuration settings from rules.d */
                  
   run prolint/core/findrules.p (pCustomProfile, output table tt_rules).

   /* Clean up the list of rules. */    

      /* do we need Xref file or Listing file? Hope not, it slows down the process */  
      ASSIGN 
          NeedProparse = FALSE
          NeedListing  = FALSE 
          NeedXref     = FALSE
          NeedProclist = FALSE.
          
      loop_needsomething:    
        FOR EACH tt_rules :
             IF tt_rules.useproparse THEN NeedProparse = TRUE.
             IF tt_rules.uselisting  THEN NeedListing  = TRUE.
             IF tt_rules.usexref     THEN NeedXref     = TRUE.
             IF tt_rules.useproclist THEN NeedProclist = TRUE.
             
             IF (NeedProparse AND NeedListing AND NeedXref AND NeedProclist) THEN 
                LEAVE loop_needsomething.
        END.                                        
   
      /* forget rules that depend on proparse if proparse isn't installed */
      IF NeedProparse AND NOT HasProparse THEN
         FOR EACH tt_rules WHERE tt_rules.useproparse=YES :
             DELETE tt_rules.
         END.
       
   /* finally, assign tt_rules.pragma a unique number, starting at 50001 */
   DEFINE VARIABLE vPragma AS INTEGER NO-UNDO INITIAL 50001.
   FOR EACH tt_rules :
       ASSIGN tt_rules.pragma = vPragma
              vPragma         = vPragma + 1.
   END.

END PROCEDURE.
                          

PROCEDURE InitializeOutputhandler :
   /* purpose: start one or more persistent procedures to publish the results to.
               each pp can write a logfile or show results on screen, or whatever it wants to do */
   
   DEFINE VARIABLE LogwinRunning  AS LOGICAL   NO-UNDO INITIAL NO.
   DEFINE VARIABLE handlers       AS CHARACTER NO-UNDO.
   DEFINE VARIABLE handler        AS CHARACTER NO-UNDO.
   DEFINE VARIABLE i              AS INTEGER   NO-UNDO.
   DEFINE VARIABLE hw             AS HANDLE    NO-UNDO.

   /* import list of outputhandlers */
   FILE-INFO:FILE-NAME = "prolint/outputhandlers/choices.d":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).
      REPEAT:
         CREATE tt_output.
         IMPORT tt_output.
         
      END.
      INPUT CLOSE.
   END.
   
   /* forget each outputhandler that isn't supported in this Progress session: */
   /*FOR EACH tt_output :
       IF tt_output.DlcVersion GT {&dlc-version} OR 
          NOT CAN-DO(tt_output.WindowSystem,SessionWindowSystem) THEN 
              DELETE tt_output.
   END.*/
   
   /* get the list of handlers you want to use, as specified in profile settings: */
   handlers = "":U.
   FILE-INFO:FILE-NAME = ProfileDirectory + "/handlers.d":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).
      REPEAT:        
         IMPORT handler.
         /* if handler exists and supported in this Progress session, then add to list */
         /*IF CAN-FIND(tt_output WHERE tt_output.progname=handler) THEN */
            handlers = handlers + ",":U + handler.
         /* Clear the value on each iteration. A blank line seems to leave the
          * previous value at IMPORT, which used to result in duplicate entries.
          */
         handler = "".
      END.
      INPUT CLOSE.                                     
   END.                          

   handlers = TRIM(handlers,',':U).
   IF handlers="" THEN 
      RETURN "no handlers":U.
          
   DO i=1 TO NUM-ENTRIES(handlers) :
      handler = ENTRY(i,handlers).
                         
      CASE handler :
         WHEN ? THEN DO: END.
         WHEN "":U THEN DO: END.
         WHEN "logwin.w":U THEN DO:                           
                                   LogwinRunning = FALSE.
                                   hw = SESSION:FIRST-CHILD.
                                   DO WHILE VALID-HANDLE(hw) :
                                      IF hw:PRIVATE-DATA = "prolint_outputhandler_logwin.w":U THEN
                                         LogwinRunning = TRUE.
                                      hw = hw:NEXT-SIBLING.
                                   END.
                                   IF NOT LogwinRunning THEN
                                      RUN VALUE(DYNAMIC-FUNCTION("ProlintProperty", "outputhandlers.resultwindow")) PERSISTENT.
                                END.
                                
         OTHERWISE              RUN VALUE("prolint/outputhandlers/":U + handler) PERSISTENT.
      END.
   END.
   PUBLISH "Prolint_InitializeResults" (pClearOutput).
   
END PROCEDURE. 


PROCEDURE GetProparseHandle :
   /* purpose: run proparse.p persistent set hParser
               or find an already running instance of proparse.p and use its handle */
                          
   DEFINE VARIABLE hpp        AS HANDLE    NO-UNDO.
   
   hpp = session:FIRST-PROCEDURE.
   DO WHILE VALID-HANDLE(hpp) AND (NOT VALID-HANDLE(hparser)) :
      IF hpp:FILE-NAME MATCHES "~*~/proparse~~.*":U THEN  /* added tildes because Progress confused it for a comment :-)*/
         hparser = hpp.
      ELSE 
         hpp = hpp:NEXT-SIBLING.
   END.
   IF (NOT VALID-HANDLE(hParser)) AND (HasProparse) THEN 
      RUN prolint/proparse-shim/api/proparse.p PERSISTENT SET hparser.
                           
   /* Look for the "jpplus" package, which provides
    * tree attributes beyond what the basic parser does.
    * jpplus/4gl/startup.p is run by proparse.p - we don't do it here.
    */
   IF VALID-HANDLE(hParser) AND SEARCH("jpplus/4gl/startup.p":U) <> ? THEN DO:
     ASSIGN HasJpplus = true.
   END.

   /* enable reading of PROPARSE-DIRECTIVE  for Prolint pragma's */
   IF VALID-HANDLE(hParser) THEN    
      parserConfigSet("show-proparse-directives":U, "true":U).

   /* define database aliases: */
   RUN DefineAliases.
                           
END PROCEDURE.

PROCEDURE DefineAliases :
   /* purpose: */
   DEFINE VARIABLE vAlias  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vDbname AS CHARACTER NO-UNDO.
   DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
   
   /* first delete all existing aliases */
   parserSchemaAliasDelete("").
                                                     
   /* pass all aliases which are defined in the current Progress session */
   REPEAT i=1 TO NUM-ALIASES:
      IF ALIAS(i)>? AND LDBNAME(ALIAS(i))>? THEN
         parserSchemaAliasCreate(ALIAS(i),LDBNAME(ALIAS(i))).
   END.
                                                     
   /* now read list of aliasses from the optional file settings/dbaliases */
   FILE-INFO:FILE-NAME = "prolint/settings/dbaliases.d":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).
      REPEAT:        
         IMPORT vAlias vDbname.
         IF vAlias>? AND vDbname>? THEN 
            parserSchemaAliasCreate(vAlias,vDbname).
      END.
      INPUT CLOSE.                                     
   END.                          
   
END PROCEDURE.

PROCEDURE AddTemptableSourceFiles :
   /* purpose : if parameter hSourcefileList is a temp-table, then assume it is a list of 
                sourcefiles to lint. The temp-table must have a field SourceFile, other
                fields (if any) don't matter */
   
   DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.
   DEFINE VARIABLE hField  AS HANDLE NO-UNDO.
   DEFINE VARIABLE hQuery  AS HANDLE NO-UNDO.
   hBuffer = hSourcefileList:DEFAULT-BUFFER-HANDLE.
   hField  = hBuffer:BUFFER-FIELD("SourceFile":U).
   IF VALID-HANDLE(hField) THEN DO:
      CREATE QUERY hQuery.
      hQuery:SET-BUFFERS(hBuffer).
      hQuery:QUERY-PREPARE(SUBSTITUTE("for each &1 no-lock":U, hSourcefileList:NAME)).
      hQuery:QUERY-OPEN(). 
      hQuery:GET-FIRST().
      DO WHILE hBuffer:AVAILABLE :
         RUN AddOneSourceItem(hField:BUFFER-VALUE).
         hQuery:GET-NEXT().
      END.
      hQuery:QUERY-CLOSE().
      DELETE OBJECT hQuery.
      
   END.  
                              
END PROCEDURE.                       


PROCEDURE AddIPProvidedSourceFiles :
   /* purpose : if parameter hSourcefileList is a procedure, then this procedure should contain 
                internal procedures that provides us with names of sourcefiles - one at a time */
   
   DEFINE VARIABLE v-SourceFile AS CHARACTER NO-UNDO.   
   
   RUN GetFirstLintSource IN hSourcefileList (OUTPUT v-SourceFile).
   DO WHILE v-SourceFile NE ? :
      RUN AddOneSourceItem(v-SourceFile).
      RUN GetNextLintSource IN hSourcefileList (OUTPUT v-SourceFile).
   END.
                              
END PROCEDURE.                       


PROCEDURE AddOneSourceItem :
   /* purpose: SourceItem can be a filename or a directoryname.
               Or even a comma-separated list of filenames and/or directories.
               For a directory lint all files in it */
   DEFINE INPUT PARAMETER p-SourceItem AS CHARACTER NO-UNDO.


   DEFINE VARIABLE basename AS CHARACTER NO-UNDO.
   DEFINE VARIABLE fullpath AS CHARACTER NO-UNDO.
   DEFINE VARIABLE attribs  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE iEntry   AS INTEGER NO-UNDO.
   
   DO iEntry = 1 TO NUM-ENTRIES(p-SourceItem) :
       FILE-INFO:FILE-NAME = ENTRY(iEntry,p-SourceItem).
       IF FILE-INFO:FULL-PATHNAME = ? THEN
          PUBLISH "Prolint_AddResult":U (ENTRY(iEntry,p-SourceItem),ENTRY(iEntry,p-SourceItem),"0":U, "file not found":T, "prolint":U, 9).
       ELSE
          IF FILE-INFO:FILE-TYPE MATCHES "*F*":U THEN
             RUN AddOneSourceFile(FILE-INFO:FULL-PATHNAME).
          ELSE
             IF FILE-INFO:FILE-TYPE MATCHES "*D*":U THEN DO:
                /* scan directory contents. recursive! */
                INPUT FROM OS-DIR (FILE-INFO:FULL-PATHNAME).
                REPEAT:
                    IMPORT basename fullpath attribs.
                    IF attribs MATCHES "*D*":U AND NOT(basename=".":U OR basename="..":U) THEN
                       RUN AddOneSourceItem(fullpath).
                    IF attribs MATCHES "*F*":U THEN
                       IF CAN-DO(filemasks, basename) THEN
                          RUN AddOneSourceFile(fullpath).
                END.
                INPUT CLOSE.
             END.
   END.
END PROCEDURE.


PROCEDURE AddOneSourceFile :
   /* purpose : add name of sourcefile to tt_files.
      That way we can assure the names are unique,
      we can count the files and show a percentage done,
      and we won't have to run LintOneSourceFile from within
      the recursive directory-scan (high stack usage) */
   DEFINE INPUT PARAMETER p-SourceFile AS CHARACTER NO-UNDO.

   p-SourceFile = DYNAMIC-FUNCTION("RelativeFilename":U IN hLintSuper, p-SourceFile).
   FIND tt_files WHERE tt_files.sourcefile = p-SourceFile NO-ERROR.
   IF NOT AVAILABLE tt_files THEN DO:
      CREATE tt_files.
      ASSIGN tt_files.sourcefile = p-Sourcefile.
   END.

END PROCEDURE.


PROCEDURE LintAllSourcefiles :
   /* purpose: actually lint each tt_files.sourcefile.
               also try to give an idea how long it's gonna take. */

   DEFINE VARIABLE maxFiles      AS INTEGER NO-UNDO.
   DEFINE VARIABLE numFiles      AS INTEGER NO-UNDO.
   DEFINE VARIABLE done          AS CHARACTER NO-UNDO.

   FOR EACH tt_files NO-LOCK :
       maxFiles = maxFiles + 1.
   END.

   IF maxFiles>1 THEN DO:
     done = "  0%":U.
     PUBLISH "Prolint_Status_Progress" ("done").
   END.

   FOR EACH tt_files NO-LOCK :
       RUN LintOneSourceFile (tt_files.sourcefile).
       numFiles = numFiles + 1.
       done = STRING((100 * numFiles) / maxFiles, ">>9":U) + "%":U.
       PUBLISH "Prolint_Status_Progress" ("done").
   END.

END PROCEDURE.

PROCEDURE LintOneSourceFile :                  
   /* purpose : lint one sourcefile. 
                Just PreAnalyze it (=compile + parserParse) and run value(each rule)  */
                
   DEFINE INPUT PARAMETER p-SourceFile AS CHARACTER NO-UNDO.
   
   DEFINE VARIABLE ErrorMessage AS CHAR NO-UNDO.

   PUBLISH "Prolint_Status_FileStart" (p-SourceFile).

   FILE-INFO:FILE-NAME = p-SourceFile.
   IF FILE-INFO:FULL-PATHNAME = ? THEN 
      PUBLISH "Prolint_AddResult":U (p-SourceFile, p-SourceFile,"0":U, "file not found":T, "prolint":U, 9).
   ELSE DO:
      p-SourceFile = FILE-INFO:FULL-PATHNAME.

      /* PreAnalyze creates compile listing, XREF file, token tree in proparse.dll, ... */
      PUBLISH "Prolint_Status_StopTimer".
      RUN PreAnalyze(p-SourceFile, OUTPUT ErrorMessage).
      PUBLISH "Prolint_Status_StartTimer".
      IF ErrorMessage="":U THEN DO:

         FOR EACH tt_rules NO-LOCK :
             PUBLISH "Prolint_Status_Action" (SUBSTITUTE('testing rule: &1':T,tt_rules.RuleID)).
                RUN VALUE(tt_rules.sourcefile)                      (xreffile,
                                                                     listingfile,
                                                                     hLintSuper,
                                                                     hparser, 
                                                                     topnode, 
                                                                     p-SourceFile, 
                                                                     tt_rules.severity,
                                                                     tt_rules.ruleID,
                                                                     tt_rules.pragma,
                                                                     tt_rules.ignoreUIB,
                                                                     tt_rules.hpRulePersist).
        END. /* each tt_rules */
        IF NeedProparse AND HasProparse THEN 
           parserReleaseHandle(topnode).
      END. /* ErrorMessage="" */
      RUN ProcedureListClear IN hLintSuper.
   END. /* file found */

   PUBLISH "Prolint_Status_FileEnd".
   
END PROCEDURE.

                       
                    
PROCEDURE PreAnalyze :                                     
   /* purpose : build information from a sourcefile, like an XREF file, 
                a LISTING file, a parsed token tree  */
                
   DEFINE INPUT  PARAMETER p-SourceFile   AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER p-ErrorMessage AS CHARACTER NO-UNDO INITIAL "":U.
   
   DEFINE VARIABLE i1 AS INTEGER NO-UNDO.
   DEFINE VARIABLE compilerLoopNum AS INTEGER NO-UNDO.
   DEFINE VARIABLE cErrorMsg AS CHARACTER NO-UNDO INITIAL "".

   ASSIGN 
      listingfile = IF NeedListing THEN tempdir + "prolint.lst":U ELSE ?
      xreffile    = IF NeedXref    THEN tempdir + "prolint.xrf":U ELSE ?.
      
   /* compile if you need an XREF file and/or listing file, but also to validate the code */
   /* please do not produce new .r-code: 
        - default location would be wrong if save into ... is required
        - special parameters might be required, like translation params */
   PUBLISH "Prolint_Status_Action" ("compiling...":U).

   compiler-loop:
   DO compilerLoopNum = 1 TO 2:

      COMPILE VALUE(p-SourceFile) 
              STREAM-IO = needCompilerStreamIO
              /* value of ? disables xref or listing */
              LISTING    VALUE(IF NeedListing THEN listingfile ELSE ?)
                         PAGE-SIZE 127 PAGE-WIDTH 255
              XREF       VALUE(IF NeedXref THEN xreffile ELSE ?)
              NO-ERROR.                   

      ASSIGN p-ErrorMessage = "":U.
      IF COMPILER:ERROR THEN error-loop: DO i1=1 TO ERROR-STATUS:NUM-MESSAGES:
         /* ignore error 6430 and 468 "r-code exists but SAVE was not specified"
            and error 4345 : &MESSAGE output */
         IF (ERROR-STATUS:GET-NUMBER(i1) EQ 6430) OR (ERROR-STATUS:GET-NUMBER(i1) EQ 4345) OR (ERROR-STATUS:GET-NUMBER(i1) EQ 468)
            THEN NEXT error-loop.

         /* unexpected compiler behaviour with class files in OpenEdge 10.1A, just ignore for now */
         IF ERROR-STATUS:GET-NUMBER(i1) EQ 12985 OR ERROR-STATUS:GET-NUMBER(i1) EQ 1700 THEN DO:
            i1 = i1 + 1.
            NEXT error-loop.
         END.

         p-ErrorMessage = "compile failed":T.
         /* Flip the STREAM-IO flag. On the first failed compile, it
            gets flipped. On the second failed compile, we flip it again,
            so that it's back to its value before we tried this compile unit. */
         ASSIGN needCompilerStreamIO = NOT needCompilerStreamIO.
         /* collect compiler messages for ED for Windows.
            can't publish them yet, because that would
            change the contents of ERROR-STATUS:...
            We might fail two attempts at compiling. In that case, we
            want to show the first set of compiler error messages, because
            the second compile might fail just because the STREAM-IO flag is
            set wrong, and that wouldn't be a helpful error message. */
         IF compilerLoopNum EQ 1 THEN DO:
            ASSIGN cErrorMsg = cErrorMsg + ERROR-STATUS:GET-MESSAGE(i1) + "~n":U.
            create tt_Error.
            assign tt_Error.ErrorMessage = error-status:get-message(i1).
            &if {&dlc-version} < 10 &then
            assign tt_Error.LineNumber   = compiler:error-row no-error.
            &else
            &if PROVERSION >= "10.1C" &then
            assign tt_Error.LineNumber   = compiler:get-row(i1) no-error.
            &else
            assign tt_Error.LineNumber   = compiler:get-error-row(i1) no-error.
            &endif
            &endif
            IF tt_Error.LineNumber=? THEN tt_Error.LineNumber=0.
         END.
      END.  /* error-loop */

      IF p-ErrorMessage EQ "":U THEN LEAVE compiler-loop.

      IF compilerLoopNum > 1 THEN DO:
         PUBLISH "WriteToEd4Windows":U (cErrorMsg). /* just in case ED is listening */
         p-SourceFile = DYNAMIC-FUNCTION("RelativeFilename":U IN hLintSuper, p-SourceFile).
         PUBLISH "Prolint_AddResult":U (p-SourceFile, p-SourceFile,"0":U, p-ErrorMessage, "compiler":U, 9).
         for each tt_Error:
           publish "Prolint_AddResult":U (p-SourceFile, p-SourceFile,string(tt_Error.LineNumber), tt_Error.ErrorMessage, "compiler":U, 9).
           delete tt_Error.
         end.
      END.

   END.  /* compiler-loop */

   /* parse sourcefile in proparse.dll */          
   IF NeedProparse AND HasProparse AND p-ErrorMessage="":U THEN DO:
      PUBLISH "Prolint_Status_Action" ('parsing...':T).

      IF parserParse(p-Sourcefile) = FALSE THEN
         p-ErrorMessage = parserErrorGetText().
         
      IF p-ErrorMessage<>"":U THEN DO:
         p-SourceFile = DYNAMIC-FUNCTION("RelativeFilename":U IN hLintSuper, p-SourceFile).
         PUBLISH "Prolint_AddResult":U (p-SourceFile, p-SourceFile,"0":U, p-ErrorMessage, "proparse":U, 0).
         /* These kinds of warnings should be reported to joanju.com */
      END.      
      ELSE DO:
        ASSIGN topnode = parserGetHandle(). /* note: must be assigned after parserParse() */
        parserNodeTop(topnode).             /* this gets us the "Program_root" node */
        RUN BuildSuperclassTree.
        RUN FindProparseDirectives.
        IF NeedProclist THEN
           RUN BuildProcedureList.

        /* Run the tree parser for added node attributes */
        IF HasJpplus THEN DO:
          RUN jpplus/4gl/utilities/runTreeParser02.p (hParser, topnode, "":U).
          IF RETURN-VALUE <> "":U THEN DO:
            ASSIGN p-ErrorMessage = RETURN-VALUE.
            p-SourceFile = DYNAMIC-FUNCTION("RelativeFilename":U IN hLintSuper, p-SourceFile).
            PUBLISH "Prolint_AddResult":U (p-SourceFile, p-SourceFile,"0":U, p-ErrorMessage, "proparse":U, 0).
          END.
        END.

      END.
   END.

END PROCEDURE.

PROCEDURE BuildSuperclassTree :
    DEFINE VARIABLE superclass AS CHARACTER NO-UNDO.
    DEFINE VARIABLE supernode AS INTEGER NO-UNDO.
    RUN GetSuperClass IN hLintSuper (topnode, OUTPUT superclass, OUTPUT supernode).
    IF supernode<>0 THEN
       RUN ParseSuperclasses IN hLintSuper("", supernode).
END PROCEDURE.

FUNCTION ParseProparseDirectives RETURNS CHARACTER (ipNode AS INTEGER, ipPragmaText AS CHARACTER)  :
   /* purpose : when a proparse directive is found, return a list of rules that it is supposed
                to suppress warnings for.
                ipPragmaText has format "prolint-nowarn(rule1[,rule2[,rule3...]])"   */

   DEFINE VARIABLE i                AS INTEGER NO-UNDO.
   DEFINE VARIABLE idx              AS INTEGER NO-UNDO.
   DEFINE VARIABLE leftparen        AS INTEGER NO-UNDO.
   DEFINE VARIABLE rightparen       AS INTEGER NO-UNDO.
   DEFINE VARIABLE ruleids          AS CHARACTER NO-UNDO.
   DEFINE VARIABLE returnvalue      AS CHARACTER NO-UNDO.
   DEFINE VARIABLE nextstatement    AS INTEGER   NO-UNDO.

   idx = INDEX(ipPragmaText, "prolint-nowarn":U).
   IF idx > 0 THEN DO:                            
      ASSIGN 
        leftparen  = INDEX(ipPragmaText, '(':U, idx)
        rightparen = INDEX(ipPragmaText, ')':U, leftparen)
        ruleids    = REPLACE(SUBSTRING(ipPragmaText, leftparen + 1, rightparen - 1 - leftparen)," ":U,"").
      IF ruleids <> "" THEN 
         DO i=1 TO NUM-ENTRIES(ruleids) :
            FIND tt_rules WHERE tt_rules.ruleID = TRIM(ENTRY(i,ruleids)) NO-ERROR.
            IF AVAILABLE tt_rules THEN
               IF tt_rules.useProparse THEN
                  returnvalue = returnvalue + ",":U + STRING(tt_rules.pragma).
               ELSE DO:
                  nextstatement = parserGetHandle().
                  IF parserNodeNextSibling(ipNode,nextstatement)="BLOCK_LABEL":U THEN
                     RUN AddNowarnFilter IN hpFilterPlugins (tt_rules.RuleId,
                                                        parserGetNodeFileName(ipNode),
                                                        parserGetNodeLine(ipNode) + 2).
                  ELSE
                     RUN AddNowarnFilter IN hpFilterPlugins (tt_rules.RuleId,
                                                        parserGetNodeFileName(ipNode),
                                                        parserGetNodeLine(ipNode) + 1).
                  parserReleaseHandle(nextstatement).
               END.

         END.
   END.        
   
   RETURN TRIM(ReturnValue,',':U).
   
END FUNCTION.


PROCEDURE FindProparseDirectives :
  /* purpose : proparse directives are used for suppressing Prolint warnings.
               find every directive, mark the statement following the directive with attributes.
               later, while running rules, the marked statements will be skipped */

  DEFINE VARIABLE numResults     AS INTEGER NO-UNDO.
  DEFINE VARIABLE i              AS INTEGER NO-UNDO.                
  DEFINE VARIABLE pragmanode     AS INTEGER NO-UNDO.                
  DEFINE VARIABLE pragma         AS CHAR    NO-UNDO.  
  DEFINE VARIABLE nextstatement  AS INTEGER NO-UNDO.

  pragmanode    = parserGetHandle().
  nextstatement = parserGetHandle().
  grandchild    = parserGetHandle().

  numResults = parserQueryCreate(topnode, "pragmas":U, "PROPARSEDIRECTIVE":U).
  DO i=1 TO numResults :
     IF parserQueryGetResult("pragmas":U, i, pragmanode) THEN DO:
        pragma = ParseProparseDirectives(pragmanode,parserAttrGet(pragmanode, "proparsedirective":U)).
        IF pragma<>"" THEN
           IF parserNodeNextSibling(pragmanode, nextstatement)<>"" THEN
              RUN DecorateTree (nextstatement, pragma).               
     END.
  END.

  parserQueryClear("pragmas":U).
  parserReleaseHandle(pragmanode).
  parserReleaseHandle(nextstatement).
  parserReleaseHandle(grandchild).

END PROCEDURE.                             


PROCEDURE DecorateTree :
  /* purpose : DecorateTree marks the statement following a proparse-directive.
               all nodes in the statement have to be marked, because a query might 
               not return the first node in the statement.
               If the statement is a block (like DO: or FOR EACH:) make sure to 
               not mark the nested statements, eg stop on LEXCOLON.
               But if the statement is a blocklabel, then don't stop at the first
               LEXCOLON because you would only have decorated the label: decorate
               the statement immediately following the blocklabel too. */
  DEFINE INPUT PARAMETER theNode AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pragma  AS CHAR    NO-UNDO.

  DEFINE VARIABLE child          AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i              AS INTEGER NO-UNDO.

  DO i=1 TO NUM-ENTRIES(pragma) :
     parserAttrSet(thenode, INTEGER(ENTRY(i,pragma)) ,1).
  END.

  child = parserGetHandle().

  /* For BLOCK_LABEL, we want to decorate down past it and its LEXCOLON. */
  IF parserGetNodeType(theNode) = "BLOCK_LABEL":U THEN DO:
    ASSIGN nodetype = parserNodeFirstChild(theNode, child). /* =LEXCOLON */
    DO i=1 TO NUM-ENTRIES(pragma) :
      parserAttrSet(child, INTEGER(ENTRY(i,pragma)) ,1).
    END.
    /* The (DO|FOR|REPEAT) is sibling to the block label's LEXCOLON */
    nodetype = parserNodeNextSibling(child,child).
  END.
  ELSE
    ASSIGN nodetype = parserNodeFirstChild(theNode,child).

  DO WHILE NOT (nodetype="" OR nodetype="LEXCOLON":U) :
        IF parserNodeFirstChild(child, grandchild)<>"" THEN
           RUN DecorateTree (child, pragma).              
        ELSE       
           DO i=1 TO NUM-ENTRIES(pragma) :
              parserAttrSet(child, INTEGER(ENTRY(i,pragma)) ,1).
           END.  
       nodetype = parserNodeNextSibling(child,child).
  END.                       
  parserReleaseHandle(child).
  
END PROCEDURE.


PROCEDURE BuildProcedureList :
  /* purpose : populate a temp-table tt_procedure (in lintsuper.p) with internal procedures.
               (and user-defined-functions and event-handlers).
               For each procedure find the first and last linenumber. This procedure list is 
               used later in some rules to determine in which procedure a particular node is. */

  DEFINE VARIABLE nextnode      AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE child         AS INTEGER   NO-UNDO.
  DEFINE VARIABLE childtype     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE procname      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE proctype      AS CHARACTER NO-UNDO.

  RUN ProcedureListClear IN hLintSuper.
            
  ASSIGN                      
    child    = parserGetHandle()
    nextnode = parserGetHandle().                
    
  nodetype = parserNodeFirstChild(topnode, nextnode).
  DO WHILE nodetype="USING" or nodetype="ANNOTATION" :
      nodetype = parserNodeNextSibling(nextnode,nextnode).
  END.
  IF nodetype<>"CLASS":U THEN DO:
     RUN BuildProcedureListSub ("PROCEDURE":U). 
     RUN BuildProcedureListSub ("FUNCTION":U). 
     RUN BuildProcedureListSub_On. 
  END.
  ELSE DO:
      /* find the first childnode (probably TYPE_NAME) */
      nodetype = parserNodeFirstChild(nextnode,nextnode).
      /* skip a few siblings until you find the "Code_block" */
      DO WHILE NOT (nodetype="Code_block" OR nodetype=""):
         ASSIGN nodetype = parserNodeNextSibling(nextnode,nextnode).
      END.
      /* dive into the Code_block, start searching for methods */
      IF nodetype<>"" THEN
         nodetype = parserNodeFirstChild(nextnode,nextnode).
      DO WHILE nodetype<>"" :

        IF LOOKUP(nodetype,"METHOD,CONSTRUCTOR,DESTRUCTOR":U)>0 THEN DO:
           ASSIGN
             childtype = parserNodeFirstChild(nextnode,child)
             proctype  = parserGetNodeText(nextnode)
             procname  = "".
       
           DO WHILE LOOKUP(childtype,""",PERIOD,LEXCOLON":U)=0:
              IF parserGetNodeType(child) = "ID":U THEN
                 procname = parserGetNodeText(child).
              ASSIGN childtype = parserNodeNextSibling(child,child).
           END.
           RUN ProcedureListAdd IN hLintSuper (proctype, procname, false, nextnode).
        END.
        ASSIGN nodetype = parserNodeNextSibling(nextnode,nextnode).
      END.

      /* Class properties can have GET and SET logic that behaves like a method.
         Find them: */
      RUN BuildAccessorList ( "Property_setter":U).
      RUN BuildAccessorList ( "Property_getter":U).
  END.

  parserReleaseHandle(nextnode).
  parserReleaseHandle(child).
  
END PROCEDURE.


PROCEDURE BuildProcedureListSub :
  DEFINE INPUT PARAMETER proctype      AS CHARACTER NO-UNDO.

  DEFINE VARIABLE procnode      AS INTEGER NO-UNDO.
  DEFINE VARIABLE child         AS INTEGER   NO-UNDO.
  DEFINE VARIABLE childtype     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE api           AS LOGICAL   NO-UNDO INITIAL FALSE.
  DEFINE VARIABLE procname      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE numresults    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE i             AS INTEGER   NO-UNDO.

  ASSIGN                      
    child    = parserGetHandle()
    procnode = parserGetHandle().             
    
    numResults = parserQueryCreate(topnode, "BuildProcedureListSub":U, proctype).
    DO i=1 TO numResults :
       parserQueryGetResult("BuildProcedureListSub":U, i, procnode).
       IF parserAttrGet(procnode, "statehead":U) <> "" THEN DO: 
       
       ASSIGN
         api       = FALSE
         childtype = parserNodeFirstChild(procnode,child)
         procname  = "".     
       
       DO WHILE (NOT api) AND (LOOKUP(childtype,""",PERIOD,LEXCOLON":U)=0): 
          CASE parserGetNodeType(child) :
            WHEN "IN":U       THEN api=TRUE.
            WHEN "SUPER":U    THEN api=TRUE.
            WHEN "EXTERNAL":U THEN api=TRUE.
            WHEN "FORWARDS":U THEN api=TRUE. /* according to PSC grammar definition */
            WHEN "FORWARD":U  THEN api=TRUE. /* according to online-help on FUNCTION statement */
            WHEN "ID":U       THEN IF procname="" THEN /* ignore UDF parameters */
                                      procname = parserGetNodeText(child).
          END CASE.
          ASSIGN childtype = parserNodeNextSibling(child,child).
       END.      
       RUN ProcedureListAdd IN hLintSuper (proctype, procname, api, procnode).
       END.
    END.
    parserQueryClear ("BuildProcedureListSub":U).
    parserReleaseHandle(procnode).
    parserReleaseHandle(child).
  
END PROCEDURE.

                 
PROCEDURE BuildProcedureListSub_On :
  
  DEFINE VARIABLE proctype      AS CHARACTER NO-UNDO INITIAL "ON":U.
  DEFINE VARIABLE procnode      AS INTEGER NO-UNDO.
  DEFINE VARIABLE child         AS INTEGER   NO-UNDO.
  DEFINE VARIABLE childtype     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE procname      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE numresults    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE i             AS INTEGER   NO-UNDO.

  ASSIGN                      
    child    = parserGetHandle()
    procnode = parserGetHandle().             
    
    numResults = parserQueryCreate(topnode, "BuildProcedureListSub":U, proctype).
    DO i=1 TO numResults :
       parserQueryGetResult("BuildProcedureListSub":U, i, procnode).
       IF parserAttrGet(procnode, "statehead":U) <> "" AND parserNodeParent(procnode, child) = "Program_root":U THEN DO: 
           ASSIGN
             childtype = parserNodeFirstChild(procnode,child)
             procname  = "".     
           
           /* an event handler doesn't really have a name. Use the name of the event instead */  
           procname=parserGetNodeText(child).
           IF procname="" THEN
             IF parserNodeFirstChild(child,child)<>"" THEN 
                procname=parserGetNodeText(child).
           RUN ProcedureListAdd IN hLintSuper (proctype, procname, false, procnode).
       END.
    END.
    parserQueryClear ("BuildProcedureListSub":U).
    parserReleaseHandle(procnode).
    parserReleaseHandle(child).
  
END PROCEDURE.


PROCEDURE BuildAccessorList :
  DEFINE INPUT PARAMETER accessortype AS CHARACTER NO-UNDO.

  DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
  DEFINE VARIABLE i AS INTEGER NO-UNDO.
  DEFINE VARIABLE procname      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE subnode      AS INTEGER NO-UNDO.

  subnode = parserGetHandle().
  numResults = parserQueryCreate(topnode, "Property_accessor":U, accessortype).
  i = 1.
  DO WHILE (i LE numResults):
     parserQueryGetResult("Property_accessor":U, i, subnode).
     /* does the accessor have a Code_block? */
     IF parserQueryCreate(topnode, "Code_block":U, "Code_block":U) > 0 THEN DO:
        /* todo: assign procname */
        RUN ProcedureListAdd IN hLintSuper (accessortype, procname, false, subnode).
     END.
     parserQueryClear ("Code_block":U).
     i = i + 1.
  END.
  parserQueryClear ("Property_accessor":U).
  parserReleaseHandle(subnode).

END PROCEDURE.

PROCEDURE ClearProparseResources :  
/* purpose: proparse.dll frees all resources before it starts a new parse.
            so, by having it parse an empty sourcefile, we effectively delete all 
            open queries, release all handles, destroy the tree, and above all: close all open files.
            If you don't start a dummy parse, you may find that some includefiles are locked
            and can't be modified with a text editor. */
                              
    IF VALID-HANDLE(hParser) THEN DO:
       OUTPUT TO VALUE (tempdir + "prolint_empty.p":U).
       PUT UNFORMATTED "~n~n":U.
       OUTPUT CLOSE.          
       parserParse(tempdir + "prolint_empty.p":U).
    END.    
    
END PROCEDURE.                                
                          

PROCEDURE ReleaseProparseHandle:
    /* purpose: release proparse.p.
                keep proparse.dll in memory, to save time on next initialisation */

    IF VALID-HANDLE(hParser) THEN DO:
      APPLY "CLOSE":U TO hParser.
      hParser=?.
    END.
   
END PROCEDURE.


PROCEDURE Prolint_AddResult :              
   /* purpose: not run, but published from a rule when it finds a violation.
               here we don't care what it found, we only need to know the severity. */
   {&_proparse_ prolint-nowarn(varusage)}            
   DEFINE INPUT PARAMETER pCompilationUnit  AS CHAR    NO-UNDO.  /* the sourcefile we're parsing          */
   {&_proparse_ prolint-nowarn(varusage)}            
   DEFINE INPUT PARAMETER pSource           AS CHAR    NO-UNDO.  /* may be an includefile                 */
   {&_proparse_ prolint-nowarn(varusage)}            
   DEFINE INPUT PARAMETER pLineNumber       AS INTEGER NO-UNDO.  /* line number in pSourceFile            */
   {&_proparse_ prolint-nowarn(varusage)}            
   DEFINE INPUT PARAMETER pDescription      AS CHAR    NO-UNDO.  /* human-readable hint                   */
   {&_proparse_ prolint-nowarn(varusage)}            
   DEFINE INPUT PARAMETER pRuleID           AS CHAR    NO-UNDO.  /* defines rule-program and maps to help */
   DEFINE INPUT PARAMETER pSeverity         AS INTEGER NO-UNDO.  /* importance of this rule, scale 0-9    */

   IF pSeverity > MaxSeverity THEN 
      ASSIGN MaxSeverity = pSeverity.
      
END PROCEDURE.

   
PROCEDURE set-hourglass :
/*------------------------------------------------------------------------------
       Purpose:     Change the cursor to reflect the process state
       Parameters:  Logical - Yes/True = Wait
       Notes:
------------------------------------------------------------------------------*/
   define input parameter MUST-WAIT as LOGICAL no-undo.
   /* Set the cursor */
   if MUST-WAIT then SESSION:set-wait-state("GENERAL":U). /* Hourglass */
                else SESSION:set-wait-state("").        /* Arrow */
END PROCEDURE.


PROCEDURE CheckMultipleSetups :
/* -----------------------------------------------------------------------------
   Purpose : test if prolint/prolint.p is installed in more than one directory
   -------------------------------------------------------------------------- */

   DEFINE VARIABLE AllProlintSetups AS CHARACTER NO-UNDO.
   DEFINE VARIABLE ThisSetup        AS CHARACTER NO-UNDO.
   DEFINE VARIABLE NewProlintSetups AS CHARACTER NO-UNDO.
   DEFINE VARIABLE fname            AS CHARACTER NO-UNDO.
   DEFINE VARIABLE i                AS INTEGER   NO-UNDO.

   IF OPSYS = "WIN32":U THEN DO:
       FILE-INFO:FILE-NAME = "prolint/core/prolint.p".
       ThisSetup = FILE-INFO:FULL-PATHNAME.
       IF ThisSetup = ? THEN RETURN.

       /* use HKCU instead HKLM, because HKLM may be write-protected for some users */
       LOAD "SOFTWARE" BASE-KEY "HKEY_CURRENT_USER".
       USE "SOFTWARE".
       GET-KEY-VALUE SECTION "prolint"
           KEY "found_in" VALUE AllProlintSetups.
       IF AllProlintSetups <> ThisSetup THEN DO:

           DO i=1 TO NUM-ENTRIES(AllProlintSetups) :
              fname = ENTRY(i, AllProlintSetups).
              IF SEARCH(fname)<>? THEN
                 NewProlintSetups = NewProlintSetups + ",":U + fname.
           END.

           IF LOOKUP(ThisSetup, NewProlintSetups)=0 THEN
              NewProlintSetups = NewProlintSetups + ",":U + ThisSetup.

           NewProlintSetups = TRIM(NewProlintSetups, ",":U).
           IF AllProlintSetups <> NewProlintSetups THEN
              PUT-KEY-VALUE SECTION "prolint"
                  KEY "found_in" VALUE NewProlintSetups NO-ERROR.
       END.

       UNLOAD "SOFTWARE".

       IF NUM-ENTRIES(NewProlintSetups) > 1 THEN
         PUBLISH "Prolint_AddResult":U ("",
                                        "",
                                        "0":U,
                                        "Prolint is installed more than once",
                                        "prolint":U, 0).
   END.

END PROCEDURE.


PROCEDURE MakeTempdir :
/* purpose : create a tempdir, unique for this session.
             this is important if several sessions run on the same environment */

   tempdir =  SESSION:TEMP-DIRECTORY.
   /* not every os version returns a path with an ending slash. To make sure, add a slash now */
   IF (SUBSTRING(tempdir, LENGTH(tempdir,"CHARACTER":U)) <> "~\":U) AND (SUBSTRING(tempdir, LENGTH(tempdir,"CHARACTER":U)) <> "/":U) THEN
      tempdir = tempdir + "/":U.

   DEFINE VARIABLE nr AS INTEGER NO-UNDO.
   nr = RANDOM(1,500).

   FILE-INFO:FILE-NAME = tempdir + "tmpprolint":U + STRING(nr, "9999":U).
   DO WHILE FILE-INFO:FULL-PATHNAME <> ? :
      nr = nr + 1.
      FILE-INFO:FILE-NAME = tempdir + "tmpprolint":U + STRING(nr, "9999":U).
   END.

   tempdir = tempdir + "tmpprolint":U + STRING(nr, "9999":U).
   OS-CREATE-DIR VALUE(tempdir).

   ASSIGN
     tempdir            = tempdir + "/":U.

END PROCEDURE.


PROCEDURE DeleteTempdir :
/* purpose : delete the tempdir and everything in it */

   IF NOT (tempdir=? OR tempdir="" OR tempdir=".":U) THEN
      OS-DELETE VALUE(tempdir) RECURSIVE.

END PROCEDURE.


PROCEDURE PublishRuleList :
/* purpose : outputhandler 'prolintdb' needs to know which rules are selected */
   DEFINE VARIABLE cList AS CHARACTER NO-UNDO.
   FOR EACH tt_rules :
       cList = cList + ",":U + tt_rules.ruleId.
   END.
   cList = TRIM(cList,",":U).
   PUBLISH "Prolint_List_Rules" (cList).
END PROCEDURE.
