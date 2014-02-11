/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserFieldPermission
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
  
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.IUser from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.IUserFieldPermission from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.

class OpenEdge.DataAdmin.UserFieldPermission inherits Entity implements IUserFieldPermission: 
	
    define public property CanRead as logical no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanRead.
            else
                return CanRead. 
        end.
    
    define public property CanWrite as logical no-undo     
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanWrite.
            else
                return CanWrite. 
        end.
	
	constructor public UserFieldPermission ( cntxt as IDataAdminContext ):
        super (cntxt).
    end constructor.
    
    /* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
     
end class.
