&IF DEFINED(Records) &THEN
   DEFINE TEMP-TABLE ltRecords
      FIELD TabName AS CHAR  LABEL "Name":T
      FIELD Ptr     AS RECID LABEL "RecId":U
      INDEX TabName TabName
      INDEX Ptr Ptr
   .
&ENDIF