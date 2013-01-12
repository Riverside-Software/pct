/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Nov 01 23:52:38 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.QueryContext from propath. 
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.PartitionQueryContext inherits QueryContext implements IPartitionContext: 
    
    constructor public PartitionQueryContext ( pparent as IDataAdminContext,pcQuery as char, phBuffer as handle extent): 
        super (pparent,pcquery,phbuffer).
    end constructor.
    
    constructor public PartitionQueryContext ( pparent as IDataAdminContext,pcQuery as char, phBuffer as handle):        
        super (pparent,pcquery,phbuffer).
    end constructor.
    
    method public logical FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,IPartitionContext):FindGroup(pcGroup,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,IPartitionContext):FindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,IPartitionContext):CanFindGroup(pcGroup,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,IPartitionContext):CanFindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    /*  Allocate currently not supported for querycontext  */
    method public logical Allocate():
        undo, throw new UnsupportedOperationError("Allocate() in PartitionQueryContext").
    end method.
     
    /*  Deallocate currently not supported for querycontext  */
    method public logical Deallocate():
        undo, throw new UnsupportedOperationError("Deallocate() in PartitionQueryContext").
    end method.
 
    
end class.