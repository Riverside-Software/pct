/** Provides backward compatability from old C++ API into new Proparse.Net.
 * DO NOT USE THIS FOR NEW CODE!
 * Anything using this old API can be made faster and cleaner by using
 * direct access to the classes and objects in Proparse.Net.
 *
 * Forward declare function calls into proparse.p.
 * {1} = handle for persistent procedure proparse.p.
 *
 * June 2010 by John Green.
 */

FUNCTION parserAttrGet RETURNS CHARACTER (theHandle AS INTEGER, theKey AS CHARACTER) IN {1}.

FUNCTION parserAttrGetI RETURNS INTEGER (theHandle AS INTEGER, theKey AS INTEGER) IN {1}.

FUNCTION parserAttrSet RETURNS LOGICAL (theHandle AS INTEGER, theKey AS INTEGER, theValue AS INTEGER) IN {1}.

FUNCTION parserAttrStringGet RETURNS CHARACTER (theHandle AS INTEGER, theKey AS INTEGER) IN {1}.

FUNCTION parserAttrStringSet RETURNS LOGICAL (theHandle AS INTEGER, theKey AS INTEGER, theValue AS CHARACTER) IN {1}.

FUNCTION parserConfigGet RETURNS CHARACTER (theFlag AS CHARACTER) IN {1}.

FUNCTION parserConfigSet RETURNS LOGICAL (theFlag AS CHARACTER, theValue AS CHARACTER) IN {1}.

FUNCTION parserCopyHandle RETURNS LOGICAL (fromHandle AS INTEGER, toHandle AS INTEGER) IN {1}.

FUNCTION parserErrorClear RETURNS LOGICAL IN {1}.

FUNCTION parserErrorGetIsCurrent RETURNS LOGICAL IN {1}.

FUNCTION parserErrorGetStackTrace RETURNS CHARACTER IN {1}.

FUNCTION parserErrorGetStatus RETURNS INTEGER IN {1}.

FUNCTION parserErrorGetText RETURNS CHARACTER IN {1}.

FUNCTION parserGetHandle RETURNS INTEGER IN {1}.

FUNCTION parserGetIndexFilename RETURNS CHARACTER (fileIndex AS INTEGER) IN {1}.

FUNCTION parserGetNode RETURNS CLASS org.prorefactor.core.JPNode (handleNum AS INT) IN {1}.

FUNCTION parserGetNodeColumn RETURNS INTEGER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetNodeFileIndex RETURNS INTEGER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetNodeFilename RETURNS CHARACTER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetNodeLine RETURNS INTEGER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetNodeText RETURNS CHARACTER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetNodeType RETURNS CHARACTER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetNodeTypeI RETURNS INTEGER (ofHandle AS INTEGER) IN {1}.

FUNCTION parserGetSuperclassClassNode RETURNS CLASS org.prorefactor.core.JPNode
         (subclassClassNode AS CLASS org.prorefactor.core.JPNode) IN {1}.

FUNCTION parserGetTokenTypeName RETURNS CHARACTER (tokenTypeNumber AS INTEGER) IN {1}.

FUNCTION parserGetVersion RETURNS CHARACTER IN {1}.

FUNCTION parserHiddenGetBefore RETURNS LOGICAL (handle AS INTEGER) IN {1}.

FUNCTION parserHiddenGetColumn RETURNS INTEGER IN {1}.

FUNCTION parserHiddenGetFilename RETURNS CHARACTER IN {1}.

FUNCTION parserHiddenGetFirst RETURNS LOGICAL (handle AS INTEGER) IN {1}.

FUNCTION parserHiddenGetLine RETURNS INTEGER IN {1}.

FUNCTION parserHiddenGetNext RETURNS LOGICAL IN {1}.

FUNCTION parserHiddenGetPrevious RETURNS LOGICAL IN {1}.

FUNCTION parserHiddenGetText RETURNS CHARACTER IN {1}.

FUNCTION parserHiddenGetType RETURNS CHARACTER IN {1}.

FUNCTION parserInit RETURNS LOGICAL IN {1}.

FUNCTION parserIsSameNode RETURNS LOGICAL (handle1 AS INTEGER, handle2 AS INTEGER) IN {1}.

FUNCTION parserIsValidNode RETURNS LOGICAL (theHandle AS INTEGER) IN {1}.

FUNCTION parserNodeFirstChild RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodeFirstChildI RETURNS INTEGER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodeNextSibling RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodeNextSiblingI RETURNS INTEGER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodeParent RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodePrevSibling RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodeStateHead RETURNS CHARACTER (ofHandle AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserNodeTop RETURNS CHARACTER (intoHandle AS INTEGER) IN {1}.

FUNCTION parserParse RETURNS LOGICAL (filename AS CHARACTER) IN {1}.

FUNCTION parserQueryClear RETURNS LOGICAL (queryName AS CHARACTER) IN {1}.

FUNCTION parserQueryCreate RETURNS INTEGER
         (fromNode AS INTEGER, queryName AS CHARACTER, nodeType AS CHARACTER) IN {1}.

FUNCTION parserQueryGetResult RETURNS LOGICAL
         (queryName AS CHARACTER, resultNum AS INTEGER, intoHandle AS INTEGER) IN {1}.

FUNCTION parserReleaseHandle RETURNS LOGICAL (theHandle AS INTEGER) IN {1}.

FUNCTION parserSchemaAliasCreate RETURNS LOGICAL (aliasname AS CHARACTER, dbasename AS CHARACTER) IN {1}.

FUNCTION parserSchemaAliasDelete RETURNS LOGICAL (aliasname AS CHARACTER) IN {1}.

FUNCTION parserSchemaClear RETURNS LOGICAL () IN {1}.


