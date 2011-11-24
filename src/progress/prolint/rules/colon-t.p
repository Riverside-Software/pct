/* -------------------------------------------------------------------------
   file    :  prolint/rules/colon-t.p
   by      :  Jurjen Dijkstra
   purpose :  dont use :T on strings that are not trimmed
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
   ------------------------------------------------------------------------- */
  
{prolint/core/ruleparams.i}  

RUN searchNode            (hTopnode,              /* "Program_root" node                 */
                           "InspectNode":U,       /* name of callback procedure          */
                           "QSTRING":U).          /* list of statements to search, ?=all */

RETURN.
                                                
                                                
PROCEDURE InspectNode :
  /* purpose: callback from searchNode.
              inspect the QSTRING node */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE thestring   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE quote       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE attrib      AS CHARACTER NO-UNDO.
                         
  ASSIGN 
    theString = parserGetNodeText(theNode)
    quote     = SUBSTRING(theString,1,1)
    attrib    = SUBSTRING(theString, R-INDEX(theString,quote) + 1).

  IF attrib<>":T":U THEN
     RETURN.

  theString = SUBSTRING(theString,2,R-INDEX(theString,quote) - 2).

  IF LENGTH(TRIM(theString)) = LENGTH(theString) THEN
     RETURN.

  /* make sure the warning isn't extremely long (but what is extreme?) */
  &SCOPED-DEFINE maxlen 30
  IF LENGTH(theString)>{&maxlen} THEN DO:
     theString = quote + SUBSTRING(theString,1,{&maxlen} - 5) + "...":U + quote + attrib.
  END.

  /* trouble in outputhandlers if the string spans a linefeed */
  theString=REPLACE(theString, "~n":U, " ":U).

  RUN PublishResult            (compilationunit,
                                parserGetNodeFilename(theNode),
                                parserGetNodeLine(theNode),
                                SUBSTITUTE("attrib :T will trim &1&2&1":T, quote,theString),
                                rule_id).

END PROCEDURE.                            
