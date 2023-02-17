define output parameter xx1 as char no-undo.
define output parameter xx2 as char no-undo.

xx1 = substitute('&1 &2', dynamic-function("getParameter" in source-procedure, "prm1"), dynamic-function("getParameter" in source-procedure, "prm2")).
xx2 = substitute('&1 &2 &1 &2', dynamic-function("getParameter" in source-procedure, "prm1"), dynamic-function("getParameter" in source-procedure, "prm2")).
return "0".
