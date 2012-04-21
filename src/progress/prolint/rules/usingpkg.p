/* -----------------------------------------------------------------------------
   file    :  prolint/rules/usingpkg.p
   purpose :  discourage "USING package.*"
   -----------------------------------------------------------------------------

    Copyright (C) 2007 Jurjen Dijkstra

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
   --------------------------------------------------------------------------------- */
  
{prolint/core/ruleparams.i}  


   RUN searchNode            (hTopnode,           /* "Program_root" node          */
                              "InspectNode":U,    /* name of callback procedure   */
                              "USING":U).          /* list of nodetypes to search for */

RETURN.


PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             

   DEFINE VARIABLE child AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
   DEFINE VARIABLE typename AS CHARACTER NO-UNDO.
   
   /* check if USING is a statement */
   IF parserAttrGet(theNode, "statehead":U)<>"" THEN DO:
      child    = parserGetHandle().
      nodetype = parserNodeFirstChild(theNode, child).
      
      IF nodetype = "TYPE_NAME":U THEN DO:
         typename = parserGetNodeText(child).
         
         /* warn if typename ends with an asterisk. */
         IF SUBSTRING(typename,LENGTH(typename),1) = "*":U THEN  
            RUN PublishResult            (compilationunit,
                                          parserGetNodeFilename(theNode),
                                          parserGetNodeLine(theNode),
                                          'USING package, replace by USING type (without wildcards)':T,
                                          rule_id).
      END. 
      parserReleaseHandle(child).      
   END.
    
END PROCEDURE.                            


