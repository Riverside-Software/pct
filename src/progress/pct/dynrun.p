USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.ObjectModelParser.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE NEW SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO.
DEFINE VARIABLE noErrorOnQuit AS LOGICAL NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO INITIAL ?.

DEFINE TEMP-TABLE ttParams NO-UNDO
  FIELD key AS CHARACTER
  FIELD val AS CHARACTER.

FUNCTION getParameter RETURNS CHARACTER (k AS CHARACTER).
  FIND ttParams WHERE ttParams.key EQ k NO-LOCK NO-ERROR.
  RETURN (IF AVAILABLE ttParams THEN ttParams.val ELSE ?).
END FUNCTION.

DEFINE VARIABLE jsonParser AS CLASS ObjectModelParser NO-UNDO.
DEFINE VARIABLE configJson AS CLASS JsonObject NO-UNDO.

ASSIGN jsonParser = NEW ObjectModelParser().
ASSIGN configJson = CAST(jsonParser:ParseFile(SESSION:PARAMETER), JsonObject).

pctVerbose = configJson:getLogical("verbose").

DEFINE VARIABLE ppEntries AS CLASS JsonArray NO-UNDO.
DEFINE VARIABLE zz AS INTEGER     NO-UNDO.
ASSIGN ppEntries = configJson:GetJsonArray("propath").
DO zz = 1 TO ppEntries:Length:
    IF pctverbose THEN MESSAGE "ajout : " + ppEntries:getCharacter(zz).

    

  ASSIGN PROPATH = ppEntries:getCharacter(zz) + "," + PROPATH.
END.

IF pctVerbose THEN MESSAGE "PROPATH : " + PROPATH.
IF pctVerbose THEN MESSAGE "RUN " + configJson:getCharacter("procedure").

RunBlock:
DO ON QUIT UNDO, RETRY:
  IF RETRY THEN DO:
    MESSAGE "QUIT statement found".
    IF noErrorOnQuit THEN i = 0. ELSE i = 66.
    LEAVE RunBlock.
  END.
  RUN VALUE(configJson:getCharacter("procedure")) NO-ERROR.
END.
IF ERROR-STATUS:ERROR THEN ASSIGN i = 1.
IF (i EQ ?) THEN ASSIGN i = INTEGER (ENTRY(1, RETURN-VALUE, " ")) NO-ERROR.
IF (i EQ ?) THEN ASSIGN i = 1.
RUN returnValue(i).

PROCEDURE returnValue PRIVATE.
  DEFINE INPUT PARAMETER retVal AS INTEGER NO-UNDO.
  IF pctVerbose THEN MESSAGE SUBSTITUTE("Return value : &1", retVal).
  OUTPUT TO VALUE(configJson:getCharacter("returnValue")) CONVERT TARGET "utf-8".
  PUT UNFORMATTED retVal SKIP.
  OUTPUT CLOSE.
END PROCEDURE.
