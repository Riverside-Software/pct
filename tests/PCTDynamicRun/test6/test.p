block-level on error undo, throw.

define variable zz as int.
assign zz = integer('foobar').

return '0'.

catch xxx as Progress.Lang.Error:
  undo, throw new Progress.Lang.AppError("Not an int").
end.
