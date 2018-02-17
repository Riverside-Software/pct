define variable hStream as handle no-undo.
define stream sOut.

hStream = stream sOut:handle.

output stream-handle hStream to value(session:temp-dir) no-echo.
export stream-handle hStream "This is a test".
output stream-handle hStream close.

