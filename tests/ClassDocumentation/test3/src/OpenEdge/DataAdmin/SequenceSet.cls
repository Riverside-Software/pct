 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SequenceSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.

using OpenEdge.DataAdmin.Binding.AuthenticationSystemContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceContext from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.SequenceSet inherits DataAdminCollection implements ISequenceSet: 
   
    
    constructor SequenceSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
    
    constructor SequenceSet(cntxt as IDataAdminContext):
        super(cntxt).
    end constructor. 
       
    constructor SequenceSet(cntxt as SequenceContext):
        super(cntxt).  
    end constructor. 
    
    constructor SequenceSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        return new SequenceContext().
    end.     
    
    method public override logical Add(o as Object):
        define variable seq as ISequence no-undo.
        seq = cast(o,ISequence). /* cast to get error */
        return this-object:Add(seq).
    end method.  
    
    method public logical Add(sequence as ISequence):  
        if Contains(sequence) then
            return false.   
       
        sequence:Attach(Context).
      
        return true.
    end method.  
    
    method public override logical Remove(o as Object):
        define variable seq as ISequence no-undo.
        seq = cast(o,ISequence). /* cast to get error */
        return Remove(seq).
    end method.  
    
    method public logical Remove(pseq as ISequence):
        AssertNotNull(pseq,"Sequence").
        return Context:Delete(pseq:Name).
    end method.  
   
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,ISequence)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(sequence as ISequence):
        if sequence:ContextId <> ContextId then 
            return false.
        if not CanFind(sequence:name) then
            return false.
        return sequence:Equals(this-object:Find(sequence:name)).      
    end method.  
    
    method override logical Equals(obj as Object): 
        define variable tset as SequenceSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,SequenceSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
            return false.   
        end catch.    
    end method.
    
    method public ISequence Find(sequencename as char):
        return cast(Context:FindEntity(sequencename),ISequence).
    end method.   
             
    method public logical CanFind(sequencename as char):
        return Context:CanFind(sequencename).
    end method.   
         
    method override protected void PrepareExport(  ):
/*        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.*/
    end method.

    method override protected void PrepareExportTree(  ):
/*        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.*/
    end method.
    
    method override protected void PrepareExportList(  ):
/*        TableHandle:default-buffer-handle:buffer-field("AuthenticationSystemName"):serialize-hidden = true.*/
    end method.
    
end class.
