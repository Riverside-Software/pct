/* ------------------------------------------------------------------------
   file    :  rules/fnusage.p
   by      :  Igor Natanzon
   purpose :  Locate unused internal functions and unused external function
              prototypes.
    -----------------------------------------------------------------

    Copyright (C) 2001-2004 Igor Natanzon

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
{prolint/core/ttprocedure.i}

DEFINE TEMP-TABLE tt-functionDefine NO-UNDO
    FIELD functionName    AS CHARACTER
    FIELD functionLine    AS INTEGER
    FIELD functionFile    AS CHARACTER
    FIELD isPrototype     AS LOGICAL
    FIELD isInternal      AS LOGICAL
    FIELD isPrivate       AS LOGICAL
    FIELD isUsed          AS LOGICAL
    INDEX functionName IS PRIMARY functionName
    INDEX isUsed isUsed.

RUN searchNode            (hTopnode, "InspectFunctionDefine":U, "FUNCTION":U).
RUN searchNode            (hTopnode, "InspectFunctionCall":U,   "USER_FUNC":U).

RUN p_report.

RETURN.


PROCEDURE InspectFunctionDefine :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE child          AS INTEGER   NO-UNDO.
  DEFINE VARIABLE childtype      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-functionName AS CHARACTER NO-UNDO.

  ASSIGN child     = parserGetHandle()
         childtype = parserNodeFirstChild(theNode,child).

  DO WHILE childtype NE "":
     CASE childtype:
          WHEN "ID":U THEN DO:
               v-functionName = TRIM(parserGetNodeText(child)).
               FIND tt-functionDefine WHERE
                    tt-functionDefine.functionName EQ v-functionName NO-ERROR.
               IF NOT AVAILABLE tt-functionDefine THEN DO:
                  CREATE tt-functionDefine.
                  ASSIGN tt-functionDefine.functionLine = parserGetNodeLine(child)
                         tt-functionDefine.functionFile = parserGetNodeFilename(child)
                         tt-functionDefine.functionName = v-functionName.
               END.
          END.
          WHEN "FORWARDS":U   OR
          WHEN "IN":U         THEN tt-functionDefine.isPrototype = TRUE.
          WHEN "PRIVATE":U    THEN tt-functionDefine.isPrivate   = TRUE.
          WHEN "Code_Block":U THEN tt-functionDefine.isInternal  = TRUE.
     END CASE.
     childtype = parserNodeNextSibling(child,child).
  END.
  parserReleaseHandle(child).
END PROCEDURE. /* InspectFunctionDefine */

PROCEDURE InspectFunctionCall :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE v-functionName AS CHARACTER NO-UNDO.

  v-functionName = TRIM(parserGetNodeText(theNode)).

  FIND first tt-functionDefine WHERE
       tt-functionDefine.functionName EQ v-functionName NO-ERROR.

  IF AVAILABLE tt-functionDefine THEN
     tt-functionDefine.isUsed = TRUE.

END PROCEDURE. /* InspectFunctionCall */

PROCEDURE p_report PRIVATE:

  FOR EACH tt-functionDefine WHERE tt-functionDefine.isUsed EQ FALSE:

      /* Internal Private Function defined, but not used */

      IF tt-functionDefine.isInternal EQ TRUE AND tt-functionDefine.isPrivate EQ TRUE THEN
         RUN PublishResult            (compilationunit,
                                       tt-functionDefine.functionFile,
                                       tt-functionDefine.functionLine,
                                       SUBSTITUTE("&1 Function &2() is not called in current program",
                                          IF tt-functionDefine.isPrivate EQ FALSE THEN "PUBLIC" ELSE "PRIVATE",
                                          tt-functionDefine.functionName),rule_id).

      /* External Function prototyped but not used */
      ELSE IF tt-functionDefine.isInternal EQ FALSE THEN
         RUN PublishResult            (compilationunit,
                                       tt-functionDefine.functionFile,
                                       tt-functionDefine.functionLine,
                                       SUBSTITUTE("External Function &1() is prototyped but not called in current program",
                                          tt-functionDefine.functionName),rule_id).
  END.
END PROCEDURE.  /* p_report */

/* End Program */