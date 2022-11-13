class rssw.TestParseError:

  /**
   * prop0 doc
   */
  define public property prop0 as character no-undo get. set.

  define public property prop1 as character no-undo
        get.
        set(input xx as character):
            assign this-object:prop1 = xx.
        end method. // Accepted by the compiler, but not by proparse

end class.
