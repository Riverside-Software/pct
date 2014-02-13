ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.ABLUnit.Assertions.Assert. 

CLASS ABLUnitTest:

   @Test. 
   METHOD PUBLIC VOID test1():
      Assert:AssertTrue(TRUE).
   END METHOD.

   @Test. 
   METHOD PUBLIC VOID test2():
     Assert:AssertTrue(FALSE).
   END METHOD.

   @Test. 
   METHOD PUBLIC VOID test3():
      /* Should be an error, but successful for now */
      Assert:AssertEquals(INTEGER("A"), 1).
   END METHOD.

END CLASS.