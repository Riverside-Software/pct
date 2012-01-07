/** Provides backward compatability from old C++ API into new Proparse.Net.
 * DO NOT USE THIS FOR NEW CODE!
 * Anything using this old API can be made faster and cleaner by using
 * direct access to the classes and objects in Proparse.Net.
 *
 * June 2010 by John Green.
 *
 * Implementation notes:
 *   - I had trouble with method chaining (10.2A), so
 *     in some cases (especially for getNode) I use an intermediate variable.
 *   - I don't know why referencing something like NodeTypes:DISPLAY didn't work
 *     for me. It should have. I don't know if the problem comes from IKVM or OE,
 *     but whatever the case, I'm using ProParserTokenTypes for now. It's too bad OE
 *     doesn't offer typename aliases like C#, because ProParserTokenTypes is awful long.
 */

USING com.joanju.proparse.ProToken.
USING com.joanju.proparse.ProParserTokenTypes.
USING org.prorefactor.core.JPNode.
USING com.joanju.proparse.NodeTypes.
USING Progress.Lang.Error.
USING Progress.Lang.AppError.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEF VAR i AS INT NO-UNDO.
DEF VAR currHiddenToken AS CLASS ProToken.
DEF VAR parseUnit AS CLASS org.prorefactor.treeparser.ParseUnit.

DEF VAR errorCurrent AS LOGICAL NO-UNDO INITIAL FALSE.
DEF VAR errorStackTrace AS CHAR NO-UNDO INITIAL "".
DEF VAR errorStatus AS INT NO-UNDO INITIAL 0.
DEF VAR errorText AS CHAR NO-UNDO INITIAL "".
DEF VAR i1 AS INTEGER NO-UNDO.
DEF VAR isOK AS LOGICAL NO-UNDO.
DEF VAR nextHandleNum AS INT NO-UNDO INITIAL 101.


ON "CLOSE" OF THIS-PROCEDURE DO:
  DELETE PROCEDURE THIS-PROCEDURE.
END.


DEF VAR proparseEnv AS CLASS com.joanju.proparse.Environment NO-UNDO.
proparseEnv = com.joanju.proparse.Environment:instance().

DEF VAR proparseSchema AS CLASS org.prorefactor.core.schema.Schema NO-UNDO.
proparseSchema = org.prorefactor.core.schema.Schema:getInstance().

DEF VAR refactorSession AS CLASS org.prorefactor.refactor.RefactorSession NO-UNDO.
refactorSession = org.prorefactor.refactor.RefactorSession:getInstance().

DEF VAR backward AS CLASS org.proparse.api.Backward NO-UNDO.
backward = NEW org.proparse.api.Backward().

FUNCTION parserConfigSet RETURNS LOGICAL (theFlag AS CHARACTER, theValue AS CHARACTER) FORWARD.
FUNCTION parserGetHandle RETURNS INTEGER FORWARD.
FUNCTION parserGetSuperclassClassNode RETURNS CLASS org.prorefactor.core.JPNode
         (subclassClassNode AS CLASS org.prorefactor.core.JPNode) FORWARD.
FUNCTION parserSchemaAliasCreate RETURNS LOGICAL (aliasname AS CHARACTER, dbasename AS CHARACTER) FORWARD.
FUNCTION parserSchemaAliasDelete RETURNS LOGICAL (aliasname AS CHARACTER) FORWARD.

refactorSession:setContextDirName(SESSION:TEMP-DIRECTORY + "/").
parserConfigSet("batch-mode", STRING(SESSION:BATCH-MODE, "true/false")).
parserConfigSet("opsys", OPSYS).
parserConfigSet("propath", PROPATH).
parserConfigSet("proversion", PROVERSION).
parserConfigSet("window-system", SESSION:WINDOW-SYSTEM).

DEF VAR schemaDumpFile AS CHAR NO-UNDO.
proparseSchema:clear().
IF NUM-DBS > 0 THEN DO:
  schemaDumpFile = SESSION:TEMP-DIRECTORY + "proparse.schema".
  RUN prolint/proparse-shim/api/schemadump1.p (schemaDumpFile).
  proparseSchema:loadSchema(schemaDumpFile).
  OS-DELETE schemaDumpFile.
END.

parserSchemaAliasDelete("").
REPEAT i=1 TO NUM-ALIASES:
  IF ALIAS(i)>? AND LDBNAME(ALIAS(i))>? THEN
    parserSchemaAliasCreate(ALIAS(i),LDBNAME(ALIAS(i))).
