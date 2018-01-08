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

DEFINE VARIABLE ppEntries AS CLASS JsonArray NO-UNDO.
DEFINE VARIABLE dbEntries AS CLASS JsonArray NO-UNDO.
DEFINE VARIABLE dbEntry   AS CLASS JsonObject NO-UNDO.
DEFINE VARIABLE prmEntries AS CLASS JsonArray NO-UNDO.
DEFINE VARIABLE prmEntry   AS CLASS JsonObject NO-UNDO.
DEFINE VARIABLE outprmEntries AS CLASS JsonArray NO-UNDO.
DEFINE VARIABLE zz AS INTEGER     NO-UNDO.
DEFINE VARIABLE xx AS INTEGER     NO-UNDO.
DEFINE VARIABLE out1 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE out2 AS CHARACTER   NO-UNDO.

ASSIGN jsonParser = NEW ObjectModelParser().
ASSIGN configJson = CAST(jsonParser:ParseFile(SESSION:PARAMETER), JsonObject).

ASSIGN pctVerbose = configJson:getLogical("verbose").

// DB connections + aliases
ASSIGN dbEntries = configJson:GetJsonArray("databases").
DO zz = 1 TO dbEntries:Length:
  ASSIGN dbEntry = dbEntries:GetJsonObject(zz).
  IF pctVerbose THEN
    MESSAGE "Connecting to '" + dbEntry:getCharacter("connect") + "'".
  CONNECT VALUE(dbEntry:getCharacter("connect")) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Unable to connect to '" + dbEntry:getCharacter("connect") + "'".
    DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
      MESSAGE ERROR-STATUS:GET-MESSAGE(i).
    END.
    RUN returnValue(14).
    QUIT.
  END.
  DO xx = 1 TO dbEntry:getJsonArray("aliases"):Length:
    IF pctVerbose THEN
      MESSAGE SUBSTITUTE("Creating alias &1 for database #&2 &3", dbEntry:getJsonArray("aliases"):getCharacter(xx),
                         zz, LDBNAME(zz)).
    CREATE ALIAS VALUE(dbEntry:getJsonArray("aliases"):getCharacter(xx)) FOR DATABASE VALUE(LDBNAME(zz)) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE SUBSTITUTE("Unable to create alias '&1' for database '&2'",
                         dbEntry:getJsonArray("aliases"):getCharacter(xx), LDBNAME(zz)).
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(i).
      END.
      RUN returnValue(15).
      QUIT.
    END.
  END.
END.

// PROPATH entries
ASSIGN ppEntries = configJson:GetJsonArray("propath").
DO zz = 1 TO ppEntries:Length:
    ASSIGN PROPATH = ppEntries:getCharacter(zz) + "," + PROPATH.
END.
IF pctVerbose THEN
  MESSAGE "PROPATH : " + PROPATH.

// Input parameters
ASSIGN prmEntries = configJson:GetJsonArray("parameters").
DO zz = 1 TO dbEntries:Length:
  ASSIGN prmEntry = prmEntries:GetJsonObject(zz).
  DO ON ERROR UNDO, LEAVE:
    CREATE ttParams.
    ASSIGN ttParams.key = prmEntry:getCharacter("name")
           ttParams.val = prmEntry:getCharacter("value").
  END.
END.

// Output parameters
ASSIGN outprmEntries = configJson:GetJsonArray("output").

// Execute procedure
IF pctVerbose THEN
  MESSAGE "RUN " + configJson:getCharacter("procedure").
RunBlock:
DO ON QUIT UNDO, RETRY:
  IF RETRY THEN DO:
    MESSAGE "QUIT statement found".
    IF noErrorOnQuit THEN i = 0. ELSE i = 66.
    LEAVE RunBlock.
  END.
  IF (outprmEntries:Length EQ 0) THEN
    RUN VALUE(configJson:getCharacter("procedure")) NO-ERROR.
  ELSE IF (outprmEntries:Length EQ 1) THEN
    RUN VALUE(configJson:getCharacter("procedure")) (OUTPUT out1) NO-ERROR.
  ELSE IF (outprmEntries:Length EQ 2) THEN
    RUN VALUE(configJson:getCharacter("procedure")) (OUTPUT out1, OUTPUT out2) NO-ERROR.
END.
IF ERROR-STATUS:ERROR THEN
  ASSIGN i = 1.
IF (i EQ ?) THEN
  ASSIGN i = INTEGER (ENTRY(1, RETURN-VALUE, " ")) NO-ERROR.
IF (i EQ ?) THEN
  ASSIGN i = 1.
RUN returnValue(i).

IF (outprmEntries:Length GE 1) THEN
  RUN writeOutputParam (out1, outprmEntries:getCharacter(1)).
IF (outprmEntries:Length GE 2) THEN
  RUN writeOutputParam (out2, outprmEntries:getCharacter(2)).

QUIT.    

PROCEDURE returnValue PRIVATE.
  DEFINE INPUT PARAMETER retVal AS INTEGER NO-UNDO.

  IF pctVerbose THEN
    MESSAGE SUBSTITUTE("Return value : &1", retVal).
  OUTPUT TO VALUE(configJson:getCharacter("returnValue")) CONVERT TARGET "utf-8".
  PUT UNFORMATTED retVal SKIP.
  OUTPUT CLOSE.

END PROCEDURE.

PROCEDURE writeOutputParam PRIVATE.
  DEFINE INPUT PARAMETER prm AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER outFile AS CHARACTER NO-UNDO.

  IF pctVerbose THEN
    MESSAGE SUBSTITUTE("OUTPUT PARAMETER : &1", prm).
  OUTPUT TO VALUE(outFile) CONVERT TARGET "utf-8".
  PUT UNFORMATTED prm SKIP.
  OUTPUT CLOSE.

END PROCEDURE.
