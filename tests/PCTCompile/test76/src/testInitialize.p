DEFINE VARIABLE fileText AS LONGCHAR NO-UNDO.
DEFINE VARIABLE fileTextChar as CHARACTER no-undo.

/* src/initialize.txt was created by the callbackClass */
COPY-LOB FILE "src/initialize.txt" TO fileText.
fileTextChar = fileText.

MESSAGE fileTextChar.
RETURN "0".
