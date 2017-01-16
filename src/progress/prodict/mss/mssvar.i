/*********************************************************************
* Copyright (C) 2006,2008-2009 by Progress Software Corporation. All rights *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/*
    History:  D. McMann 03/03/99 Removed On-line from Informix
              D. McMann 02/01/00 Added sqlwidth variable
              D. McMann 06/18/01 Added case and collation variables
              fernando  04/14/06 Unicode support
              fernando  04/11/08 Support for new seq generator
              fernando  03/20/09 Support for datetime-tz
              Nagaraju  09/22/09 Support for Computed Columns
*/    

DEFINE {1} SHARED VARIABLE pro_dbname     AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE pro_conparms   AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE osh_dbname     AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_dbname     AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_pdbname    AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_username   AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_password   AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_codepage   AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_collname   AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_incasesen  AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE mss_conparms   AS CHARACTER NO-UNDO.
DEFINE {1} SHARED VARIABLE long-length    AS INTEGER   NO-UNDO.
DEFINE {1} SHARED VARIABLE movedata       AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE pcompatible    AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE sqlwidth       AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE loadsql        AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE rmvobj         AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE shadowcol      AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE descidx        AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE dflt           AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE iFmtOption     AS INTEGER   NO-UNDO
                                                    INITIAL 2.
DEFINE {1} SHARED VARIABLE lFormat        AS LOGICAL   NO-UNDO
                                                    INITIAL TRUE.
DEFINE {1} SHARED VARIABLE iRecidOption   AS INTEGER   NO-UNDO
                                                    INITIAL 2.
DEFINE {1} SHARED VARIABLE unicodeTypes   AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE lUniExpand     AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE {1} SHARED VARIABLE newseq         AS LOGICAL   NO-UNDO.
DEFINE {1} SHARED VARIABLE mapMSSDatetime AS LOGICAL   NO-UNDO INITIAL TRUE.

DEFINE {1} SHARED STREAM dbg_stream.

DEFINE {1} SHARED VARIABLE stages 		    AS LOGICAL EXTENT 7 NO-UNDO.
DEFINE {1} SHARED VARIABLE stages_complete 	AS LOGICAL EXTENT 7 NO-UNDO.

/*
 * Constants describing stage we are at.
 */ 
define {1} shared variable mss_create_sql	  as integer   initial 1.
define {1} shared variable mss_dump_data   	  as integer   initial 2.
define {1} shared variable mss_create_sh 	  as integer   initial 3. 
define {1} shared variable mss_create_objects as integer   initial 4.
define {1} shared variable mss_build_schema	  as integer   initial 5.
define {1} shared variable mss_fixup_schema	  as integer   initial 6.
define {1} shared variable mss_load_data	  as integer   initial 7. 
define {1} shared variable s_file-sel         as character initial "*". 



