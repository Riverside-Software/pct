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

DEFINE {1} SHARED STREAM dbg_stream.
