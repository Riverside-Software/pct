/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation ("PSC"),       *
* 14 Oak Park, Bedford, MA 01730, and other contributors as listed   *
* below.  All Rights Reserved.                                       *
*                                                                    *
* The Initial Developer of the Original Code is PSC.  The Original   *
* Code is Progress IDE code released to open source December 1, 2000.*
*                                                                    *
* The contents of this file are subject to the Possenet Public       *
* License Version 1.0 (the "License"); you may not use this file     *
* except in compliance with the License.  A copy of the License is   *
* available as of the date of this notice at                         *
* http://www.possenet.org/license.html                               *
*                                                                    *
* Software distributed under the License is distributed on an "AS IS"*
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. You*
* should refer to the License for the specific language governing    *
* rights and limitations under the License.                          *
*                                                                    *
* Contributors:                                                      *
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
    
*/
/*------------------ begin Trailer-INFO ------------------*/

  PUT {&stream} UNFORMATTED "." SKIP.
  
  i = SEEK({&seek-stream}).
  
  PUT {&stream} UNFORMATTED "PSC" SKIP.
  
  {&entries}
  
  PUT {&stream} UNFORMATTED "cpstream=" 
    ( if user_env[5] = "<internal defaults apply>"
       then "UNDEFINED"
       else user_env[5] 
     )                                          SKIP.
   
  PUT {&stream} UNFORMATTED
    "." SKIP
      STRING(i,"9999999999") SKIP. /* location of trailer */

/*------------------ end   Trailer-INFO ------------------*/

