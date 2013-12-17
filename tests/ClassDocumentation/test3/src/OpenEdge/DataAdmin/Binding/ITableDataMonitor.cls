/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ITableDataMonitor
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : Tue Mar 20 17:06:47 IST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

interface OpenEdge.DataAdmin.Binding.ITableDataMonitor:  
             
    define public property FileName as character no-undo 
        get. 
        set.   
                
    define public property TaskName as character no-undo 
        get. 
        set.   
   
    define public property IsLoad as logical  no-undo 
        get. 
        set.  
        
    define public property LogTime as datetime-tz  no-undo 
        get. 
         
    define public property StartTime as datetime-tz  no-undo 
        get. 
        
    define public property EndTime as datetime-tz  no-undo 
        get. 
        
    define public property NumSharedTables as integer no-undo 
        get. 
     
    define public property NumTenantTables as integer no-undo 
        get. 
    
    define public property NumGroupTables as integer no-undo 
        get. 
    
    define public property NumProcessedSharedTables as integer no-undo 
        get. 
     
    define public property NumProcessedTenantTables as integer no-undo 
        get. 
    
    define public property NumProcessedGroupTables as integer no-undo 
        get. 
    
    define public property NoLobs as logical no-undo 
        get. 
        set.    
        
    define public property AnyError as logical no-undo 
        get. 
        set.
        
    define public property ErrorMessage as char no-undo 
        get. 
        set.
        
    define public property Interval as int no-undo 
        get. 
        set.    
    
    define public property IsComplete as log no-undo 
        get. 
        set.    
    
    define public property LogType as char no-undo 
        get. 
        set.
    
    define public property Cancel as logical no-undo 
        get.
        set. 
        
    define public property ConnectionUrl as character no-undo 
        get.
        set. 
        
    define public property CheckFiles as logical  no-undo 
        get. 
        set. 
    
    define public property AnyFileExists as logical  no-undo 
        get.
     
    define public property Slash as character no-undo 
        get. 
        set.    
    
    method public void AddSharedTables(pcPath as char, table-handle htbl).
    method public void AddGroupTables(pcPath as char, pcGroupdir as char,  table-handle htbl).
    method public void AddTenantTables(pcPath as char, pcTenant as char, table-handle htbl).
 
    method public void Export().
    
    /** 
       the actual file name used in the dump may differ, since the we 
       dump logic may change slashes and possibly also differences with relative 
       name and full path (?)  so we pass both owner and file at start */ 
    method public void StartTable(ptable as char, ptype as character,powner as char,pfile as char).
    
    method public void EndTable(pname as character).
  
    method public void EndTable(pname as character,numrows as int64).
    
    method public logical CountRow(pname as character). 
    /** called with any error logger may store all or just keep track of any  */
    method public void AddTableError(pname as character,e as Error).
    /** called with any error logger may store all or just keep track of any  */
    method public void AddTableError(pname as character,msg as char).
    
    /** set expected num rows   */
    method public void SetTableExpectedNumRows(pname as character,pinum as int64 ).
    
    /* set bailed so Endtable can decide whther to set isComplete true false
       when less than expected     */
    method public logical SetTableBailed(pname as character): 
    
    method public void EndTask().
  
    method public void BindFiles(h as handle).
 
 end interface.