/* -----------------------------------------------------------------------------
   file    :  prolint/rules/########_1.p
   purpose :  ########_2
   -----------------------------------------------------------------------------

    Copyright (C) 2003 ########_3

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

/* TODO:
   Please complete the header (this is a legal requirement for LPGL):
     - ########_1 : the filename of this sourcefile
     - ########_2 : a description of what this sourcefile does
     - ########_3 : please put your name in the copyright notice
*/


/* TODO:
   uncomment in case you need a list of every procedure, function or trigger:

{prolint/core/ttprocedure.i}
    run ProcedureListGet in hLintSuper (output table tt_procedure).
*/


   RUN searchNode            (hTopnode,           /* "Program_root" node          */
                              "InspectNode":U,    /* name of callback procedure   */
                              "RUN":U).           /* list of nodetypes to search for */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE child    AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.

   ASSIGN
     child       = parserGetHandle()
     nodetype    = parserNodeFirstChild(theNode,child).

   /* TODO:
      Add code here to examine the nodes for the problem
      and test any other relevant conditions.
      See existing rule for examples.
   */

   
   /* TODO:
      Publish a warning to every running outputhandler when appropriate.
      Replace ########_4 by the real message text.
   */
   IF nodetype<>"FILENAME" /* TODO: replace by a sensible condition */ THEN
      RUN PublishResult            (compilationunit,
                                    parserGetNodeFilename(theNode),
                                    parserGetNodeLine(theNode),
                                    "########_4":T,
                                    rule_id).

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(child).
    
END PROCEDURE.                            


