 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AuthenticationSystem
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jun 29 14:17:54 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath.
using OpenEdge.DataAdmin.IAuthenticationSystem from propath.
using OpenEdge.DataAdmin.IDomainSet from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Binding.AuthenticationSystemContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.AuthenticationSystem inherits Entity implements IAuthenticationSystem, IDataAdminElement,IDataAdminSerializable: 
	
   
     /** This is a free text description to describe the authentication system,
         its purpose, use, etc. primarily for tools and reporting purposes. */  
    define public property Description as character no-undo 
         get():
            if valid-handle(mBuffer) then
                return mBuffer::Description.
            else
                return Description. 
        end.
        set(pDescription as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Description = pDescription.
            end.
            Description = pDescription.
        end. 
       
       define public property isEnabled as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::isEnabled.
            else
                return isEnabled. 
        end.
        set(isEnabledValue as logical):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::isEnabled = isEnabledValue.
            end.
            isEnabled = isEnabledValue.
        end. 
        
        define public property Comments as char no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Comments.
            else
                return Comments. 
        end.
        set(pComments as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Comments = pComments.
            end.
            Comments = pComments.
        end. 
        
    /** This is an additional field to record custom specific information about this 
        authentication system. */    
    define public property Callback as char no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Callback.
            else
                return Callback. 
        end.
        set(pCallback as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Callback = pCallback.
            end.
            Callback = pCallback.
        end. 
    
    define public property Domains as IDomainSet no-undo  
        get():
            if not valid-object(Domains) then
            do:
                Domains = cast(Context:GetChildCollection(name,"users"),IDomainSet).
                /*
                if valid-object(Service) then 
                do:
                     Users = Service:GetUsers(serializename + ".id/" + string(id)).     
                     Users:Tenant = this-object. 
                end.
                */                        
            end.         
            return Domains.     
        end.
        private set. 
	 
	define public property Type as character no-undo 
	     get():
            if valid-handle(mBuffer) then
                return mBuffer::Type.
            else
                return Type. 
        end.
        set(pType as character):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Type = pType.
            end.
            Type = pType.
        end.  
	
	constructor public AuthenticationSystem (cntxt as IDataAdminContext):
        super (cntxt).
    end constructor.
      
    constructor public AuthenticationSystem (name as character):
        super (name).
    end constructor. 
    
     /*  local context needed - for child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return new AuthenticationSystemContext().
    end method.
     
    method public override void ExportTree(pcfile as char):
        this-object:Export(pcFile).
    end method.     
    
    method public override void Export(  ):
	    this-object:Export("domain.json").
	end method.

end class.
