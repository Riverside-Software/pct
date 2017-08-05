/*********************************************************************
* Copyright (C) 2005,2011 by Progress Software Corporation. All rights *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/*---------------------------------------------------------------------------

dumpvars.i - dictionary dump utility shared variables & workfiles

Author: Mario Brunetti

Date Created: 10/04/99

History:  kmcintos 04/29/2005  Added new dump streams for auditing
          kmcintos 04/30/2005  Added second parameter which, when equal to
                               "STREAMS" defines stream information only.
          fernando 11/10/2005  Added streams for _client-session and _db-detail 20051110-020
          fernando 02/27/2007  Handle critical field change - OE00147106
          kmayur   06/21/2011  Added variable for constraint dump OE00195067
-----------------------------------------------------------------------------*/

DEFINE {1} STREAM ddl.
DEFINE {1} STREAM err-log.  
DEFINE {1} STREAM dumpPol.
DEFINE {1} STREAM dumpEvtPol.
DEFINE {1} STREAM dumpFldPol.
DEFINE {1} STREAM dumpFilPol.
DEFINE {1} STREAM dumpAudD.
DEFINE {1} STREAM dumpAudDVal.
DEFINE {1} STREAM dumpCliSess.
DEFINE {1} STREAM dumpDbDet.

&IF "{2}" NE "STREAMS" &THEN
  &GLOBAL-DEFINE errFileName "incrdump.e"
  
  DEFINE {1} WORKFILE missing NO-UNDO
    FIELD name AS CHARACTER INITIAL ""
    FIELD crit AS LOGICAL   INITIAL NO. /* for OE00147106 */

  DEFINE {1} WORKFILE table-list NO-UNDO
    FIELD t1-name AS CHARACTER INITIAL ""
    FIELD t2-name AS CHARACTER INITIAL ?.

  DEFINE {1} WORKFILE field-list NO-UNDO
    FIELD f1-name   AS CHARACTER INITIAL ""
    FIELD f2-name   AS CHARACTER INITIAL ?.

  DEFINE {1} WORKFILE seq-list NO-UNDO
    FIELD s1-name AS CHARACTER INITIAL ""
    FIELD s2-name AS CHARACTER INITIAL ?.

  DEFINE {1} WORKFILE index-list NO-UNDO
    FIELD i1-name AS CHARACTER INITIAL ""
    FIELD i1-comp AS CHARACTER INITIAL ""
    FIELD i2-name AS CHARACTER INITIAL ?
    FIELD i1-i2   AS LOGICAL.
  DEFINE {1} WORKFILE constraint-list NO-UNDO
    FIELD c1-name AS CHARACTER INITIAL ""
    FIELD c1-comp AS CHARACTER INITIAL ""
    FIELD c2-name AS CHARACTER INITIAL ?
    FIELD c1-i2   AS LOGICAL.    

  DEFINE {1} BUFFER index-alt FOR index-list.
  DEFINE {1} BUFFER const-alt FOR constraint-list.
  DEFINE {1} BUFFER old-field FOR DICTDB._Field.
  DEFINE {1} BUFFER new-field FOR DICTDB2._Field.

  DEFINE {1} VARIABLE h_dmputil        AS HANDLE.
  DEFINE {1} VARIABLE s_errorsLogged   AS LOGICAL INIT FALSE.
  DEFINE {1} VARIABLE cnt              AS INT.  
&ENDIF
