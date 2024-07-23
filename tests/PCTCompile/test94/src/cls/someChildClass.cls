class cls.someChildClass inherits cls.someClass:

  method public void createRecordChild () :
    create ttCustomer.
    assign ttCustomer.someChar = "test".
    release ttCustomer.

    empty temp-table ttCustomer.
    // parentMethodReliantOnSchema().
  end method.

end class.
