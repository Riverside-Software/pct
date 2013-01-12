/*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : PartitionQueryContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Nov 01 23:52:38 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath. 
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.Query.PartitionQuery from propath.

using OpenEdge.DataAdmin.Binding.IPartitionContext from propath. 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.PartitionFilteredContext inherits PartitionQuery implements IPartitionContext: 
    
    constructor public PartitionFilteredContext ( pparent as IDataAdminContext,filter as char ):
        super (pparent,filter).
    end constructor.
    
    constructor public PartitionFilteredContext ( pparent as IDataAdminContext,pReq as IRequestInfo):
        super (pparent,pReq).
    end constructor.
    
    
    method public logical FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,PartitionContext):FindGroup(pcGroup,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,PartitionContext):FindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical CanFindGroup(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,PartitionContext):CanFindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return cast(parent,PartitionContext):CanFindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    /*  Allocate currently not supported for filteredcontext  */
    method public logical Allocate():
        undo, throw new UnsupportedOperationError("Allocate() in PartitionFilteredContext").
    end method.
 
end class.