END.


RETURN.




PROCEDURE clear PRIVATE:
  parseUnit = ?.
  currHiddenToken = ?.
  backward:clear().
END PROCEDURE.


FUNCTION parserAttrGet RETURNS CHARACTER (theHandle AS INTEGER, theKey AS CHARACTER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(theHandle).
  RETURN node:attrGetS(theKey).
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserAttrGetI RETURNS INTEGER (theHandle AS INTEGER, theKey AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(theHandle).
  IF theKey = 2100 THEN DO:
    node = parserGetSuperclassClassNode(node).
    IF node = ? THEN
      RETURN 0.
    DEF VAR hdl AS INT NO-UNDO.
    hdl = parserGetHandle().
    backward:setHandle(hdl, node).
    RETURN hdl.
  END. ELSE
    RETURN node:attrGet(theKey).
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END.


FUNCTION parserAttrSet RETURNS LOGICAL (theHandle AS INTEGER, theKey AS INTEGER, theValue AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(theHandle).
  node:attrSet(theKey, theValue).
  RETURN TRUE.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserAttrStringGet RETURNS CHARACTER (theHandle AS INTEGER, theKey AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(theHandle).
  RETURN node:attrGetS(theKey).
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserAttrStringSet RETURNS LOGICAL (theHandle AS INTEGER, theKey AS INTEGER, theValue AS CHARACTER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(theHandle).
  node:attrSet(theKey, theValue).
  RETURN TRUE.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserConfigGet RETURNS CHARACTER (theFlag AS CHARACTER):
  errorCurrent = FALSE.
  RETURN proparseEnv:configGet(theFlag).
  CATCH e AS Error: RUN raiseError(e). RETURN ?. END CATCH.
END.


FUNCTION parserConfigSet RETURNS LOGICAL (theFlag AS CHARACTER, theValue AS CHARACTER):
  errorCurrent = FALSE.
  proparseEnv:configSet(theFlag, theValue).
  RETURN TRUE.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserCopyHandle RETURNS LOGICAL (fromHandle AS INTEGER, toHandle AS INTEGER):
  errorCurrent = FALSE.
  backward:copyHandle(fromHandle, toHandle).
  RETURN TRUE.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserErrorClear RETURNS LOGICAL:
  errorText = "".
  errorStackTrace = "".
  errorStatus = 0.
  errorCurrent = FALSE.
  RETURN TRUE.
END.


FUNCTION parserErrorGetIsCurrent RETURNS LOGICAL:
  RETURN errorCurrent.
END.


FUNCTION parserErrorGetStackTrace RETURNS CHARACTER:
  RETURN errorStackTrace.
END.


FUNCTION parserErrorGetStatus RETURNS INTEGER:
  RETURN errorStatus.
END.


FUNCTION parserErrorGetText RETURNS CHARACTER:
  RETURN errorText.
END.


FUNCTION parserGetHandle RETURNS INTEGER:
  errorCurrent = FALSE.
  RETURN backward:getHandle().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetIndexFilename RETURNS CHARACTER (indexnum AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR filenames AS CHAR NO-UNDO EXTENT.
  filenames = parseUnit:getFileIndex().
  RETURN filenames[indexnum].
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


/** Get the JPNode for a handle.
 * Throws an exception if the handle is not valid.
 */
FUNCTION parserGetNode RETURNS CLASS JPNode (handleNum AS INT):
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(handleNum).
  IF VALID-OBJECT(node) THEN
    RETURN node.
  ELSE
    UNDO, THROW NEW AppError("Reference to invalid node handle", 0).
END FUNCTION.


FUNCTION parserGetNodeColumn RETURNS INTEGER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN node:getColumn().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetNodeFileIndex RETURNS INTEGER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN node:getFileIndex().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetNodeFilename RETURNS CHARACTER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN node:getFilename().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetNodeLine RETURNS INTEGER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN node:getLine().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetNodeText RETURNS CHARACTER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN node:getText().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetNodeType RETURNS CHARACTER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN NodeTypes:getTypeName(node:getType()). 
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetNodeTypeI RETURNS INTEGER (ofHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  RETURN node:getType().
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


/** For a subclass's CLASS node, return the superclass's CLASS node.
 * The old API did this for node attribute 2100 on a CLASS node.
 * From looking at the code, it appears that the old proparse.dll is rather
 * out of date, because it counted on CLASS being the first child of the
 * Program_root, which is no longer valid.
 * We can't just use JPNode.SUPER_CLASS_TREE, because it returns the
 * Program_root node. So, we need to do a little extra work.
 */
FUNCTION parserGetSuperclassClassNode RETURNS CLASS JPNode
         (subclassClassNode AS CLASS JPNode):
  DEF VAR node AS CLASS JPNode NO-UNDO.
  DEF VAR SUPER_CLASS_TREE AS CLASS java.lang.Integer NO-UNDO.
  SUPER_CLASS_TREE = NEW java.lang.Integer(JPNode:SUPER_CLASS_TREE).
  node = CAST(subclassClassNode:getLink(SUPER_CLASS_TREE), JPNode).
  IF node = ? THEN
    RETURN ?.
  RETURN node:findDirectChild(ProParserTokenTypes:CLASS).
END.


FUNCTION parserGetTokenTypeName RETURNS CHARACTER (tokenTypeNumber AS INTEGER):
  errorCurrent = FALSE.
  RETURN NodeTypes:getTypeName(tokenTypeNumber).
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserGetVersion RETURNS CHARACTER:
  errorCurrent = FALSE.
  RETURN "4.0.0".
  CATCH e AS Error: RUN raiseError(e). END CATCH.
END.


FUNCTION parserHiddenGetBefore RETURNS LOGICAL (nodeHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(nodeHandle).
  currHiddenToken = node:getHiddenBefore().
  RETURN currHiddenToken NE ?.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserHiddenGetColumn RETURNS INTEGER:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetColumn() called with no current hidden token", 0).
  RETURN currHiddenToken:getColumn().
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END.


FUNCTION parserHiddenGetFileNum RETURNS INTEGER:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetFilename() called with no current hidden token", 0).
  RETURN currHiddenToken:getFileIndex().
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END.


FUNCTION parserHiddenGetFirst RETURNS LOGICAL (nodeHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(nodeHandle).
  currHiddenToken = node:getHiddenFirst().
  RETURN currHiddenToken NE ?.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserHiddenGetLine RETURNS INTEGER:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetLine() called with no current hidden token", 0).
  RETURN currHiddenToken:getLine().
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END.


FUNCTION parserHiddenGetNext RETURNS LOGICAL:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetNext() called with no current hidden token", 0).
  ASSIGN currHiddenToken = currHiddenToken:getNext().
  RETURN currHiddenToken NE ?.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserHiddenGetPrevious RETURNS LOGICAL:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetPrevious() called with no current hidden token", 0).
  ASSIGN currHiddenToken = currHiddenToken:getPrev().
  RETURN currHiddenToken NE ?.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserHiddenGetText RETURNS CHARACTER:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetText() called with no current hidden token", 0).
  RETURN currHiddenToken:getText().
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserHiddenGetType RETURNS CHARACTER:
  errorCurrent = FALSE.
  IF NOT VALID-OBJECT(currHiddenToken) THEN 
      UNDO, THROW NEW AppError("hiddenGetText() called with no current hidden token", 0).
  RETURN NodeTypes:getTypeName(currHiddenToken:getType()).
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserIsSameNode RETURNS LOGICAL (handle1 AS INTEGER, handle2 AS INTEGER):
  errorCurrent = FALSE.
  RETURN backward:getNode(handle1):hashCode() EQ backward:getNode(handle2):hashCode().
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserIsValidNode RETURNS LOGICAL (theHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS JPNode NO-UNDO.
  node = backward:getNode(theHandle).
  RETURN VALID-OBJECT(node).
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserNodeFirstChild RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:firstChild().
  IF VALID-OBJECT(node) THEN DO:
    backward:setHandle(intoHandle, node).
    RETURN NodeTypes:getTypeName(node:getType()).
  END. ELSE
    RETURN "".
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserNodeFirstChildI RETURNS INTEGER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:firstChild().
  IF VALID-OBJECT(node) THEN DO:
    backward:setHandle(intoHandle, node).
    RETURN node:getType().
  END. ELSE
      RETURN 0.
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END.


FUNCTION parserNodeNextSibling RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:nextSibling().
  IF VALID-OBJECT(node) THEN DO:
    backward:setHandle(intoHandle, node).
    RETURN NodeTypes:getTypeName(node:getType()).
  END. ELSE
    RETURN "".
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserNodeNextSiblingI RETURNS INTEGER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:nextSibling().
  IF VALID-OBJECT(node) THEN DO:
    backward:setHandle(intoHandle, node).
    RETURN node:getType().
  END. ELSE
    RETURN 0.
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END.


FUNCTION parserNodeParent RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:parent().
  IF VALID-OBJECT(node) THEN DO:
    backward:setHandle(intoHandle, node).
    RETURN NodeTypes:getTypeName(node:getType()).
  END. ELSE
    RETURN "".
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserNodePrevSibling RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:prevSibling().
  IF VALID-OBJECT(node) THEN DO:
    backward:setHandle(intoHandle, node).
    RETURN NodeTypes:getTypeName(node:getType()).
  END. ELSE
    RETURN "".
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserNodeStateHead RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  DEF VAR node AS CLASS JPNode NO-UNDO.
  node = backward:getNode(ofHandle).
  node = node:parent().
  DO WHILE node NE ?:
    IF node:isStateHead() THEN DO:
      backward:setHandle(intoHandle, node).
      RETURN NodeTypes:getTypeName(node:getType()).
    END.
    node = node:parent().
  END.
  RETURN "".
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserNodeTop RETURNS CHARACTER (intoHandle AS INTEGER):
  errorCurrent = FALSE.
  backward:setHandle(intoHandle, parseUnit:getTopNode()).
  CATCH e AS Error: RUN raiseError(e). RETURN "". END CATCH.
END.


FUNCTION parserParse RETURNS LOGICAL (filename AS CHARACTER):
  errorCurrent = FALSE.
  RUN clear.
  DEF VAR javafile AS CLASS java.io.File.
  javafile = NEW java.io.File(filename).
  parseUnit = NEW org.prorefactor.treeparser.ParseUnit(javafile).
  parseUnit:treeParser01().
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserSchemaAliasCreate RETURNS LOGICAL (aliasname AS CHARACTER, dbasename AS CHARACTER):
  errorCurrent = FALSE.
  proparseSchema:aliasCreate(aliasname, dbasename).
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserSchemaAliasDelete RETURNS LOGICAL (aliasname AS CHARACTER):
  errorCurrent = FALSE.
  proparseSchema:aliasDelete(aliasname).
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserQueryClear RETURNS LOGICAL (queryName AS CHARACTER):
  errorCurrent = FALSE.
  backward:queryClear(queryName).
  RETURN TRUE.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserQueryCreate RETURNS INTEGER(fromNode AS INTEGER, queryName AS CHARACTER, typeName AS CHARACTER):
  errorCurrent = FALSE.
  RETURN backward:queryCreate(fromNode, queryName, typeName):Length.
  CATCH e AS Error: RUN raiseError(e). RETURN -2. END CATCH.
END FUNCTION.


FUNCTION parserQueryGetResult RETURNS LOGICAL (queryName AS CHARACTER, resultNum AS INTEGER, intoHandle AS INTEGER):
  errorCurrent = FALSE.
  backward:queryGetResult(queryName, resultNum, intoHandle).
  RETURN TRUE.
  CATCH e AS Error: RUN raiseError(e). RETURN FALSE. END CATCH.
END.


FUNCTION parserReleaseHandle RETURNS LOGICAL (theHandle AS INTEGER):
  backward:setHandle(theHandle, ?).
  RETURN TRUE.
END.


PROCEDURE raiseError PRIVATE:
  DEF INPUT PARAM e AS Error NO-UNDO.
  /* If there's an existing error, don't change it.
   * We do "upgrade" from a warning to an error though.
   */
  IF errorStatus GT -2 THEN DO:
    ASSIGN
        errorCurrent = TRUE
        errorStatus = -2
        errorText = e:GetMessage(1)
        errorStackTrace = e:CallStack
        .
  END. ELSE DO:
	errorCurrent = FALSE.
  END.
END PROCEDURE.


PROCEDURE raiseWarning PRIVATE:
  DEF INPUT PARAM s AS CHAR NO-UNDO.
  /* If there's an existing warning, don't change it. */
  IF errorStatus NE 0 THEN DO:
    ASSIGN
        errorCurrent = TRUE
        errorStatus = -1
        errorText = s
        .
  END. ELSE DO:
    errorCurrent = FALSE.
  END.
END PROCEDURE.

