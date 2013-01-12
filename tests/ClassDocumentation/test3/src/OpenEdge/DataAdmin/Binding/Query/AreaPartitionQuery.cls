/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : abstract query for partitions of an area 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 2011
    Notes       : Known subclasses TablePartitionQuery, IndexPartitionQuery 
                  and FieldPartitionQuery 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IRequestInfo  from propath.
 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath.
 
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.AreaPartitionQuery inherits FilteredContext implements IPartitionContext: 
	/*------------------------------------------------------------------------------
			Purpose: Used for a collection of partitions of a schema element
			 		 mapped by tenant or group															  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	/** Parent context (Model) may change so don't store this */
	define private property PartitionContext as PartitionContext no-undo
	     get():
	         return cast(Parent,PartitionContext).
	     end.
    define protected variable AreaName as character no-undo.
     
    constructor protected AreaPartitionQuery (pdatacontext as PartitionContext,pcAreaName as char,pReq as IRequestInfo):
		super (pdatacontext,"areas",pcAreaName,pReq).	 
 	    AreaName = pcAreaName.	     
	end constructor.
     
    method public override logical CanFind(pname as character):
        undo, throw new UnsupportedOperationError("AreaPartitionQuery CanFind with single key").
    end.    
     
    method public override logical Find(pname as character):
        undo, throw new UnsupportedOperationError("AreaPartitionQuery Find with single key").
    end.    
    
    method protected override IFetchRequest GetQueryRequest():
        define variable msg    as FetchRequest no-undo.
        define variable tree   as IContextTree no-undo.
        define variable hds    as handle no-undo.      
        tree = new ContextTree().
        AddTableTo(tree).       
        hds = tree:GetReadHandle().
        msg = new FetchRequest(Name,Id,hds). 
        return msg.  
    end method.
    
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            /*
            hbuffer:buffer-field ("SchemaName"):serialize-hidden = true.
            hbuffer:buffer-field ("SequenceName"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
             */
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
          
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):      
        return PartitionContext:FindAreaTenant(AreaName,pcTenant,pcTable,pcField,pcIndex,pcCollation).
    end method.
    
    method public logical FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        return PartitionContext:FindAreaGroup(AreaName,pcGroup,pcTable,pcField,pcIndex,pcCollation).
    end method.
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):      
        return PartitionContext:CanFindAreaTenant(AreaName,pcTenant,pcTable,pcField,pcIndex,pcCollation).
    end method.
    
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        return PartitionContext:CanFindAreaGroup(AreaName,pcGroup,pcTable,pcField,pcIndex,pcCollation).
    end method.
    
     /*  Allocate probably does not make sense for area partitions  */
    method public logical Allocate():
        undo, throw new UnsupportedOperationError("Allocate() in AreaPartitionContext").
    end method.
     
    /*  Deallocate probably does not make sense for area partitions  */
    method public logical Deallocate():
        undo, throw new UnsupportedOperationError("Deallocate() in AreaPartitionContext").
    end method.
end class.