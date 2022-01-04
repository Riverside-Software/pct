class cls.someChildClass inherits cls.someClass:

  method public void createRecordChild () :
    create ttTable.
    assign ttTable.someChar = "test".
    release ttTable.
  end method.

end class.
