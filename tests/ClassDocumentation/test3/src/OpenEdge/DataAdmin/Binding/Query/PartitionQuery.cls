/*************************************************************/
 /* Copyright (c) 2012 by Progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Query for Users
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Apr 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using Progress.Json.ObjectModel.ObjectModelParser from propath.
using Progress.Json.ObjectModel.JsonConstruct from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Json.ObjectModel.JsonArray from propath.
using OpenEdge.DataAdmin.IRequestInfo  from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IUser from propath.
 
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.UserContext from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
  
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.PartitionQuery inherits FilteredContext: 
	
	/** Parent context (Model) may change so don't store this */
	define protected property UserContext as UserContext no-undo
	    get():
	        return cast(Parent,UserContext).
	    end.
  
    constructor public PartitionQuery (sourcecntxt as IDataAdminContext,pfilter as char):
        super (sourcecntxt,pfilter).      
    end constructor.
    
    constructor public PartitionQuery (sourcecntxt as IDataAdminContext,pReq as IRequestInfo):
        super(sourcecntxt,pReq).
    end constructor.
    
    constructor public PartitionQuery (sourcecntxt as IDataAdminContext,pcparent as char,pcKeyvalue as char):
        super(sourcecntxt,pcParent,pcKeyValue). 
    end constructor.
    
    constructor public PartitionQuery (sourcecntxt as IDataAdminContext,pparent as iRow,pReq as IRequestInfo):
        super(sourcecntxt,pParent,pReq). 
    end constructor.
    
    
    constructor public PartitionQuery (sourcecntxt as IDataAdminContext,pcparent as char,pcKeyValues as char extent,pReq as IRequestInfo):
        super (sourcecntxt,pcparent,pcKeyValues,pReq).      
    end constructor.
    
	constructor protected PartitionQuery (pSource as IDataAdminContext, pcParent as char, pcKeyValue as char,pReq as IRequestInfo ):
		super (pSource,pcParent,pcKeyValue,pReq).	    
	end constructor.
    
    /* we cannot pass ttPartion.AreaName to server, since it is mapped
       to tenant and mess up join of area of partition   */  
    method public override character ColumnSource(pcColumn as char):
        if pccolumn = "AreaName" then 
            pcColumn = "Area.Name". 
        return super:ColumnSource(pcColumn).
    end method.
    
    method public override character ColumnSortSource(pcColumn as char):
        if pccolumn = "AreaName" then 
            pcColumn = "Area.Name". 
        return super:ColumnSortSource(pcColumn).
    end method.
    
end class.