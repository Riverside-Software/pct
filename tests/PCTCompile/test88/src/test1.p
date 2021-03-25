define temp-table tt1
  field fld1 as char.

procedure proc1:
  find first tt1.
  do transaction:
    do transaction:
      update tt1.fld1.
    end.
  end.
end.

procedure proc2:
  messge "Hello World".
end.
