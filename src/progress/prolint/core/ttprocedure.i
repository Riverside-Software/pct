
  DEFINE TEMP-TABLE tt_procedure NO-UNDO 
     FIELD proctype   AS CHARACTER  
     FIELD procname   AS CHARACTER 
     FIELD startnode  AS INTEGER 
     FIELD prototype  AS LOGICAL
     INDEX idx_proto  AS PRIMARY prototype.
