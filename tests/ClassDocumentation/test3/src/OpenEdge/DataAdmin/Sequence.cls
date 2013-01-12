/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Sequence class 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 
using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.Entity from propath.  
using OpenEdge.DataAdmin.DataAdminService from propath.  
 
/*using OpenEdge.DataAdmin.SequenceSet from propath.*/
using OpenEdge.DataAdmin.ISequence from propath.
using OpenEdge.DataAdmin.ISequenceValueMap from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath. 
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Error.ForbiddenOperationError from propath.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.DataAdminError from propath.
  
class OpenEdge.DataAdmin.Sequence inherits Entity implements ISequence, IDataAdminElement, IDataAdminSerializable:  
    /** currently only PUB */
     define public property Schema as ISchema no-undo 
        get():
            if valid-handle(mBuffer) and valid-object(Service) 
            and mBuffer::SchemaName = "PUB" then 
                return Service:GetSchema().       
            return ?.          
        end.    
    /** Returns true if the sequence is multi-tenant enabled.
        Can only be edited before the sequence is created.  */
    define public property IsMultiTenant as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsMultiTenant.
            return IsMultiTenant.  
        end.    
        set(plMulti as log):
            if plMulti <> IsMultiTenant and valid-object(Service) then 
                undo, throw new ReadOnlyPropertyError("Sequence",name,"IsMultiTenant").
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsMultiTenant = plMulti.
            end.
            IsMultiTenant = plMulti.    
        end.    
     
     /** The minimum value of the sequence   */
     define public property MinimumValue as int64 no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::MinimumValue.
            else
                return MinimumValue. 
        end.
        set(pVal as int64):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::MinimumValue = pVal.
            end.
            MinimumValue = pVal.
        end.    
        
    /** The maximum value of the sequence   */
    define public property MaximumValue as int64 no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::MaximumValue.
            else
                return MaximumValue. 
        end.
        set(pVal as int64):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::MaximumValue = pVal.
            end.
            MaximumValue = pVal.
        end.    
    
    /** The initial value of the sequence   */
    define public property InitialValue as int64 no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::InitialValue.
            else
                return InitialValue. 
        end.
        set(pVal as int64):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::InitialValue = pVal.
            end.
            InitialValue = pVal.
        end.    
    
    /* The current value for a shared (non Multi-tenant) sequence */
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
        
     /** The increment value of the sequence   */
    define public property IncrementValue as int64 no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IncrementValue.
            else
                return IncrementValue. 
        end.
        set(pVal as int64):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IncrementValue = pVal.
            end.
            IncrementValue = pVal.
        end.    
     
     /** Defines whether the sequence is cyclic or not */     
     define public property IsCyclic as logical no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsCyclic.
            else
                return IsCyclic. 
        end.
        set(pVal as logical):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsCyclic = pVal.
            end.
            IsCyclic = pVal.
        end.  
          
    /** Collection of all tenant sequence values for a Multi-tenant sequence 
        Restricted access - Only a super tenant can see other sequence values for other tenants */
    define public property SequenceValues as ISequenceValueMap no-undo      
        get():
            
            define variable err as Error no-undo.
            if not valid-object(Service) then
            do:
                undo, throw new UnsupportedOperationError("SequenceValues can only be accessed after the sequence has been created.").
            end.    
            if not valid-object(SequenceValues) then
            do:
                SequenceValues = cast(GetChildCollection("SequenceValues"),ISequenceValueMap).
            end.
            return SequenceValues.
            catch e as DataAdminError :
                err =  e:InnerError.
                if valid-object(err) then 
                do:
                    if err:GetMessageNum(1) = 15956 then 
                        undo, throw new ForbiddenOperationError("SequenceValues with data for many tenants can only be accessed by a super-tenant.", e).
              
                end.    
                undo,throw e.
                
            end catch.
        end.     
        private set.
        
    constructor public Sequence ( pcntxt as IDataAdminContext ):
		super (pcntxt).
	end constructor.
	
	constructor public Sequence (pcntxt as IDataAdminContext,preq as IRequestInfo):
	    super (pcntxt,preq).
    end constructor.
		
	constructor public Sequence ( pname as character ):
		super (pname).		
	end constructor.
    

    /* No local context needed - no child collections (yet...?)   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
    
/*    method public override logical Equals(obj as Object):*/
/*        define variable lOk as logical no-undo.          */
/*        lok = super:Equals(obj).                         */
/*        if not lok and obj:GetClass() = GetClass() then  */
/*            return Name = cast(obj,ISequence):Name.      */
/*        return lok.                                      */
/*    end method.                                          */
                                                               
    method private character GetFileExtension(pcfile as char):
        return entry(num-entries(pcfile,"."),pcfile,".").
    end method.
        
end class.
