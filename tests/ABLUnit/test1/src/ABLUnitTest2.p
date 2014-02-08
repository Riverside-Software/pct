
/*------------------------------------------------------------------------
    File        : FirstABLUnitTest.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Tue Jan 28 14:49:48 CET 2014
    Notes       :
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.
/* ***************************  Definitions  ************************** */
USING OpenEdge.ABLUnit.Assertions.Assert.

/* ### STATIC TESTS*/
/*------------------------------------------------------------------------------
My First Test. Not that complex but should work fine!
------------------------------------------------------------------------------*/
@Test.
PROCEDURE testMyFirstTest:
     Assert:AssertTrue(TRUE).
END.

/*------------------------------------------------------------------------------
Another test, more complex
------------------------------------------------------------------------------*/
@Test.
PROCEDURE testMyAnotherTest:
     Assert:AssertTrue(TRUE).
     Assert:AssertEquals(10, 20).
     Assert:AssertEquals("OK", "OK").
END.

/*------------------------------------------------------------------------------
My Third Test. Again, the test fails when X equals 7.
------------------------------------------------------------------------------*/
@Test.
PROCEDURE testMyThirdTest:
    DEFINE VARIABLE X AS INTEGER     NO-UNDO.
    DO X = 1 TO 10000:
         Assert:AssertFalse(X MOD 7 = 0).
    END.
END.