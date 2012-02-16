/* ------------------------------------------------------------------------
   file    :  prolint/rules/runname.p
   by      :  Jurjen Dijkstra
   purpose :  find RUN statements like "RUN dir/name.p" and see if the name 
              of the external procedure is Unix-compatible (all lowercase 
              and using forward-slashes)
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
           
DEFINE VARIABLE qstrings AS CHARACTER NO-UNDO.

FUNCTION WithoutQuotes RETURNS CHARACTER (qstring AS CHARACTER) FORWARD.

RUN ProcedureListGet IN hLintSuper (OUTPUT TABLE tt_procedure).

RUN Ignore_RTB_xref_generator.
                         
RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectNode":U,         /* name of callback procedure   */
                           "RUN":U).                /* list of statements to search */

RETURN.


PROCEDURE Ignore_RTB_xref_generator :
/* purpose: all RUN statements inside internal procedure "RTB_xref_generator" 
            should be ignored, so mark them with a pragma attribute */
   DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
   DEFINE VARIABLE i          AS INTEGER NO-UNDO.
   DEFINE VARIABLE childnode  AS INTEGER NO-UNDO.

            
   FIND tt_procedure WHERE tt_procedure.proctype = "PROCEDURE":U
                       AND tt_procedure.procname = "RTB_xref_generator":U
                     NO-LOCK NO-ERROR.
                     
   IF AVAILABLE tt_procedure THEN DO:
      childnode = parserGetHandle().
      numResults = parserQueryCreate(tt_procedure.startnode, "rtb_xref":U, "RUN":U).
      DO i=1 TO numResults :
        IF parserQueryGetResult("rtb_xref":U, i, childnode) THEN
           parserAttrSet(childnode, pragma_number, 1).
      END.
      parserQueryClear("rtb_xref":U).
      parserReleaseHandle(childnode).
   END.                            
     
END PROCEDURE.

                                                     
PROCEDURE InspectNode :           
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode in ruledefs.i */                                                    
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
                             
  DEFINE VARIABLE child            AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE progname         AS CHARACTER NO-UNDO INITIAL "" CASE-SENSITIVE.
  DEFINE VARIABLE found_persistent AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE found_in         AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE found_on         AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE found_period     AS LOGICAL NO-UNDO INITIAL NO.
  
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
          IF CAN-DO("',~"", SUBSTRING(progname,1,1)) THEN progname = WithoutQuotes(progname).
        END.
     
        WHEN "ID":U       THEN progname = parserGetNodeText(child). /* maybe an internal procedure, maybe not */
     
        WHEN "VALUE":U    THEN DO:
                             /* difficult case; it's an expression. We have to dive into 
                                the expression and see if there are any string literals inside. */
                             
                             qstrings = "".   
                             RUN searchNode            (child, "SearchQstrings":U, "QSTRING":U).
                             progname = qstrings.
                        END.
     END CASE.

     /* we are still not sure if it's really a filename or an internal procedure. */
     /*  - if the keyword "PERSISTENT" is used, it sure is an external procedure. */
     /*  - if the keyword "ON" is used, it is an external procedure. (run xyz on [server handle]) */
     /*  - if the keyword "IN" is used, it must be an internal procedure.
            except when IN is used to set event-procedure context for async appserver call,
            but in that case IN comes after ON */
     /*  - if both "PERSISTENT" and "IN" are found, we are wrong and will pretend nothing happened */
     /*  - otherwise, let's assume it's an external procedure if progname contains a dot (like .p or .r) */
                                         
     nodetype = parserNodeNextSibling(child,child).
     DO WHILE nodetype<>"" :
        CASE nodetype :
           WHEN "PERSISTENT":U THEN found_persistent = TRUE.
           WHEN "ON":U         THEN found_on         = TRUE. /* run xyz on [server ...] */
           WHEN "IN":U         THEN IF NOT found_on THEN found_in = TRUE.
           WHEN "PERIOD":U     THEN found_period     = TRUE.
        END CASE.
        nodetype = parserNodeNextSibling(child,child).
     END.

     IF NOT found_in THEN 
       IF found_persistent OR found_on OR INDEX(progname,'.':U)>0 THEN 
         IF (NOT progname EQ LOWER(progname)) OR (INDEX(progname,'~\':U)>0) THEN DO:
             FIND tt_procedure WHERE tt_procedure.procname = progname
                                 AND tt_procedure.proctype = "procedure":U
                               NO-LOCK NO-ERROR.
             IF NOT AVAILABLE tt_procedure THEN
                RUN PublishResult            (compilationunit,
                                              parserGetNodeFilename(theNode),
                                              parserGetNodeLine(theNode),
                                              "progname in RUN-statement is not Unix-compatible":T,
                                              rule_id).
     END.
                                                    
     IF NOT found_period THEN 
           RUN PublishResult            (compilationunit,
                                         parserGetNodeFilename(theNode),
                                         parserGetNodeLine(theNode), 
                                         "RUN-statement does not end with period":T,
                                         rule_id).

  END.  /* if havenode */

  parserReleaseHandle(child).
    
END PROCEDURE.                            


FUNCTION WithoutQuotes RETURNS CHARACTER (qstring AS CHARACTER) :
  /* purpose: remove the quotes from nodetext "test" or 'test'.
     more important: remove string attributes (like :U) because they are probably in uppercase. */
  DEFINE VARIABLE quote AS CHARACTER NO-UNDO.
  
  quote = SUBSTRING(qstring,1,1). 
  RETURN SUBSTRING(qstring,2,R-INDEX(qstring,quote) - 2).
  
END FUNCTION.


PROCEDURE SearchQstrings :
  /* simply concatenate all string literals you can find. If there is a dot in the 
     resulting string we will assume it's a filename  (like "ordertotal.p")  */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL TRUE.
  
  IF parserGetNodeType(theNode) = "QSTRING":U THEN  
     ASSIGN qstrings = qstrings + WithoutQuotes(parserGetNodeText(theNode)).
                                                                   
END PROCEDURE.                            

