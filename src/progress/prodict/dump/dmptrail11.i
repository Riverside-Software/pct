/*********************************************************************
* Copyright (C) 2000,2007 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/* dmptrail.i

function:
    appends a trailer with codepage-information 

preconditions:    
    needs the stream to be open, and all data to be output
    user_env[5] contains the value for the codepage-entry
        
text-parameters:
    &entries        ev. additional entries
    &seek-stream    "<stream-name>"        or "OUTPUT"
    &stream         "stream <stream-name>" or ""
    
included in:
  prodict/dump/_dmpdata.p    
  prodict/dump/_dmpsddl.p    
  prodict/dump/_dmpseqs.p    
  prodict/dump/_dmpuser.p    
  prodict/dump/_dmpview.p    
  prodict/dump/_dmpincr.p    
    
history:
    hutegger    94/03/02    creation
    fernando    Jun 19,2007 Support for large files
    
*/
/*------------------ begin Trailer-INFO ------------------*/
  DEFINE VARIABLE i64       AS INT64   NO-UNDO.

  PUT {&stream} UNFORMATTED "." SKIP.
  
  i64 = SEEK({&seek-stream}).
  
  PUT {&stream} UNFORMATTED "PSC" SKIP.
  
  {&entries}
  
  PUT {&stream} UNFORMATTED "cpstream=" 
    ( if user_env[5] = "<internal defaults apply>"
       then "UNDEFINED"
       else user_env[5] 
     ) SKIP.
   
  PUT {&stream} UNFORMATTED
    "." SKIP .

  /* location of trailer */
  IF i64 > 9999999999 THEN
      PUT {&stream} UNFORMATTED STRING(i64) SKIP.
  ELSE
      PUT {&stream} UNFORMATTED STRING(i64,"9999999999") SKIP.


/*------------------ end   Trailer-INFO ------------------*/

