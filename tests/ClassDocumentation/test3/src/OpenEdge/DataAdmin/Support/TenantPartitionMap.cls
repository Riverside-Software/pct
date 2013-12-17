 
 /*------------------------------------------------------------------------
    File        : TenantPartitionMap
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Jul 10 22:17:53 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Support.PartitionMap from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Support.TenantPartitionMap inherits PartitionMap: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public TenantPartitionMap ( cntxt as IPartitionQuery ):
		super (input cntxt).
	end constructor.

	method override protected void PrepareExport(  ):
		TableHandle:default-buffer-handle:buffer-field("TenantGroupName"):serialize-hidden = true.
		TableHandle:default-buffer-handle:buffer-field("TenantGroupUrl"):serialize-hidden = true.
        
	end method.

end class.