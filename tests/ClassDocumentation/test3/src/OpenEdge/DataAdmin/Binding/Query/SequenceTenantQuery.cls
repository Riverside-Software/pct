/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Used for a collection of sequence values under a sequence
                  indexed/mapped by tenant                                                             
        
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 18 22:12:27 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IRequestInfo  from propath. 
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceValueContext from propath.
using OpenEdge.DataAdmin.Binding.TenantContext from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath. 
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.SequenceTenantQuery inherits FilteredContext: 
	/** Parent context (Model) may change so don't store this */
	define private property SequenceValueContext as SequenceValueContext no-undo
	    get():
	        return cast(Parent,SequenceValueContext).
	    end.
	
	/** Parent context (Model) may change so don't store this */
	define private property TenantContext as TenantContext no-undo
	     get():
	          return cast(Model:ContextScope:GetContext("tenant"),TenantContext).
         end.
	
	define private variable mSchemaname as character no-undo.  
    
	constructor public SequenceTenantQuery (pparent as  SequenceValueContext,pRow as IRow,pReq as IRequestInfo):
		super (pparent,pRow,pReq).	    
	    ParentValue = pRow:KeyValues[2].
	    mSchemaname  = pRow:KeyValues[1].
	end constructor.
    
    method public override logical CanFind(pname as character):
        if SequenceValueContext:Find(ParentValue,pName) then
            return CanFindCurrentModel().
        return false.      
    end.    
     
    method public override logical Find(pname as character):
        if SequenceValueContext:Find(ParentValue,pName) then
            return SynchWithModel(). 
        return false.      
    end.    
    
    method public override IFetchRequest GetQueryRequest():
        define variable tree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        define variable hds as handle no-undo.
        define variable cSeqValQuery as character no-undo.
        define variable cTenantQuery as character no-undo.
        define variable qstr as QueryString no-undo.
        
        tree = new ContextTree().
        AddTableTo(tree).
        
        TenantContext:AddTableTo(tree).
        hds = tree:GetReadHandle().
        msg = new FetchRequest(Name,Id,hds). 
        
        qstr = new QueryString(Filter ).
        cSeqValQuery = qstr:GetUnparsedWhereClause("ttSequenceValue").
        cTenantQuery = qstr:GetUnparsedWhereClause("ttTenant").
         
        if not left-trim(cSeqValQuery) begins "for " then
            cSeqValQuery = "for " + cSeqValQuery.
        if not left-trim(cTenantQuery) begins "for " then
            cTenantQuery = "for " + cTenantQuery.
               
        Filter = cSeqValQuery.
/*  Filter is assigned to SetTabelQuery in caller -->      msg:SetTableQuery("ttSequenceValue",qstr:BuildQueryString("ttSequenceValue") ).*/
        msg:SetTableQuery("ttTenant",cTenantQuery ).
  
         
         
        return msg.     
        finally:
            delete object qstr no-error.        
        end finally. 
    
    end method.
     
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            hbuffer:buffer-field ("SchemaName"):serialize-hidden = true.
            hbuffer:buffer-field ("SequenceName"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
 
   
       
end class.