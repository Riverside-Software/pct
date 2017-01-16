DEF VAR guid1 AS CHARACTER NO-UNDO.
DEF VAR guid2 AS CHARACTER NO-UNDO.
DEF VAR guid3 AS CHARACTER NO-UNDO.
DEF VAR guid4 AS CHARACTER NO-UNDO.

FIND Test1._Db.
ASSIGN guid1 = Test1._Db._Db-Guid.
FIND Test2._Db.
ASSIGN guid2 = Test2._Db._Db-Guid.
FIND Test3._Db.
ASSIGN guid3 = Test3._Db._Db-Guid.
FIND Test4._Db.
ASSIGN guid4 = Test4._Db._Db-Guid.

IF (guid1 NE guid2) THEN RETURN '100'.
IF (guid1 EQ guid3) THEN RETURN '101'.
IF (guid1 EQ guid4) THEN RETURN '102'.
IF (guid3 EQ guid4) THEN RETURN '103'.

RETURN '0'.
