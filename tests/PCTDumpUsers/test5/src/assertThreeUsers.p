DEF VAR zz AS INT NO-UNDO.

FOR EACH _User:
  ASSIGN zz = zz + 1.
END.
IF (zz EQ 3) THEN
  RETURN '0'.
ELSE
  RETURN '1'.
