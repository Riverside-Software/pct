/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : SequenceValue
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 
using Progress.Lang.Object from propath.

using OpenEdge.DataAdmin.Entity from propath.  
using OpenEdge.DataAdmin.DataAdminService from propath.  
 
/*using OpenEdge.DataAdmin.SequenceSet from propath.*/
using OpenEdge.DataAdmin.ISequenceValue from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath. 

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ISequence from propath. 
 
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath.
  
class OpenEdge.DataAdmin.SequenceValue inherits Entity implements ISequenceValue, IDataAdminElement, IDataAdminSerializable:  
    
    define public property Tenant as ITenant no-undo 
        get():
             if not valid-object(Tenant) then
             do:
                 if valid-handle(mBuffer) and mBuffer::TenantName > "" 
                 and valid-object(Service) then
                     return Service:GetTenant(mBuffer::TenantName).            
             end.
             return Tenant.
        end.     
        set(pTenant as ITenant ):
            /*
            if valid-object(Service) then 
                undo, throw new ReadOnlyPropertyError("Domain",name,"Tenant").     
            */
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TenantName = pTenant:name.
            end.
            Tenant = pTenant.    
        end.
        
    define public property Sequence as ISequence no-undo 
        get():
             if not valid-object(Sequence) then
             do:
                 if valid-handle(mBuffer) and mBuffer::SequenceName > "" 
                 and valid-object(Service) then
                     return Service:GetSequence(mBuffer::SequenceName).            
    
             end.
             return Sequence. 
        end.     
        set(pSequence as ISequence ):
            /*
            if valid-object(Service) then 
                undo, throw new ReadOnlyPropertyError("Domain",name,"Tenant").     
            */
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::pSequenceName = pSequence:name.
            end.
            Sequence = pSequence.    
        end.
        
    define public property CurrentValue as int64 no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CurrentValue.
            else
                return CurrentValue. 
        end.
        set(pVal as int64):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::CurrentValue = pVal.
            end.
            CurrentValue = pVal.
        end.    
    
    constructor public SequenceValue ( cntxt as IDataAdminContext ):
		super (input cntxt).
	end constructor.
	
    /* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
    	
    method private character GetFileExtension(pcfile as char):
        return entry(num-entries(pcfile,"."),pcfile,".").
    end method.
        
end class.
