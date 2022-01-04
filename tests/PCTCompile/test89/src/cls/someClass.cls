class cls.someClass:

  {inc/ttTable-comp.i}

  method public void createRecord () :
    create ttTable.
    assign ttTable.someChar = "some value 1".
    release ttTable.
  end method.

  method public void displayRecord () :
    message 100.
    for first ttTable no-lock:
      message 101 ttTable.someChar.
    end.
  end method.

end class.
