/* ------------------------------------------------------------------------
   file    :  prolint/rules/i18nlength.p
   by      :  John Green
              adapted for prolint by Jurjen Dijkstra
   purpose :  Find LENGTH, OVERLAY, and SUBSTRING function calls which do not
              provide the second "type" parameter: "CHARACTER," "RAW," or 
              "COLUMN". This second parameter is necessary for ensuring that
              your code is unicode ready.
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 John Green

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

DEFINE VARIABLE currfunc AS CHARACTER NO-UNDO.
DEFINE VARIABLE funcslist AS CHARACTER NO-UNDO
  INITIAL "LENGTH,OVERLAY,SUBSTRING":U.
DEFINE VARIABLE i AS INTEGER NO-UNDO.

DO i = 1 TO NUM-ENTRIES(funcslist):
  ASSIGN currfunc = ENTRY(i, funcslist).
  RUN searchNode            (hTopnode,                /* "Program_root" node                 */
                             "InspectNode":U,         /* name of callback procedure          */
                             currfunc).               /* list of statements to search, ?=all */
END.

RETURN.

PROCEDURE InspectNode:
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.

  DEFINE VARIABLE child       AS INTEGER NO-UNDO.
  DEFINE VARIABLE numChildren AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.

  ASSIGN
    SearchChildren = TRUE  /* a LENGTH function may contain an expression that 
                              contains more LENGTH functions */
    child          = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child)
    numChildren    = 0.
      
  DO WHILE nodetype<>"":
    ASSIGN 
      numChildren = numChildren + 1
      nodetype    = parserNodeNextSibling(child,child).
  END.
    

  IF currfunc = "LENGTH":U THEN DO:
    /* LENGTH: Expecting children: LEFTPAREN expression COMMA expression RIGHTPAREN
     * Anything less than 5 children means there's no "type" parameter.
     */
    IF numChildren < 5 THEN
      RUN PublishResult            (compilationunit,
                                    parserGetNodeFilename(theNode),
                                    parserGetNodeLine(theNode),
                                    SUBSTITUTE("&1 function called without TYPE parameter":T,currfunc),
                                    rule_id).
  END.
  ELSE DO:
    /* OVERLAY and SUBSTRING
     * SUBSTRING syntax is: ( source , position [ , length [ , type ] ] )
     * OVERLY syntax is: ( target , position [ , length [ , type ] ] )
     * We only insist on "type" if "length" is being used.
     * OVERLAY is a dual-purpose keyword. If it doesn't have any children,
     * it's not being used as a function. That's not a concern, because we
     * only examine it if it has > 5 children anyway.
     */
    IF numChildren > 5 AND numChildren < 8 THEN
       RUN PublishResult            (compilationunit,
                                     parserGetNodeFilename(theNode),
                                     parserGetNodeLine(theNode),
                                     SUBSTITUTE("&1 function called without TYPE parameter":T,currfunc),
                                     rule_id).
  END.

  parserReleaseHandle(child).
    
END.

