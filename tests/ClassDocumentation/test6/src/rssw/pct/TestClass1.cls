USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* Class documentation for class 1 */
CLASS rssw.pct.TestClass1:

  /**
   * Constructor
   */
  CONSTRUCTOR PUBLIC TestClass1():
    SUPER().
  END CONSTRUCTOR.

END CLASS.
