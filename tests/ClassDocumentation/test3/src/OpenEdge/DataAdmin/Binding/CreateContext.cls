 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : CreateContext
    Purpose     : Provide filtered access to rows created by this
                  in another context
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : FilteredContext is a buffer and query used to 
                  control and limit access to the Parent DataAdminContext,
                  which really is a temp-table. 
                  It has the same interface so that the collection
                  that uses it doesn't need to know the difference. 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.DataError from propath.
using OpenEdge.DataAdmin.Binding.Query.AbstractFilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminModel from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.CreateContext inherits AbstractFilteredContext  : 
            
    /** only add to query if added from here */        
	define variable mAdd as logical no-undo. 
	/** delete can happen from anywhere */        
    define variable mDelete as logical no-undo. 
    
	/*** constructors *******************************************/    
	constructor public CreateContext (pparent as IDataAdminContext):
		super (pparent).
		this-object:Parent = pparent.
		CreateQuery().
		 /* open empty - must be open for create-result-list to work */
        QueryHandle:query-prepare ("preselect each " + TableHandle:name + " where false").
        QueryHandle:query-open( ).
        cast(parent,IDataAdminModel):BeforeDelete:subscribe(BeforeDelete).
    end constructor.
    
    method private void BeforeDelete(prid as rowid).       
        define variable lok as logical no-undo.
        if QueryHandle:get-buffer-handle(1):rowid = prid then 
           mDelete = true.
        else do:
            lok = QueryHandle:reposition-to-rowid (prid) no-error.  
            if lok then 
            do:
                QueryHandle:get-next.
                mDelete = true.
            end.
        end.
    end method.
    
    /*** protected methods ****************************************/ 
    method protected override void RowCreated().       
        define variable rid as rowid no-undo.
        define variable lok as logical no-undo.
        if mAdd then
        do:
            rid = TableHandle:default-buffer-handle:rowid.
            QueryHandle:get-buffer-handle(1):find-by-rowid(rid).   
            
            if QueryHandle:create-result-list-entry () then
                OnRowCreated().
        end.
    end method.
    
    method protected override void RowDeleted().       
        if mDelete then
        do: 
            if QueryHandle:delete-result-list-entry () then
               OnRowDeleted().
            mDelete = false.
        end.
    end method.
    
    /*** methods ************************************************/     
    method public override void ValidateChanges(phDs as handle ):
        define variable hTopNavQuery as handle no-undo.
        hTopNavQuery = phDs:top-nav-query(TableHandle:name).
        ValidateQueryChanges(hTopNavQuery).   
        
    end method.
    
    /** override to repos in query - this query has no query-prepare that can be used 
        to query against the extracted changes */
    method public override void ValidateQueryChanges(phQuery as handle):
        define variable hAfterbuffer as handle no-undo.
        define variable hBefore as handle no-undo.
        define variable lok as logical no-undo.
        define variable cKey as character extent no-undo.
        define variable hBuffer as handle no-undo.
        
        hAfterBuffer = phQuery:get-buffer-handle(1).
         
        phQuery:query-open(). 
        phQuery:get-first.        
         
        hAfterBuffer = phQuery:get-buffer-handle(1).
        do while hAfterBuffer:avail:
            if hAfterBuffer:row-state <> 0 then
            do:
                lok = FindOrigin(hAfterBuffer:origin-rowid).
            end.
            else do:
                cKey = GetKeyValues(hAfterBuffer).
                if extent(ckey) = 1 then 
                   lok = this-object:Find(cKey[1]).
                else 
                   lok = this-object:Find(cKey).    
            end.
            if lok then
                Model:ValidateRowChanges(hAfterBuffer,?).
            else 
                RemoveUpdateBuffer(hAfterBuffer).
            phQuery:get-next.        
        end.
    end method.
    
    method protected override logical CanFindCurrentModel(pModel as IDataAdminModel):  
        define variable lok as logical no-undo.
        define variable hModelBuffer as handle no-undo.
        hModelBuffer = pModel:TableHandle:default-buffer-handle.
        lok = QueryHandle:reposition-to-rowid(hModelBuffer:rowid) no-error. 
        return lok.
    end method.
    
    method public override void CreateRow(entity as IDataAdminElement).   
/*        Parent:RowCreated:Subscribe(RowCreated).*/
        mAdd = true.
        super:CreateRow(entity).
        mAdd = false.
/*        Parent:RowCreated:Unsubscribe(RowCreated).*/
    end method.
        
    method public override void AddTreeTo(tree as IContextTree).
        define variable lparse as logical no-undo.
        lparse = tree:Parse.
        tree:Parse = true.
        super:AddTreeTo(tree).
        tree:Parse = lparse. 
    end method.    
    
    method public override void AddTreeTo(tree as IContextTree,pcCollections as char).
        define variable lparse as logical no-undo.
        lparse = tree:Parse .
        tree:Parse = true.
        super:AddTreeTo(tree,pcCollections).
        tree:Parse = lparse. 
    end method.
    
    method public override void Copy(cntxt as IDataAdminContext):
/*        Parent:RowCreated:Subscribe(RowCreated).*/
        mAdd = true.

        super:Copy(cntxt).
/*        Parent:RowCreated:Unsubscribe(RowCreated).*/
        mAdd = false.
  
    end method.    
    
    method public override void TableRefreshed(msg as ITableResponse):
        /* nothing - keep query intact with only our own changes  */
    end method.   
    
    /* single table import of the entity (flat - no tree)*/
    method public override void Import(pcfile as char,pcMode as char):
        undo, throw new UnsupportedOperationError("Import to CreateContext").
    end method.
    
    /* single row import of the entity (flat no tree) */     
    method public override void ImportRow(pcfile as char, i as int).
        undo, throw new UnsupportedOperationError("Import to CreateContext").
    end method.
    
    /* single row import of the entity (flat no tree) */     
    method public override void ImportRow(pcfile as char, c as char).
        undo, throw new UnsupportedOperationError("Import to CreateContext").
    end method.
    /*
    method public override void ImportTree(pcfile as char).
        undo, throw new UnsupportedOperationError("Import to CreateContext").
    end method.
    */
    method public override void ReadChild(pParentrow as IRow, json as JSONObject).
        undo, throw new UnsupportedOperationError("ReadChild to CreateContext").
    end method.  
    
    
end class.
