/*------------------------------------------------------------------------
   File        : rssw.pct.TestClass1
   Purpose     : Comment #1
 ----------------------------------------------------------------------*/

USING Progress.Lang.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS rssw.pct.TestClass1:
    /*------------------------------------------------------------------------
    File        : include.i
    Purpose     : Comment #2
  ----------------------------------------------------------------------*/


  CONSTRUCTOR PUBLIC TestClass1():
    SUPER().
  END CONSTRUCTOR.

END CLASS.
