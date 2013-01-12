/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Default implementation of IFieldPermission 
                  Mapped to a subset of _Field.   
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
  
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.IFieldPermission from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
 
class OpenEdge.DataAdmin.FieldPermission inherits Entity implements IFieldPermission: 
	    
    define public property CanRead as character no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanRead.
            else
                return CanRead. 
        end.
        set(pVal as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::CanRead = pVal.
            end.
            CanRead = pVal.
        end.    
    
    define public property CanWrite as character no-undo     
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanWrite.
            else
                return CanWrite. 
        end.
        set(pVal as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::CanWrite = pVal.
            end.
            CanWrite = pVal.
        end.    
	
	constructor public FieldPermission ( cntxt as IDataAdminContext ):
        super (cntxt).
    end constructor.
   
    /* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
     
     
end class.
