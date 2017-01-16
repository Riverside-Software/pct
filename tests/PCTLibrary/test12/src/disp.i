def var zz as int  no-undo.
def var cc as char no-undo.

do zz = 1 to length(str, 'character'):
 assign cc = cc + (if cc eq '' then '' else ' ') + string(asc(substring(str, zz, 1, 'character'))).
end.
message cc.
