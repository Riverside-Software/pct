/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Used for a collection of sequence values under a tenant
                  indexed/mapped by sequence            
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 18 22:12:27 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceValueContext from propath.
using OpenEdge.DataAdmin.Binding.SequenceContext from propath.
using OpenEdge.DataAdmin.Binding.TenantContext from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath. 
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.TenantSequenceQuery inherits FilteredContext: 
	
	/** Parent context (Model) may change so don't store this */
    define private property SequenceValueContext as SequenceValueContext no-undo
        get():
            return cast(Parent,SequenceValueContext).
        end.
    
    /** Parent context (Model) may change so don't store this */     
    define private property SequenceContext as SequenceContext no-undo
         get():
/*             SequenceContext = cast(Parent:GetChild("sequences"),SequenceContext).*/
 
              SequenceContext  = cast(Model:ContextScope:GetContext("Sequence"),SequenceContext).
             return SequenceContext.
         end.
         private set.
     
    constructor public TenantSequenceQuery (pparent as  SequenceValueContext,pParentRow as IRow,pReq as IRequestInfo):
		super (pparent,pParentRow,pReq).	
	end constructor.
                                                          
    method public override logical CanFind(pname as character):
        if SequenceValueContext:Find(pname,ParentValue) then
            return CanFindCurrentModel().
         return false.    
    end.    
       
    method public override logical Find(pname as character):
        if SequenceValueContext:Find(pname,ParentValue) then
            return SynchWithModel().
         return false.    
    end.    
    
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            hbuffer:buffer-field ("TenantName"):serialize-hidden = true.
            hbuffer:buffer-field ("TenantUrl"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
    method public override IFetchRequest GetQueryRequest():
        define variable tree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        define variable hds as handle no-undo.
        define variable cSeqValQuery as character no-undo.
        define variable cSequenceQuery as character no-undo.
        define variable qstr as QueryString no-undo.
        
        tree = new ContextTree().
        AddTableTo(tree).
        
        SequenceContext:AddTableTo(tree).
        hds = tree:GetReadHandle().
        msg = new FetchRequest(Name,Id,hds). 
        
        qstr = new QueryString(Filter ).
        cSeqValQuery = qstr:GetUnparsedWhereClause("ttSequenceValue").
        cSequenceQuery = qstr:GetUnparsedWhereClause("ttSequence").
        if not left-trim(cSeqValQuery) begins "for " then
            cSeqValQuery = "for " + cSeqValQuery.
        if not left-trim(cSequenceQuery) begins "for " then
            cSequenceQuery = "for " + cSequenceQuery.
               
        Filter = cSeqValQuery.
/*  Filter is assigned to SetTableQuery in caller -->      msg:SetTableQuery("ttSequenceValue",qstr:BuildQueryString("ttSequenceValue") ).*/
        msg:SetTableQuery("ttSequence",cSequenceQuery ).
     
        return msg.
                 
    end method.
    
 
  
end class.