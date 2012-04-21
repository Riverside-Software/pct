/* ------------------------------------------------------------------
    file    : prolint/core/lintsuper.p
    purpose : super procedure for every rule
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra

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
   ------------------------------------------------------------------ */

{prolint/core/dlc-version.i}         

DEFINE INPUT PARAMETER hparser AS HANDLE  NO-UNDO.
DEFINE INPUT PARAMETER hpFilterPlugins AS HANDLE NO-UNDO.
{prolint/proparse-shim/api/proparse.i hparser}
                                    
DEFINE VARIABLE IgnoreAB         AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE ActivePragma     AS INTEGER NO-UNDO.
DEFINE VARIABLE ActiveSeverity   AS INTEGER NO-UNDO.
DEFINE VARIABLE AbortSearch      AS LOGICAL NO-UNDO.

  /* tt_procedure lists every procedure and function in a compilation unit */
  {prolint/core/ttprocedure.i}
  
  /* tt_cacheRelativeName makes function RelativeFilename slightly faster */                          
  DEFINE TEMP-TABLE tt_cacheRelativeName NO-UNDO 
     FIELD longname     AS CHAR
     FIELD relativename AS CHAR
     INDEX idx_1 AS PRIMARY UNIQUE longname.
  DEFINE VARIABLE SearchPath AS CHARACTER NO-UNDO.

  /* list class inheritance (recursive) */
  DEFINE TEMP-TABLE tt_superclass NO-UNDO
     FIELD classname AS CHARACTER
     FIELD superclass AS CHARACTER
     INDEX idx_1 AS PRIMARY UNIQUE classname
     INDEX idx_2 superclass.

  /* list public/protected members for each class: */
  DEFINE TEMP-TABLE tt_classinterface NO-UNDO
     FIELD classname AS CHARACTER
     FIELD attribname AS CHARACTER
     FIELD attribtype AS CHARACTER
     FIELD accessmode AS CHARACTER
     INDEX idx_1 AS PRIMARY UNIQUE classname attribname.

ON "CLOSE":U OF THIS-PROCEDURE DO:
  DELETE PROCEDURE THIS-PROCEDURE.
END.  


/* --------------------------------------------------------------------------------
   dealing with tt_superclass and tt_classinterface
   -------------------------------------------------------------------------------- */

FUNCTION IsInheritedAttribute RETURNS LOGICAL (INPUT classname AS CHARACTER, INPUT varname AS CHARACTER) :
   /* suppose we have a class "cube" which inherits from "body", and the source cube.cls
      references "weight". We want to know if "weight" is defined as a variable/attribute in
      one of the superclasses of "cube". */
   DEFINE BUFFER tt_superclass FOR tt_superclass.
   DEFINE BUFFER tt_classinterface FOR tt_classinterface.
   IF CAN-FIND(tt_classinterface WHERE tt_classinterface.classname = classname
                                   AND tt_classinterface.attribname = varname) THEN
      RETURN TRUE.
   ELSE DO:
      FIND tt_superclass WHERE tt_superclass.classname = classname NO-ERROR.
      IF NOT AVAILABLE tt_superclass THEN
         RETURN FALSE.
      ELSE
         RETURN IsInheritedAttribute(tt_superclass.superclass, varname).
   END.
END FUNCTION.


