ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Core.Assert. 

CLASS ABLUnitTest: 

   @Test. 
   METHOD PUBLIC VOID test1():
     /* Syntax error here */
     Assert:isTue(TRUE).
   END METHOD.

END CLASS.