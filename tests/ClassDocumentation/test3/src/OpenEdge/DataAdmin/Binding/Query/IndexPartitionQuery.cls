/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Query Partitions for an index 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.Query.SchemaPartitionQuery from propath.
 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.IndexPartitionQuery inherits SchemaPartitionQuery: 
	
	constructor public IndexPartitionQuery ( pdatacontext as PartitionContext, pcTable as character, pcIndex as char, pccollation as char,preq as IRequestInfo):
	 	super (pdatacontext,"indexes", pcTable, "",pcIndex,pccollation,pReq).     
	end constructor.
    
end class.