class cls.someClass:

  // {inc/ttTable.i}

  define protected temp-table ttCustomer no-undo like customer
    field newField as character
    field someChar as character.

  method public void createRecord () :
    create ttCustomer.
    assign ttCustomer.someChar = "some value 1".
    release ttCustomer.
  end method.

  method public void parentMethodReliantOnSchema () :
    create ttCustomer.
    assign ttCustomer.newField = "some value 2".
    release ttCustomer.
  end method.

  method public void displayRecord () :
    message 100.
    for first ttCustomer no-lock:
      message 101 ttCustomer.someChar.
    end.
  end method.

end class.
