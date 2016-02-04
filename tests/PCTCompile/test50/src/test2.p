{src\test3.i}
{src\test2.i}

DEFINE VARIABLE iC AS INTEGER     NO-UNDO.
DO iC = 1 TO 100: 
    iTest = iTest + 10.

END.

MESSAGE iTest
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
