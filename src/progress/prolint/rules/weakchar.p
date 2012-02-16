/* ------------------------------------------------------------------------
   file    :  prolint/rules/weakchar.p
   by      :  Jurjen Dijkstra
   purpose :  Greg Higgins' weak character test as discussed on Peg
    -----------------------------------------------------------------

    Copyright (C) 2004 Jurjen Dijkstra

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

RUN searchNode            (hTopnode,               /* "Program_root" node          */
                           "InspectNode":U,        /* name of callback procedure   */
                           "IF,WHEN,WHILE":U).     /* list of nodetypes to search  */

RETURN.



FUNCTION CheckedForUnknownvalue RETURNS LOGICAL (topnode AS INTEGER, fieldname AS CHARACTER, operatortype AS character):

  DEFINE VARIABLE retval        AS LOGICAL NO-UNDO INITIAL FALSE.
  DEFINE VARIABLE numResults    AS INTEGER NO-UNDO.
  DEFINE VARIABLE i             AS INTEGER NO-UNDO.
  DEFINE VARIABLE node          AS INTEGER NO-UNDO.
  DEFINE VARIABLE operatornode  AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype      AS CHARACTER NO-UNDO.

  node       = parserGetHandle().
  numResults = parserQueryCreate(topnode, "query_?":U, "UNKNOWNVALUE":U).
  DO i=1 TO numResults :
     IF parserQueryGetResult("query_?":U, i, node) THEN DO:
        operatornode = parserGetHandle().
        IF parserNodeParent(node,operatornode) = operatortype THEN DO:
           nodetype = parserNodeFirstChild(operatornode, node).
           DO WHILE nodetype<>"Field_ref":U AND nodetype>"":
              nodetype = parserNodeNextSibling(node, node).
           END.
           IF nodetype="Field_ref":U THEN DO:
              IF fieldname = GetFieldnameFromFieldref(node) THEN
                 retval = TRUE.
           END.
           ELSE DO:
              /* no fieldname? maybe it was return-value, or a function call */
              nodetype = parserNodeFirstChild(operatornode, node).
              DO WHILE nodetype="QSTRING":U AND nodetype>"":
                 nodetype = parserNodeNextSibling(node, node).
              END.
              IF nodetype>"":U THEN
                 fieldname = parserGetNodeText(node).
           END.
        END.
        parserReleaseHandle(operatornode).
     END.
  END.
  parserQueryClear("query_?":U).
  parserReleaseHandle(node).

  RETURN retval.
END.


PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  define variable nodetype      as character no-undo.
  define variable expressiontop as INTEGER   no-undo.  /* topnode of the boolean expression */
  DEFINE VARIABLE numResults    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE i             AS INTEGER   NO-UNDO.
  DEFINE VARIABLE node          AS INTEGER   NO-UNDO.
  DEFINE VARIABLE theString     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE quote         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE strlen        AS INTEGER   NO-UNDO.
  DEFINE VARIABLE operatornode  AS INTEGER   NO-UNDO.
  DEFINE VARIABLE operatortype  AS character NO-UNDO.
  DEFINE VARIABLE fieldname     AS CHARACTER NO-UNDO.

  ASSIGN expressiontop = parserGetHandle()
         node          = parserGetHandle()
         operatornode  = parserGetHandle()
         nodetype      = parserNodeFirstChild(theNode,expressiontop).

  /* find something like  fieldname=""  */
  /*   or something like  fieldname<>"" */

  /* first query the expression to see if there is an empty string in it */
  numResults = parserQueryCreate(expressiontop, "query_qstring":U, "QSTRING":U).
  DO i=1 TO numResults :
     IF parserQueryGetResult("query_qstring":U, i, node) THEN DO:
        theString = parserGetNodeText(node).
        /* is theString the empty string (like "''" or '""') ? */
        quote  = SUBSTRING(theString, 1,1).
        strlen = R-INDEX(theString, quote) - 2.
        theString = TRIM(SUBSTRING(theString, 2, strlen)).
        IF theString = "" THEN DO:
           /* what is the type of the operator? */
           operatortype = parserNodeParent(node,operatornode).
           IF operatortype="EQ":U OR operatortype="NE":U THEN DO:

              /* ok we already have a red flag! To supress false positives we must now
                 test if the same expression also contains a sub-expression involving the
                 same fieldname, the same operator and UNKNOWNVALUE, because this is ok:
                     not (fieldname = "" or fieldname=?)
                     fieldname<>"" and fieldname<>?
              */

              /* what is the name of the field? */
              /* find the childnode of operatornode that is of type "Field_ref" */
              nodetype = parserNodeFirstChild(operatornode, node).
              DO WHILE nodetype<>"Field_ref":U AND nodetype>"":
                 nodetype = parserNodeNextSibling(node, node).
              END.
              IF nodetype="Field_ref":U THEN
                 fieldname = GetFieldnameFromFieldref(node).
              ELSE DO:
                 /* no fieldname? maybe it was return-value, or a function call */
                 nodetype = parserNodeFirstChild(operatornode, node).
                 DO WHILE nodetype="QSTRING":U AND nodetype>"":
                    nodetype = parserNodeNextSibling(node, node).
                 END.
                 IF nodetype>"":U THEN
                    fieldname = parserGetNodeText(node).
              END.

              /* now check if the same expression also contains a sub-expression
                 with the same fieldname and the same operator and UNKNOWNVALUE. */
              IF NOT CheckedForUnknownvalue (expressiontop, fieldname, operatortype) THEN
                 RUN PublishResult            (compilationunit,
                                               parserGetNodeFilename(theNode),
                                               parserGetNodeLine(theNode),
                                               SUBSTITUTE("weak character test for &1":T, fieldname),
                                               rule_id).

           END.
        END.
     END.
  END.
  parserQueryClear("query_qstring":U).

  parserReleaseHandle(operatornode).
  parserReleaseHandle(node).
  parserReleaseHandle(expressiontop).

END PROCEDURE.

