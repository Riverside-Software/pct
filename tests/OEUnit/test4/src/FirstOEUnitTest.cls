 
 /*------------------------------------------------------------------------
    File        : FirstOEUnitTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bastien
    Created     : Wed Jan 22 09:46:35 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OEUnit.Assertion.*.

CLASS FirstOEUnitTest: 
  
  DEFINE VARIABLE tests AS CLASS ThrowHardThings NO-UNDO.
  
  CONSTRUCTOR PUBLIC FirstOEUnitTest():
     tests = NEW ThrowHardThings().
   END CONSTRUCTOR.
  
   @Test. 
   METHOD PUBLIC VOID IntegerTest():
     Assert:AreEqual(tests:getInt(),10).
   END METHOD.
   
   @Test. 
   METHOD PUBLIC VOID StringTest():
     AssertString:IsNotNullOrEmpty(tests:getChar()).
   END METHOD.
 
   @Test. 
   METHOD PUBLIC VOID StringContainTest():
     AssertString:Contains(tests:getChar(),'R').
   END METHOD.
     
END CLASS.