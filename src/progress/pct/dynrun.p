USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.ObjectModelParser.
USING rssw.pct.IMainCallback.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE NEW SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO.
DEFINE NEW SHARED VARIABLE mainCallback AS IMainCallback NO-UNDO.
DEFINE VARIABLE noErrorOnQuit AS LOGICAL NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO INITIAL ?.

DEFINE TEMP-TABLE ttParams NO-UNDO
  FIELD key AS CHARACTER
  FIELD val AS CHARACTER.

FUNCTION getParameter RETURNS CHARACTER (k AS CHARACTER):
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
DEFINE VARIABLE zz   AS INTEGER     NO-UNDO.
DEFINE VARIABLE zz2  AS INTEGER     NO-UNDO.
DEFINE VARIABLE out1 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE out2 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE procOrClass AS LOGICAL NO-UNDO.

ASSIGN jsonParser = NEW ObjectModelParser().
ASSIGN configJson = CAST(jsonParser:ParseFile(SESSION:PARAMETER), JsonObject).

ASSIGN pctVerbose = configJson:getLogical("verbose").

// DB connections + aliases
ASSIGN dbEntries = configJson:GetJsonArray("databases").
DO zz = 1 TO dbEntries:Length ON ERROR UNDO, THROW:
  ASSIGN dbEntry = dbEntries:GetJsonObject(zz).
  RUN dbConnect (dbEntry).
  CATCH pErr AS Progress.Lang.Error:
    // TODO Some messages are just warnings. Example: 512 is for no-integrity mode
    DO zz2 = 1 TO pErr:NumMessages:
      MESSAGE pErr:GetMessage(zz2).
    END.
    RUN returnValue(14).
    QUIT.
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
DO zz = 1 TO prmEntries:Length:
  ASSIGN prmEntry = prmEntries:GetJsonObject(zz).
  DO ON ERROR UNDO, LEAVE:
    CREATE ttParams.
    ASSIGN ttParams.key = prmEntry:getCharacter("name")
           ttParams.val = prmEntry:getCharacter("value").
  END.
END.

if (configJson:getCharacter("callback") GT "":U) THEN DO:
  mainCallback = DYNAMIC-NEW configJson:getCharacter("callback") ().
  mainCallback:initialize().
END.

// Output parameters
ASSIGN outprmEntries = configJson:GetJsonArray("output").

IF configJson:getLogical("super") THEN DO:
  SESSION:ADD-SUPER-PROCEDURE(THIS-PROCEDURE).
END.

ASSIGN procOrClass = configJson:has("procedure").

// Execute procedure
IF pctVerbose THEN DO:
  IF procOrClass THEN
    MESSAGE SUBSTITUTE("RUN &1", configJson:getCharacter("procedure")).
  ELSE
    MESSAGE SUBSTITUTE("DYNAMIC-INVOKE('&1', 'main')", configJson:getCharacter("className")).
END.

RunBlock:
DO ON QUIT UNDO, RETRY:
  IF RETRY THEN DO:
    MESSAGE "QUIT statement found".
    IF noErrorOnQuit THEN i = 0. ELSE i = 66.
    LEAVE RunBlock.
  END.
  IF VALID-OBJECT(mainCallback) THEN
    mainCallback:beforeRun().
  IF NOT procOrClass THEN
    ASSIGN i = DYNAMIC-INVOKE(configJson:getCharacter("className"), 'main').
  ELSE IF (outprmEntries:Length EQ 0) THEN
    RUN VALUE(configJson:getCharacter("procedure")).
  ELSE IF (outprmEntries:Length EQ 1) THEN
    RUN VALUE(configJson:getCharacter("procedure")) (OUTPUT out1).
  ELSE IF (outprmEntries:Length EQ 2) THEN
    RUN VALUE(configJson:getCharacter("procedure")) (OUTPUT out1, OUTPUT out2).
  CATCH pAppErr AS Progress.Lang.AppError:
    ASSIGN i = 1.
    MESSAGE pAppErr:ReturnValue.
    DO zz2 = 1 TO pAppErr:NumMessages:
      MESSAGE pAppErr:GetMessage(zz2).
    END.
  END.
  CATCH pErr AS Progress.Lang.Error:
    ASSIGN i = 1.
    DO zz2 = 1 TO pErr:NumMessages:
      MESSAGE pErr:GetMessage(zz2).
    END.
  END.
END.
IF (i EQ ?) THEN
  ASSIGN i = INTEGER (ENTRY(1, RETURN-VALUE, " ")) NO-ERROR.
IF (i EQ ?) THEN
  ASSIGN i = 1.
IF VALID-OBJECT(mainCallback) THEN
  mainCallback:afterRun(i).
RUN returnValue(i).

IF (outprmEntries:Length GE 1) THEN
  RUN writeOutputParam (out1, outprmEntries:getCharacter(1)).
IF (outprmEntries:Length GE 2) THEN
  RUN writeOutputParam (out2, outprmEntries:getCharacter(2)).

QUIT.

PROCEDURE returnValue PRIVATE:
  DEFINE INPUT PARAMETER retVal AS INTEGER NO-UNDO.

  IF pctVerbose THEN
    MESSAGE SUBSTITUTE("Return value : &1", retVal).
  OUTPUT TO VALUE(configJson:getCharacter("returnValue")) CONVERT TARGET "utf-8".
  PUT UNFORMATTED retVal SKIP.
  OUTPUT CLOSE.

END PROCEDURE.

PROCEDURE writeOutputParam PRIVATE:
  DEFINE INPUT PARAMETER prm AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER outFile AS CHARACTER NO-UNDO.

  IF pctVerbose THEN
    MESSAGE SUBSTITUTE("OUTPUT PARAMETER : &1", prm).
  OUTPUT TO VALUE(outFile) CONVERT TARGET "utf-8".
  PUT UNFORMATTED prm SKIP.
  OUTPUT CLOSE.

END PROCEDURE.

PROCEDURE dbConnect:
  DEFINE INPUT PARAMETER dbEntry AS JsonObject NO-UNDO.

  DEFINE VARIABLE connectStr AS CHARACTER NO-UNDO.
  DEFINE VARIABLE osCmdOut   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE xx AS INTEGER     NO-UNDO.

  IF (dbEntry:getCharacter("passphrase") EQ "cmdline") THEN DO:
    MESSAGE "Executing passphrase command line: " + dbEntry:getCharacter("cmd").
    INPUT THROUGH VALUE(dbEntry:getCharacter("cmd")).
    IMPORT UNFORMATTED osCmdOut.
    INPUT CLOSE.
  END.
  IF pctVerbose THEN
    MESSAGE "Connecting to '" + dbEntry:getCharacter("connect") + "'".
  IF (dbEntry:getCharacter("passphrase") EQ "cmdline") THEN DO:
    ASSIGN connectStr = SUBSTITUTE('&1 -KeyStorePassPhrase "&2"', dbEntry:getCharacter("connect"), osCmdOut).
  END.
  ELSE DO:
    ASSIGN connectStr = dbEntry:getCharacter("connect").
  END.
  CONNECT VALUE(connectStr).
  DO xx = 1 TO dbEntry:getJsonArray("aliases"):Length:
    IF pctVerbose THEN
      MESSAGE SUBSTITUTE("Creating alias &1 for database #&2 &3", dbEntry:getJsonArray("aliases"):getCharacter(xx), zz, LDBNAME(zz)).
    CREATE ALIAS VALUE(dbEntry:getJsonArray("aliases"):getCharacter(xx)) FOR DATABASE VALUE(LDBNAME(zz)).
  END.
END PROCEDURE.
