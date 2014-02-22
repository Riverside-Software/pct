ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Core.Assert.

@Test.
PROCEDURE test1:
  Assert:isTrue(TRUE).
END.

@Test.
PROCEDURE test2:
  Assert:isTrue(FALSE).
END.

@Test.
PROCEDURE test3:
  /* Should be an error, but successful for now */
  Assert:equals(INTEGER("A"), 1).
END.