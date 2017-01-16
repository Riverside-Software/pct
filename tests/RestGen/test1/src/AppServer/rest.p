@openapi.openedge.export FILE(type="REST", executionMode="external", useReturnValue="false", writeDataSetBeforeImage="false").
DEFINE INPUT  PARAMETER ipChar AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER opChar AS CHARACTER NO-UNDO.

ASSIGN opChar = ipChar + ipChar.