PROCEDURE ParseSuperclasses :
    /* hClass is a handle to the CLASS node of a superclass. We are gonna locate
       the public/protected variables in that superclass. */
    DEFINE INPUT PARAMETER childclassname AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER hClass AS INTEGER NO-UNDO.

    DEFINE VARIABLE nextSuperclass AS INTEGER NO-UNDO.
    DEFINE VARIABLE thisclassname  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE child AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
    DEFINE VARIABLE statehead AS INTEGER NO-UNDO.
    DEFINE VARIABLE grandchild AS INTEGER NO-UNDO.
    DEFINE VARIABLE varname AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ispublic AS LOGICAL NO-UNDO.
    DEFINE VARIABLE isprotected AS LOGICAL NO-UNDO.

    child = parserGetHandle().
    grandchild = parserGetHandle().

    nodetype = parserGetNodeType(hClass).
    DO WHILE nodetype="USING" :
        nodetype=parserNodeNextSibling(hClass, hClass).
    END.
    nodetype = parserNodeFirstChild(hClass, child).
    DO WHILE NOT (nodetype="") :
       CASE nodetype :
          WHEN "TYPE_NAME":U THEN thisclassname = parserGetNodeText(child).
          WHEN "Code_block":U THEN
              IF NOT CAN-FIND(FIRST tt_superclass WHERE tt_superclass.superclass=thisclassname) THEN
              IF NOT CAN-FIND(FIRST tt_classinterface WHERE tt_classinterface.classname=thisclassname) THEN
              DO:
                 statehead = parserGetHandle().
                 nodetype = parserNodeFirstChild(child, statehead).
                 DO WHILE nodetype<>"" :
                    IF nodetype="DEFINE":U THEN
                       IF parserAttrGet(statehead,"state2":U)="variable":U OR parserAttrGet(statehead,"state2":U)="property":U THEN DO:
                          /* dive in to get the variable name and to see if it is private/public/protected */
                          ispublic = FALSE.
                          isprotected = FALSE.
                          varname = "".
                          nodetype = parserNodeFirstChild(statehead, grandchild).
                          DO WHILE nodetype<>"" :
                             CASE nodetype:
                                WHEN "public" THEN ispublic = TRUE.
                                WHEN "protected" THEN isprotected = TRUE.
                                WHEN "id" THEN IF varname="" THEN DO:
                                                  varname = parserGetNodeText(grandchild).
                                                  IF ispublic OR isprotected THEN DO:
                                                     CREATE tt_classinterface.
                                                     ASSIGN
                                                            tt_classinterface.attribtype = parserAttrGet(statehead,"state2":U)
                                                            tt_classinterface.classname = thisclassname
                                                            tt_classinterface.attribname = varname
                                                            tt_classinterface.accessmode = IF ispublic THEN "public":U ELSE IF isprotected THEN "protected":U ELSE "private":U.
                                                  END.
                                               END.
                             END.
                             nodetype = parserNodeNextSibling(grandchild, grandchild).
                          END.
                       END.
                    nodetype = parserNodeNextSibling(statehead, statehead).
                 END.
                 parserReleaseHandle(statehead).
              END.
       END CASE.
       nodetype = parserNodeNextSibling(child, child).
    END.
    parserReleaseHandle(grandchild).
    parserReleaseHandle(child).

    IF childclassname>"" THEN DO:
       FIND tt_superclass WHERE tt_superclass.classname = childclassname NO-ERROR.
       IF available tt_superclass THEN
          RETURN.  /* already inspected in an earlier compilation unit */
       CREATE tt_superclass.
       ASSIGN tt_superclass.classname  = childclassname
              tt_superclass.superclass = thisclassname.
    END.

    nextSuperclass=parserAttrGetI(hClass, 2100).  /* 2100 = see documentation "Super Class Syntax Tree at joanju */
    IF nextSuperclass<>0 THEN
       RUN ParseSuperclasses (thisclassname, nextSuperclass).

END PROCEDURE.

PROCEDURE GetSuperClass :
    DEFINE INPUT PARAMETER   startnode      AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER  superclassname AS CHARACTER NO-UNDO INITIAL "".
    DEFINE OUTPUT PARAMETER  superclassnode AS INTEGER NO-UNDO INITIAL 0.

    DEFINE VARIABLE newnode AS INTEGER NO-UNDO.
    DEFINE VARIABLE child AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.

    child = parserGetHandle().
    newnode = parserGetHandle().
    parserCopyHandle(startnode, newnode).
    IF parserGetNodeType(newnode)="Program_root":U THEN DO:
       nodetype = parserNodeFirstChild(newnode, newnode).
       /* skip over the USING statements... */
       DO WHILE nodetype = "USING":U :
           nodetype = parserNodeNextSibling(newnode, newnode).
       END.
    END.

    IF parserGetNodeType(newnode) = "CLASS":U THEN DO:
       /* attrib 2100 : see documentation "Super Class Syntax Tree at joanju */
       superclassnode = parserAttrGetI(newnode, 2100).
       IF superclassnode<>0 THEN DO:
          nodetype = parserNodeFirstChild(superclassnode, child).
          DO WHILE nodetype<>"" :
             IF nodetype="TYPE_NAME":U THEN
                ASSIGN
                   nodetype = ""
                   superclassname = parserGetNodeText(child).
             ELSE
                nodetype = parserNodeNextSibling(child, child).
          END.
       END.
    END.

    parserReleaseHandle(child).
    parserReleaseHandle(newnode).

