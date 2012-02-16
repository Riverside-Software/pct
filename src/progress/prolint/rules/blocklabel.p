/* ------------------------------------------------------------------------
   file    :  prolint/rules/blocklabel.p
   by      :  Jurjen Dijkstra
   purpose :  find LEAVE without label, as in 
                FOR EACH ...... :
                   IF ... THEN LEAVE [blocklabel].
                END.    
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
                                
RUN searchNode            (hTopnode,              /* "Program_root" node          */
                           "InspectNode":U,       /* name of callback procedure   */
                           "LEAVE,NEXT":U).       /* list of statements to search */

RETURN.

                           
PROCEDURE InspectNode :           
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
                             
  DEFINE VARIABLE child            AS INTEGER NO-UNDO.
  
  ASSIGN
    SearchChildren = TRUE
    child          = parserGetHandle().

  /* see if it is a statement head. If it isn't, it must be a "FIND NEXT" 
     statement or an "ON LEAVE OF" statement. We are now only interested in the LEAVE and NEXT 
     statements */
  IF parserAttrGet(theNode, "statehead":U)<>"" THEN DO:
  
     /* raise a warning if the statement doesn't contain a block-label */
     IF parserNodeFirstChild(theNode,child) <> "BLOCK_LABEL":U THEN
        RUN PublishResult            (compilationunit,
                                      parserGetNodeFilename(theNode),
                                      parserGetNodeLine(theNode), 
                                      SUBSTITUTE("&1 should specify a blocklabel":T, parserGetNodeType(theNode)),
                                      rule_id).
  END.                      
    
  parserReleaseHandle(child).
    
END PROCEDURE.                            


