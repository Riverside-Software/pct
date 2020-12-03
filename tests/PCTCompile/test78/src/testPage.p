/**************************************************************************************************/
/* This is a very long commentary to test PCTCompile's pageSize and pageWidth attributes which    */
/* are responsible to set, in that order, the PAGE-SIZE and PAGE-WIDTH attributes from the        */
/* COMPILE statement.                                                                             */
/**************************************************************************************************/
PROCEDURE testPage:
    DEFINE VARIABLE cHello AS CHARACTER NO-UNDO.

    ASSIGN
        cHello = "Hello!".

    MESSAGE cHello.
END PROCEDURE.

