/*************************************************************/
/* Copyright (c) 2010-2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/

/*------------------------------------------------------------------------
   File        : AbstractFilteredContext
   Purpose     : Provide filtered access to another context
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
using Progress.Json.ObjectModel.JsonArray from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.DataError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminModel from propath.
using OpenEdge.DataAdmin.Binding.IRowChange from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Binding.IFilteredContext from propath.
using OpenEdge.DataAdmin.Binding.Query.DataAdminQuery from propath. 

using OpenEdge.DataAdmin.Lang.BeforeQuery from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath. 
 
class OpenEdge.DataAdmin.Binding.Query.AbstractFilteredContext abstract  use-widget-pool  inherits DataAdminQuery implements IFilteredContext,IDataAdminContext: 
    /*** events ****************************************/ 
    define public event RowCreated signature void (). 
    define public event RowDeleted signature void ().
    define public event ContextDeleted signature void ().
    define public event AddedToContext signature void (newContext as IDataAdminContext). 
    define public event ContextRefreshed signature void (tblResponse as ITableResponse). 
              
    /*** properties ****************************************/
	
	define public override property Tables         as character no-undo 
      get():
          define variable hBufs as handle extent no-undo.
          define variable i  as integer no-undo. 
          define variable cTables as character no-undo.
          hBufs = GetBufferHandles().
          /** Tables could possibly be referenced early in construction
              before all query handles are decided 
              so refresh each time (this is not called often)
              This is consistent with the fact that CreateQuery also can be called 
              again if the buffers are changed */
          do i = 1 to extent(hBufs):
              cTables = (if i > 1 then cTables + "," else "")
                 + hBufs[i]:name.
          end.   
          return cTables.  
      end. 
 
    define public property Filter as character  no-undo  get. 
        protected set.
	
    /* init yes - filtered context is  not shared (the data is) ??
        */ 
    define public property IsLocal as logical init yes no-undo 
        get.
    
    define public property ReadOnly as logical init no no-undo 
        get.
    
    define public property Lazy  as logical  no-undo  
        init true
        get.  
        set(l as log).
            if l = true then
                undo, throw new UnsupportedOperationError("Set of Filter context to lazy").
        end.
    
    define protected property Parent as IDataAdminContext no-undo 
        get.
        set(pParent as IDataAdminContext):
            define variable pModel as IDataAdminModel no-undo.
            if valid-object(Parent) then 
            do:
                Parent:ContextRefreshed:unsubscribe(TableRefreshed).
                Parent:RowCreated:unsubscribe(RowCreated).     
                Parent:RowDeleted:unsubscribe(RowDeleted).  
                Parent:AddedToContext:unsubscribe(NewContext). 
                Parent:ContextDeleted:unsubscribe(Destroy).
                if type-of(Parent,IDataAdminModel) then
                do:
                    pModel = cast(Parent,IDataAdminModel).
                    pModel:SearchQuery:unsubscribe(SearchContent). 
                    pModel:SearchRequest:unsubscribe(SearchRequest). 
                    pModel:KeyChanged:unsubscribe(ForeignKeyChanged).
                end.
            end.
            this-object:Parent = pParent.
            
            Parent:ContextRefreshed:subscribe(TableRefreshed).
            Parent:RowCreated:subscribe(RowCreated).     
            Parent:RowDeleted:subscribe(RowDeleted).  
            Parent:AddedToContext:subscribe(NewContext). 
            Parent:ContextDeleted:subscribe(Destroy).
            if type-of(Parent,IDataAdminModel) then
            do:
                pModel = cast(Parent,IDataAdminModel).
                pModel:SearchQuery:subscribe(SearchContent). 
                pModel:SearchRequest:subscribe(SearchRequest). 
                pModel:KeyChanged:subscribe(ForeignKeyChanged).
            end.
            this-object:KeyFields = parent:KeyFields.
        end.
        
    /* model - should eventually replace parent  */
    define protected property Model as IDataAdminModel no-undo 
        get():
            return cast(Parent,IDataAdminModel).
        end.    
        set.
    
    /** return unknown - filter should not be root context */
    define public property RootId as Rowid no-undo 
        get.
        
    define public property DatasetHandle as handle no-undo 
        get():
            return Parent:DatasetHandle. 
        end.
	
	define public property EntityFieldName as char no-undo 
        get().
            return Parent:EntityFieldName.  
        end.
         
	
	define public property LastSavedDataset as handle no-undo 
        get():
            return Parent:LastSavedDataset. 
        end.
        set(h as handle):
            Parent:LastSavedDataset = h.
        end.    
	  
    define public property TableHandle as handle no-undo 
        get():
            return Parent:TableHandle. 
        end.
 
	    
