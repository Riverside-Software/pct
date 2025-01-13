// Compile with 12.5+
class rssw.TestGenerics:

  /**
   * Variable documentation 1
   */
  define public property mBackingHashMap as Progress.Collections.HashMap<Progress.Lang.Object, Progress.Lang.Object> get. set.
  /**
   * Variable documentation 2
   */
  define public property localInt as integer get. set.

  /**
   * Documentation 'foobar'
   */
  method public Progress.Collections.List<Progress.Lang.Object> foobar(prm1 as Progress.Collections.List<Progress.Lang.Object>):
    return ?.
  end.

end class.
