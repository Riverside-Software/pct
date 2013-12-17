 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : PropertyPermissionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Sep 04 02:01:56 EDT 2010
    Notes       : BaseQuery does not filter on _hidden 
                  but does filter on _Owner = "PUB"
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.UserFieldPermissionDataSource from propath.
  
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.PropertyPermissionDataSource inherits UserFieldPermissionDataSource: 
    {daschema/userfieldpermission.i}
/*    define private variable mMapping as char                              */
/*	   init "SchemaName,_Owner,Name,_File-name,Hidden,_File._Hidden" no-undo.*/
   
    constructor public PropertyPermissionDataSource ():     
        super(). 
/*        super (mMapping).*/
    end constructor.
    
/*    /* allow subclasses to override to set call back even if we don't have call back here */*/
/*    method protected override logical SetCallBack(phBuffer as handle):                      */
/*        phBuffer:set-callback("After-row-fill","AfterRowField").                            */
/*    end method.                                                                             */
/*                                                                                            */
    constructor public PropertyPermissionDataSource (hParent as handle):     
        super(hparent). 
/*        super (mMapping).*/
    end constructor.
    
    constructor public PropertyPermissionDataSource (hParent as handle,pcTablejoin as char,pcjoin as char):     
        super(hparent,pcTablejoin,pcjoin). 
    end constructor.
    
    /* override to rename the db fields to tt fields and deal with 
       sequencevalues which is not a physical table and only accessible by super-tenant */
    method public override void AfterFieldRow(dataset-handle hds):
        define variable hBuffer       as handle no-undo. 
        define variable hMap          as handle no-undo. 
        define variable hTable        as handle no-undo. 
        
        hMap = DataSourceHandle:get-source-buffer(1).
        hbuffer = hds:get-buffer-handle("ttUserFieldPermission").
       
        if hMap::TargetTable = "ttSequenceValue"  then    
        do:
            /* Note this only takes care of the mapped relation fields 
               current value is handled by DataAccess.MetaData
               These fields are never writeable since this is a mandatory relation  
               @TODO need a more generic mechanism to deal with these types of 
               relations. (partitions for example)    
               */
               
            assign
                hbuffer::CanRead = DatabaseInfo:IsUserSuperTenant
                hbuffer::CanWrite = false. 
        end.
        else do:    
            super:AfterFieldRow(dataset-handle hds by-reference).
        end.
        
        hBuffer::tablename = hMap::TargetTable.
        hBuffer::name = hMap::TargetField.
     
    end method.
    
end class.