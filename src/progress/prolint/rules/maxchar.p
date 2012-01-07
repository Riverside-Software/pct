/* -------------------------------------------------------------------------
   file    :  prolint/rules/maxchar.p
   by      :  Jurjen Dijkstra
   purpose :  Translation Manager cannot accept QSTRINGS longer that 188
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
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL FALSE.
  
  DEFINE VARIABLE thestring   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE quote       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE attrib      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE strlen      AS INTEGER   NO-UNDO.
                         
  ASSIGN 
    theString = parserGetNodeText(theNode)
    quote     = SUBSTRING(theString,1,1)
    strlen    = R-INDEX(theString, quote) - 2
    attrib    = SUBSTRING(theString, R-INDEX(theString,quote) + 2).

  IF (attrib MATCHES "U*":U) OR (strlen<188) THEN RETURN.

  RUN PublishResult            (compilationunit,
                                parserGetNodeFilename(theNode),
                                parserGetNodeLine(theNode),
                                "String constant too long for Tranman (max 188)":T,
                                rule_id).
END PROCEDURE.
