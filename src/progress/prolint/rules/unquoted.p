/* -----------------------------------------------------------------------------
   file    :  prolint/rules/unquoted.p
   purpose :  find string literals that have no quotes around them
   -----------------------------------------------------------------------------

    Copyright (C) 2003 Jurjen Dijkstra

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

   RUN searchNode            (hTopnode,             /* "Program_root" node          */
                              "InspectFilename":U,  /* name of callback procedure   */
                              "FILENAME":U).  /* list of nodetypes to search for */

   RUN searchNode            (hTopnode,             /* "Program_root" node          */
                              "ReportUNQString":U,  /* name of callback procedure   */
                              "UNQUOTEDSTRING":U).  /* list of nodetypes to search for */
                              
RETURN.

PROCEDURE InspectFilename :
/* OUTPUT TO variablename.
   It looks like variablename is a variable, but it isn't. This is confusing. */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.

   DEFINE VARIABLE parentnode AS INTEGER NO-UNDO.
   DEFINE VARIABLE txt AS CHARACTER NO-UNDO.

   ASSIGN
     parentnode = parserGetHandle()
     txt = parserGetNodeText(theNode).

   /* FILENAME is supposed to be quoted, like in
         OUTPUT TO tempfile.
      But make an exception for RUN procname  (procname is a FILENAME node).
      There are two cases:
        1. RUN is parentnode of FILENAME
        2. RUN is PrevSibling of FILENAME
      example of the second case:
         ON DEL OF hGrid PERSISTENT RUN Grid-RowDelete IN THIS-PROCEDURE.
   */

   IF NOT (parserNodeStateHead(theNode, ParentNode)="RUN":U OR
           parserNodePrevSibling(theNode, ParentNode)="RUN":U) THEN
      IF NOT (SUBSTRING(txt,1,1)='"':U OR SUBSTRING(txt,1,1)="'":U) THEN
         RUN PublishResult            (compilationunit,
                                       parserGetNodeFilename(theNode),
                                       parserGetNodeLine(theNode),
                                       SUBSTITUTE("unquoted string: &1":T, txt),
                                       rule_id).
   parserReleaseHandle(parentnode).
                                    
END PROCEDURE.


PROCEDURE ReportUNQString :
/* sometimes 4GL accepts strings without quotes. Especially radio-set buttons */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.

   RUN PublishResult            (compilationunit,
                                 parserGetNodeFilename(theNode),
                                 parserGetNodeLine(theNode),
                                 SUBSTITUTE("unquoted string: &1":T, parserGetNodeText(theNode)),
                                 rule_id).

END PROCEDURE.


