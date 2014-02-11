/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Mar 30 21:56:15 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.

interface OpenEdge.DataAdmin.IDataFile inherits IDataAdminElement:  
    /** dump load order */
    define property TableSequence      as integer       no-undo get.  
    
    /** full filename  */
    define property FileName           as character     no-undo get.  
    
    /** Table  of .d file */
    define property Table              as ITable        no-undo get.  
   
    /** shared, tenant or group */
    define property Type               as character     no-undo get.  
    
    /** Tenant of d. file - unknown if group or shared file */
    define property Tenant             as ITenant       no-undo get.  
   
    /** TenantGroup of file */
    define property TenantGroup        as ITenantGroup  no-undo get.  
    /** Start time of dumo or load   */
    define property StartTime          as datetime-tz   no-undo get.  
    /** End time of dumo or load   */
    define property EndTime            as datetime-tz   no-undo get.  
    /** Expected number of row for load (from .d trailer)  */
    define property ExpectedNumRows    as int64         no-undo  get.  
    /** Processed number or rows for dump or load    */
    define property ProcessedNumRows   as int64         no-undo get.  
    /** True if file was processed 
       (could be incomplete if AcceptableErrorPercentage was reached)  */
    define property IsComplete         as logical       no-undo get.  
    /** True if any error occured during load   */
    define property AnyError          as logical       no-undo get.  
    /** True if bailed - internal */
    define property Bailed             as logical       no-undo get.  
    /** True if the file is available  */
    define property IsAvailable        as logical       no-undo get.
    /** True if the security allows load.
        False of CanWrite or CanLoad is false for the table for current user */
    define property CanImport          as logical       no-undo get.
    /** True if the security allows dump.
        False of CanRead or CanDump is false for the table for current user */
    define property CanExport          as logical       no-undo get.
    /** Last error message from load */
    define property ErrorMessage       as char          no-undo get.
end interface.