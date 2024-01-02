block-level on error undo, throw.

class rssw.pct.MyClass9:
  define temp-table ttOne no-undo
    field fld1 as char.

  constructor public MyClass9():
    create ttOne.
    assign ttOne.fld1 = 'ABC'.
  end.

  method public void method01():
    find first ttOne.
    message ttOne.fld1.
  end method.

  method static public int main():
    def var xyz as rssw.pct.MyClass9.
    xyz = new rssw.pct.MyClass9().
    xyz:method01().
    return 0.
  end.

end class.
