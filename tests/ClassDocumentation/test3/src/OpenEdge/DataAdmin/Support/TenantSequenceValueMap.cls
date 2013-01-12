 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TenantSequenceValueMap
    Purpose     : Sequence values for a tenant mapped by sequence name
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ISequenceValueMap from propath.
using OpenEdge.DataAdmin.ISequenceValue from propath.
using OpenEdge.DataAdmin.ISequence from propath.
using OpenEdge.DataAdmin.SequenceValue from propath.

using OpenEdge.DataAdmin.Support.SequenceValueMap from propath.
 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceValueContext from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Support.TenantSequenceValueMap inherits SequenceValueMap : 
   
    constructor TenantSequenceValueMap(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
     
   
    method public override logical ContainsKey(elem as IDataAdminElement):
        if type-of(elem,ISequence) then
            return ContainsKey(cast(elem,ISequence)). 
        return false.  
    end method.
   
    method public logical ContainsKey(seq as ISequence):
/*        if seq:ContextId <> ContextId then*/
/*            return false.                 */
        return Context:CanFind(seq:name).
    end method.
    
    method public override logical ContainsValue(seqVal as ISequenceValue):
        return ContainsKey(seqVal:Sequence).
    end method.
    
    method public override ISequenceValue Get(elem as IDataAdminElement).
        if type-of(elem,ISequence) then
            return Get(cast(elem,ISequence)).  
        else 
            undo, throw new IllegalArgumentError("Invalid type used in Get. The collection is mapped to ISequence entities.").
            
    end method.
    
    method public ISequenceValue Get(seq as ISequence). 
        
        if /*seq:ContextId = ContextId 
        and */ Context:Find(seq:name) then
            return new SequenceValue(Context).
        
    end method.
             
    method override protected void PrepareExport(  ):
        TableHandle:default-buffer-handle:buffer-field("TenantName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Url"):serialize-hidden = true.
    end method.

    method override protected void PrepareExportTree(  ):
/*        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.*/
    end method.
    
    method override protected void PrepareExportList(  ):       
        TableHandle:default-buffer-handle:buffer-field("TenantName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Url"):serialize-hidden = true.
    end method.
    
end class.
