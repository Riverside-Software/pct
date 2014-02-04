
ROUTINE-LEVEL ON ERROR UNDO, THROW. 
USING OpenEdge.ABLUnit.Assertions.Assert. 

CLASS src.ABLUnitTest: 
  
   @Test. 
   METHOD PUBLIC VOID IntegerTest():
     Assert:AssertEquals(10,10).
   END METHOD.
   
   @Test. 
   METHOD PUBLIC VOID StringTest():
     Assert:AssertTrue("EQ" EQ "NEQ").
   END METHOD.
 
   @Test. 
   METHOD PUBLIC VOID StringContainTest():
     Assert:AssertTrue("Assure" MATCHES "*R*").
   END METHOD.
  
END CLASS.