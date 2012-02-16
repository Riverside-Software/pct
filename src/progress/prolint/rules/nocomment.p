/* ------------------------------------------------------------------------
   file    :  prolint/rules/comment.p
   by      :  Jurjen Dijkstra
   purpose :  find procedures or functions that don't start with a comment
   ------------------------------------------------------------------------
   Change  : 28 may 2002
   by      : Patrick Tingen
   desc    : - If no comment found after procedure/function statement, 
               try to find one before it. 
   Change  : 24 June 2002
   by      : Jurjen
   desc    : ignore comment before procedure if it is on the same line as
             last token of previous procedure.
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra, Patrick Tingen

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
                            
  DEFINE VARIABLE child             AS INTEGER   NO-UNDO.
  DEFINE VARIABLE tempbool           AS LOGICAL   NO-UNDO.                            
  DEFINE VARIABLE nodetype          AS CHARACTER NO-UNDO.
  DEFINE VARIABLE found_hidden      AS LOGICAL   NO-UNDO INITIAL FALSE.
  DEFINE VARIABLE found_comment     AS LOGICAL   NO-UNDO INITIAL FALSE.
  DEFINE VARIABLE uibdefaultcomment AS CHARACTER NO-UNDO.
  DEFINE VARIABLE comment_line      AS INTEGER   NO-UNDO.
  DEFINE VARIABLE numResults        AS INTEGER   NO-UNDO.

                                                     
  uibdefaultcomment = "                                                   
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/":U.
  uibdefaultcomment = REPLACE(uibdefaultcomment," ":U,"").
  uibdefaultcomment = REPLACE(uibdefaultcomment,"~n":U,"").

  child          = parserGetHandle().

  
  RUN ProcedureListGet IN hLintSuper (OUTPUT TABLE tt_procedure).
  FOR EACH tt_procedure WHERE tt_procedure.prototype=FALSE
                          AND (NOT tt_procedure.proctype MATCHES "PROPERTY*") 
                          AND tt_procedure.proctype NE "ON":U :
     
     ASSIGN                      
       found_hidden   = FALSE                      
       found_comment  = FALSE
       comment_line   = 0
       nodetype       = parserNodeFirstChild(tt_procedure.startnode,child).


     /* find the Code_block node, and then find the next non-synthetic node (if any) */       
     DO WHILE nodetype <> "Code_block":U :
        nodetype = parserNodeNextSibling(child,child).
     END.
     RUN NextNaturalNode IN hLintSuper (child, child, OUTPUT tempbool).

     /* if we found the next non-synthetic node, check for comments before it */
     IF tempbool THEN DO:
        found_hidden = parserHiddenGetBefore(child).
        DO WHILE found_hidden AND NOT found_comment :
           IF parserHiddenGetType() EQ "COMMENT":U THEN 
              IF REPLACE(REPLACE(parserHiddenGetText()," ":U,""),"~n":U,"") NE uibdefaultcomment THEN 
                 found_comment = TRUE.
           found_hidden  = parserHiddenGetPrevious().
        END.
     END.


     /* Try to find comment in the opposite direction 
     ** ie (BEFORE the procedure/function statement). */
     IF NOT found_comment THEN
     DO:
       /* search for a comment before the procedure/function: */
       found_hidden = parserHiddenGetBefore(tt_procedure.startnode).
       DO WHILE found_hidden AND NOT found_comment :       
          IF parserHiddenGetType() EQ "COMMENT":U THEN 
             IF parserHiddenGetText() = "/* _UIB-CODE-BLOCK-END */":U THEN
                found_hidden = FALSE. /* stop searching */
             ELSE
                IF REPLACE(REPLACE(parserHiddenGetText()," ":U,""),"~n":U,"") NE uibdefaultcomment THEN
                   ASSIGN
                      comment_line  = parserHiddenGetLine()
                      found_comment = TRUE.
          IF found_hidden THEN
             found_hidden  = parserHiddenGetPrevious().
       END.

       /* check if this comment does not belong to the previous procedure,
          for example:
               END. /* of procedure proc_1 */
               PROCEDURE proc_2 :
          ie check if comment is not on same line as END. */
       /* find the last token of the previous statement: */
       IF parserNodePrevSibling (tt_procedure.startnode, child)<>"" THEN DO:
          numResults = parserQueryCreate(child, "nocomment":U, "").
          IF numResults>0 THEN DO:
             parserQueryGetResult("nocomment":U, numResults, child).
             IF parserGetNodeLine(child) = comment_line THEN
                found_comment = FALSE.
          END.
          parserQueryClear("nocomment":U).
       END.

     END.
     
     IF NOT found_comment THEN                                         
        RUN PublishResult            (compilationunit,
                                      parserGetNodeFilename(tt_procedure.startnode),
                                      parserGetNodeLine(tt_procedure.startnode), 
                                      SUBSTITUTE("&1 &2 is not commented":T,tt_procedure.proctype,tt_procedure.procname),
                                      rule_id).

  END.    

  parserReleaseHandle(child).

RETURN.                                                                            
  
