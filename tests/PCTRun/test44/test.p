DEFINE SHARED VARIABLE mainCallback AS Progress.Lang.Object NO-UNDO.

DYNAMIC-INVOKE(mainCallback, 'log', 'Log1').
DYNAMIC-INVOKE(mainCallback, 'log', 'Log2').

RETURN "0".