END PROCEDURE.

/* --------------------------------------------------------------------------------
                        maintenance procedures for tt_procedure 
                         (see BuildProcedureList in prolint.p)
   -------------------------------------------------------------------------------- */                      

PROCEDURE ProcedureListClear :
   /* empty the temp-table. */
   FOR EACH tt_procedure :
      DELETE tt_procedure.
   END.
END PROCEDURE.
   

PROCEDURE ProcedureListGet :             
   /* copy temp-table tt_procedure to calling procedure. 
      It would be cleaner to only output the handle, but then the calling procedure would 
      have to use dynamic FIND statements to navigate the temp-table. That's slightly slower */
   DEFINE OUTPUT PARAMETER TABLE FOR tt_procedure.
END PROCEDURE.


PROCEDURE ProcedureListAdd :
   /* create a new record tt_procedure */
   DEFINE INPUT PARAMETER pProcType  AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER pProcName  AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER pPrototype AS LOGICAL NO-UNDO.
   DEFINE INPUT PARAMETER pStartnode AS INTEGER   NO-UNDO.
                                            
   DEFINE VARIABLE vstartnode AS INTEGER   NO-UNDO.

   ASSIGN 
     vstartnode = parserGetHandle().

   parserCopyHandle(pStartnode, vstartnode).       
                                                            
   CREATE tt_procedure.
   ASSIGN tt_procedure.proctype   = pProctype 
          tt_procedure.procname   = pProcName           
          tt_procedure.prototype  = pPrototype
          tt_procedure.startnode  = vStartnode.

   /* do not releaseHandle(vStartnode)! */
   
END PROCEDURE.
   

/* --------------------------------------------------------------------------------
                       misc functions and procedures
   -------------------------------------------------------------------------------- */                      

