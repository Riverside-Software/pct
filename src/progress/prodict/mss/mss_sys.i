/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/*--------------------------------------------------------------------

File: prodict/mss/mss_sys.i

Description:
    This string contains a comma-seperated list of the names of all
    system-objects for ODBC-based schemaholders, that are non-queryable.
    For example: Stored-Procedures, Buffers, ...
    This file gets used also from the report-builder -therefore it
    needs to be in a format that complies with C *and* PROGRESS
    
Text-Parameters:  
   none
                                     
--------------------------------------------------------------------*/
/*h-*/
"SQLTables,SQLTables_buffer,SQLColumns,SQLColumns_buffer,SQLStatistics,SQLStatistics_buffer,GetFieldIds,GetFieldIds_buffer,GetInfo,GetInfo_buffer,CloseAllProcs,SendInfo,PROC-TEXT-BUFFER,SEND-SQL-STATEMENT,SQLProcs_Buffer,SQLProcCols_Buffer,SQLSpecialColumns_buffer,SQLProcedures,SQLProcColumns,SQLSpecialColumns,_Constraint_Info"

/*------------------------------------------------------------------*/
