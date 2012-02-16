/* ------------------------------------------------------------------------
   file    :  prolint/rules/runnotfound.p
   by      :  Jurjen Dijkstra
   purpose :  find RUN statements like "RUN dir/name.p" and see if the name 
              of the external procedure can be found
              (trying to prevent runtime error 293)
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
   ------------------------------------------------------------------------ */
  
{prolint/core/ruleparams.i}  
{prolint/core/ttprocedure.i}
           
DEFINE VARIABLE dlcdir AS CHARACTER NO-UNDO.

FUNCTION WithoutQuotes RETURNS CHARACTER (qstring AS CHARACTER) FORWARD.
FUNCTION IsDlcComponent RETURNS LOGICAL (progname AS CHARACTER) FORWARD.

RUN ProcedureListGet IN hLintSuper (OUTPUT TABLE tt_procedure).

RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectNode":U,         /* name of callback procedure   */
                           "RUN":U).                /* list of statements to search */

RETURN.


PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode in ruledefs.i */                                                    
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
                             
  DEFINE VARIABLE child            AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE progname         AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE found_persistent AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE found_in         AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE found_on         AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE irtb             AS INTEGER NO-UNDO INITIAL 0.

  ASSIGN
    SearchChildren = FALSE  /* a RUN statement can not contain other RUN statements */
    child          = parserGetHandle()                
    nodetype       = parserNodeFirstChild(theNode,child).
                      
  /* not every RUN node has children, for example ON "CHOOSE" PERSISTENT RUN ip IN THIS-PROCEDURE" */
  IF nodetype<>"" THEN DO:

     CASE nodetype :
     
        WHEN "FILENAME":U THEN DO: 
          progname = parserGetNodeText(child).
          /* Remove quotes from filename, if any. For example:
                 RUN 'apps/tpm/itin/d-clone.w':U (chRowID, OUTPUT keyValue).
             Else you would get a warning about the capital U in :U */
          IF CAN-DO("',~"":U, SUBSTRING(progname,1,1)) THEN progname = WithoutQuotes(progname).
        END.
     
        WHEN "ID":U       THEN progname = parserGetNodeText(child). /* maybe an internal procedure, maybe not */
     
     END CASE.

     /* roundtable XREF generator adds a signature to the filename. Remove it: */
     irtb = INDEX (progname, "*RTB-smObj*":U).
     IF irtb>0 THEN DO:
        SUBSTRING(progname, irtb, 11) = "".
        progname = TRIM(progname).
     END.

     /* we are still not sure if it's really a filename or an internal procedure. */
     /*  - if the keyword "PERSISTENT" is used, it sure is an external procedure. */
     /*  - if the keyword "ON" is used, it is an external procedure but not in this partition. (run xyz on [server handle]) */
     /*  - if the keyword "IN" is used, it must be an internal procedure.
            except when IN is used to set event-procedure context for async appserver call,
            but in that case IN comes after ON */
     /*  - if it looks like a filename (contains dot or slash) then its probably a filename. */
     /*  - if it contains a dot it may be an ActiveX trigger procedure: look it up in tt_procedure */
     /*  - if not in tt_procedure it may still be an ip in a super procedure. False Positive! */

     nodetype = parserNodeNextSibling(child,child).
     DO WHILE nodetype<>"" :
        CASE nodetype :
           WHEN "PERSISTENT":U THEN found_persistent = TRUE.
           WHEN "ON":U         THEN found_on         = TRUE. /* run xyz on [server ...] */
           WHEN "IN":U         THEN IF NOT found_on THEN found_in = TRUE.
        END CASE.
        nodetype = parserNodeNextSibling(child,child).
     END.

     IF NOT (progname="" OR found_on OR found_in) THEN
        IF found_persistent OR INDEX( progname, '.':U )>0 OR INDEX( progname, '/':U )>0 OR INDEX( progname, '~\':U )>0 THEN
                 DO:
                     FIND tt_procedure NO-LOCK 
                          WHERE tt_procedure.procname = progname 
                            AND tt_procedure.proctype = "procedure":U 
                          NO-ERROR.
                     IF NOT AVAILABLE tt_procedure THEN
                         IF SEARCH ( progname ) = ? THEN
                            IF NOT IsDlcComponent(progname) THEN
                               RUN PublishResult            ( compilationunit,
                                                              parserGetNodeFilename( theNode ),
                                                              parserGetNodeLine( theNode ),
                                                              SUBSTITUTE( "proc '&1' not found":T, progname ),
                                                              rule_id ).
                 END.
  END.

  parserReleaseHandle(child).
    
END PROCEDURE.                            


FUNCTION WithoutQuotes RETURNS CHARACTER (qstring AS CHARACTER) :
  /* purpose: remove the quotes from nodetext "test" or 'test'. */
  DEFINE VARIABLE quote AS CHARACTER NO-UNDO.
  
  quote = SUBSTRING(qstring,1,1). 
  RETURN SUBSTRING(qstring,2,R-INDEX(qstring,quote) - 2).
  
END FUNCTION.


FUNCTION IsDlcComponent RETURNS LOGICAL (progname AS CHARACTER) :
  /* purpose: check if compiled procedure is found in DLC */
  DEFINE VARIABLE dlc-component AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rprogname     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rprogpath     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE dot           AS INTEGER   NO-UNDO.

  /* get DLC without using OS-GETENV(DLC): it may not be set, or may have a funny format */
  IF dlcdir = "" THEN
    ASSIGN
       dlc-component =  'bin/prowin32.exe':U
       dlcdir = SEARCH (dlc-component)
       dlcdir = SUBSTRING(dlcdir, 1, LENGTH(dlcdir) - LENGTH(dlc-component)).

  /* if progname is a sourcefile, the name of its compiled r-code would be: */
  dot = R-INDEX (progname, ".":U).
  IF dot>0 THEN
     rprogname = SUBSTRING(progname, 1, dot) + 'r':U.
  ELSE
     RETURN FALSE.

  rprogpath = SEARCH (rprogname).
  IF rprogpath = ? THEN
     RETURN FALSE.
  ELSE
     RETURN (rprogpath MATCHES (dlcdir + "*":U)).

END FUNCTION.


