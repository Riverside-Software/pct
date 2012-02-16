/* -----------------------------------------------------------------------------
   file    :  prolint/rules/where-cando.p
   purpose :  Find WHERE clauses which contain a CAN-DO function
   -----------------------------------------------------------------------------

    Copyright (C) 2007 Tim Townsend

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

&global-define Node int


   RUN searchNode            (hTopnode,           /* "Program_root" node          */
                              "InspectNode":U,    /* name of callback procedure   */
                              "WHERE":U).         /* list of nodetypes to search for */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   def input  parameter theNode        as {&Node} no-undo.
   def output parameter AbortSearch    as log     no-undo init false.
   def output parameter SearchChildren as log     no-undo init true.
                             
   def var iiNumResults    as int          no-undo.
   def var inParent        as {&Node}      no-undo.
   def var icTableName     as char         no-undo.
   def var icTableType     as char         no-undo.

   iiNumResults = parserQueryCreate(theNode,
                                    "QueryCando":u,
                                    "CANDO":u).

   parserQueryClear("QueryCando":u).

   /* Strictly speaking we are only concerned if a db field is a parameter to the
      can-do function, but for simplicity we will report them all.  It's unlikely
      can-do would be used in a where phrase in any other way. */
   if iiNumResults > 0 then do:
       inParent       = parserGetHandle().
       parserNodeParent(theNode,inParent).
       icTableType = parserAttrGet(inParent,"storetype").
       icTableName = parserGetNodeText(inParent).
       if icTableType = "" or icTableType = "st-dbtable" then
          run PublishResult (compilationunit,
                             parserGetNodeFilename(theNode),
                             parserGetNodeLine(theNode), 
                             substitute("CAN-DO Function used in WHERE clause for table &1":T,icTableName),
                             rule_id).
   end.

   return.
END PROCEDURE.                            