PROCEDURE parsePropath :
/* purpose: makes function RelativeFilename faster */
    DEFINE VARIABLE i AS INTEGER NO-UNDO.

    DO i=1 TO NUM-ENTRIES(PROPATH) :
       /* ignore PL files */
       FILE-INFO:FILE-NAME = ENTRY(i, PROPATH).
       IF FILE-INFO:FULL-PATHNAME<>? AND FILE-INFO:FILE-TYPE MATCHES "*D*":U THEN DO:
          SearchPath = SearchPath + ",":U + FILE-INFO:FULL-PATHNAME.
       END.
    END.
    SearchPath = TRIM(SearchPath, ",":U).
    SearchPath = REPLACE(SearchPath, "~\":U, "/").
END PROCEDURE.


FUNCTION RelativeFilename RETURNS CHARACTER (pFileName AS CHARACTER):
   DEFINE VARIABLE i AS INTEGER NO-UNDO.
   DEFINE VARIABLE subdir AS CHARACTER NO-UNDO.
   DEFINE VARIABLE tmp AS CHARACTER NO-UNDO.
   DEFINE VARIABLE shortpath AS CHARACTER NO-UNDO.

   IF SearchPath = "" THEN RUN parsePropath.
   pFileName = REPLACE(pFileName, "~\", "/").

   /* search pFileName in cache, for speed */
   FIND tt_cacheRelativeName WHERE tt_cacheRelativeName.longname = pFileName NO-ERROR.
   IF AVAILABLE tt_cacheRelativeName THEN 
      RETURN tt_cacheRelativeName.relativename.

   IF SUBSTRING(pFileName, 1, 2) = './':U THEN
      pFileName = SUBSTRING(pFileName, 3).

   DO i=1 to num-entries(SearchPath) :
        subdir = entry(i, SearchPath).
        if length(subdir)<length(pFileName) then
           if subdir = substring(pFileName,1,length(subdir)) then
              DO:
                 shortpath = SUBSTRING(pFileName, length(subdir) + 2).
                 if length(shortpath) < length(pFileName) then DO:
                    FILE-INFO:FILE-NAME = shortpath.
                    IF REPLACE(FILE-INFO:FULL-PATHNAME,"~\","/") = pFileName THEN DO:
                       CREATE tt_cacheRelativeName.
                       ASSIGN tt_cacheRelativeName.longname     = pFileName
                              tt_cacheRelativeName.relativename = shortpath.
                       RETURN shortpath.
                    END.
                 END.
              END.
   END.
   RETURN pFileName.
END FUNCTION.


PROCEDURE GetFilePosition :
/* purpose: return linenumber and sourcefile where theNode is found */
  DEFINE INPUT  PARAMETER theNode AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER LineNumber AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER SourceFile AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE subnode    AS INTEGER NO-UNDO.
  DEFINE VARIABLE numresults AS INTEGER NO-UNDO.
  DEFINE VARIABLE i          AS INTEGER NO-UNDO.
                                             
  ASSIGN                                              
     LineNumber = parserGetNodeLine(theNode)
     SourceFile = parserGetNodeFilename(theNode).
  
  /* if TheNode is a synthetic node, then LineNumber will be 0 and SourceFile will be "".
     in that case, query children/grandchildren until you find any non-synthetic node.
     Just assume it's on the same line */
  IF LineNumber EQ 0 OR SourceFile EQ "" THEN DO:
     subnode = parserGetHandle().
     numResults = parserQueryCreate(TheNode, "getfileposition":U, "":U).
     i = 1.
     DO WHILE (i LE numResults) AND (LineNumber EQ 0 OR SourceFile EQ ""):
        parserQueryGetResult("getfileposition":U, i, subnode). 
        ASSIGN 
           LineNumber = parserGetNodeLine(subnode)
           SourceFile = parserGetNodeFilename(subnode)
           i = i + 1.
     END.
     parserQueryClear ("getfileposition":U).
     parserReleaseHandle(subnode).
  END.

  IF SourceFile NE "" THEN 
     SourceFile = RelativeFileName(SourceFile).
  
END PROCEDURE.                                                                          


FUNCTION GetFieldnameFromFieldref RETURNS CHARACTER (INPUT nFieldRef AS INTEGER) :
  /* assuming nFieldRef is a "Field_ref" node, return the name of the field */

  DEFINE VARIABLE child  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE retval AS CHARACTER NO-UNDO.

  child = parserGetHandle().

  IF "ID":U <> parserNodeFirstChild(nFieldRef, child)  THEN
     IF "ID":U <> parserNodeNextSibling(child, child) THEN
        parserNodeNextSibling(child, child).

  retval = parserGetNodeText(child).
  parserReleaseHandle(child).
  RETURN retval.

END FUNCTION.

   
PROCEDURE SetRuleParameters :
  /* purpose: helps {&_Proparse_ prolint-nowarn} directives */
  DEFINE INPUT PARAMETER pActivePragma   AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pActiveSeverity AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pIgnoreAB       AS LOGICAL NO-UNDO.

  ASSIGN                                
     AbortSearch    = FALSE
     IgnoreAB       = pIgnoreAB
     ActivePragma   = pActivePragma
     ActiveSeverity = pActiveSeverity.
     
END PROCEDURE.

  
PROCEDURE searchNode :
  /* purpose: query the tree:
              find all nodes of type NodeTypesToInspect within theNode. For every node 
              found run value(ipCallBack) which will implement the actual rule.
              Params: theNode : a proparse node
                      ipCallBack : an internal procedure in a rule
                      NodeTypesToInspect : comma separated list of nodetypes */
  DEFINE INPUT  PARAMETER theNode            AS INTEGER NO-UNDO.  
  DEFINE INPUT  PARAMETER ipCallBack         AS CHAR    NO-UNDO.
  DEFINE INPUT  PARAMETER NodetypesToInspect AS CHAR    NO-UNDO.
                                          
  /* searching a tree (recursive) is probably faster than a query if no nodetypes are specified */
  /* actually this may not be true anymore with the latest version of proparse, have to test that */
  IF NodeTypesToInspect="" OR NodeTypesToInspect=? THEN
     RUN SearchNodeTree   IN  TARGET-PROCEDURE (theNode, ipCallBack, NodeTypesToInspect).
  ELSE
     RUN searchNodeQueries IN TARGET-PROCEDURE (theNode, ipCallBack, NodeTypesToInspect).
                         
END PROCEDURE.
  
  
PROCEDURE searchNodeQueries :
  /* purpose  : like SearchNode, using queries in proparse */
  DEFINE INPUT  PARAMETER theNode            AS INTEGER NO-UNDO.  
  DEFINE INPUT  PARAMETER ipCallBack         AS CHAR    NO-UNDO.
  DEFINE INPUT  PARAMETER NodetypesToInspect AS CHAR    NO-UNDO.
  
  DEFINE VARIABLE numResults     AS INTEGER NO-UNDO.
  DEFINE VARIABLE q              AS INTEGER NO-UNDO.                
  DEFINE VARIABLE i              AS INTEGER NO-UNDO.                
  DEFINE VARIABLE queryname      AS CHAR    NO-UNDO.
  DEFINE VARIABLE childnode      AS INTEGER NO-UNDO.
  DEFINE VARIABLE SearchChildren AS LOGICAL NO-UNDO INITIAL FALSE.
                                          
  childnode = parserGetHandle().
  
  loop_nodetypes:
  DO q=1 TO NUM-ENTRIES(NodetypesToInspect) :                
     /* invent a probably unique name */
     queryname  = 'query_':U + ENTRY(q,NodetypesToInspect) + "_":U +  STRING(theNode) + "_":U + STRING(q).  
     numResults = parserQueryCreate(theNode, queryname, ENTRY(q,NodetypesToInspect)).
     loop_results:
     DO i=1 TO numResults :
       /* skip node if marked by FindProparseDirectives in prolint.p */
       IF parserQueryGetResult(queryname, i, childnode) THEN
          IF 0=parserAttrGetI(childnode,ActivePragma) THEN
             RUN VALUE(ipCallBack) IN TARGET-PROCEDURE (childnode,
                                                        OUTPUT AbortSearch,
                                                        OUTPUT SearchChildren).
       IF AbortSearch THEN LEAVE loop_results.
     END.
     parserQueryClear(queryname).
     IF AbortSearch THEN LEAVE loop_nodetypes.
  END.
                                                
  parserReleaseHandle(childnode).
                                                
END PROCEDURE.

                                    
PROCEDURE searchNodeTree :
  /* purpose  : like SearchNode, using a recursive loop. In general this is lots slower
                than searchNodeQuery, although in some cases it's faster */
  DEFINE INPUT  PARAMETER theNode            AS INTEGER   NO-UNDO.  
  DEFINE INPUT  PARAMETER ipCallBack         AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER NodetypesToInspect AS CHARACTER NO-UNDO.

  DEFINE VARIABLE child          AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
  DEFINE VARIABLE grandchild     AS INTEGER NO-UNDO.
          
  ASSIGN                      
    child      = parserGetHandle()
    grandchild = parserGetHandle().               
    
  IF 0=parserAttrGetI(theNode,ActivePragma) THEN
  IF (NodetypesToInspect=?) OR (LOOKUP(parserGetNodeType(theNode),NodetypesToInspect) GT 0) THEN
     RUN VALUE(ipCallBack) IN TARGET-PROCEDURE (theNode,
                                                OUTPUT AbortSearch,
                                                OUTPUT SearchChildren).
  
  IF SearchChildren AND (NOT AbortSearch) THEN DO:
     ASSIGN nodetype = parserNodeFirstChild(theNode,child).
     DO WHILE nodetype<>"" AND (NOT AbortSearch):
              
       /* if child is a new node head, run searchNodeTree with it (recursion) */
       IF parserNodeFirstChild(child, grandchild)<>"" THEN
          RUN searchNodeTree IN TARGET-PROCEDURE (child, ipCallBack, NodetypesToInspect).
       nodetype = parserNodeNextSibling(child,child).
     END.                       
  END.

  parserReleaseHandle(child).
  parserReleaseHandle(grandchild).
END.
                         
                          
PROCEDURE PublishResult :
   /* purpose: if a rule finds something to complain about, it runs this procedure,
               using the default severity level for this rule.
               Here is an opportunity to override PUBLISH "Prolint_AddResult"  */
   DEFINE INPUT PARAMETER pCompilationUnit  AS CHAR    NO-UNDO.  /* the sourcefile we're parsing          */
   DEFINE INPUT PARAMETER pSource           AS CHAR    NO-UNDO.  /* may be an includefile                 */
   DEFINE INPUT PARAMETER pLineNumber       AS INTEGER NO-UNDO.  /* line number in pSourceFile            */
   DEFINE INPUT PARAMETER pDescription      AS CHAR    NO-UNDO.  /* human-readable hint                   */
   DEFINE INPUT PARAMETER pRuleID           AS CHAR    NO-UNDO.  /* defines rule-program and maps to help */

   RUN PublishResultSeverity IN TARGET-PROCEDURE
                              (pCompilationunit,
                               pSource,
                               pLineNumber, 
                               REPLACE(pDescription,"~n":U," ":U),
                               pRuleID,
                               ActiveSeverity).
                                                                       
END PROCEDURE.


PROCEDURE PublishResultSeverity :
   /* purpose: Like PublishResult, but with extra Severity parameter.
               If a rule finds something to complain about, it runs this procedure.
               Here is an opportunity to override PUBLISH "Prolint_AddResult"  */
   DEFINE INPUT PARAMETER pCompilationUnit  AS CHAR    NO-UNDO.  /* the sourcefile we're parsing          */
   DEFINE INPUT PARAMETER pSource           AS CHAR    NO-UNDO.  /* may be an includefile                 */
   DEFINE INPUT PARAMETER pLineNumber       AS INTEGER NO-UNDO.  /* line number in pSourceFile            */
   DEFINE INPUT PARAMETER pDescription      AS CHAR    NO-UNDO.  /* human-readable hint                   */
   DEFINE INPUT PARAMETER pRuleID           AS CHAR    NO-UNDO.  /* defines rule-program and maps to help */
   DEFINE INPUT PARAMETER pCurrentSeverity  AS INTEGER NO-UNDO.  /* allows override of ActiveSeverity     */

   DEFINE VARIABLE filteredby AS CHARACTER NO-UNDO. /* comma-sep list of filters that deny this warning */
   DEFINE VARIABLE severity AS INTEGER NO-UNDO.
   DEFINE VARIABLE RelativeSource AS CHARACTER NO-UNDO.

   ASSIGN
      pDescription = REPLACE(REPLACE(pDescription,"~n":U," ":U),CHR(9)," ":U)
      severity = IF pCurrentSeverity=? THEN ActiveSeverity ELSE pCurrentSeverity.

   /* replace fully-qualified path by relative path (relative to propath) */
   IF pCompilationUnit = pSource THEN
      ASSIGN
        pCompilationUnit = RelativeFileName(pCompilationUnit)
        RelativeSource   = pCompilationUnit.
   ELSE
      ASSIGN
        pCompilationUnit = RelativeFileName(pCompilationUnit)
        RelativeSource   = RelativeFileName(pSource).

   RUN GetFilterResult IN hpFilterPlugins (pCompilationUnit,
                                           pSource,
                                           RelativeSource,
                                           pLineNumber,
                                           pRuleID,
                                           IgnoreAB,
                                           INPUT-OUTPUT pDescription,
                                           INPUT-OUTPUT severity,
                                           OUTPUT filteredby).

   IF filteredby <> "" THEN RETURN.  /* TODO: send filteredby to outputhandlers */

   PUBLISH "Prolint_AddResult":U (pCompilationunit,
                                  RelativeSource,
                                  pLineNumber,
                                  REPLACE(pDescription,"~n":U," ":U),
                                  pRuleID,
                                  severity).
                                                                       
END PROCEDURE.


PROCEDURE PublishResultSeverityRelative :
   /* purpose: Like PublishResultSeverity, but this time we know for sure that filenames are already relative filenames */
   DEFINE INPUT PARAMETER pCompilationUnit  AS CHAR    NO-UNDO.  /* the sourcefile we're parsing          */
   DEFINE INPUT PARAMETER pSource           AS CHAR    NO-UNDO.  /* may be an includefile                 */
   DEFINE INPUT PARAMETER pLineNumber       AS INTEGER NO-UNDO.  /* line number in pSourceFile            */
   DEFINE INPUT PARAMETER pDescription      AS CHAR    NO-UNDO.  /* human-readable hint                   */
   DEFINE INPUT PARAMETER pRuleID           AS CHAR    NO-UNDO.  /* defines rule-program and maps to help */
   DEFINE INPUT PARAMETER pCurrentSeverity  AS INTEGER NO-UNDO.  /* allows override of ActiveSeverity     */

   DEFINE VARIABLE filteredby AS CHARACTER NO-UNDO. /* comma-sep list of filters that deny this warning */
   DEFINE VARIABLE severity AS INTEGER NO-UNDO.
   DEFINE VARIABLE RelativeSource AS CHARACTER NO-UNDO.

   ASSIGN
      pDescription = REPLACE(REPLACE(pDescription,"~n":U," ":U),CHR(9)," ":U)
      severity = IF pCurrentSeverity=? THEN ActiveSeverity ELSE pCurrentSeverity.

   RUN GetFilterResult IN hpFilterPlugins (pCompilationUnit,
                                           pSource,
                                           pSource,
                                           pLineNumber,
                                           pRuleID,
                                           IgnoreAB,
                                           INPUT-OUTPUT pDescription,
                                           INPUT-OUTPUT severity,
                                           OUTPUT filteredby).

   IF filteredby <> "" THEN RETURN.  /* TODO: send filteredby to outputhandlers */

   PUBLISH "Prolint_AddResult":U (pCompilationunit,
                                  pSource,
                                  pLineNumber,
                                  REPLACE(pDescription,"~n":U," ":U),
                                  pRuleID,
                                  severity).
                                                                       
END PROCEDURE.



PROCEDURE NextNaturalNode :
/* purpose: set a handle to point at the next non-synthetic node
            There are at least two reasons for wanting the next non-synthetic node:
            - finding line/filename (not stored in synthetic nodes)
            - finding hidden tokens (are only attached to natural nodes)
            This function became more necessary with the removal of parserHiddenGetAfter().
   Author: John Green
   INPUT: start handle, target handle (may be the same as each other)
   OUTPUT: TRUE if a natural node was found, FALSE otherwise.
   NOTES: * If the start handle is a natural node, then targetHandle=startHandle,
            and the return value is TRUE.
          * If no natural node is found,
            then targetHandle isn't pointing to anything useful.
          * Siblings of startHandle are checked, but not parents.
          * Watches for "operator nodes" which were made root to its operands.
            From 1 + 2, we want the "1", not the "+".
          * Are PROPARSEDIRECTIVE nodes natural?
            Well, they have no text, but they do have a line number,
            and they do hold hidden tokens. We use line number as our test,
            which serves us correctly here for hidden tokens.
*/
   DEFINE INPUT  PARAMETER startNode  AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER targetNode AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER wasFound   AS LOGICAL NO-UNDO.

   DEFINE VARIABLE operatorAttr AS CHARACTER NO-UNDO.
   DEFINE VARIABLE nodeLine     AS INTEGER   NO-UNDO.

   /* Only copy start to target if they aren't the same handle */
   IF startNode <> targetNode THEN
      parserCopyHandle(startNode, targetNode).

   /* exit condition - "natural" nodes have a line number */
   IF parserGetNodeLine(targetNode) <> 0 THEN DO:
      wasFound = TRUE.
      RETURN.
   END.

   /* Check for child, then check for sibling, then fail */
   IF ( parserNodeFirstChild(targetNode, targetNode) = ""
        AND parserNodeNextSibling(targetNode, targetNode) = ""
       ) THEN DO:
      wasFound = FALSE.
      RETURN.
   END.

   /* Now we have either the first child or the next sibling */
   nodeLine = parserGetNodeLine(targetNode).
   DO WHILE nodeLine = 0:
      IF parserNodeFirstChild(targetNode, targetNode) = "" THEN DO:
         /* This would happen at end of file; ie: next sibling was Program_tail */
         wasFound = FALSE.
         RETURN.
      END.
      nodeLine = parserGetNodeline(targetNode).
   END.

   /* Now we have a natural node.
      But if it's an *operator* node, then it's not really the *first* natural node! */
   operatorAttr = parserAttrGet(targetNode, "operator":U).
   DO WHILE operatorAttr = "t":U :
      findnatural:
      DO WHILE TRUE: /* find first non-synthetic child */
         parserNodeFirstChild(targetNode, targetNode).
         IF parserGetNodeLine(targetNode) <> 0 THEN
           LEAVE findnatural.
      END.
      operatorAttr = parserAttrGet(targetNode, "operator":U).
   END.

   /* Now we really have the first natural node. */
   wasFound = TRUE.
   RETURN.

END PROCEDURE.  /* NextNaturalNode */                                                                          
   

