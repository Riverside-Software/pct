/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : abstract query for extents of an area 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sept 2011
    Notes       :   
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IExtent from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
 
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.ExtentContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath. 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath. 
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.DataContextError from propath.

using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.AreaExtentQuery inherits FilteredContext  : 
	/*------------------------------------------------------------------------------
			Purpose: Used for a Area list of extents 													  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	/** Parent context (Model) may change so don't store this */
	define private property ExtentContext as ExtentContext no-undo
	    get():
	         return cast(Parent,ExtentContext).
	    end.
	    
    define private variable AreaType   as char no-undo.
    define private variable LastExtent as int no-undo.
    
    /* 
    constructor public AreaExtentQuery (pcntxt as ExtentContext,pcAreaName as char,pReq as IRequestInfo):
		super (pcntxt,"areas",pcAreaName,pReq).	 
 	    ExtentContext = pcntxt.
 	end constructor.
    */
    constructor public AreaExtentQuery (pModel as ExtentContext, pParent as IRow,pReq as IRequestInfo):
        super (pModel,"areas",pParent:KeyValue,pReq).  
        AreaType = pParent:FieldValue("Type").
        LastExtent = int(pParent:FieldValue("NumExtents")).
    end constructor.
     
    method public override logical CanFind(pname as character):
        undo, throw new UnsupportedOperationError("AreaExtentQuery CanFind with single character key").
    end.    
     
    method public override logical Find(pname as character):
        undo, throw new UnsupportedOperationError("AreaExtentQuery Find with single character key").
    end.    
    
    method public override logical CanFind(pNum as integer):
        if ExtentContext:Find(ParentValue,pNum) then 
             return CanFindCurrentModel(). 
        return false.    
    end.    
     
    method public override logical Find(pNum as integer):
        if ExtentContext:Find(ParentValue,pNum) then 
             return SynchWithModel().
        return false.
    end.    
    
    /* override to call createrow that takes areaname  */
    method public override void CreateRow(entity as IDataAdminElement):
        define variable ext as IExtent no-undo.
        /* the default syserror has all info */
        if AreaType <> "Data" then 
            undo, throw new DataContextError("Cannot add extent to area " + quoter(ParentValue) +  ". Adding extents to other area types than data is not supported.").
        ext = cast(entity,IExtent).
        ExtentContext:CreateRow(ParentValue,ext,LastExtent + 1).    
        LastExtent = LastExtent + 1.
        
    end method.
  
    
end class.