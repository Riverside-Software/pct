/* ------------------------------------------------------------------------
   file    :  prolint/rules/dotcomment.p
   by      :  Jurjen Dijkstra
   purpose :  find statements that begin with a PERIOD

   These dot comments are usually a typo, and should be replaced with regular
   comments.
   -----------------------------------------------------------------

    Copyright (C) 2001,2002,2006 Jurjen Dijkstra, John Green

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

DEFINE VARIABLE TheNode     AS INTEGER NO-UNDO.
DEFINE VARIABLE NextSibling AS INTEGER NO-UNDO.
DEFINE VARIABLE numResults  AS INTEGER NO-UNDO.
DEFINE VARIABLE i           AS INTEGER NO-UNDO.


IF parserGetVersion() > "3" THEN
   /*
   example source:
      .MESSAGE "b".

   The '.' in front of "MESSAGE" causes the entire statement to be commented.
   (The comment extends to the next regular '.')
   Proparse recognizes these, and turns the entire comment into a DOT_COMMENT
   node. These nodes are only found in the syntax where a statement can be
   found. (i.e. You can't have a dot comment in the middle of a statement.)
   
   */
    RUN searchNode (
          hTopnode               /* "Program_root" node */
          , "InspectNode":U      /* name of callback procedure */
          , "DOT_COMMENT":U      /* list of statements to search, ?=all */
         ).

ELSE DO:

   /*
   How it works:
       example source:

          MESSAGE "a".
          .MESSAGE "b".

       tokenlister:
          MESSAGE  MESSAGE (statehead)
             QSTRING "a"
             PERIOD .
          PERIOD .
          MESSAGE  MESSAGE (statehead)
             QSTRING "b"
             PERIOD .

   so we are looking for a PERIOD with a NextSibling if this NextSibling
   is a statehead.
   */

    /* Make it fast: there are lots of PERIOD nodes in the source.
       So, unlike other rules we don't use procedure searchNode.
       Just open a query, less overhead. This means we are not
       going to check for _proparse_ prolint-nowarn(dotcomment) */

    ASSIGN
      TheNode     = parserGetHandle()
      NextSibling = parserGetHandle()
      numResults  = parserQueryCreate(hTopnode, "dotcomment":U, "PERIOD":U).

    DO i=1 TO numResults :
       IF parserQueryGetResult("dotcomment":U, i, theNode) THEN DO:

           /* is there a NextSibling? */
           IF ""<>parserNodeNextSibling(theNode, NextSibling) THEN
              /* there should be no whitespace following the PERIOD */
              IF NOT parserHiddenGetBefore(NextSibling) THEN
                 /* is this NextSibling a statement head? */
                 IF parserAttrGet(NextSibling, "statehead":U) <> "" THEN
                    /* check if there is NO _proparse_ directive */
                    IF 0=parserAttrGetI(theNode,pragma_number) THEN
                       RUN PublishResult            (compilationunit,
                                                     parserGetNodeFilename(theNode),
                                                     parserGetNodeLine(theNode),
                                                     "PERIOD comments a statement":U,
                                                     rule_id).
   
       END.
    END.

    parserQueryClear("dotcomment":U).
    parserReleaseHandle(TheNode).
    parserReleaseHandle(NextSibling).

END.

PROCEDURE InspectNode:
  /* purpose: Simply report all DOT_COMMENT nodes. */

  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  RUN PublishResult (
    compilationunit
    , parserGetNodeFilename(theNode)
    , parserGetNodeLine(theNode)
    , "PERIOD comments a statement":T
    , rule_id
    ).

END PROCEDURE.


