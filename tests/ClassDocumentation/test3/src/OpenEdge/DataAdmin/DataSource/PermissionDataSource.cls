 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UserTablePermissionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Sep 04 02:01:56 EDT 2010
    Notes       : BaseQuery does not filter on _hidden 
                  but does filter on _Owner = "PUB"
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.UserTablePermissionDataSource.
 
using OpenEdge.DataAdmin.DataAccess.DataAccessError.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.PermissionDataSource inherits UserTablePermissionDataSource: 
    
/*    define private variable mMapping as char                              */
/*	   init "SchemaName,_Owner,Name,_File-name,Hidden,_File._Hidden" no-undo.*/
   
    define public property TableMap as char  no-undo get. set.
    
    constructor public PermissionDataSource ():     
        super(). 
/*        super (mMapping).*/
    end constructor.
    
    method public override void AfterTableRow(dataset-handle hds):
        define variable hBuffer       as handle no-undo. 
        define variable i             as integer no-undo.
        define variable cName         as character no-undo.
        /* sequenceValues is a virtual table that is a many-to-many sequence and tenant
           whose only field is the CurrentValue field "mapped" to the ABL current-value function 
           We set the can- fields to false for regualr tenants since this can only be accessed 
           by super-tenant */
        
        hbuffer = hds:get-buffer-handle("ttUserTablePermission").   
         /* there is currently no known reason why we could not rename the field before the 
           call to super, but it seems safer to keep any rename stuff out of the superclass */
        i = lookup(hBuffer::name,TableMap).
        if i > 1 then  
             cName = entry(i - 1,TableMap).      
        if cName = "ttSequenceValue" and not DatabaseInfo:IsUserSuperTenant then
        do:
            assign        
                hbuffer::CanRead   = false 
                hbuffer::CanWrite  = false
                hbuffer::CanCreate = false   
                hbuffer::CanDelete = false  
                hbuffer::CanDump   = false  
                hbuffer::CanLoad   = false. 
        end.
        else
            super:AfterTableRow(dataset-handle hds by-reference).        
        
        if cName > "" then 
            hBuffer::name = entry(i - 1,TableMap).      
         
    end method.
    
       /* convert istype2 value in query to the expression required in the db */
    method public override character ColumnSortSource(pcColumn as char):
        /** @todo make this work - probably easy -   */
        if pcColumn = "_file._file-name" then
        do:
           undo, throw new UnsupportedOperationError("Sort permission request on table.").
        end.
    end method.
    
    /* convert expression for QueryString - unknown = keep as is */
    /* (part of IQueryMap interface used by QueryString to map query */
    /* override _file-name to repalce vlaue with dataabse table from TableMap */
    method public override character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        define variable i as integer no-undo.
        if pcColumn = "_file._file-name" then
        do:
           i = lookup(pcValue,TableMap).
           if i > 0 then 
               return pcColumn + " " + pcOperator +  " " + quoter(entry(i + 1,TableMap)). 
        end.
        return super:ColumnExpression(pcColumn,pcOperator,pcValue).     
    end.   
    
end class.