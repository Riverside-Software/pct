/*********************************************************************
* Copyright (C) 2006,2008-2009,2011,2015 by Progress Software Corporation.*
* All rights reserved.  Prior versions of this work may contain      *
* portions contributed by participants of Possenet.                  *
*                                                                    *
*********************************************************************/

/*dictvar.i - dictionary shared variable definitions 

Modified:
   02/19/97 DLM     Changed cache_file from extent 1024 to 2048 (97-02-14-001) 
   12/28/98 Mario B 12/28/98 Add s_In_Schema_Area enable 1 time notification. 
   07/28/99 Mario B Support for array data types. BUG 19990716-033.
   10/14/99 Mario B Removed shared variable s_Set_Anyway.  No longer needed.
   03/13/06 fernando Store table names in temp-table - bug 20050930-006.
   06/12/06 fernando Support for int64
   06/26/08 fernando Adding pre-processors for encryption stuff
   07/21/08 fernando Adding shared var for epolicy
   04/13/09 fernando Change for alternate buffer pool
*/

DEFINE {1} SHARED VARIABLE dict_rog        AS LOGICAL               NO-UNDO.
DEFINE {1} SHARED VARIABLE dict_trans      AS LOGICAL               NO-UNDO.
DEFINE {1} SHARED VARIABLE dict_dirty      AS LOGICAL               NO-UNDO.

DEFINE {1} SHARED VARIABLE cache_dirty     AS LOGICAL  INITIAL TRUE NO-UNDO.

DEFINE {1} SHARED VARIABLE cache_db#        AS INTEGER   INITIAL 0   NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_s       AS CHARACTER EXTENT 480  NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_l       AS CHARACTER EXTENT 480  NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_p       AS CHARACTER EXTENT 480  NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_t       AS CHARACTER EXTENT 480  NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_db_e       AS CHARACTER EXTENT 480  NO-UNDO.
/* s=schema_db, l=logical_db, p=physical_db, t=db_type(int), e=db_type(ext)*/

DEFINE {1} SHARED VARIABLE cache_file#      AS INTEGER  INITIAL 0    NO-UNDO.
DEFINE {1} SHARED VARIABLE cache_file       AS CHARACTER EXTENT 2048 NO-UNDO.
DEFINE {1} SHARED VARIABLE l_cache_tt       AS LOGICAL  INIT NO      NO-UNDO.

DEFINE {1} SHARED VARIABLE drec_db          AS RECID    INITIAL ?    NO-UNDO.
DEFINE {1} SHARED VARIABLE drec_file        AS RECID    INITIAL ?    NO-UNDO.

DEFINE {1} SHARED VARIABLE s_DbType1        AS CHARACTER INITIAL ?   NO-UNDO.
DEFINE {1} SHARED VARIABLE s_DbType2        AS CHARACTER INITIAL ?   NO-UNDO.
DEFINE {1} SHARED VARIABLE s_DbRecId        AS RECID    INITIAL ?    NO-UNDO.
DEFINE {1} SHARED VARIABLE s_In_Schema_Area AS LOGICAL  INIT NO      NO-UNDO.

/* set when a pre-101b db, so we don't allow 10.1B stuff */
DEFINE {1} SHARED VARIABLE is-pre-101b-db   AS LOGICAL               NO-UNDO.

DEFINE {1} SHARED VARIABLE dictObjAttrCache AS LOGICAL                      NO-UNDO.
DEFINE {1} SHARED VARIABLE dictEPolicy      AS prodict.sec._sec-pol-util    NO-UNDO.
DEFINE {1} SHARED VARIABLE dictObjAttrs     AS prodict.pro._obj-attrib-util NO-UNDO.
DEFINE {1} SHARED VARIABLE dictLoadOptions  AS OpenEdge.DataAdmin.Binding.IDataDefinitionOptions NO-UNDO.
DEFINE {1} SHARED VARIABLE dictMonitor      AS OpenEdge.DataAdmin.Binding.ITableDataMonitor NO-UNDO.

/* for bug fix 20050930-006 */
&IF DEFINED(NOTTCACHE) = 0 &THEN

DEFINE {1} SHARED TEMP-TABLE tt_cache_file NO-UNDO
    FIELD nPos       AS INTEGER
    FIELD cName      AS CHARACTER
    FIELD p_flag     AS LOGICAL
    FIELD multitenant  AS LOGICAL
    INDEX nPos IS UNIQUE PRIMARY nPos
    INDEX cName cName.
&ENDIF

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
 

/* List of areas that should not be available to the user */
&GLOBAL-DEFINE INVALID_AREAS "Encryption Policy Area":U

/* List of schema tables to be filtered out */
&GLOBAL-DEFINE INVALID_SCHEMA_TABLES "_sec-db-policy,_sec-obj-policy,_sec-pwd-policy":U