/*    define protected property BufferHandle as handle no-undo     */
/*        get():                                                   */
/*            if not valid-handle(BufferHandle) then               */
/*            do:                                                  */
/*                create buffer BufferHandle for table TableHandle.*/
/*                                                                 */
/*            end.                                                 */
/*            return BufferHandle.                                 */
/*        end.                                                     */
/*        private set.                                             */
    
    define public property IteratorHandle as handle  no-undo  
        get():
            return QueryHandle.
        end.
        
    define public property Count as integer no-undo  
        get():
            return if QueryHandle:is-open then QueryHandle:num-results else 0.
        end.	    
         
    define public property Service as IDataAdminService no-undo  
        get():
            return Parent:Service. 
        end.
   
    define public property TargetService as IDataAdminService no-undo  
        get():
            return Parent:TargetService. 
        end.
   
    /* unique context identifier, exposed as contextid for comparison
       of collections and entities */ 
    define public property Id            as character no-undo  
        get():
            return Parent:Id.    
        end.    
    
     /**  
        unique query (content) identifier, exposed as Sourceid in collections. 
        Used to isolate updates in context.  
        Is the same as the Id for the Model itself 
     */ 
     define public property ContentId       as character no-undo  
        get():
            if ContentId = "" then
               ContentId = "OE" + string(QueryHandle:handle) + "12".
            return ContentId.
        end.    
        private set.
        
    define public property Total as integer no-undo 
        get():
            return Parent:Total. 
        end. 
        
    define public property Name as character no-undo 
        get():
            return Parent:name.
        end.    
        private set. 
	
	define public property RequestInfo as IRequestInfo no-undo get. set.
	
    /*** constructors ****************************************/ 
     
    constructor public AbstractFilteredContext (pParent as IDataAdminContext):
        this-object(pParent,?).
    end constructor.
      
    constructor public AbstractFilteredContext (pParent as IDataAdminContext,pReq as IRequestInfo):
        super (pParent:TableHandle:Name).
        RequestInfo = pReq. 
        this-object:Parent = pParent.
       
       
        
        /* set BaseQuery for QueryString to override defaultquery, which
           adds no-lock and indexed-reposition */
        
        if BaseQuery = "" then
            BaseQuery  = "for each " + TableHandle:name.
        
    end constructor.
    
    method protected override handle extent GetBufferHandles():
        return SingleExtent(TableHandle:default-buffer-handle).
    end method.    
     
    method protected void NewContext(sourcecntxt as IDataAdminContext):
        define variable cQueryString as character no-undo. 
        this-object:Parent = sourcecntxt.
        if valid-handle(QueryHandle) then 
            cQueryString = QueryHandle:prepare-string.
        
        /* Calls GetBufferHandles and ensures query will use the new context */
        CreateQuery().    
       
        /** init parent end (localfilter is changed in subclas constructors) **/
        if cQueryString > "" then
             QueryHandle:query-prepare (cQueryString).
        OpenQuery().
        /* entities added with no context will still subscribe to the query 
           and need to be refreshed here 
           (DataAdminCollection Context setter does not subscribe from query ) */
        AddedToContext:Publish(sourcecntxt).
    end method.
    
    method protected logical OpenQuery():
        return QueryHandle:query-open(). 
    end method.  
    
    method protected void OnRowCreated():
        RowCreated:Publish().
    end method.    
    
    method protected void OnRowDeleted():
        RowDeleted:Publish().
    end method.    
    
    method public void DataRefreshed(pResponse as IFetchResponse):
        undo, throw new UnsupportedOperationError("DataRefreshed in AbstractFilteredContext").                              
    end method.   
    
    method public void SaveRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("SaveRow in AbstractFilteredContext").                              
    end method.   
         
    method public void SaveCollection(entity as IDataAdminCollection):
        undo, throw new UnsupportedOperationError("SaveCollection in AbstractFilteredContext").                              
    end method.   
    
    
    method protected abstract void TableRefreshed(pResponse as ITableResponse).   
