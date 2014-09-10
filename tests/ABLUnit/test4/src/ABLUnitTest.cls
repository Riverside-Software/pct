
ROUTINE-LEVEL ON ERROR UNDO, THROW. 
USING OpenEdge.Core.Assert. 

CLASS src.ABLUnitTest: 
  
   @Test. 
   METHOD PUBLIC VOID IntegerTest():
     Assert:equals(10,10).
   END METHOD.
   
   @Test. 
   METHOD PUBLIC VOID StringTest():
     Assert:isTrue("EQ" EQ "EQ").
   END METHOD.
 
   @Test. 
   METHOD PUBLIC VOID StringContainTest():
     Assert:isTrue("Assure" MATCHES "*R*").
   END METHOD.
  
END CLASS.