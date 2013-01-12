 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Collection of SequenceValues Mapped to tenant
                  Sequence is parent
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
using OpenEdge.DataAdmin.SequenceValue from propath.
using OpenEdge.DataAdmin.Sequence from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.Support.SequenceValueMap from propath.
 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceValueContext from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Support.SequenceSequenceValueMap inherits SequenceValueMap : 
 
    
    constructor SequenceSequenceValueMap(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
     
    /* @TODO - separate from collection and remove this from map.. */
    method public override logical Contains(obj as Object):
        return ContainsValue(cast(obj,ISequenceValue)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public override logical ContainsKey(elem as IDataAdminElement):
        if type-of(elem,ITenant) then
            return ContainsKey(cast(elem,ITenant)). 
        return false.    
    end method.
    
    method public logical ContainsKey(tenant as ITenant):
/*   @TODO fix 
         if tenant:ContextId <> ContextId then
            return false.                     */
         return Context:CanFind(tenant:name).
    end method.
    
    method public override logical ContainsValue(seqVal as ISequenceValue):
        return ContainsKey(seqVal:Tenant).
    end method.
    
    method public override ISequenceValue Get(elem as IDataAdminElement).
        if type-of(elem,ITenant) then
            return Get(cast(elem,ITenant)).  
        else 
            undo, throw new IllegalArgumentError("Invalid type used in Get. The collection is mapped to ITenant.").         
    end method.
    
    method public ISequenceValue Get(tenant as ITenant). 
        if Context:Find(tenant:name) then
           return new SequenceValue(Context).
        
    end method.
              
    method override protected void PrepareExport(  ):
        TableHandle:default-buffer-handle:buffer-field("SchemaName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("SequenceName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("SequenceUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Url"):serialize-hidden = true.
    end method.

    method override protected void PrepareExportTree(  ):
/*        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.*/
    end method.
    
    method override protected void PrepareExportList(  ):       
        TableHandle:default-buffer-handle:buffer-field("SchemaName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("SequenceName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("SequenceUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Url"):serialize-hidden = true.
    end method.
    
end class.
