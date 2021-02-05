define output parameter xx1 as char no-undo.
{test.i}.
message dynamic-function("getParameter" in source-procedure, "prm1").
message dynamic-function("getParameter" in source-procedure, "prm2").
message "num-dbs: " + string(num-dbs).
message "num-aliases: " + string(num-aliases).
run test3.p.
xx1 = dynamic-function("getParameter" in source-procedure, "prm1") + dynamic-function("getParameter" in source-procedure, "prm2").
RETURN "0".