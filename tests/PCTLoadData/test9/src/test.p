find tab1 where tab1.fld1 = "�" no-lock no-error.
if (avail tab1) then return '0'.
else return '1'.
