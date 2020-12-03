COMPILE "prgs/Internal.cls" SAVE INTO "build4" OPTIONS "require-field-qualifiers".
MESSAGE SUBSTITUTE("Error &1 - Num messages &2 - Warnings &3", COMPILER:ERROR, COMPILER:NUM-MESSAGES, COMPILER:WARNING).
COMPILE "rssw/Class1.cls" SAVE INTO "build4" OPTIONS "require-field-qualifiers".
MESSAGE SUBSTITUTE("Error &1 - Num messages &2 - Warnings &3", COMPILER:ERROR, COMPILER:NUM-MESSAGES, COMPILER:WARNING).

RETURN '0'.
