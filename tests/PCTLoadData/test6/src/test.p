define output parameter opNum as character no-undo.

def var zz as int no-undo.
for each tab1:
  zz = zz + 1.
end.
opNum = string(zz).

RETURN "0".
