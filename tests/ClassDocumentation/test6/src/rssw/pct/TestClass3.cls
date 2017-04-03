USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS rssw.pct.TestClass3:

  /**
   * Documentation for method 1
   */
  METHOD PUBLIC INTEGER method1 (INPUT xxx AS CHARACTER):
    // Documentation with single quote ' ...
    RETURN 0.
  END METHOD.

  /**
   * Documentation for method 2
  */
  METHOD PUBLIC INTEGER method2 (INPUT xxx AS CHARACTER):
    // Documentation with single quote ' ...
    RETURN 0.
  END METHOD.

  /**
   * Documentation for method 3
   */
  METHOD PUBLIC INTEGER method3 (INPUT xxx AS CHARACTER):
    RETURN 0.
  END METHOD.

END CLASS.
