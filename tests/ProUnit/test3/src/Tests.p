
/*------------------------------------------------------------------------
    File        : Tests.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Mon Jan 27 10:23:35 CET 2014
    Notes       :
  ----------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
Some code to initialize the environment or database before running the test.
------------------------------------------------------------------------------*/
PROCEDURE initialize:
END.


/*------------------------------------------------------------------------------
Some code run before every test to reset internal states, if needed.
------------------------------------------------------------------------------*/
PROCEDURE setUp:
END.


/*------------------------------------------------------------------------------
Some code run after a test to restore, log or something else.
------------------------------------------------------------------------------*/
PROCEDURE tearDown:
END.


/*------------------------------------------------------------------------------
Dispose everything, free resource, close files, disconnect databases, etc.
------------------------------------------------------------------------------*/
PROCEDURE dispose:
END.

/* ### STATIC TESTS*/
/*------------------------------------------------------------------------------
My First Test. Not that complex but should work fine!
------------------------------------------------------------------------------*/
PROCEDURE testMyFirstTest:
    RUN assertTrue(TRUE).
END.

/*------------------------------------------------------------------------------
Another test, more complex
------------------------------------------------------------------------------*/
PROCEDURE testMyAnotherTest:
    RUN assertTrue(TRUE).
    RUN assertEqualsInt(10, 20).
    RUN assertEqualsChar("OK", "OK").
END.

/*------------------------------------------------------------------------------
My Third Test. Again, the test fails when X equals 7.
------------------------------------------------------------------------------*/
PROCEDURE testMyThirdTest:
    DEFINE VARIABLE X AS INTEGER     NO-UNDO.
    DO X = 1 TO 10000:
        RUN assertFalse(X MOD 7 = 0).
    END.
    RUN fail("This test has failed !").
END.