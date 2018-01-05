define output parameter xx1 as char no-undo.
{test.i}.
message dynamic-function("getParameter" in source-procedure, "prm1").
message dynamic-function("getParameter" in source-procedure, "prm2").
xx1 = dynamic-function("getParameter" in source-procedure, "prm1") + dynamic-function("getParameter" in source-procedure, "prm2").
RETURN "0".