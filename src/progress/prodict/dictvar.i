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


/*dictvar.i - dictionary shared variable definitions 

Modified:
   02/19/97 DLM     Changed cache_file from extent 1024 to 2048 (97-02-14-001) 
   12/28/98 Mario B 12/28/98 Add s_In_Schema_Area enable 1 time notification. 
   07/28/99 Mario B Support for array data types. BUG 19990716-033.
   10/14/99 Mario B Removed shared variable s_Set_Anyway.  No longer needed.
*/

DEFINE {1} SHARED VARIABLE dict_rog        AS LOGICAL               NO-UNDO.
DEFINE {1} SHARED VARIABLE dict_trans      AS LOGICAL               NO-UNDO.
DEFINE {1} SHARED VARIABLE dict_dirty      AS LOGICAL               NO-UNDO.

DEFINE {1} SHARED VARIABLE cache_dirty     AS LOGICAL  INITIAL TRUE NO-UNDO.

DEFINE {1} SHARED VARIABLE cache_db#        AS INTEGER   INITIAL 0   NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_s       AS CHARACTER EXTENT 64   NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_l       AS CHARACTER EXTENT 64   NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_p       AS CHARACTER EXTENT 64   NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_t       AS CHARACTER EXTENT 64   NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_e       AS CHARACTER EXTENT 64   NO-UNDO.
/* s=schema_db, l=logical_db, p=physical_db, t=db_type(int), e=db_type(ext)*/

DEFINE {1} SHARED VARIABLE cache_file#      AS INTEGER  INITIAL 0    NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_file       AS CHARACTER EXTENT 2048 NO-UNDO.

DEFINE {1} SHARED VARIABLE drec_db          AS RECID    INITIAL ?    NO-UNDO.
DEFINE {1} SHARED VARIABLE drec_file        AS RECID    INITIAL ?    NO-UNDO.

DEFINE {1} SHARED VARIABLE s_DbRecId        AS RECID    INITIAL ?    NO-UNDO.
DEFINE {1} SHARED VARIABLE s_In_Schema_Area AS LOGICAL  INIT NO      NO-UNDO.

&IF "{&DATASERVER}" = "YES" OR "{&ORACLE-DATASERVER}" = "YES"
 &THEN
  { prodict/ora/ora_lkdf.i 
      &new = " {1}"
      } /* Defines temp-table s_ttb_link for DATASERVER*/
  {prodict/gate/gatework.i 
    &new        = " {1}"
    &selvartype = "{1} shared variable s"
    &options    = "initial ""*"" "
    } /* Defines: temp-table gate-work */
 &ENDIF
 

