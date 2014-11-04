 
 /*------------------------------------------------------------------------
    File        : StandAloneTests
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bastien
    Created     : Wed Jan 22 10:22:52 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OEUnit.Assertion.*.

CLASS StandAloneTests: 
       
   @Test(expected="Progress.Lang.AppError").
   METHOD PUBLIC VOID ExampleExpectingError():
     RETURN ERROR NEW Progress.Lang.AppError().  /* Passes */
   END METHOD.
   
END CLASS.