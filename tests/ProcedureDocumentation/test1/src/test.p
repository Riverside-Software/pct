DEFINE FRAME DEFAULT-FRAME
     w-article AT ROW 1.27 COL 8.43 COLON-ALIGNED
     Btn-lookup AT ROW 1.27 COL 87.86
     W-desi AT ROW 1.27 COL 35 COLON-ALIGNED NO-LABEL
     Btn-recherche AT ROW 1.35 COL 99.86
     W-lieu AT ROW 2.5 COL 8.43 COLON-ALIGNED
     W-desi-lieu AT ROW 2.5 COL 16.43 COLON-ALIGNED NO-LABEL
     Cde-liv AT ROW 2.62 COL 60.72
     w-entite AT ROW 3.77 COL 8.43 COLON-ALIGNED
     W-desi-entite AT ROW 3.77 COL 17.57 COLON-ALIGNED NO-LABEL
     t-Domaine AT ROW 3.77 COL 80 COLON-ALIGNED
     BROWSE-1 AT ROW 4.81 COL 1.29
     Btn-lookup-2 AT ROW 2.5 COL 56.43
     Btn-lookup-3 AT ROW 3.77 COL 57.57
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 113.86 BY 19.92
         FONT 6.
         
PROCEDURE internalProc1:

END PROCEDURE.

/* yes man 
trala pouet pouet */
PROCEDURE internalProc2:
  find foobar where foobar.truc = machin .
  
END PROCEDURE.

PROCEDURE internalProc3 PRIVATE:

END PROCEDURE.
