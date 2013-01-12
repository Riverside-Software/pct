/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Query for domains of a single Tenant 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Jun 2011
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
 
using OpenEdge.DataAdmin.Binding.Query.UserQuery from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.UserContext from propath.
  
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.DomainUserQuery inherits UserQuery: 
	
	constructor public DomainUserQuery (pSource as UserContext, pDomainName as char,pReq as IRequestInfo ):
		super (pSource,"domains",pDomainName,pReq).	    
	     
	end constructor.
      
    method public override logical CanFind(pid as character):
        if UserContext:Find(pid,ParentValue) then
            return CanFindCurrentModel().
        return false.    
    end.    
     
    method public override logical Find(pid as character):
        if index(pid,'@') > 0 then
        do:
            if entry(2,pid,'@') <> ParentValue then  
                return false. 
            pid = entry(1,pid,'@').
        end.
        if UserContext:Find(pid,ParentValue) then
            return SynchWithModel().
        return false. 
    end.    
    
    /* override to call createrow that takes domain */
    method public override void CreateRow(entity as IDataAdminElement):
        /* the default syserror has all info */
       
        UserContext:CreateRow(cast(entity,IUser),ParentValue).    
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
    
    
      
end class.