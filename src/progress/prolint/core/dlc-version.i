
/* Which (main) version of Progress are we running? */
&IF INTEGER(ENTRY(1,PROVERSION,'.'))=8 &THEN
   &GLOBAL-DEFINE dlc-version 8
&ELSEIF INTEGER(ENTRY(1,PROVERSION,'.'))=9 &THEN
   &GLOBAL-DEFINE dlc-version 9
&ELSEIF INTEGER(ENTRY(1,PROVERSION,'.'))=10 &THEN
   &GLOBAL-DEFINE dlc-version 10
&ENDIF
                               
/* Is this session running in GUI, ChUI or Batch? 
   This defines which outputhandlers are supported, and some more */    
{&_proparse_ prolint-nowarn(varusage)}
DEFINE VARIABLE SessionWindowSystem AS CHARACTER NO-UNDO.   
IF SESSION:BATCH-MODE THEN
   SessionWindowSystem="".
ELSE
   SessionWindowSystem=SESSION:DISPLAY-TYPE.

                       