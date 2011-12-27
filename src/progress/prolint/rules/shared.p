/* ------------------------------------------------------------------------
   file    :  prolint/rules/shared.p
   by      :  Jurjen Dijkstra
   purpose :  avoid using the SHARED keyword, use parameters instead
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

DEFINE VARIABLE SharePhrase AS CHARACTER NO-UNDO.
  
RUN searchNode            (hTopnode,         /* "Program_root" node                 */
                           "InspectNode":U,  /* name of callback procedure          */
                           "SHARED":U).      /* list of statements to search, ?=all */

RETURN.

PROCEDURE InspectNode :             
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.
  
  DEFINE VARIABLE child        AS INTEGER NO-UNDO.
  DEFINE VARIABLE grandchild   AS INTEGER NO-UNDO.
  DEFINE VARIABLE objname      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE objtype      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE vartype      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodetype     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE raisewarning AS LOGICAL NO-UNDO.

  /* theNode is of type "SHARED". Find the beginning of the DEFINE statement: */
  IF ParserNodeStateHead(theNode, theNode) <> "DEFINE":U THEN 
     RETURN.
                         
  ASSIGN
    child          = parserGetHandle()
    grandchild     = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child)

  /* if it's a SHARED definition, it's always specified in the first child.
     Let's see if this first child contains the SHARED keyword */
  SharePhrase = nodetype.
  RUN searchNodeTree            (child, 
                                 "InspectSharePhrase":U,
                                 ?).

  IF (SharePhrase MATCHES "*SHARED":U) THEN DO:

     /* the second child specifies the object type (variable, temp-table, buffer, stream etc) */
     ASSIGN nodetype = parserNodeNextSibling(child,child).
     IF nodetype<>"" THEN 
        objtype = nodetype.

     /* the next child is ID */
     IF nodetype<>"" THEN DO:
        ASSIGN nodetype = parserNodeNextSibling(child,child).
        IF nodetype="ID":U THEN 
           objname = parserGetNodeText(child).
     END.                             
     
     /* the next child should be the 'AS variabletype' specification, if objtype="VARIABLE" */
     IF objtype="VARIABLE":U AND nodetype<>"" THEN DO:
        ASSIGN nodetype = parserNodeNextSibling(child,child).
        IF nodetype<>"" THEN 
           IF nodetype = "AS":U THEN DO:
              vartype = parserNodeFirstChild(child,grandchild).
              IF vartype="" THEN 
                 vartype = parserNodeNextSibling(child,child).
           END.
     END.                             
     
     /* we have collected enough data now. Let's decide if we want to raise a warning: */
     raisewarning = TRUE.
     
     IF objtype="VARIABLE":U AND vartype="HANDLE":U AND SharePhrase="NEW GLOBAL SHARED":U THEN 
        raisewarning = FALSE.
        
     IF objtype="STREAM":U AND NOT (SharePhrase MATCHES "*GLOBAL*":U) THEN 
        raisewarning = FALSE.
     
     IF raisewarning THEN    
        RUN PublishResult            (compilationunit,
                                      parserGetNodeFilename(theNode),
                                      parserGetNodeLine(theNode), 
                                      SUBSTITUTE("avoid SHARED on &1 '&2'":T, LC(objtype), objname),
                                      rule_id).
                        
  END. /* if SharePhrase MATCHES "*SHARED" */
  
  parserReleaseHandle(child).
  parserReleaseHandle(grandchild).
    
END PROCEDURE.                            


PROCEDURE InspectSharePhrase :
  /* purpose : callback from searchNodeTree, assemble the SharePhrase */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL TRUE.
 
  DEFINE VARIABLE child    AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
                         
  ASSIGN
    child          = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child).
    
  DO WHILE nodetype<>"" :
     SharePhrase = SharePhrase + " ":U + nodetype.
     RUN searchNodeTree            (child, 
                                    "InspectSharePhrase":U,
                                    ?).
     nodetype = parserNodeNextSibling(child,child).
  END.      
  parserReleaseHandle(child).
                            
END PROCEDURE.
                               
                                                                                        