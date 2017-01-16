/*********************************************************************
* Copyright (C) 2007 by Progress Software Corporation. All rights    *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/* Modified 11/17/97 DLM Added logicals for dump/load, validate and remove
                         obsolete object.
            01/13/98 DLM Added ora_version to know if 2000 or 4000 is now a long.
            03/11/98 DLM Added ora_tspace and ora_ispace so that tablespaces for
                         files and indexes can be entered.   
            02/01/00 DLM Added sqlwidth variable to know if the user wants to
                         use the _Width size instead of the code calculating. 
            05/31/00 DLM Added ora_pdbname for _gat_md9.i to compile.   
            05/30/01 DLM Added ora_owner and ora-collname. 
            10/12/01 DLM Added crtdefault for user to select to dump default values 
            06/25/02 DLM Added shadowcol to know if UPPER function should be used.    
            02/28/03 DLM Removed shadowcol as option
            06/11/07 fernando Unicode and clob support
*/                         

DEFINE {1} SHARED VARIABLE pro_dbname   AS CHARACTER.
DEFINE {1} SHARED VARIABLE pro_conparms AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_dbname   AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_pdbname  AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_version  AS INTEGER.
DEFINE {1} SHARED VARIABLE osh_dbname   AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_username AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_password AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_codepage AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_collname AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_conparms AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_sid      AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_tspace   AS CHARACTER.
DEFINE {1} SHARED VARIABLE ora_ispace   AS CHARACTER.
DEFINE {1} SHARED VARIABLE pcompatible  AS LOGICAL.
DEFINE {1} SHARED VARIABLE movedata     AS LOGICAL.
DEFINE {1} SHARED VARIABLE loadsql      AS LOGICAL.
DEFINE {1} SHARED VARIABLE rmvobj       AS LOGICAL NO-UNDO.
DEFINE {1} SHARED VARIABLE sqlwidth     AS LOGICAL.
DEFINE {1} SHARED VARIABLE ora_owner    AS CHARACTER.
DEFINE {1} SHARED VARIABLE crtdefault   AS LOGICAL.
DEFINE {1} SHARED VARIABLE iFmtOption   AS INTEGER INITIAL 2 NO-UNDO.
DEFINE {1} SHARED VARIABLE lFormat      AS LOGICAL INITIAL TRUE NO-UNDO.
DEFINE {1} SHARED VARIABLE shadowcol    AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE unicodeTypes AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE lExpandClob   AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE {1} SHARED VARIABLE lCharSemantics AS LOGICAL  NO-UNDO INITIAL FALSE.
DEFINE {1} SHARED VARIABLE ora_varlen   AS INTEGER INITIAL 4000.

DEFINE {1} SHARED STREAM dbg_stream.
