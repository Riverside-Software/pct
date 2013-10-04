/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Query for partitions of a single TenantGroup 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
  
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupContext from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

interface OpenEdge.DataAdmin.Binding.Query.IPartitionQuery: 
	/*------------------------------------------------------------------------------
			Purpose: Common interface for context used by collections under
			         a tenant or group 
			 		 indexed/mapped by schema element															  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	method public logical FindTable(pctable as char).
    method public logical FindField(pctable as char, pcfield as char):
    method public logical FindIndex(pctable as char, pcIndex as char,pcCollection as char):
    method public logical CanFindTable(pctable as char):
    method public logical CanFindField(pctable as char,pcfield as char):
    method public logical CanFindIndex(pctable as char, pcIndex as char,pccollection as char):
    
    /* also in Ipartitioncontext */
    method public logical Allocate().
 
    
         
end interface.