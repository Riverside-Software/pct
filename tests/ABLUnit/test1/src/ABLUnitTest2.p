ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.ABLUnit.Assertions.Assert.

@Test.
PROCEDURE test1:
  Assert:AssertTrue(TRUE).
END.

@Test.
PROCEDURE test2:
  Assert:AssertTrue(FALSE).
END.

@Test.
PROCEDURE test3:
  /* Should be an error, but successful for now */
  RUN test.p.
END.