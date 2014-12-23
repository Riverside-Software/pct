ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Core.Assert.

CLASS ABLUnitTest: 

   @Test.
   METHOD PUBLIC VOID test1():
     Assert:isTrue(TRUE).
   END METHOD.

   @Test.
   METHOD PUBLIC VOID test2():
     Assert:isTrue(FALSE).
   END METHOD.

END CLASS.