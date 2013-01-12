 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Common class for sequence value maps
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
using OpenEdge.DataAdmin.Sequence from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceValueContext from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Support.SequenceValueMap abstract inherits DataAdminCollection implements ISequenceValueMap: 
    
    constructor SequenceValueMap(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        return ? .
    end.     
    
    /* @TODO - separate from collection and remove this.. */
    /* @TODO - separate from collection and remove this.. */
    method public override logical Contains(obj as Object):
        return ContainsValue(cast(obj,ISequenceValue)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public abstract logical ContainsKey(elem as IDataAdminElement):
    method public abstract ISequenceValue Get(elem as IDataAdminElement).
 
    method public abstract logical ContainsValue(seqval as ISequenceValue).
             
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