/*    method protected abstract void TableRefreshed().*/
    
    method protected abstract void RowCreated().     
    method protected abstract void RowDeleted().   
    
    method public abstract void Import(pcfile as char,pcMode as char).
     
     
    /** @TODO move to IDataAdminModel or make unsupported 
        need to enure that all instances are realized from IDataAdminModel first. 
        v11.0.0 some may still use query context 
    */ 
    /* single row import of the entity (flat no tree) */     
    method public abstract void ImportRow(pcfile as char, i as int).
     
    /* single row import of the entity (flat no tree) */     
    method public abstract void ImportRow(pcfile as char, c as char).
   
   /* single row import of the entity (flat no tree) */     
    method public void ImportRow(pcfile as char, c as char extent).
        parent:ImportRow(pcFile,c).
    end method.
   
    method public void ImportTree(pcfile as char, c as char):
        parent:ImportTree(pcFile,c).
    end method.
    
    /**  */
    method public void ImportRowTree(pcfile as char, c as char):
        parent:ImportRowTree(pcFile,c).
        /*        undo, throw new UnsupportedOperationError("ImportRowTree in filtered context").*/
    end method.
    
    method public void ImportRowTree(pcfile as char, pc as char extent):
        parent:ImportRowTree(pcFile,pc).
        /*        undo, throw new UnsupportedOperationError("ImportRowTree in filtered context").*/
    end method.
    
    /** */ 
    method public void ImportRowTree(pcfile as char, i as int):
        parent:ImportRowTree(pcFile,i).
        /*        undo, throw new UnsupportedOperationError("ImportRowTree in filtered context").*/
    end method.
 
    method public abstract void ReadChild(parentRow as IRow, json as JSONObject).
       
    method public void ImportForParent(pcParent as char, pcValue as char,pcfile as char):
        undo, throw new UnsupportedOperationError("ImportForParent in filtered context").
    end method. 
    
     method public void ImportNewForParent(pcParent as char, pcValue as char,pcfile as char):
        undo, throw new UnsupportedOperationError("ImportNewForParent in filtered context").
    end method. 
     
    method public void CreateRow(entity as IDataAdminElement).   
        Parent:CreateRow(entity).
    end method.
    
    method public logical Delete(pName as character):
        if this-object:Find(pName) then 
        do:
            return DeleteCurrent().
        end.
        return false. 
    end.    
    
    method public logical Delete(pid as integer):
        if this-object:Find(pid) then 
        do:
            return DeleteCurrent().
        end.
        return false. 
    end.    
   
    method protected logical DeleteCurrent():
        define variable hBuffer as handle no-undo.
        hBuffer = QueryHandle:get-buffer-handle(this-object:Table).
        return Parent:Remove(hBuffer).
    end method.
    
    
    method public logical Delete(name as char extent).
        undo, throw new UnsupportedOperationError("Delete with extent key in abstract filter context.").
    end method.
    
    method protected void Destroy().
        delete object this-object.
    end method.  
    
    define public property SerializeName as character  no-undo  
        get():
            if valid-object(parent) then
                return Parent:SerializeName.
            return "".
        end. 
    
    method public character GetJoinFields(parenturl as char):
        return Parent:GetJoinFields(parenturl).
    end method.
    
    method protected character GetJoinFieldsReversed(parenturl as char):
        define variable i as integer   no-undo.
        define variable cJoin as character no-undo.
        define variable cJoinReversed as character no-undo.
        cJoin = GetJoinFields(parenturl).
        do i = 1 to num-entries(cJoin) by 2:
            cJoinReversed = cJoinReversed 
                          + (if cJoinReversed = "" then "" else ",")
                          + entry(i + 1,cJoin) + "," + entry(i,cJoin).
        end.    
        return cJoinReversed.
    end method.
    
    method public character extent GetKeyValues(pBuffer as handle): 
        return Parent:GetKeyValues(pBuffer).   
    end method.
    
     /** get a where expression from the passed extent using Keyfields */
    method public character GetKeyWhere(pcValues as char extent):
        return Parent:GetKeyWhere(pcValues).   
    end method.       
         
    /** future - see IDataAdminContext commented code
    method public character GetServerJoinFields(parenturl as char):
        return Parent:GetServerJoinFields(parenturl).
    end method.
    **/
    /* cannot use parent - need BaseQuery here */
    method public void TransferMatchingRequests(pReq as IRequestInfo,pMsg as IFetchRequest):
        undo, throw new UnsupportedOperationError("TransferMatchingRequests in abstract filter context.").
    end method.
   
    method public void TransferMatchingRequests(pReq as IRequestInfo extent,pMsg as IFetchRequest):
        undo, throw new UnsupportedOperationError("TransferMatchingRequests in abstract filter context.").
    end method.
    
    method public void AddTableTo(tree as IContextTree):
        tree:setHandle(SerializeName,TableHandle:default-buffer-handle,Filter).
    end method.    
    
    method public void AddRowTo(tree as IContextTree,prid as rowid).
        Parent:AddRowTo(tree,prid).
    end method.    
    
    method public void AddTreeTo(tree as IContextTree).
        tree:SetFilter(SerializeName,filter).
        Parent:AddTreeTo(tree).
    end method.    
    
    method public void AddTreeTo(tree as IContextTree,parentcntxt as IDataAdminContext).
        tree:SetFilter(SerializeName,Filter).
        Parent:AddTreeTo(tree,parentcntxt).
    end method.    
    
    method public void AddTreeTo(tree as IContextTree,parentcntxt as IDataAdminContext,pcCollections as char).
        tree:SetFilter(SerializeName,Filter).
        Parent:AddTreeTo(tree,parentcntxt,pcCollections).
    end method.    
    
    method public void AddTreeTo(tree as IContextTree,pcCollections as char).
        tree:setHandle(SerializeName,TableHandle:default-buffer-handle,Filter).
        Parent:AddTreeTo(tree,pcCollections).     
    end method.
    
    method public void WriteTo(writer as IContextWriter):
        define variable cName as character no-undo. 
        cName = TableHandle:serialize-name.
        writer:WriteHandle(cName,DatasetHandle).
    end method.
        
    method public void WriteRowTo(writer as IContextWriter,pcKey as char):
        Parent:WriteRowTo(writer,pcKey). 
    end method.
    
    method public void WriteRowTo(writer as IContextWriter,piKey as int):
        Parent:WriteRowTo(writer,piKey).  
    end method.
    
    method public logical CanFind(i as int):
        if parent:Find(i) then 
            return CanFindCurrentModel().
        return false.
    end method. 
    
    method public logical Find(i as int):
        if Parent:Find(i) then 
            return SynchWithModel().
        return false.          
    end method. 
    
     /** FindOrigin - find row from origin rowid in row extracted with getchanges  
       @param rOriginid rowid from row in change dataset   */
    method public logical FindOrigin(rOriginid as rowid):
        
        if Parent:FindOrigin(rOriginid) then 
        do:
            return SynchWithModel().
        end.
        return false.          
    end method.    
    
    method public logical CanFind(c as char):
        if parent:Find(c) then 
            return CanFindCurrentModel().
        return false.
    end method. 
    
    method public final logical Find(c as char extent):
        undo, throw new UnsupportedOperationError("Find with extent key in abstract filter context. This is typically resolved by a FilteredContext sublcass that takes single key with the rest of the key as constant parent values in the filter.").
        /*
        if Parent:Find(c) then 
            return SynchWithParent().
        return false. 
        */         
    end method. 
    
    method public logical Find(c as char):
        if Parent:Find(c) then 
            return SynchWithModel().
        return false.          
    end method. 
    
    method public logical Find(pReq as IRequestInfo):
        if Parent:Find(pReq) then 
            return SynchWithModel().
        return false.          
    end method. 
    
    method protected logical CanFindCurrentModel():  
        return CanFindCurrentModel(Model).
    end method.
     
    method protected logical CanFindCurrentModel(pModel as IDataAdminModel):  
        define variable lok as logical no-undo.
        define variable rid as rowid   no-undo.   
        define variable hQuery as handle no-undo.
        define variable hModelBuffer as handle no-undo.
        hModelBuffer = pModel:TableHandle:default-buffer-handle.
        hQuery = CloneQuery(QueryHandle).  
        hQuery:query-open().
        lok = hQuery:reposition-to-rowid(hModelBuffer:rowid) no-error. 
      
        delete object hQuery.
        return lok.
    end method.
    
    
    method protected logical SynchWithModel():  
        return SynchWithModel(Model).
    end.
    
    /** position the query to the row corresponding to the passed model 
        The Model must define the same table as the first table in the query */
    method protected logical SynchWithModel(pModel as IDataAdminModel):  
        define variable lok as logical no-undo.    
        define variable hModelBuffer as handle no-undo.
        define variable hBuf as handle no-undo.
        hModelBuffer = pModel:TableHandle:default-buffer-handle.
        hBuf = QueryHandle:get-buffer-handle (1).
        /* The following errors are developer errors and need to be fixed by developer */
        if hbuf:table-handle <> hModelBuffer:table-handle then
            undo, throw new IllegalArgumentError("Attempt to synchronize query with " + substr(hBuf:name,3) + " as first table with model for " + substr(hModelBuffer:name,3) + ".").
        if not hModelBuffer:avail then  
            undo, throw new IllegalArgumentError("Attempt to synchronize query with no row available in the " + substr(hModelBuffer:name,3) + " model."). 
        lok = (hModelBuffer:rowid = hBuf:rowid).
        if not lok then 
        do:
            /** release - to ensure get-next 
               (if query has multiple tables all tables must be in synch)  */
            hBuf:buffer-release.
            lok = QueryHandle:reposition-to-rowid(hModelBuffer:rowid) no-error. 
            if lok and not hBuf:avail then 
                QueryHandle:get-next.
        end.
        return lok. 
    end.
    
    method public void Reopen():
        
        define variable rids as rowid extent no-undo.
        /* @TODO  research - refine 
        - if the query changed the iterator should possibly be made stale
          except if this happens after an iterator:remove       */ 
        if QueryHandle:is-open then
        do:
            rids = GetQueryRowids(QueryHandle).
        end.
        QueryHandle:query-open().    
        if extent(rids) <> ? then
            SetPosition(rids). 
    end method.  
    
    /** set a property  
         @param rowid the rowid of the tt
         @param name property name
         @param value value
       
       */
    method public logical SetProperty(pid as rowid,pname as char,pvalue as char).
         define variable lok as logical no-undo.
         define variable rsinglerowid as rowid extent 1 no-undo.
         lok = QueryHandle:get-buffer-handle(1):rowid = pid. 
         if not lok then
         do: 
            rsinglerowid[1] = pid.
            lok = SetPosition(rsinglerowid).
         end.
         if lok then
             lok = Parent:SetProperty(pid,pname,pvalue).
      
         return lok.   
    end method.
     
    /* subclasses with relational parent overrides this to call CopyFoParent in their context parent*/ 
    method public void Copy(cntxt as IDataAdminContext):
        Parent:Copy(cntxt).                   
    end method.  
    
    method public void MoveQueries(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("MoveQueries in abstract filter context").
/*        Parent:MoveQueries(cntxt).*/
    end method.
    
    /* subclasses overrides copy(cntxt) to call this in their context parent 
     - should not be needed here (unless a filter can be parent) */     
    method public void CopyForParent(pcParent as char, pcValue as char,cntxt as IDataAdminContext):
        undo, throw new UnsupportedOperationError("CopyForParent in abstract filter context").
/*        Parent:CopyForParent(pcParent,pcValue,cntxt).*/
    end method.  
    
/*    method public void CopyTable(cntxt as IDataAdminContext):*/
/*        Parent:CopyTable(cntxt).                             */
/*    end method.                                              */
     
    method public void ForeignKeyChanged(pparentChange as IRowChange):
       
    end method.

    /* @TODO implement logic for query */    
    method public logical HasChanges().
          return TableHandle:before-table:has-records.
    end method.
   
    method public IDataAdminCollection NewCollection().
        undo, throw new UnsupportedOperationError("NewCollection in filtered context").
    end method.
   
    
    /* @TODO separate this out from IDataAdmincontext - */
    method public IDataAdminCollection GetCollection():
        return parent:GetCollection().
    end method.   
     
    method public final IDataAdminCollection GetCollection(filter as char).
        undo, throw new UnsupportedOperationError("GetCollection(filter) in filtered context").
    end method.
   
    method public final IDataAdminCollection GetCollection(preq as IRequestInfo).
        undo, throw new UnsupportedOperationError("GetCollection(IRequestInfo) in filtered context").
    end method.
    
    method public final IDataAdminCollection GetCollection(pParentRow as IRow, preq as IRequestInfo).
        undo, throw new UnsupportedOperationError("GetCollection(IRow,RequestInfo) in filtered context").
    end method.
   
    method public final IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as char,preq as IRequestInfo).    
        undo, throw new UnsupportedOperationError("GetCollection(parent,key,IRequestInfo) in filtered context").
    end method.
    
    method public final IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as char extent,preq as IRequestInfo).    
        undo, throw new UnsupportedOperationError("GetCollection(parent,key[],IRequestInfo) in filtered context").
    end method.
    
    method public final IDataAdminCollection GetCollection(pcparent as char,pkey as char).
        undo, throw new UnsupportedOperationError("GetCollection(parent,key) in filtered context").
    end method.
    
    method public final IDataAdminCollection GetCollection(pcparent as char,pkey as char extent).
        undo, throw new UnsupportedOperationError("GetCollection(parent,key[]) in filtered context").
    end method.
    
    method public final IDataAdminCollection GetChildCollection(ckey as char extent, child as char).
        undo, throw new UnsupportedOperationError("GetChildCollection with extent key in filtered context.").
    end method.    
    
    method public IDataAdminCollection GetChildCollection(pParent as IRow,preq as IRequestInfo): 
        undo, throw new UnsupportedOperationError("GetChildCollection with IRow and IRequestInfo in filtered context.").
    end method.    
   
    method public IDataAdminCollection GetChildCollection(pParent as IRow,child as char): 
        undo, throw new UnsupportedOperationError("GetChildCollection with IRow and child serializename in filtered context.").
    end method.    
  
    
    method public IDataAdminCollection GetChildCollection(ckey as char, child as char).
        define variable req as IRequestInfo no-undo.
        if this-object:Find(ckey) then
        do: 
            if valid-object(RequestInfo) then
                req = RequestInfo:Get(child). 
                
            if valid-object(req) then 
                return Parent:GetChildCollection(ckey,req).
            else        
                return Parent:GetChildCollection(ckey,child).
        end.
        return ?.
    end method.
    
    method public IDataAdminCollection GetChildCollection(ikey as int, child as char).
        define variable req as IRequestInfo no-undo.
        if this-object:Find(ikey) then
        do:
            if valid-object(RequestInfo) then
                req = RequestInfo:Get(child). 
            
            if valid-object(req) then 
                return Parent:GetChildCollection(ikey,req).
            else
                return Parent:GetChildCollection(ikey,child).
        end.
        return ?.
    end method.
    
    method public IDataAdminCollection GetChildCollection(ckey as char, pReq as IRequestInfo).
        if this-object:Find(ckey) then
        do:
            return Parent:GetChildCollection(cKey,pReq).
        end.
        return ?.
    end method.
    
    method public IDataAdminCollection GetChildCollection(ikey as int, pReq as IRequestInfo).
        if this-object:Find(ikey) then
        do:
            return Parent:GetChildCollection(iKey,pReq).
        end.
        return ?.
    end method.
    
    method public final IDataAdminCollection GetChildCollection(ckey as char extent, pReq as IRequestInfo).
        undo, throw new UnsupportedOperationError("GetChildCollection with extent key in filtered context.").
    end method.
     
    method public IFetchRequest GetRequest():
        return new FetchRequest(Name,Id,DatasetHandle).
    end method.
    
    /* @todo    */
    method public ISaveRequest GetSaveRequest():
        return Parent:GetSaveRequest().
    end method.
    
    method public void ValidateChanges(phDs as handle ):
        define variable hTopNavQuery as handle no-undo.
        define variable hBefNavQuery as handle no-undo.
        define variable hBefQuery as handle no-undo.
        define variable hBefore as handle no-undo.
        define variable hAfter as handle no-undo.
        
        hTopNavQuery = phDs:top-nav-query(TableHandle:name).
       
        hAfter = hTopNavQuery:get-buffer-handle(1).
        hBefore = hAfter:before-buffer.
        
        /* create the query to nav */
        hBefNavQuery = CreateBeforeNavQuery(hBefore,hTopNavQuery).
        /* create the query that matches this object */
       
        create Query hBefQuery.
        hBefQuery = CreateBeforeUpdQuery(hBefore).
       
        ValidateDeletes(hBefNavQuery,hBefQuery).
        ValidateQueryChanges(hTopNavQuery).   
        finally:
            delete object hBefNavQuery no-error.		
            delete object hBefQuery no-error.       
        end finally.
        
    end method.
    
    method protected handle CreateBeforeNavQuery(phBefore as handle, phOrigQuery as handle):
        define variable beforeQuery as BeforeQuery no-undo.
        define variable hQuery as handle no-undo.
        
        /* create the query to nav */
        create Query hQuery.
        hQuery:add-buffer(phBefore).
        beforeQuery = new BeforeQuery(phOrigQuery:prepare-string).
        hQuery:query-prepare (beforeQuery:GetQueryString()).
        return hQuery.
    end method.
    
    method protected handle CreateBeforeUpdQuery(input phBefore as handle):
        define variable beforeQuery as BeforeQuery no-undo.
        define variable hQuery as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
    
        create query hQuery.
        iMax = QueryHandle:num-buffers.
    
        do iLoop  = 1 to iMax:
            if phBefore:after-buffer:name = TableHandle:name then
                hQuery:add-buffer(phBefore).
            else    
                hQuery:add-buffer(QueryHandle:get-buffer-handle(iLoop)).
        end.
        beforeQuery = new BeforeQuery(QueryHandle:prepare-string).
        hQuery:query-prepare (beforeQuery:GetQueryString()).
        return hQuery.
  
    end method. 
    
    method protected handle CreateAfterQuery(input phAfterBuffer as handle):
        define variable hQueryClone as handle no-undo.        
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
    
        create query hQueryClone.
        iMax = QueryHandle:num-buffers.
    
        do iLoop  = 1 to iMax:
            if phAfterBuffer:name = TableHandle:name then
                hQueryClone:add-buffer(phAfterBuffer).
            else    
                hQueryClone:add-buffer(QueryHandle:get-buffer-handle(iLoop)).
        end.
        hQueryClone:query-prepare(QueryHandle:prepare-string).

      return hQueryClone.
    end method. 
    
    method protected final void ValidateDeletes(phNavQuery as handle,phOrigQuery as handle):
        define variable lok as logical no-undo.
        define variable hBuffer as handle no-undo.
        define variable rid as rowid no-undo.
        phNavQuery:query-open(). 
        phOrigQuery:query-open(). 
        phNavQuery:get-first.   
        hBuffer = phNavQuery:get-buffer-handle(1).    
        do while hBuffer:avail:
            if hBuffer:row-state = row-deleted then
            do:
                rid = hBuffer:rowid.
               /* the queries are working on the same buffer, so the record becomes unavail after
                  a repos.  (not allowed to create buffer for before tables)*/ 
                lok = phOrigQuery:reposition-to-rowid (rid) no-error.
                if not lok then
                do:
                    hbuffer:find-by-rowid(rid).
                    hbuffer:reject-row-changes.
                end.    
            end.
            phNavQuery:get-next.
        end.    
    end method.
    
    method public void ValidateQueryChanges(phQuery as handle):
        define variable hAfterbuffer as handle no-undo.
        define variable hBefore as handle no-undo.
        define variable lok as logical no-undo.
        
        define variable hQuery as handle no-undo.
        define variable hBefQuery as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        hAfterBuffer = phQuery:get-buffer-handle(1).
        hBefore =  hAfterBuffer:before-buffer.
        
        /* we use a copy query for reposition checks 
           subclasses may override to use the actual query (CreateContext)
           note: origin-rowid points to afterbuffer
                 parent records with no changes have no origin-rowid */  
         
        create buffer hbuffer for table hAfterBuffer.
        hQuery = CreateAfterQuery(hBuffer).
        hQuery:query-open(). 
        
        if valid-handle(hBefore) then
        do:    
            hBefQuery = CreateBeforeUpdQuery(hBefore).
            hBefQuery:query-open(). 
        end.
        
        phQuery:query-open(). 
        phQuery:get-first.        
        
        do while hAfterBuffer:avail:
            if hAfterBuffer:row-state = row-modified then
               lok = hBefQuery:reposition-to-rowid (hAfterBuffer:before-rowid) no-error.
            else
               lok = hQuery:reposition-to-rowid (hAfterBuffer:rowid) no-error.
            
            if lok then
                Model:ValidateRowChanges(hAfterBuffer,RequestInfo).
            else 
                RemoveUpdateBuffer(hAfterBuffer).
            phQuery:get-next.        
        end.
        finally:
            delete object hQuery no-error.		
            delete object hBuffer no-error.     
            delete object hBefQuery no-error. 
        end finally.    
    end method.
    
    method protected void RemoveUpdateBuffer(phBuffer as handle):
        define variable ichild as integer no-undo.
        define variable hRel   as handle no-undo.
        do iChild = 1 to phBuffer:num-child-relations:
            hRel = phBuffer:get-child-relation (ichild).
            hrel:query:query-open(). 
            hrel:query:get-first.
            do while hrel:child-buffer:avail:
                RemoveUpdateBuffer(hrel:child-buffer).
                hrel:query:get-next.
            end.    
        end.       
        phBuffer:buffer-delete(). 
    end method.    
    
    method public IDataAdminContext GetChild(name as char):
        return Parent:GetChild(name).
    end method.    
    
    method public void MergeChanges(pResponse as ISaveRequest):
        Parent:MergeChanges(pResponse).     
    end method.    
    
    method public void MergeChanges(phChangeDataset as handle):
        Parent:MergeChanges(phChangeDataset). 
    end method.    
    
    method public IDataAdminElement GetEntity(i as int):
        undo, throw new UnsupportedOperationError("GetEntity in filtered context").
    end method.
    
    method public logical Remove(phdl as handle):
         define variable hbuffer as handle no-undo. 
         if PositionToHandle(phdl) then
         do: 
             hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
             return Parent:Remove(hBuffer).
         end.
         return false.   
    end method.
    
    method public IDataAdminElement GetEntity(c as char).
        undo, throw new UnsupportedOperationError("GetEntity in filtered context"). 
    end method.
    
    method public IDataAdminElement GetEntity(preq as IRequestInfo).
        undo, throw new UnsupportedOperationError("GetEntity in filtered context"). 
    end method.
    
    method public char TransformQuery(pKeyWhere as char): 
        define variable QueryString as QueryString no-undo.       
        define variable cq as character no-undo.
        QueryString = new QueryString(pKeyWhere,this-object). 
        
        cq = QueryString:BuildQueryString(Tables).
        
        return cq.
        catch e as Progress.Lang.Error :
            HandleParseError(e,pKeyWhere). 
        end catch.
        
    end method. 
    
    method protected character GetJoinExpression(parentid as char).
        define variable cjoinFields as character no-undo.
        define variable i as integer no-undo.
        define variable cExpression as character no-undo.
        cJoinFields = GetJoinFields(parentid).
        if cJoinfields = "" then
             undo, throw new IllegalArgumentError("JoinFields not defined for parent " + quoter(parentid)).
           
        do i = 1 to extent(cJoinFields):
            cExpression = cExpression
                        + (if i = 1 then "" else " and ")
                        +  TableHandle:name + "." + entry(i * 2,cJoinFields)
                        + " = "    
                        +  parentid + "." + entry((i * 2) - 1,cJoinFields)
                        . 
        end. 
        return cExpression.
    end method.
    
    method private void HandleParseError(e as Error, filter as char):
         define variable cmsg as character no-undo.
         if type-of(e,IllegalArgumentError) then
            undo, throw e.
        
         cMsg = "Parsing of filter " + quoter(filter)  + " causes error "
              + "~n"
              +  e:GetMessage(1).
         undo, throw new IllegalArgumentError(cMsg,e).
    end method.    
    
    /** query rowids (may not be ordered by tables)   */ 
    method protected rowid extent GetQueryRowids (hquery as handle):
        define variable iBuffer as integer    no-undo.
        define variable rPosition as rowid extent no-undo.
     
        extent(rPosition) = hQuery:num-buffers.
     
        do iBuffer = 1 to hQuery:num-buffers:
            assign
                rPosition[iBuffer] =  hQuery:get-buffer-handle(ibuffer):rowid .
        end.
        return rPosition.
    end method.
 
    /** find the entity (factory method ) 
        Is considered internal.                    
        @param handle query or buffer that is positioned to the record to be found   */  
    method public IDataAdminElement FindEntity(phdl as handle).
         define variable hbuffer as handle no-undo. 
         if PositionToHandle(phdl) then
         do: 
            hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
            return Parent:FindEntity(hBuffer).
         end.
         return ?.    
    end method.
    
    method private logical PositionToHandle(phdl as handle).
        define variable lok as logical no-undo.
        define variable rrowids as rowid extent no-undo.
        define variable rsinglerowid as rowid extent 1 no-undo.
        define variable rfindrid as rowid extent no-undo.
        define variable hBuffer as handle no-undo.
        if phdl:type = 'query' then
        do:
           lok = (phdl = QueryHandle).
           if not lok then
           do: 
              rrowids = GetQueryRowids(phdl).
              lok = SetPosition(rrowids). 
           end.
        end.        
        else do:
            hBuffer = QueryHandle:get-buffer-handle(this-object:Table).
            lok = (hbuffer = phdl).
            if not lok then 
            do:
                rsinglerowid[1] = phdl:rowid.
                lok = SetPosition(rsinglerowid).
            end.             
        end.
        return lok.     
    end method.
    
    method public IDataAdminElement FindEntity(i as integer): 
        define variable hBuffer as handle no-undo.
        if this-object:Find(i) then 
        do:
            hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
            return Model:FindEntity(hBuffer,RequestInfo).
        end.
    end.
    
      /** find in current data (no service request)
           NOTE: The RequestInfo is only for support of find on alternate values
                 it is not stored in the instance and not used for collection filters  */
    method public IDataAdminElement FindEntity(req as IRequestInfo).
       define variable hBuffer as handle no-undo.
        if this-object:Find(req) then 
        do:
            /* NOTE we pass on this object's  RequestInfo 
              - not the one passed in parameter, whihc is used for find only */
            hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
            return Model:FindEntity(hBuffer,RequestInfo).
        end.
    end method.
    
    method public IDataAdminElement FindEntity(c as char): 
        define variable hBuffer as handle no-undo.
        if this-object:Find(c) then 
        do:
            hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
            return Model:FindEntity(hBuffer,RequestInfo).
        end.
    end.
    
    method public final IDataAdminElement FindEntity(c as char extent): 
        define variable hBuffer as handle no-undo.
        if this-object:Find(c) then 
        do:
            hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
            return Model:FindEntity(hBuffer,RequestInfo).
        end.
    end.
    
    method public final IDataAdminElement CreateRootEntity().
        undo, throw new UnsupportedOperationError("NewEntity() in filtered context"). 
    end method.
    
    method public final IDataAdminElement CreateRootEntity(c as char).
        undo, throw new UnsupportedOperationError("NewEntity(char) in filtered context"). 
    end method.
    
    method public final IDataAdminElement CreateRootEntity(i as int):
        undo, throw new UnsupportedOperationError("NewEntity(int) in filtered context"). 
    end method.
    
    method public final IDataAdminElement CreateRootEntity(pReq as IRequestInfo).
        undo, throw new UnsupportedOperationError("NewEntity(IRequestInfo) in filtered context"). 
    end method.
    
    method public final void CreateRootRow().
        undo, throw new UnsupportedOperationError("NewEntity() in filtered context"). 
    end method.
    
    method public final void CreateRootRow(c as char).
        undo, throw new UnsupportedOperationError("NewEntity(char) in filtered context"). 
    end method.
    
    method public final void CreateRootRow(i as int):
        undo, throw new UnsupportedOperationError("NewEntity(int) in filtered context"). 
    end method.
    
    method public final void CreateRootRow(pReq as IRequestInfo).
        undo, throw new UnsupportedOperationError("NewEntity(IRequestInfo) in filtered context"). 
    end method.
    /*
    method protected void ExportQuery(pcfile as char):
        define variable hOrigBuffer as handle no-undo.
        define variable hExpBuffer as handle no-undo.
        define variable hTbl as handle no-undo.
        
        hOrigBuffer = QueryHandle:get-buffer-handle (1).
        
        create temp-table htbl.
        /* hidden fields are inherited */
        htbl:create-like(hOrigBuffer).
        htbl:temp-table-prepare (hOrigBuffer:name).
        htbl:default-buffer-handle:serialize-name = SerializeName.    
        
        QueryHandle:get-first ().
        do while hOrigBuffer:avail:
            htbl:default-buffer-handle:buffer-create().
            htbl:default-buffer-handle:buffer-copy (hOrigBuffer).
            QueryHandle:get-next ().
        end.
        
        htbl:default-buffer-handle:write-json ("File",pcfile,yes).   
        
        finally:
            delete object htbl.
        end finally.
    end method.
    */
    method public void Export(pcfile as char,pcHidefields as char):
        define variable hflds as handle extent no-undo.
        define variable hUrlflds as handle extent no-undo.
        if pcHidefields > "" then
            hflds = Model:HideColumns(pcHidefields).
        
        if Total = ? and (valid-object(service) and service:url = "") then
        do:
            hUrlFlds = Model:HideUrlColumns().    
            ExportJSON(pcfile). 
            Model:ViewHiddenColumns(hUrlFlds).
        end.    
        else do:    
            ExportJSON(pcfile).
        end.
        if extent(hflds) <> ? then
            Model:ViewHiddenColumns(hflds).
    end method.
    
    method protected void ExportJSON(pcfile as char):
        define variable jsonRoot  as JsonObject no-undo.    
        jsonRoot   = new JsonObject(). 
        if valid-object(service) and service:url > "" then
            jsonRoot:Add("success",true). 
        if Total <> ? then 
            jsonRoot:Add("total",Total).  
        jsonRoot:Add(SerializeName,GetJsonArray()). 
        jsonroot:WriteFile(pcfile, TRUE).          
    end method.
    
    method protected JsonArray GetJsonArray():
        define variable hBuffer as handle no-undo.
        define variable jsonArray as JsonArray no-undo.    
        jsonArray  = new JSONArray().
        QueryHandle:get-first.
        hBuffer = QueryHandle:get-buffer-handle (this-object:Table).
        do while hBuffer:avail:
           jsonArray:Add(JsonRow(hBuffer)).
           QueryHandle:get-next.
        end.
        return jsonArray.
    end method.
    
    method protected JsonObject JSONROw(hBuffer as handle):
        define variable jsonRow   as JsonObject no-undo.
        define variable i         as integer no-undo.    
        define variable hfld as handle no-undo.
       
        define variable cChar as character no-undo.
        define variable dDec as decimal no-undo.
        define variable iInt as integer no-undo.
        define variable iInt64 as int64 no-undo.
        define variable lLog as logical no-undo.
        
        JsonRow = new JSONObject(). 
        
        do i = 1 to hbuffer:num-fields:
            hfld = hBuffer:buffer-field(i).
            if not hfld:serialize-hidden then
            do:
               case hfld:data-type: 
                   when "character" then
                   do:  
                       cChar = hfld:buffer-value.
                       JsonRow:Add(hfld:serialize-name,cChar).
                   end.
                   when "decimal" then
                   do:  
                       dDec = hfld:buffer-value.
                       JsonRow:Add(hfld:serialize-name,dDec).
                   end.
                   when "logical" then
                   do:  
                       llog = hfld:buffer-value.
                       JsonRow:Add(hfld:serialize-name,llog).
                   end.
                   when "integer" then
                   do:  
                       iInt = hfld:buffer-value.
                       JsonRow:Add(hfld:serialize-name,iInt).
                   end.
                   when "int64" then
                   do:  
                       iInt64 = hfld:buffer-value.
                       JsonRow:Add(hfld:serialize-name,iInt64).
                   end.
                    
               end.
            end.        
        end. 
        return JsonRow.
    end method.
    
    method public void ExportLastSavedTree(pcfile as char):
        Parent:ExportLastSavedTree(pcfile).     
    end method.
    
    method public void ExportNormalized(pcfilename as char):         
        Parent:ExportNormalized(pcfilename).
    end method.
    
    method public void ExportLastSaved(pcfile as char). 
        Parent:ExportLastSaved(pcfile).     
    end method.   
    
     /** convert expression for QueryString - unknown = keep as is */
    method public character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        return Parent:ColumnExpression(pcColumn,pcoperator,pcValue).
    end. 
    
    method public character ColumnSortSource(pcColumn as char).
        return Parent:ColumnSortSource(pcColumn).
    end method.   
       
    /* qualify columns for QueryString parsing */
    method public character ColumnSource(pcColumn as char):
        return Parent:ColumnSource(pccolumn).
    end method.
    
    method private void SearchContent (pid as char,input-output pqueryContext as IDataAdminContext): 
        if pid = ContentId then 
             pQuerycontext = this-object.
    end.
    
    /** override in child filtered queries*/
    method protected void SearchRequest (pRequestInfo as IRequestInfo,pcParent as char,pcKeys as char extent,input-output pqueryContext as IDataAdminContext): 
    end method. 
    /*
    method protected character extent GetKeyValues():
        define variable hBuffer as handle no-undo.
        hBuffer = QueryHandle:get-buffer-handle(this-object:Table).
        return GetKeyValues(hBuffer). 
    end method.
    
    method private character extent GetKeyValues(phBuffer as handle):
        define variable cKey as character no-undo.
        define variable hFld as handle no-undo. 
        define variable i as integer no-undo.
        define variable cValues as char extent no-undo.
        extent(cValues) = num-entries(KeyFields).
        do i = 1 to num-entries(KeyFields):
            hFld = phBuffer:buffer-field (entry(i,KeyFields)).
            cValues[1] = string(hfld:buffer-value).
        end.     
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("KeyFields does not match buffer" + e:GetMessage(1)).  
        end catch. 
    end method. 
 */
  
end class.
