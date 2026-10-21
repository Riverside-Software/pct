/*------------------------------------------------------------------------
    File        : TestClass
    Purpose     : Test fixture for documentation tasks
    Author(s)   : Riverside Software
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using Progress.Lang.* from propath.

class eu.rssw.pct.TestClass final:

  /*------------------------------------------------------------------------------
      Purpose: Default constructor
      Notes:
  ------------------------------------------------------------------------------*/
  constructor public TestClass():
    super().
  end constructor.

  /*------------------------------------------------------------------------------
      Purpose: Constructor with one argument
      Notes:
      @param pcName Name of the instance
  ------------------------------------------------------------------------------*/
  constructor public TestClass(pcName as character):
    super().
  end constructor.

  /*------------------------------------------------------------------------------
      Purpose: Method without annotation
      Notes:
      @param pcValue Input value
  ------------------------------------------------------------------------------*/
  method public final void DoSomething(pcValue as character):
    return.
  end method.

  /*------------------------------------------------------------------------------
      Purpose: Method with an annotation
      Notes:
      @param pcValue Input value
  ------------------------------------------------------------------------------*/
  @Test.
  method public void DoSomethingElse(pcValue as character):
    return.
  end method.

end class.
