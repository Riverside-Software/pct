define temp-table tt1 no-undo
  field fld1 as char.

find tt1. // Will fail
display tt1.fld1.

return '0'.
