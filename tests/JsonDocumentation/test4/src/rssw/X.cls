using Progress.Lang.*.

/**
 * Class comment
 * <a href="test">Some text in an anchor</a>*/
 
class rssw.X:
  @Deprecated.
  define public property foo1 as char get. set.
  @NotDeprecated.
  define protected property foo2 as char get. set.

  @Deprecated(since = '1.0').
  constructor public X () :
    // No-op
  end constructor.

  @Deprecated(since = '1.0', message = 'xxxx').
  constructor public X( foo as int, bar as char ):
    // No-op
  end constructor.

  @Deprecated(message = 'yyyy').  
  method public void method1():
    // No-op
  end method.

end class.
