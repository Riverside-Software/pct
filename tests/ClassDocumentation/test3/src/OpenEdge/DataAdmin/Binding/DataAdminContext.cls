/*************************************************************/
/* Copyright (c) 2011,2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /** ------------------------------------------------------------------------
    Purpose     : Default implementation of IDataAdminContext    
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Aug 07 16:54:55 EDT 2010
    Notes       : implements IDataAdminModel 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.

using Progress.Lang.* from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using Progress.Json.ObjectModel.JsonArray from propath.
using Progress.Json.ObjectModel.JsonConstruct from propath.
using Progress.Json.ObjectModel.ObjectModelParser from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminModel from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IRowChange from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath.
using OpenEdge.DataAdmin.Binding.RowBuffer from propath.
using OpenEdge.DataAdmin.Binding.RowChange  from propath.
 
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath.

using OpenEdge.DataAdmin.Error.DataError from propath.

using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Message.TableResponse from propath.

using OpenEdge.DataAdmin.Message.SaveRequest  from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Rest.IPageRequest from propath.
using OpenEdge.DataAdmin.Lang.BeforeQuery from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap from propath.
using OpenEdge.DataAdmin.Core.IElement from propath.

/** default implementation IDataAdminContextData implements IDataAdminModel */ 
class OpenEdge.DataAdmin.Binding.DataAdminContext abstract use-widget-pool implements IDataAdminContext,IDataAdminModel: 
    
    define public event RowCreated signature void (). 
    
    define public event RowDeleted signature void ().
    
    define public event BeforeDelete  signature void (rid as rowid). 
    define public event ContextDeleted signature void (). 
    
    define public event ContextRefreshed signature void (tblResponse as ITableResponse). 
       
    define public event AddedToContext signature void (newContext as IDataAdminContext). 
    define public event SearchQuery signature void (id as char,input-output queryContext as IDataAdminContext). 
    define public event SearchRequest signature void (Req as IRequestInfo,pcParent as char,pcKeys as char extent,input-output queryContext as IDataAdminContext). 
    define public event KeyChanged signature void (keyChange as IRowChange). 
       
    /** KeppInstacne decides whther to keep a reference to the entity in the tt.
        Set to true since as of current entities are not garbage collected due to the subscribtion
        to events here. There are probably no benefits from not keeping the reference here
        and it does improve performance if the object is retrieved more than once. */    
    define public property KeepInstances as logical no-undo 
        init true
        get. 
/*        set.*/
    
    define private variable LineFeed as character init "~r~n" no-undo.
     
	define public property LastSavedDataset as handle no-undo get. set.
    
    /* set to false if retrieved with parent on intstantiation */
    define public property Lazy as logical  no-undo  
        init true
        get.  
        set.
    
    define protected property SkipList as character no-undo 
        get. 
        set.     
    
    define private variable mChildContextList as IDataAdminContext extent no-undo. 
    
    define protected variable SaveDataset as handle no-undo.
    
    /* true on a secondary page request (not on the first request with only limit ) */
    define protected property PageRequested as logical  no-undo  
        get. 
        private set.
      
    define public property Total as integer no-undo 
        init ?  
        get. 
        protected set.
    
    define protected property NextPosition as character  no-undo  
        get. 
        private set.
        
    define protected property PrevPosition as character  no-undo  
        get. 
        private set.
        
    define protected property Loaded as logical  no-undo get. set. 
    
    define public property ContextScope as IContextScope no-undo
        get.
        private set.
    
    define protected property ServiceAdapter as ServiceAdapter no-undo
        protected get.
        private set.
    
    define protected property TargetAdapter as ServiceAdapter no-undo
        protected get.
        private set.
    
    define public property TargetService as IDataAdminService no-undo
          get.
          protected set.
       
	define abstract public property DatasetHandle as handle no-undo 
	    get.
	
	define abstract public property TableHandle as handle no-undo 
	    get.
	
	define  public property CanEditKey as logical no-undo 
        get.
	    protected set.
	    
	/* IIterable */
	define  public property Table as char no-undo 
        get():
            return TableHandle:Name.
        end.
    
	define public property BaseQuery as char no-undo 
        get():
            return "for each " + TableHandle:name.
        end.      
        set.
	
	define public property RootId as rowid no-undo 
        get.      
        private set.
    
	 /* set to false if retrieved with parent on instantiation */
    define public property ReadOnly as logical  no-undo  
        get():
            return not valid-handle(TableHandle:before-table).
        end.  
	
	/** iteratorHandle implements IIterable allows IIterator to use existing query or tablehandle */
    define public property IteratorHandle as handle  no-undo  
	    get():
            return TableHandle.
        end.
	
	define public property EntityFieldName as char no-undo 
	    get().
	        return "Entity".  
	    end.
	     
	define abstract public property KeyFields as character  no-undo  
	    get. 	
	    
	define public property IsLocal as logical no-undo 
        get.
        private set.
      
    define public property IsLocalShared as logical no-undo 
        get.
/*        private set.*/
        
	define public property SerializeName as character  no-undo  
	    get():
	        if valid-handle(TableHandle) then
	            return TableHandle:default-buffer-handle:serialize-name.
	        return "".
	    end. 
	     
	define abstract public property Count as integer no-undo  
	    get.	    
        protected set.
        
	define public property Service as IDataAdminService no-undo  
        get.
        protected set.
   
	 /* unique identifier, exposed as contextid for comparison
        of collections and entities */ 
    define public property Id            as character no-undo  
        get():
            if Id = "" then
            do:
                /* adding oe to avoid to easy access to widget-handle 
                   as this may change  (and TableHandle is public) */ 
                Id = string("OE" + string(TableHandle)).
            end.
            return Id.    
        end method.    
        private set. 
    
     /**  
        unique content identifier, exposed as Sourceid in collections. 
        Used to isolate updates in context.  
        Is the same as the Id for the Model itself 
     */ 
     define public property ContentId       as character no-undo  
        get():
             return id.
        end.    
        
    define public property Name as character no-undo 
        get.
        private set.
        
    /* @todo improve this - see usercontext  */   
	define protected variable mParent    as char no-undo. 
    define protected variable mParentKey as char no-undo. 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    constructor public DataAdminContext (pname as char):
        super ().
        IsLocal = true.
        this-object:Name = pname.    
    end constructor.
 
    constructor public DataAdminContext (pname as char, pscope as IContextScope):
         this-object(pname,pscope,pScope:IsLocal). 
    end constructor.
    
    constructor protected DataAdminContext (pname as char, pscope as IContextScope, plLocal as logical):
       super ().
        /*
        if not valid-object(pservice) then
            undo, throw new UnknownValueError("DataAdminContext constructor","service").
        if not valid-object(padapter) then
           undo, throw new UnknownValueError("DataAdminContext constructor","ServiceAdapter").
        */
        this-object:IsLocal = pscope:IsLocal.
        
        this-object:Name = pname.  
        this-object:ContextScope = pscope.
/*   true not supported yet     this-object:IsLocalShared = pScope:IsLocalShared.*/
        /* @todo improve this... ? */
        if plLocal then 
        do:
            TargetService = pscope:Service.
            TargetAdapter = pscope:ServiceAdapter.
        end.
        else 
        do:
            this-object:Service = pscope:Service.  
            this-object:ServiceAdapter = pscope:ServiceAdapter.        
        end.
        pscope:Service:ServiceDeleted:Subscribe(this-object:Destroy). 
                             
    end constructor.
    
    method protected void OnRowCreated():
        RowCreated:Publish().
    end method.    
    
    method protected void OnBeforeDelete():
        BeforeDelete:Publish(TableHandle:default-buffer-handle:rowid).
    end method.    
    
    method protected void OnRowDeleted():
        RowDeleted:Publish().
    end method.    
    
    method protected void FireContextRefreshed(pTbl as ITableResponse):
        ContextRefreshed:Publish(pTbl).
    end method.    
    
    method protected character GetCreateError(entity as IDataAdminElement, fldvalue as char):
        return GetCreateError(fldvalue). 
    end method.
    
    method protected character GetCreateError(fldvalue as char):
        return Name + " " + quoter(fldvalue) + " was not " 
               + (if valid-object(Service) 
                  then "created in service " + quoter(Service:Name) 
                  else "added to collection")
               + ".". 
    end method.
    
    /* Client key - external key - for import 
       now this should really be a property... 
       method is used since it is rarely overridden */
    method protected character GetClientKeyFields():
        return KeyFields. 
    end method.
    
    method public abstract character GetJoinFields(parenturl as char).
    
    /* override for external join - for example json import  */  
    method protected character GetClientJoinFields(parenturl as char).
        return GetJoinFields(parenturl).
    end method.
    
    /* override if server join is different - */  
    method protected character GetServerJoinFields(parenturl as char).
        return GetJoinFields(parenturl).
    end method.
    
   
/*    method public handle GetIteratorHandle():*/
/*        return TableHandle.                  */
/*    end method.                              */
    
    method public abstract void CreateRow(entity as IDataAdminElement).
    
    /**  Create row with key - used by CreateRootEntity */
    method final public void CreateRootRow(pName as char):
        define variable hbuffer as handle no-undo.
        hBuffer = TableHandle:default-buffer-handle.
/*        hBuffer:buffer-release().*/
        InitRow(pname).      
        RegisterRow(hBuffer:rowid). 
        catch e as Progress.Lang.Error :
            InitNewError(e,pname).
        end catch.
    end method.
    
    method private void RegisterRow(pr as rowid):
        if not IsLocalShared then
        do:
            RootId = pr.                    
        end.
        
    end method.
    
    method private void InitNewError(e as Error,pckey as char):
        define variable hbuffer as handle no-undo.
        define variable cmsg as character no-undo.
        define variable cmsg2 as character no-undo.        
        define variable hfld  as handle no-undo.
        define variable err as AppError no-undo.
        hBuffer = TableHandle:default-buffer-handle.
        if hBuffer:avail then
           hBuffer:buffer-delete().             
         
         cmsg = replace(e:GetMessage(1),TableHandle:name,name).
         if e:GetMessageNum(1) = 132 and IsLocalShared then
         do:
             hfld = hbuffer:buffer-field(KeyFields) no-error.
             
             if hFld:data-type = "character" then 
                 pcKey = quoter(pcKey).
             entry(2,cMsg,".") = "".
             cMsg = right-trim(cMsg,".").
             cMsg = " A new " + name + " with " + KeyFields + " " + pcKey + " is already active for this service.".  
             undo, throw new IllegalArgumentError(cMsg). 
         end.
         cMsg2 = " The new " + name + " could not be initialized for the service.".  
         Err = new IllegalArgumentError(cMsg2).  
         Err:AddMessage(cmsg,?).
         undo, throw Err. 
    
    end method.
    
    /**  Create row with key - used by CreateRootRow */
    method protected void InitRow(pName as char):
        define variable hField as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        if num-entries(KeyFields) > 1 then 
            undo, throw new UnsupportedOperationError("CreateRow(character) with multiple KeyFields").      
        hBuffer = TableHandle:default-buffer-handle.
        hfield = hBuffer:buffer-field(KeyFields). 
        if hField:data-type <> "character" then 
            undo, throw new UnsupportedOperationError("CreateRow(character) cannot be used on key field " + hField:name + ", which is of data type " + hField:data-type + ".").      
        hBuffer:buffer-create().
        hField:buffer-value = pname.
    end method.
    
    method public void CreateRootRow():
        define variable hbuffer as handle no-undo.
        hBuffer = TableHandle:default-buffer-handle.
        InitRow().      
        RegisterRow(hBuffer:rowid). 
        catch e as Progress.Lang.Error :
            InitNewError(e,"").
        end catch.
 
    end method.
    
    /**  Create row  - used by CreateRootRow  - override if needed */
    method protected void InitRow():
        undo, throw new UnsupportedOperationError("CreateRow with no parameters is not supported in " + GetClass():TypeName).      
      
/*        define variable hBuffer as handle no-undo.  */
/*        hBuffer = TableHandle:default-buffer-handle.*/
/*        do transaction:                             */
/*            hBuffer:buffer-create().                */
/*        end.                                        */
    end method.
    
    /**  Create row with key - used by CreateRootEntity */
    method final public void CreateRootRow(pId as int):
        define variable hbuffer as handle no-undo.
        hBuffer = TableHandle:default-buffer-handle.
        InitRow().
        RegisterRow(hBuffer:rowid). 
        catch e as Progress.Lang.Error :
            InitNewError(e,string(pid)).
        end catch.
 
    end method.
    
    /**  Create row with key - used by CreateRootRow */
    method protected void InitRow(pId as int):
        define variable hField as handle no-undo.
        define variable hBuffer as handle no-undo.
        if num-entries(KeyFields) > 1 then 
            undo, throw new UnsupportedOperationError("CreateRow(integer) with multiple KeyFields").      
        hBuffer = TableHandle:default-buffer-handle.
        hfield = hBuffer:buffer-field(KeyFields). 
        if hField:data-type <> "integer" then 
            undo, throw new UnsupportedOperationError("CreateRow(integer) cannot be used on key field " + hField:name + ", which is of data type " + hField:data-type + ".").      
         
        hBuffer:buffer-create().
        hField:buffer-value = pId.
   
    end method.
       
     /**  Create row with IRequestInfo - used by CreateRootEntity */
    method public void CreateRootRow(pReq as IRequestInfo):
        define variable hbuffer as handle no-undo.
        define variable cVal as character extent no-undo.
        hBuffer = TableHandle:default-buffer-handle.
        InitRow(pReq).
        RegisterRow(hBuffer:rowid). 
        catch e as Progress.Lang.Error :
            cVal = pReq:GetKeyValues(). 
            InitNewError(e,cVal[1]).
        end catch.
    end method.

    /**  Create row with key - used by CreateRootRow */
    method protected void InitRow(pReq as IRequestInfo):
        define variable hField as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable cKeys as character extent no-undo. 
        /* @todo - check index instead - if unique allow  (adm2 dataset.p has code)*/
        if num-entries(Preq:KeyFields) > 1 then 
            undo, throw new UnsupportedOperationError("CreateRow from RequestInfo with multiple key values").      
        
        /* @todo - check index instead - if unique allow  (adm2 dataset.p has code)*/
        if KeyFields <> Preq:KeyFields then 
        do:
            undo, throw new UnsupportedOperationError("CreateRow from RequestInfo with different key fields").      
        end.       
        hBuffer = TableHandle:default-buffer-handle.
        hfield = hBuffer:buffer-field(KeyFields).
        cKeys =  pReq:GetKeyValues().
        hBuffer:buffer-create().
        hField:buffer-value = cKeys[1].
    end method.
    
    /** Delete 
    */  
    
    method public logical Delete(pNum as integer):
       
        if this-object:Find(pNum) then
        do:  
            return Remove().          
        end.
        return false.
    end method.
    
    method public logical Delete(name as character):
       
        if this-object:Find(name) then
        do:  
            return Remove().          
        end.
        return false.
    end method.
    
    /** Delete 
        @param name extent for multi-component keys
    */  
    
    method public logical Delete(name as character extent):
       
        if this-object:Find(name) then
        do:  
            return Remove().          
        end.
        return false.
    end method.
    
    /** subclasses must implement CopyTable that throws DataError if 
       any of the records exists and that works also when the 
       source (or target) has changes 
       (temp-table-copy does not handle any of these requirements) 
       @TODO - protected ?
       */  
    method protected abstract void CopyTable(cntxt as IDataAdminContext).
    
    /** @TODO Make abstract - currently calls default since many collections handle parent 
                             with settable <Entity> property  
      - override to set from FilteredContext:ParentValue */
    method protected void CopyTableForParent(pparent as char, pValue as char,cntxt as IDataAdminContext):
        CopyTable(cntxt).
    end method.   
    
    /** @TODO Make abstract -    
      - override to set from FilteredContext:ParentRow*/
    method protected void CopyTableForParent(pRow as IRow,cntxt as IDataAdminContext):
        undo, throw new UnsupportedOperationError("CopyTableForParent with IRow."). 
    end method.   
    
    /** add foreign key for parent (called from filteredContext:copy with parentvalue) 
       NOTE: the copy wil copy all records from the passed context assuming all records 
             belongs to the passed parent value (only local context should be passed) */
    method final public void CopyForParent(pRow as IRow,cntxt as IDataAdminContext):
        if cntxt = this-object then 
             undo, throw new UnsupportedOperationError("Cannot copy to itself"). 
        
        CopyTableForParent(pRow,cntxt).
        CopyChildren(cntxt).
        /** hack for Newcontext call back to GetKeywhere */
        mParent = pRow:SerializeName.
        mParentKey = pRow:KeyValue.
        cntxt:MoveQueries(this-object).
        finally:
            mParent = "".
            mParentKey = "".
        end finally.        
    end method.
    
    /** add foreign key for parent (called from filteredContext:copy with parentvalue) 
       NOTE: the copy wil copy all records from the passed context assuming all records 
             belongs to the passed parent value (only local context should be passed) */
    method public final void CopyForParent(pparent as char, pValue as char,cntxt as IDataAdminContext):
        if cntxt = this-object then 
             undo, throw new UnsupportedOperationError("Cannot copy to itself"). 
        
        CopyTableForParent(pparent,pvalue,cntxt).
        CopyChildren(cntxt).
        /** hack for Newcontext call back to GetKeywhere */
        mParent = pparent.
        mParentKey = pvalue.
        cntxt:MoveQueries(this-object).
        finally:
            mParent = "".
            mParentKey = "".
        end finally.        
    end method.
          
    /** This is not intended for general copy, but used specifically to move new objects/records from local 
       context to this context (including children). This could be both a local or service context.
       A new entity with its own context can be copied/added to a new collection with its own local context.
       A new entity with a local context can also be copied directly to the service context.
       A new collection is only copied to a service context.
       (A new entity without context uses createrow to achieve this) 
      - The passed context is no longer in use after this operation  */
    method public void Copy(cntxt as IDataAdminContext):
        CopyTable(cntxt).
        CopyChildren(cntxt).
        cntxt:MoveQueries(this-object).
    end method.    
    
    method public void MoveQueries(cntxt as IDataAdminContext).
        AddedToContext:Publish(cntxt).
    end method.
    
    method protected void CopyChildren(cntxt as IDataAdminContext):
        define variable i as int no-undo.
        define variable cname as character no-undo.
        define variable childcntxt as IDataAdminContext no-undo.
        do i = 1 to extent(mChildContextList):       
            cName = mChildContextList[i]:SerializeName.
            if lookup(cName,SkipList) = 0 then
            do:  
                childcntxt = cntxt:GetChild(cName).
            
                if valid-object(childcntxt)   then
                    mChildContextList[i]:Copy(childcntxt).
            end.
        end. 
        Loaded = false. 
    end method.    
    
    method public void ForeignKeyChanged(pparentChange as IRowChange):
        define variable hQuery as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable cQuery as character no-undo.
        define variable cChildJoinFields as character no-undo.
        define variable lTrack as logical no-undo init ?.
        define variable i as integer no-undo. 
        
        create query hquery.
        create buffer hBuffer for table TableHandle.
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = false.
        hQuery:add-buffer(hBuffer).
        cQuery = GetChildQuery(pparentChange:SerializeName,pparentChange:OldKeyValues).
        cQuery = "for " + TrimQuery(cQuery).
        cChildJoinFields = GetChildJoinFields(pparentChange:SerializeName).
        hQuery:query-prepare(cQuery).
        hQuery:query-open().
        hQuery:get-first().
        
        do while hBuffer:avail:
            /* @todo if keyfields in THIS changed as part of this
               Keychanged:publish -  */
            SetValues(hBuffer,cChildJoinFields,pparentChange:KeyValues).                   
            hQuery:get-next().
            
        end.    

        finally:
            if lTrack <> ? then
                TableHandle:tracking-changes = lTrack.
            delete object hQuery.
            delete object hBuffer.
        end finally.
    end method.
    
    /* trim off for or preselect */
    method private char TrimQuery(pcQuery as char):
        pcQuery = left-trim(pcQuery).
        entry(1,pcQuery," ") = "".
        return left-trim(pcQuery).
    end.
    
    method public character GetChildJoinFields(parentid as char):
        define variable cJoinFields as character no-undo.
        define variable cChildFields as character no-undo.
        define variable cChildField as character no-undo.
        define variable i as integer no-undo.
        cJoinfields = GetJoinFields(parentid).
        do i = 1 to num-entries(cJoinfields) by 2:
            cChildField = entry(i + 1,cJoinFields).
            cChildFields = cChildFields + "," + cChildField.
        end.   
        return left-trim(cChildFields,",").
    end method.
    
    method public logical CanFind(i as int):
        undo, throw new UnsupportedOperationError("CanFind with integer key").
    end method. 
    
    method public logical Find(i as int):
        undo, throw new UnsupportedOperationError("Find with integer key").
    end method. 
    
    method public logical Find(preq as IRequestInfo):
        define variable lok as logical no-undo.
        define variable cWhere as character no-undo.
        if preq:KeyFields = ""  or preq:KeyFields = ? then
            undo, throw new IllegalArgumentError("RequestInfo with no key expression passed to find."). 
        cWhere = GetWhere(preq:KeyFields,preq:GetKeyValues()). 
      
        /* @todo  - ensure not exposing hidden internal fields (?) */
        lok = Tablehandle:default-buffer-handle:find-unique("where " + cWhere) no-error. 
        if error-status:error and error-status:get-number (1) <> 138 then
        do: 
            undo, throw CreateFindError(error-status:get-message(1),error-status:get-number (1),preq).
        end.  
        return lok.
    end method.    
    
    method public logical Find(c as char):
        define variable lok as logical no-undo.
        if num-entries(KeyFields) > 1 then 
            undo, throw new UnsupportedOperationError("Find with char key. " + this-object:GetClass():TypeName + " has multiple KeyFields").
        else do:
            lok = TableHandle:default-buffer-handle:find-unique("where " + TableHandle:name + "." + KeyFields + " = " + quoter(c)) no-error. 
            return lok.
        end.    
        return false.
    end method. 
    
    method public logical Find(c as char extent):
        define variable lok as logical no-undo.       
        lok = Tablehandle:default-buffer-handle:find-unique("where " + GetKeyWhere(c)) no-error. 
        return lok. 
    end method. 
    
    /** FindOrigin - find row from origin rowid in row extracted with getchanges  
       @param rOriginid rowid from row in change dataset   */
    method public logical FindOrigin(rOriginid as rowid).
        define variable hBefore as handle no-undo. 
        define variable lok     as logical no-undo.
        if valid-handle(TableHandle:before-table) then
        do:
           hBefore = TableHandle:before-table:default-buffer-handle.
           lok = hBefore:find-by-rowid(rOriginid) no-error.  
           if lok then
           do:
               TableHandle:default-buffer-handle:find-by-rowid(hBefore:after-rowid).
               return true.   
           end.
           return false. 
        end.
        else
            undo, throw new IllegalArgumentError("Find Origin called in non updatable context " + SerializeName).
   
    end method. 
    
    method public logical CanFind(c as char):
        undo, throw new UnsupportedOperationError("CanFind with character key").
    end method. 
    
    method public void AddTableTo(tree as IContextTree):
        tree:setHandle(SerializeName,TableHandle:default-buffer-handle).
    end method.    
    
    method public void AddRowTo(tree as IContextTree,prid as rowid).
        tree:setHandle(SerializeName,TableHandle:default-buffer-handle,prid).
    end method.    
    
    method protected handle CreateDataset(pcCollections as char):
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        AddTreeTo(tree,pcCollections). 
        return tree:GetReadHandle().
    end method.
    
    method protected handle CreateDataset():
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().  
        tree:Parse = true.       
       
        AddTreeTo(tree).
/*        message tree      */
/*        view-as alert-box.*/
        return tree:GetReadHandle().
    end method.
    
    method protected handle CreateSaveDataset():
        return CreateDataSet(). 
    end method.
    
    method public void AddTreeTo(tree as IContextTree).
        define variable i as integer no-undo.
        define variable cname as character no-undo.
        AddTableTo(tree).
              
        do i = 1 to extent(mChildContextList):
            
            if lookup(mChildContextList[i]:SerializeName,SkipList) = 0 then
                mChildContextList[i]:AddTreeTo(tree,this-object).
              
        end.
    end method.    
   
    method public void AddTreeTo(tree as IContextTree,parent as IDataAdminContext).
        define variable msg as IFetchRequest no-undo.
        tree:SetJoin(Parent:SerializeName,Serializename,GetJoinFields(Parent:SerializeName)).
        
        if Lazy and valid-object(Service) and tree:Parse = false  then
        do: 
            msg = GetRequest().
            FetchData(msg).
        end.    
        
        AddTreeTo(tree).
    end method.    
    
    method public void AddTreeTo(tree as IContextTree,parent as IDataAdminContext,pcCollections as char).
        define variable msg as IFetchRequest no-undo.
        tree:SetJoin(Parent:SerializeName,Serializename,GetJoinFields(Parent:SerializeName)).
        
        if Lazy and valid-object(Service) and tree:Parse = false then
        do: 
            msg = GetRequest().
            FetchData(msg).
        end.    
        
        AddTreeTo(tree,pcCollections).
    end method.    
    
    method public void AddTreeTo(tree as IContextTree,pcCollections as char).
        define variable i as integer no-undo.
        AddTableTo(tree).
        do i = 1 to extent(mChildContextList):
            if lookup(mChildContextList[i]:SerializeName,pcCollections) > 0 then
                mChildContextList[i]:AddTreeTo(tree,this-object).
        end.
    end method.    
                                                      
    method public void WriteTo(writer as IContextWriter):
        define variable cName as character no-undo. 
        cName = TableHandle:serialize-name.
        writer:WriteHandle(cName,DatasetHandle).
    end method.
        
    method public void WriteRowTo(writer as IContextWriter,pcKey as char):
        define variable cName as character no-undo. 
        define variable rid as rowid no-undo.
        cName = TableHandle:serialize-name.
        if this-object:Find(pcKey) then
        do: 
            rid = TableHandle:default-buffer-handle:rowid.
            writer:WriteBuffer(cName,TableHandle:default-buffer-handle,rid).
        end.
    end method.
    
    method public void WriteRowTo(writer as IContextWriter,piKey as int):
        define variable cName as character no-undo. 
        define variable rid as rowid no-undo.
        cName = TableHandle:serialize-name.
        if this-object:Find(piKey) then
        do: 
            rid = TableHandle:default-buffer-handle:rowid.
            writer:WriteBuffer(cName,TableHandle:default-buffer-handle,rid).
        end.
    end method.
    
    method public IFetchRequest GetRequest():
        return new FetchRequest(Name,Id,DatasetHandle).
	end method.
	
	method public ISaveRequest GetSaveRequest():
	    define variable hchanges as handle no-undo.
	    define variable savemsg as ISaveRequest no-undo.
	    
	    delete object SaveDataset no-error.
	    SaveDataset = CreateSaveDataset().       
	    hchanges = GetChanges(SaveDataset).
	     
	    savemsg = new SaveRequest(Name,Id,hchanges).
      
        return savemsg.
    end method.
    
    method public ISaveRequest GetSaveRequest(pid as char):
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
       
        hchanges = GetSaveChanges(pid).
        if valid-handle(hChanges) then 
            savemsg = new SaveRequest(Name,Id,hchanges).
        return savemsg.  
    end method.   
   
    method public ISaveRequest GetSaveRowRequest(pcKey as char,pReq as IRequestInfo):
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
               
        hchanges = GetSaveRowChanges(pcKey,pReq).
        if valid-handle(hChanges) then 
           savemsg = new SaveRequest(Name,Id,hchanges).
        
        return savemsg.  
        
    end method.   
    
    method public ISaveRequest GetSaveRowRequest(pRow as IRow,pReq as IRequestInfo):
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
        hchanges = GetSaveRowChanges(pRow,pReq,row-modified). 
        if valid-handle(hChanges) then 
            savemsg = new SaveRequest(Name,Id,hchanges).
        return savemsg.  
    end method.   
    
    method public ISaveRequest GetCreateRowRequest(pRow as IRow):
        define variable hchanges as handle no-undo.
        define variable savemsg  as ISaveRequest no-undo.
        hchanges = GetSaveRowChanges(pRow,?,row-created).
        if valid-handle(hChanges) then 
           savemsg = new SaveRequest(Name,Id,hchanges).
        return savemsg.  
    end method.   
    
    method public ISaveRequest GetCreateRowRequest():
        define variable hchanges as handle no-undo.
        define variable savemsg  as ISaveRequest no-undo.
        define variable cKey     as character no-undo.
        define variable hField    as handle no-undo.
        
        if num-entries(KeyFields) > 1 then 
        do:
            undo, throw new IllegalArgumentError("GetCreateRowRequest() with multiple keys. ").
        end.    
        if TableHandle:default-buffer-handle:row-state <> row-created then
            undo, throw new IllegalArgumentError("GetCreateRowRequest with new row in context not available.").
        
        hField = TableHandle:default-buffer-handle:buffer-field(KeyFields).
        hchanges = GetSaveRowChanges(hField:buffer-value,?).
        if valid-handle(hChanges) then 
           savemsg = new SaveRequest(Name,Id,hchanges).
        return savemsg.  
    end method.   
    
    method public ISaveRequest GetDeleteRowRequest(pRow as IRow,pReq as IRequestInfo):
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
       
        hchanges = GetDeleteRowChanges(pRow,pReq).
        if valid-handle(hChanges) then 
            savemsg = new SaveRequest(Name,Id,hchanges).
        return savemsg.  
    end method.   
   
    method protected handle GetSaveChanges(pid as char):
        define variable hchanges   as handle    no-undo.
        define variable hNavQuery  as handle    no-undo.
        define variable childcntxt as IDataAdminContext no-undo.
       
        delete object SaveDataset no-error.
       
        SaveDataset = CreateSaveDataset().       
        hchanges = GetChanges(SaveDataset).
         
        if Contentid <> pid then 
        do:
            SearchQuery:Publish(pid,input-output childcntxt).            
            childcntxt:ValidateChanges(hChanges).        
        end.    
        else 
            ValidateChanges(hChanges).        
        return hChanges.
    end method.
    
    method protected handle GetDeleteRowChanges(pRow as IRow,pReq as IRequestInfo):
        define variable hchanges   as handle    no-undo.
        define variable hTopNavQuery as handle no-undo.
        define variable hAfter as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable rBefOrig as rowid no-undo.
        define variable rAfter     as rowid no-undo.
        
        delete object SaveDataset no-error.
        SaveDataset = CreateSaveDataset().       
        hchanges = GetChanges(SaveDataset).
        hTopNavQuery = hchanges:top-nav-query(TableHandle:name).
        RemoveAfterBuffers(hTopNavQuery).
        hAfter = hTopNavQuery:get-buffer-handle(1).
        
        if valid-handle(hAfter:before-buffer) then 
           RemoveDeletes(hAfter:before-buffer,prow). 
        
        return hchanges.
    end method.
    
    method protected handle GetSaveRowChanges(pRow as IRow,pReq as IRequestInfo,pstate as int):
        define variable hchanges   as handle    no-undo.
        define variable hTopNavQuery as handle no-undo.
        define variable hAfter as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable rBefOrig as rowid no-undo.
        define variable rAfter     as rowid no-undo.
        define variable lok as logical no-undo.
        if this-object:Find(pRow:KeyValues) then
        do:
            hBuffer = TableHandle:default-buffer-handle.
            
            if pstate <> hBuffer:row-state then
            do:
                if pstate = row-created then
                    undo, throw new IllegalArgumentError("GetSaveRowChanges for create called with new row in context not available.").
            end.     
            
            delete object SaveDataset no-error.
            SaveDataset = CreateSaveDataset().       
            hchanges = GetChanges(SaveDataset).
            hTopNavQuery = hchanges:top-nav-query(TableHandle:name).
             
            if hBuffer:row-state = 0 then 
            do: 
                 rAfter = FindRidAndRemoveOtherAfterBuffers(hTopNavQuery,prow).
            end.
            else do:     
                 rBefOrig = hBuffer:before-rowid.
                 rAfter = FindRidAndRemoveOtherAfterBuffers(hTopNavQuery,rBefOrig).
            end.
            hAfter = hTopNavQuery:get-buffer-handle(1).
            
            if valid-handle(hAfter:before-buffer) then
                RemoveDeletes(hAfter:before-buffer,?). 
            lok = hAfter:find-by-rowid(rAfter) no-error.
            if lok then 
            do:
                ValidateRowChanges(hAfter,pReq).   
            end.
            return hChanges.
        end.
            
    end method.
    
    method protected handle GetSaveRowChanges(pcKey as char,pReq as IRequestInfo):
        define variable hchanges   as handle    no-undo.
        define variable hTopNavQuery as handle no-undo.
        define variable hAfter as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable rBefOrig as rowid no-undo.
        define variable rAfter     as rowid no-undo.
        define variable lok as logical no-undo.
        
        if this-object:Find(pcKey) then
        do:
            hBuffer = TableHandle:default-buffer-handle.
            
            delete object SaveDataset no-error.
            SaveDataset = CreateSaveDataset().       
            hchanges = GetChanges(SaveDataset).
            hTopNavQuery = hchanges:top-nav-query(TableHandle:name).
             
            if hBuffer:row-state = 0 then 
            do:
                 rAfter = FindRidAndRemoveOtherAfterBuffers(hTopNavQuery,pcKey).
            end.
            else do:     
                 rBefOrig = hBuffer:before-rowid.
                 rAfter = FindRidAndRemoveOtherAfterBuffers(hTopNavQuery,rBefOrig).
            end.
            hAfter = hTopNavQuery:get-buffer-handle(1).
            
            if valid-handle(hAfter:before-buffer) then
               RemoveDeletes(hAfter:before-buffer,?). 
            lok = hAfter:find-by-rowid(rAfter) no-error.
            if lok then 
            do:
                ValidateRowChanges(hAfter,pReq).   
            end.
            return hChanges.
        end.
            
    end method.
    
    method protected final rowid FindRidAndRemoveOtherAfterBuffers(phTopNavQuery as handle,porigrid as rowid):
        define variable hAfter as handle no-undo.
        define variable rAfter as rowid no-undo. 
        phTopNavQuery:query-open(). 
        phTopNavQuery:get-first.        
        hAfter = phTopNavQuery:get-buffer-handle(1).
        do while hAfter:avail:
           
           if hAfter:origin-rowid = porigrid then
           do:
              rAfter = hAfter:rowid.
           end.
           
           else  
              RemoveRow(hAfter).
           
           phTopNavQuery:get-next.
        end. 
        return rAfter. 
    end method.        
    
    method protected final rowid FindRidAndRemoveOtherAfterBuffers(phTopNavQuery as handle,pKey as char):
        define variable hAfter as handle no-undo.
        define variable rAfter as rowid no-undo. 
        define variable hField as handle no-undo.
        if pKey > "" and num-entries(KeyFields) > 1 then 
        do:
            undo, throw new IllegalArgumentError("Single row update with multiple keys and child changes only.").
        end.    
      
        phTopNavQuery:query-open(). 
        phTopNavQuery:get-first.        
        
        hAfter = phTopNavQuery:get-buffer-handle(1).
        if pKey > "" then
            hField = hAfter:buffer-field (KeyFields).
        
        do while hAfter:avail:
           if not valid-handle(hField) or hField:buffer-value <> pKey then
           do:
               RemoveRow(hAfter).
           end.
           else  
               rAfter = hAfter:rowid.
           
           phTopNavQuery:get-next.
        end. 
        return rAfter. 
    end method.        
    
    method protected final rowid FindRidAndRemoveOtherAfterBuffers(phTopNavQuery as handle,pRow as IRow):
        define variable hAfter as handle no-undo.
        define variable rAfter as rowid no-undo. 
        define variable hField as handle extent no-undo.
        define variable cField as character no-undo.
        define variable i       as integer no-undo.
        define variable lRemove as logical no-undo.
        define variable cValues as character no-undo.
        phTopNavQuery:query-open(). 
        phTopNavQuery:get-first.        
        hAfter = phTopNavQuery:get-buffer-handle(1).
        if valid-object(pRow)  then
        do:
            extent(hField) = extent(pRow:KeyValues).
            do i = 1 to num-entries(pRow:KeyFields).
                cField = entry(i,pRow:KeyFields).
                hField[i] = hAfter:buffer-field (cField ).
            end.
        end.
        do while hAfter:avail:
           lRemove = false.
           if extent(hField) = ? then 
               lRemove = true.
           else 
           do: 
               do i = 1 to num-entries(pRow:KeyFields):
                   if hField[i]:buffer-value <> pRow:KeyValues[i] then
                   do:
                       lRemove = true.
                       leave.              
                   end.
               end. 
           end.
           if lRemove then  
               RemoveRow(hAfter).
           else  
               rAfter = hAfter:rowid.
           
           phTopNavQuery:get-next.
        end. 
        return rAfter. 
    end method.        
    
    method protected final void RemoveAfterBuffers(phTopNavQuery as handle):
        define variable hAfter as handle no-undo.
        define variable rAfter as rowid no-undo. 
        phTopNavQuery:query-open(). 
        phTopNavQuery:get-first.        
        hAfter = phTopNavQuery:get-buffer-handle(1).
        do while hAfter:avail:
           RemoveRow(hAfter).
           phTopNavQuery:get-next.
        end. 
    end method.        
    
    method protected final void RemoveDeletes(phBefore as handle,pRow as IRow):
        define variable lok as logical no-undo.
        define variable hBuffer as handle no-undo.
        define variable hNavQuery as handle no-undo.
        define variable cField as char no-undo.
        define variable hField as handle extent no-undo.
        define variable i      as integer no-undo.
        define variable lDelete as logical no-undo. 
        
        if not valid-handle(phBefore) then 
        do:
            undo, throw new IllegalArgumentError("Cannot delete row for invalid handle.").        
        end.    
                
        create query hNavQuery.
        hNavQuery:add-buffer(phBefore).
        hNavQuery:query-prepare ("for each " + phBefore:name).
        
        hNavQuery:query-open(). 
        hNavQuery:get-first.   
        hBuffer = hNavQuery:get-buffer-handle(1).    
        
        if valid-object(pRow) then
        do:
            extent(hField) = num-entries(pRow:KeyFields).
            do i = 1 to num-entries(pRow:KeyFields).
                cField = entry(i,pRow:KeyFields).
                hField[i] = hBuffer:buffer-field (cField ).
            end.
        end.
        
        do while hBuffer:avail:
            lDelete = false.
            if hBuffer:row-state = row-deleted then
            do:
                if not valid-object(pRow) then
                    lDelete = true.
                else do:
                    lDelete = false.
                    do i = 1 to extent(pRow:KeyValues):
                        if hfield[i]:buffer-value <> pRow:KeyValues[i] then
                        do:
                            lDelete = true.
                            leave.
                        end.       
                    end.
                end.    
                if lDelete then
                    hbuffer:reject-row-changes.
            end.
            hNavQuery:get-next.
        end.    
        
        finally:
            delete object hNavQuery no-error.        
        end finally.
    end method.
    
    method public void ValidateChanges(phDs as handle ):
        define variable hquery as handle no-undo.
        hQuery = phDs:top-nav-query(TableHandle:name).
        ValidateQueryChanges(hQuery).   
    end method.
    
    method public void ValidateQueryChanges(phQuery as handle):
        phQuery:query-open(). 
        phQuery:get-first.        
        do while phQuery:get-buffer-handle(1):avail:
            ValidateRowChanges(phQuery:get-buffer-handle(1),?).
            phQuery:get-next.        
        end.    
    end method.
    
    method public void ValidateRowChanges(hBuffer as handle,pReq as IRequestInfo):
        define variable ichild as integer no-undo.
        define variable hRel   as handle no-undo.        
        define variable childReq     as IRequestInfo no-undo.        
        define variable childContext as IDataAdminContext no-undo.
         
        if hBuffer:row-state > 0 then
            ValidateBuffer(hbuffer).
            
        do iChild = 1 to hBuffer:num-child-relations:
            hRel = hBuffer:get-child-relation (ichild).
            if valid-object(pReq) then 
                childReq = pReq:Get(hRel:child-buffer:serialize-name).
            childContext = GetChild(hRel:child-buffer:serialize-name).
            if not valid-object(childcontext) then 
                 undo, throw new IllegalArgumentError(
                          "Save of data for " 
                          + hRel:child-buffer:serialize-name 
                          +  " of " 
                          + this-object:name 
                          + " does not have a matching context."
                       ).
            
            cast(childContext,IDataAdminModel):ValidateRelationChanges(hRel,childReq).    
        
        end.    
    end method.    
    
    method private character GetParentKey(phRelation as handle):
        define variable cFields as character no-undo.
        define variable cParentFields as character no-undo.
        define variable i as integer no-undo.  
        cFields = phRelation:relation-fields.
        do i = 1 to num-entries(cfields) by 2:
            cParentfields = (if i = 1 then "" else cParentfields + ",") 
                            + entry(i,cFields). 
        end.
        return cParentfields.
    end method.
    
    
    method public void ValidateRelationChanges(hRelation as handle, pReq as IRequestInfo):
        define variable cntxt as IDataAdminContext no-undo.
        define variable cParent as character no-undo.
        define variable cValues as character extent no-undo.
        if valid-object(pReq) then
        do:
            cParent = hRelation:parent-buffer:serialize-name.
            cValues = GetValues(hRelation:parent-buffer,GetParentKey(hRelation)).
            SearchRequest:publish(pReq,cParent, cValues, input-output cntxt).
            /* no child no updates */
            if valid-object(cntxt) then         
               cntxt:ValidateChanges(hRelation).
        end.
        else 
            ValidateQueryChanges(hRelation:Query).           
    end method.    
    
    /*  
    method private void LoopRelation(phRel as handle):
        define variable hParent     as handle no-undo. 
        define variable hBuffer     as handle no-undo.
        define variable hBefore     as handle no-undo.
        define variable cRelFields  as character no-undo.
        define variable cValues     as character extent no-undo.
        define variable cField      as character no-undo.
        define variable cFields     as character no-undo.
        define variable hField      as handle no-undo.
        define variable i           as integer no-undo.
        define variable hBefQuery   as handle no-undo.
        define variable beforeQuery as BeforeQuery no-undo.
        define variable cBefQuery   as character no-undo. 
        
        hParent    = phRel:parent-buffer.
        hBuffer    = phRel:child-buffer.
        cRelFields = phRel:relation-fields. 
        extent(cValues) = int(num-entries(cRelFields) / 2). 
        do i = 1 to extent(cValues):
            cField = entry((i * 2) - 1,cRelFields).
            cFields = cFields + (if i = 1 then "" else ",") 
                      + hParent:name + "." + cField.
            hField = hParent:buffer-field(cfield).
            cValues[i] = hField:buffer-value.
        end.     
        
        hBefore = hbuffer:before-buffer. 
        hBefQuery = CreateUpdateQuery(hBefore).
        beforeQuery = new BeforeQuery(phRel:query:prepare-string,cfields,cValues). 
        cBefQuery = beforeQuery:GetQueryString().
        hBefQuery:query-prepare (cBefQuery).        
        
/*        LoopBeforeQuery(hBefQuery).*/
      
        
        LoopQuery(phRel:Query). 
        
    end method.
     */
    
    
    method private character GetRowState(phbuffer as handle):
        return if phbuffer:row-state = row-created then "Created"
               else if phbuffer:row-state = row-deleted then "Deleted" 
               else if phbuffer:row-state = row-modified then "Modified"
               else "Unchanged".
    end.    
   /*     
    method protected handle CreateUpdateQuery(phBuffer as handle):
        define variable hQuery as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable cQuery as char no-undo.
        define variable hBuffers as handle extent no-undo.
        define variable i as integer no-undo.
        create Query hQuery.
        hBuffers = GetQueryHandles(phBuffer:serialize-name).
        do i = 1 to extent(hBuffers):
            if phbuffer:table-handle:origin-handle = hBuffers[i]:table-handle then
            do: 
                hBuffer = phBuffer.
/*                if i > 1 then /* there should not be any, but there is currently nothing that prevents this */ */
/*                   undo, throw new UnsupportedOperationError("Save of query where update table is not first.").*/
/*                create buffer hBuffer for table phbuffer.                                                      */
            end.
            else    
                create buffer hBuffer for table hbuffers[i].
            
            hQuery:add-buffer(phbuffer).
        end.    
        return hQuery.         
        
    end method.
    */
    
    method protected handle GetChanges(phdataset as handle):
        define variable hChangeDataset as handle  no-undo.
        define variable i              as integer no-undo.
        define variable hBuffer        as handle  no-undo.
        
        create dataset hChangeDataset.
        
        hChangeDataset:create-like(phdataset).
        hchangeDataSet:serialize-name = "root".
         
        do i = 1 to hChangeDataset:num-buffers:
            hChangeDataset:get-buffer-handle(i):serialize-name = phDataset:get-buffer-handle(i):serialize-name. 
        end.    
        hChangeDataset:get-changes(phdataset,true). 
        
        return hChangeDataset.
    end method.   
    
    method public logical HasChanges().
        if valid-handle(TableHandle:before-table) then 
           return TableHandle:before-table:has-records.
        else
           return false.
    end method.
     /*
	method public handle GetChanges():
        define variable hChangeDataset as handle no-undo.
        create dataset hChangeDataset.
        
        hChangeDataset:create-like(DatasetHandle).
        hChangeDataset:get-changes(DatasetHandle). 
        return hChangeDataset.
    end method.   
    */
    /* @TODO merge data in child context */
    method public void MergeChanges(pResponse as ISaveRequest).   
        define variable hLast as handle no-undo.  
        if not valid-handle(SaveDataset) then
            undo, throw new UnsupportedOperationError("Attempting to merge changes without a pending save request").
        if not valid-object(pResponse) then
            undo, throw new UnknownValueError("MergeChange","response").
        
        hLast = LastSavedDataset.       
        MergeChanges(SaveDataset,pResponse:DataHandle).
        delete object SaveDataset no-error.
        delete object hLast no-error.
    end method.
     
    /* @TODO merge data in child context properly - not just set LastSaved */
    method protected void MergeChanges(phOlddataSet as handle, phChangedDataset as handle):
        define variable hTable as handle no-undo.
        define variable i as integer no-undo.
        define variable child as IDataAdminContext no-undo.
        
      
        LastSavedDataset = phChangedDataset.
        do i = 1 to phOlddataSet:num-buffers:
            hTable = phOlddataSet:get-buffer-handle(i):table-handle.
            child = GetChild(phOlddataSet:get-buffer-handle(i):serialize-name).
            if valid-object(child) then
                child:LastSavedDataset = LastSavedDataset.
            hTable:tracking-changes = false. 
        end.    
        phChangedDataset:merge-changes(phOlddataSet).
        do i = 1 to phOlddataSet:num-buffers:
            hTable = phOlddataSet:get-buffer-handle(i):table-handle.
            if valid-handle(hTable:before-table) then
                hTable:tracking-changes = true.     
        end. 
       
    end method.    
 
    /* Note returns an array for each table - with unknown if tracking was not changed */
    method private handle extent TrackDataset(phdataset as handle,pltrack as log):
        define variable hExt as handle no-undo extent.
        define variable i as integer no-undo.
        define variable htable as handle no-undo.
        extent(hExt) = phdataset:num-buffers.
        do i = 1 to phdataset:num-buffers:
            hTable = phdataset:get-buffer-handle(i):table-handle.
            if valid-handle(hTable:default-buffer-handle:before-buffer) then
            do:   
               hExt[i] = htable.
               hTable:tracking-changes = pltrack.     
            end.
        end.
        return hExt.    
    end method.    
    
    method private void TrackTables(phtables as handle extent,plTrack as log):
       
        define variable i as integer no-undo.
        do i = 1 to extent(phtables):
           if valid-handle(phtables[i]) then
                phtables[i]:tracking-changes = plTrack.     
        end.
     
    end method.    
    
    /* @Deprecated  */
    method public void MergeChanges(phChangeDataset as handle):
        define variable lTrack as logical extent no-undo.
        define variable hTable as handle no-undo.
        define variable i as integer no-undo.
        LastSavedDataset = phChangeDataset.
        extent(ltrack) = DatasetHandle:num-buffers.
        do i = 1 to DatasetHandle:num-buffers:
            hTable = DatasetHandle:get-buffer-handle(i):table-handle.
            lTrack[i] = hTable:tracking-changes.
            hTable:tracking-changes = false. 
        end.    
        phChangeDataset:merge-changes(DatasetHandle).
        do i = 1 to DatasetHandle:num-buffers:
            hTable = DatasetHandle:get-buffer-handle(i):table-handle.
            hTable:tracking-changes = lTrack[i].     
        end. 
           
    end method.    
    
    /** keep client changes  - remove corresponding records in received new table */             
    method private void RemoveBeforeChanges(hNewBuffer as handle):
        define variable hq as handle no-undo.
        define variable hBefore as handle no-undo.
        define variable cWhere as character no-undo.
        define variable lok as logical no-undo. 
        
        hBefore = TableHandle:before-table:default-buffer-handle.
        create query hq.
        hq:add-buffer(hBefore).   
        hq:query-prepare("for each "  + hBefore:name).
        hq:query-open ().
        hq:get-first.
        do while hBefore:avail.
            cWhere = GetKeyWhere(GetKeyValues(hBefore)).
            lok = hNewBuffer:find-unique("where " + cWhere) no-error.           
            if lok then
            do:
                hNewBuffer:buffer-delete().
            end.    
            hq:get-next.
        end.
        
    end method.
    
    method protected void ReceiveBuffer(phNewBuffer as handle):
        /* keep client changes  - remove corresponding records in received new table */
        if HasChanges() then 
        do:
            RemoveBeforeChanges(phNewBuffer).
        end.    
        Tablehandle:copy-temp-table(phNewBuffer,yes,yes).
       
    end method.
    
    method protected void AfterTableRefreshed():
    end method.
    
    method public  void DataRefreshed(pResponse as IFetchResponse):
        define variable i as integer no-undo.
        define variable TblResponse as ITableResponse no-undo.
        define variable hNewBuffer  as handle no-undo.
        
        TblResponse = pResponse:GetTableResponse(TableHandle:Name).
/*        message "datarefreshed in " this-object skip "response" pResponse skip*/
/*          "valid table response " valid-object(TblResponse)                   */
/*        view-as alert-box.                                                    */
        if valid-object(TblResponse) then
        do:
            hNewBuffer = pResponse:DataHandle:get-buffer-handle (TableHandle:Name).              
            if hNewBuffer:table-handle <> Tablehandle then
            do:
                /* keep client changes  - remove corresponding records in received new table */
                if HasChanges() then 
                do:
                    RemoveBeforeChanges(hNewBuffer).
                end.    
                Tablehandle:copy-temp-table(hNewBuffer,yes,yes).
            end.
            
/*            Lazy = TblResponse:RequestType <> "ALL".*/
            this-object:Total = TblResponse:Total.
            AfterTableRefreshed().
            
            /* pass message on to children */
            do i = 1 to extent(mChildContextList): 
                mChildContextList[i]:DataRefreshed(pResponse).
            end.
            
            /* refresh queries */
            ContextRefreshed:Publish(TblResponse).
            
            if valid-handle(TableHandle:before-table) then
                TableHandle:tracking-changes = true.                    
                    
        end.            
    end method.   
    
    method protected character extent GetCurrentKeyValues():
        define variable hBuffer as handle no-undo.
        hBuffer = TableHandle:default-buffer-handle.
        return GetKeyValues(hBuffer). 
    end method. 
    
    method public character extent GetKeyValues(pBuffer as handle):
        return GetValues(pBuffer,KeyFields).
    end method. 
    
    method private void SetValues(pBuffer as handle,pcFields as char,pcValues as char extent):
        define variable cKey as character no-undo.
        define variable hFld as handle no-undo. 
        define variable i as integer no-undo.
        do i = 1 to num-entries(pcFields):
            /** @todo = callsetproperty for each value if  */
            hFld = pBuffer:buffer-field (entry(i,pcFields)).
            hfld:buffer-value = pcValues[i].
        end.     
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("Fields " + pcfields +  " does not match buffer: " + e:GetMessage(1)).  
        end catch. 
    end method. 
    
    
    method private character extent GetValues(pBuffer as handle,pcFields as char):
        define variable cKey as character no-undo.
        define variable hFld as handle no-undo. 
        define variable i as integer no-undo.
        define variable cValues as char extent no-undo.
         
        extent(cValues) = num-entries(pcFields).
        do i = 1 to num-entries(pcFields):
            hFld = pBuffer:buffer-field (entry(i,pcFields)).
            cValues[i] = string(hfld:buffer-value).
        end.     
        return cValues.
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("Fields " + pcfields +  " does not match buffer: " + e:GetMessage(1)).  
        end catch. 
    end method. 
    
    method public char TransformQuery(pKeyWhere as char): 
        return TransformQuery(TableHandle:name,pKeyWhere,this-object).   
    end method.
    
    method public char TransformQuery(pcTables as char, pWhere as char,mapcontxt as IQueryMAp):    
        define variable  QueryString as QueryString no-undo.       
        define variable cq as character no-undo.
        QueryString = new QueryString(pWhere,mapcontxt). 
        /* CcolumnExpression adds the table qualifier */
     
        cq = QueryString:BuildQueryString(pcTables).
        
        return cq.
        catch e as Progress.Lang.Error :
            HandleParseError(e,pWhere). 
        end catch.
        
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
    
    method public character GetKeyWhere(pcValues as char extent):
        define variable cJoin  as character no-undo.
        define variable cField as character no-undo.
        define variable i as int no-undo.
        define variable iKey as int no-undo.
        if extent(pcValues) <> num-entries(KeyFields) then 
            undo, throw new IllegalArgumentError("The number of extents passed as key does not match the number of entries in the KeyFields property."). 
        
        if name = "User" and mParent = "domains" then
        do:
           
           if Keyfields = "id" then
           do:
         
               if index(pcvalues[1],"@") = 0 then
                  pcvalues[1] = pcValues[1] + "@" + mParentKey.
                
           end.    
        end.
        else if mParent > "" then
        do:
            cJoin = GetJoinFields(mParent).
           /* add parent values to key values  */
           do i = 2 to num-entries(cJoin) by 2:
              cField = entry(i,cJoin).
              iKey = lookup(cField,KeyFields). 
              /* if the passed values is part one of the keyfields then use the value from the parameter */
              if iKey > 0 then 
              do:
                  pcValues[iKey] = mParentKey.
              end.
           end.   
        end.
        return GetWhere(KeyFields,pcValues).       
         
    end method. 
    
    method private character GetWhere(pcKeyFields as char, pcValues as char extent):
        define variable cKeyFields as character  no-undo.
        define variable iField     as integer    no-undo.
        define variable cField     as character  no-undo.
        define variable cKeyWhere  as character  no-undo.
        
        if extent(pcValues) <> num-entries(pcKeyFields) then 
            undo, throw new IllegalArgumentError("The number of extents passed as key does not match the number of entries in the passed key"). 
               
        do iField = 1 to extent(pcValues):
           assign
              cField     = entry(iField,pcKeyFields)
              cField     = entry(num-entries(cField,'.'),cField,'.')
              cKeyWhere  = cKeyWhere 
                         + (if iField > 1 then ' and ' else '')
                         + (TableHandle:name)
                         + '.' 
                         + cField
                         + ' = ' 
                         + quoter(pcValues[ifield]). 
        end.
  
        return cKeyWhere. 

    end method. 
    
    method public void TransferMatchingRequests(pReq as IRequestInfo,pmsg as IFetchRequest):
        if pmsg:HasTable(TableHandle:Name) then
        do:
            if pReq:QueryString > "" then 
                pmsg:SetTableQuery(TableHandle:Name,TransformQuery(pReq:QueryString)).
            
            if pReq:PageSize > 0 then
            do:
                if type-of(pReq,IPageRequest) then
                    pmsg:SetTablePageRequest(TableHandle:Name,pReq:PageSize,cast(pReq,IPageRequest):Start).    
                else if pReq:PageSize > 0 then
                    pmsg:SetTablePageRequest(TableHandle:Name,pReq:PageSize).                   
            end. 
            TransferMatchingRequests(pReq:GetChildren(),pmsg).
        end.               
    end method.    
    
    method public void TransferMatchingRequests(pReqs as IRequestInfo extent,pmsg as IFetchRequest):
        define variable i as integer no-undo.
          
        define variable cntxt as IDataAdminContext no-undo.
        do i = 1 to extent(pReqs):
            
            if pReqs[i]:name  = "" then 
                undo, throw new IllegalArgumentError("Request with no name used in request for " + Name). 
            
            cntxt =  GetChild(pReqs[i]:name) .
            if not valid-object(cntxt) then 
                undo, throw new IllegalArgumentError("Invalid collection reference " + pReqs[i]:name + " used in request for " + Name). 
            
            cntxt:TransferMatchingRequests(pReqs[i],pmsg).              
        end.    
    end method.
    
    /** subclasses must implement factory method for classes */ 
    method protected IDataAdminCollection CreateCollection(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("CreateCollection not implemented").     
    end method.
    
    /** subclasses must implement factory method for classes 
       @deprecated */ 
    method protected abstract IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
  
     /** subclasses must implement factory method for classes 
        @todo - make abstract and remove deprecated CreateEntity(IDataAdminContext)
        current behavior allows old methods to be used amd only gives error
        if attempting to use RequestInfo 
       */ 
    method protected IDataAdminElement CreateEntity(req as IRequestInfo):
        
        if valid-object(req) then 
        do:
             undo, throw new UnsupportedOperationError("CreateEntity with Request Info is not implemented for " + Name).       
        end.    
        return CreateEntity(this-object).
        
    end method.
    
    /** override in context with integer key */
    method protected char FindExpression(i as int):
        undo, throw new UnsupportedOperationError("FindExpression with integer").
    end method.
    
    /** default find expression assumes there is a name field 
       override in context with different key name or more complext logic */
    method protected char FindExpression(c as char):
        define variable h as handle no-undo.
        h = TableHandle:default-buffer-handle:buffer-field ("name").
        if not valid-handle(h) then 
            undo, throw new UnsupportedOperationError("FindExpression with character").
        
        return TableHandle:Name + ".Name = " + quoter(c).
    end method.
    
    /** Override in context to handle both key and filter or to 
        return FilteredContext (Query) subclasses for a specific parent */
    method protected FilteredContext CreateFilteredContext(pparent as char,pkey as char,pReq as IRequestInfo):
        if valid-object(pReq) then
            return new FilteredContext(this-object,pparent,pkey,pReq).        
        else
            return new FilteredContext(this-object,pparent,pkey).        
    end method.
    
    /** Create filtered context for parent row    */
    method protected FilteredContext CreateFilteredContext(pParentRow as IRow,pReq as IRequestInfo):
        /* @todo deprecate these variations  */
        if pParentRow:KeyValue <> ? then
            return CreateFilteredContext(pParentRow:Serializename,pParentRow:KeyValue,pReq).        
        else if pParentRow:KeyIntValue <> ? then
            return CreateFilteredContext(pParentRow:Serializename,string(pParentRow:KeyIntValue),pReq).        
        else
            return CreateFilteredContext(pParentRow:Serializename,pParentRow:KeyValues,pReq).        
    end method. 
    
    /** Override in context to handle extent key (more than one KeyFields) and filter  to 
       return FilteredContext (Query) subclasses for a speciiic parent */
 
    method protected FilteredContext CreateFilteredContext(pparent as char,pkeys as char extent,pReq as IRequestInfo):
        return new FilteredContext(this-object,pparent,pkeys,pReq).        
    end method. 
 
    /** create default filteredcontext that also handles parent/keyvalue as filter. */
    method protected FilteredContext CreateFilteredContext(filter as char):
        return new FilteredContext(this-object,filter).
    end method.
  
    /** create default filteredcontext with requestinfo  */
    method protected FilteredContext CreateFilteredContext(pReq as IRequestInfo):
        return new FilteredContext(this-object,pReq).
    end method.
    
    /** create default collection - override for dedicated child collections */
    method protected IDataAdminCollection CreateCollection(parent as char,cntxt as FilteredContext):
        return CreateCollection(cntxt).
    end method.
    
    method protected void FetchFilteredData(cntxt as FilteredContext):
        if valid-object(ServiceAdapter) and Lazy then
        do:   
            /**   @todo this (Lazy) needs to be improved
             useful for cases that can only have one parent, but is turned off for most cases
             deja vu - this is resolved in adm2 dataview using dataisfetched and 
             other logic to decide if data is fetched by parent or in dataavailable
             (this is equivalent of dataavailable for the cases where filter 
              has single row parent...foreignkey is already added though )  */ 
            FetchData(cntxt:GetRequest()).
        end.
        else  
            ContextRefreshed:Publish(new TableResponse(Name)).
         
    end method.
    
    method public /*final*/ IDataAdminCollection NewCollection().
        return CreateCollection(this-object).
    end method.
     
    method public final IDataAdminCollection GetCollection().
        define variable coll as IDataAdminCollection no-undo.
        if valid-object(ServiceAdapter) and Lazy then   
            FetchData(GetRequest()).
        return CreateCollection(this-object). 
    end method.
    
    method public IDataAdminCollection GetCollection(pParentRow as IRow,pReq as IRequestInfo).    
        define variable cntxt as FilteredContext no-undo.
        cntxt = CreateFilteredContext(pParentRow,pReq).
        FetchFilteredData(cntxt). 
        return CreateCollection(pParentRow:SerializeName,cntxt).
    end method.
    
    /** GetCollection foreign key extent query */
    method public final IDataAdminCollection GetCollection(pparent as char,pkeys as char extent).
        define variable cntxt as FilteredContext no-undo.
        cntxt = CreateFilteredContext(pparent,pkeys,?).
        FetchFilteredData(cntxt). 
        return CreateCollection(pparent,cntxt).
    end method.
    
    /** GetCollection foreign key query */
    method public final IDataAdminCollection GetCollection(pparent as char,pkey as char).
        define variable cntxt as FilteredContext no-undo.
        cntxt = CreateFilteredContext(pparent,pkey,?).
        FetchFilteredData(cntxt). 
        return CreateCollection(pparent,cntxt).
    end method.
    
    /** GetCollection foreign key query */
    method public final IDataAdminCollection GetCollection(pparent as char,pkey as char,pReq as IRequestInfo).
        define variable cntxt as FilteredContext no-undo.
        cntxt = CreateFilteredContext(pparent,pkey,pReq).
        FetchFilteredData(cntxt). 
        return CreateCollection(pparent,cntxt).
    end method.
    
    /** GetCollection foreign key query */
    method public final IDataAdminCollection GetCollection(pparent as char,pkeys as char extent,pReq as IRequestInfo).
        define variable cntxt as FilteredContext no-undo.
        cntxt = CreateFilteredContext(pparent,pkeys,pReq).
        FetchFilteredData(cntxt). 
        return CreateCollection(pparent,cntxt).
    end method.
      
    method public /*final*/ IDataAdminCollection GetCollection(filter as char).
        define variable cntxt as FilteredContext no-undo.
        cntxt = CreateFilteredContext(filter).
        FetchFilteredData(cntxt). 
        return CreateCollection(cntxt).
    end method.
      
    method public /*final*/ IDataAdminCollection GetCollection(preq as IRequestInfo).
        define variable cntxt as IDataAdminContext no-undo.
        define variable msg   as IFetchRequest no-undo.
        
        if preq:QueryString > "" then
        do: 
            cntxt = CreateFilteredContext(preq).
            msg   = cntxt:GetRequest().
        end.    
        else
        do:
            cntxt = this-object.         
            msg = GetRequest().
            TransferMatchingRequests(preq,msg). 
        end.
            
/*        req:AddRequest(preq).*/
        FetchData(msg). 
        
        return CreateCollection(cntxt).
    end method.
    
    method public final IDataAdminCollection GetChildCollection(pRow as IRow,pchild as char).
        define variable cntxt as IDataAdminContext no-undo.
        cntxt = GetChild(pchild).       
        if not valid-object(cntxt) then
            undo, throw new IllegalArgumentError("Get child collection " + quoter(pchild) + " from " + name + " context").
         return cntxt:GetCollection(pRow,?).         
    end method.    
   
    method public final IDataAdminCollection GetChildCollection(pRow as IRow,pReq as IRequestInfo).
        define variable cntxt as IDataAdminContext no-undo.
        cntxt = GetChild(pReq:Name).       
        if not valid-object(cntxt) then
            undo, throw new IllegalArgumentError("Get child collection " + quoter(pReq:Name) + " from " + name + " context").
         return cntxt:GetCollection(pRow, pReq).         
    end method.    
    
    method public final IDataAdminCollection GetChildCollection(pcKey as char extent,pchild as char).
        define variable cntxt as IDataAdminContext no-undo.
        if this-object:Find(pcKey) then
        do:
            cntxt = GetChild(pchild).       
            if not valid-object(cntxt) then
                undo, throw new IllegalArgumentError("Get child collection " + quoter(pchild) + " from " + name + " context").
            
            
            return cntxt:GetCollection(SerializeName, pcKey).         
            
        end.     
    end method.
    
    method public final IDataAdminCollection GetChildCollection(pcKey as char,preq as IRequestInfo).
        define variable cntxt as IDataAdminContext no-undo.
        if this-object:Find(pcKey) then
        do:         
            cntxt = GetChild(pReq:name).       
            if not valid-object(cntxt) then
                undo, throw new IllegalArgumentError("Get child collection " + quoter(pReq:name) + " from " + name + " context").
                   
            
            return cntxt:GetCollection(SerializeName,pcKey,pReq). 
        end.
        return ?.
    end method.
    
    method public final IDataAdminCollection GetChildCollection(piKey as int,preq as IRequestInfo).
        define variable cntxt as IDataAdminContext no-undo.
        if this-object:Find(piKey) then
        do:         
            cntxt = GetChild(pReq:name).       
            if not valid-object(cntxt) then
                undo, throw new IllegalArgumentError("Get child collection " + quoter(pReq:name) + " from " + name + " context").
                   
            
            return cntxt:GetCollection(SerializeName,string(piKey),pReq). 
        end.
        return ?.
    end method.
    
    method public final IDataAdminCollection GetChildCollection(pcKeys as char extent,preq as IRequestInfo).
        define variable cntxt as IDataAdminContext no-undo.
        if this-object:Find(pcKeys) then
        do:
            
            cntxt = GetChild(pReq:name).       
            if not valid-object(cntxt) then
                undo, throw new IllegalArgumentError("Get child collection " + quoter(pReq:name) + " from " + name + " context").
                   
            return cntxt:GetCollection(SerializeName,pcKeys,pReq). 
        end.
        return ?.
    end method.
    
    method public final IDataAdminCollection GetChildCollection(cKey as char,child as char).
        define variable cntxt as IDataAdminContext no-undo.
        if this-object:Find(cKey) then
        do:
            
            cntxt = GetChild(child).       
            if not valid-object(cntxt) then
                undo, throw new IllegalArgumentError("Get child collection " + quoter(child) + " from " + name + " context").
                   
            return cntxt:GetCollection(SerializeName, cKey).         
        end.
        return ?.
    end method.
    
    method public final IDataAdminCollection GetChildCollection(iKey as int,child as char).
        define variable cntxt as IDataAdminContext no-undo.
        if this-object:Find(iKey) then
        do:
            
            cntxt = GetChild(child).       
            if not valid-object(cntxt) then
                undo, throw new IllegalArgumentError("Get child collection " + quoter(child) + " from " + name + " context").
                   
            return cntxt:GetCollection(SerializeName, string(iKey)).         
        end.
        return ?.
    end method.
    
    
    method public IDataAdminElement GetEntity(i as int):
        define variable msg as IFetchRequest no-undo.
        if not this-object:Find(i) then
        do:
            msg = GetRequest(). 
            msg:SetTableQuery(Tablehandle:name,
               "for each " + Tablehandle:name + " where " + FindExpression(i)).
            FetchData(msg).   
        end.   
        return FindEntity(i). 
    end method.
    
    method public IDataAdminElement GetEntity(preq as IRequestInfo):
        define variable msg as IFetchRequest no-undo.
        define variable cWhere as character no-undo.
        define variable cError as character no-undo.
        define variable lok as logical no-undo.
        
        lok = this-object:Find(pReq).
                  
        if not lok then 
        do:
            msg = GetRequest(). 
            msg:SetTableQuery(Tablehandle:name,"for each " + Tablehandle:name + " where " + cWhere).
            TransferMatchingRequests(pReq:GetChildren(),msg).
            FetchData(msg). 
        end.  
        lok = Tablehandle:default-buffer-handle:find-unique("where " + cWhere) no-error. 
        /* find again in case ambiguous now */
        lok = this-object:Find(pReq).
        if lok then      
            return RealizeEntity(pReq).  
    end method. 
    
    method public IDataAdminElement GetEntity(cKey as char).
        define variable msg as IFetchRequest no-undo.
        if not this-object:Find(cKey) then
        do:
            msg = GetRequest(). 
            msg:SetTableQuery(Tablehandle:name,
               "for each " + Tablehandle:name + " where " + FindExpression(cKey)).
                       
            FetchData(msg). 
        end.  
        
        return FindEntity(cKey).
       
    end method.    

    method public logical Remove(phdl as handle):
        define variable lok as logical no-undo.
        lok = SynchWithHandle(phdl).
        if lok then
        do:
            return Remove(). 
        end.
        return false.          
    end method.
    
    method private logical SynchWithHandle(phdl as handle):
        define variable lok as logical no-undo.
        lok = phdl = TableHandle:default-buffer-handle.
        if not lok then
        do: 
            lok = TableHandle:default-buffer-handle:find-by-rowid(phdl:rowid) no-error.
        end. 
        return lok. 
    end method.
    
    method private IllegalArgumentError CreateFindError(pmsg as char,pnum as int,preq as IRequestInfo):
        define variable cvalues as character extent no-undo.
        if pnum = 7328 then 
        do:
            pmsg = "Invalid property reference " + entry(3,pmsg,"") + " used in in request for " + substr(entry(2,pmsg,""),3).
        end.
        else if pnum = 3166 then 
        do: 
            if num-entries(preq:Keyfields) = 1 then 
            do:
                  cValues = preq:GetKeyValues().
                  pmsg = "More than one " + Name + " found by request using " + preq:KeyFields + " = " + quoter(cValues[1]) + " as unique key.".
            end.  
            else  
                  pmsg = "More than one " + Name + " found by request using " + preq:KeyFields + " as unique key.".
        end.    
        return new IllegalArgumentError(pmsg).
    end.
    
    /**
    method public IDataAdminElement Remove(phdl as handle):
        define variable elem as IDataAdminElement no-undo.
        elem = FindEntity(phdl).
        if valid-object(elem) then
        do:
            elem:Detach().   
            if Remove() then
                return elem.    
        end.
        return ?.          
    end method.
    **/
    
    /** remove row */
    method protected logical Remove(): 
      
        define variable lTrack as logical no-undo.
        OnBeforeDelete().
        lTrack = TableHandle:tracking-changes.
        /***
        /** @todo replace/improve to walk through context children and 
             fire OnRowDeleted */
        RemoveChildren(TableHandle:default-buffer-handle).
        ***/
        TableHandle:tracking-changes = true.
        
        TableHandle:default-buffer-handle:buffer-delete().
        
        TableHandle:tracking-changes = lTrack.
        
        Count = Count - 1.
        OnRowDeleted().
        return true.                             
    end method.
    
    /** remove row  */
    method protected void RemoveRow(phBuffer as handle):
        RemoveChildren(phBuffer).
        phBuffer:buffer-delete(). 
    end method.    
    
    /** currently used to delete non applicable data for change and 
        regular cascade when deleting row from service 
        (the latter need to be replaced/improved - see comment in Remove) */ 
    method protected void RemoveChildren(phBuffer as handle):
         define variable ichild as integer no-undo.
         define variable hRel   as handle no-undo.
         do iChild = 1 to phBuffer:num-child-relations:
            hRel = phBuffer:get-child-relation (ichild).
            hrel:query:query-open(). 
            hrel:query:get-first.
            do while hrel:child-buffer:avail:
                RemoveRow(hrel:child-buffer).
                hrel:query:get-next.
            end.    
        end.       
    end method.    
    
    method public logical Detach(entity as IDataAdminElement).
               
    end.
    
    method private IDataAdminElement RealizeEntity().
        return RealizeEntity(?).       
    end method.
    
    method private IDataAdminElement RealizeEntity(pReq as IRequestInfo).
        define variable lTrack as logical no-undo.
        define variable inst as IDataAdminElement no-undo.
        if not valid-object(TableHandle::Entity) then 
        do:
            lTrack = TableHandle:tracking-changes.
            inst = CreateEntity(pReq).   
            if KeepInstances then
            do:      
                TableHandle:tracking-changes = false.   
                TableHandle::Entity = inst.
                TableHandle:tracking-changes = lTrack.            
            end.
            return inst.
        end.
        return TableHandle::Entity.       
    end method.
  
  /**   Return a query expression with the key field(s) and current
        value(s). 
     @param handle  - the buffer is typically the before-image or after-image
                      buffer.  
           pcQual   - Optional qualifier for the column reference.               
            
    Notes: Used to find a record without relying on rowid. 
           For example in deleteRow error handling, where prodataset methods 
           may reuse the rowids of a deleted record that need to be undeleted. */   
     
   
    /** find the entity (factory method - data already avail )
        Is considered internal.                    
        @param handle buffer that points to the record to find the entity for */ 
    method public IDataAdminElement FindEntity(phdl as handle).
        if SynchWithHandle(phdl) then
            return RealizeEntity().
        return ?.          
    end method.
    
    /** find the entity (factory method - data already avail )
        Is considered internal.                    
        @param handle buffer that points to the record to find the entity for */ 
    method public IDataAdminElement FindEntity(phdl as handle,pReq as IRequestInfo).
        if SynchWithHandle(phdl) then
            return RealizeEntity(pReq).
        return ?.          
    end method.
    
    
    method public IDataAdminElement FindEntity(c as char extent).
        if this-object:Find(c) then
            return RealizeEntity().
        return ?.
    end method.
    
    method public IDataAdminElement FindEntity(pReq as IRequestInfo).
        if this-object:Find(pReq) then
            return RealizeEntity().
        return ?.
    end method.
    
    method public IDataAdminElement FindEntity(c as char).
        if this-object:Find(c) then
            return RealizeEntity().
        return ?.
    end method.
    
    method public IDataAdminElement FindEntity(i as int):
        if this-object:Find(i) then
            return RealizeEntity(). 
        return ?.
    end method.
    
    method public IDataAdminElement FindEntity(c as char extent,pReq as IRequestInfo).
        if this-object:Find(c) then
            return RealizeEntity(preq).
        return ?.
    end method.
    
    method public IDataAdminElement FindEntity(c as char,pReq as IRequestInfo).
        if this-object:Find(c) then
            return RealizeEntity(pReq).
        return ?.
    end method.
    
    method public IDataAdminElement FindEntity(i as int,pReq as IRequestInfo):
        if this-object:Find(i) then
            return RealizeEntity(preq). 
        return ?.
    end method.
    
    method public final IDataAdminElement CreateRootEntity().
        /* default unsupported */
        CreateRootRow().
        return RealizeEntity().
    end method.
    
    method public final IDataAdminElement CreateRootEntity(c as char).
        CreateRootRow(c).
        return RealizeEntity().
    end method.
    
    method public final IDataAdminElement CreateRootEntity(i as int):
        CreateRootRow(i).
        return RealizeEntity().
    end method.
    
    method public final IDataAdminElement CreateRootEntity(pReq as IRequestInfo).
        CreateRootRow(pReq).
        return RealizeEntity(pReq).
    end method.
    
    method public IDataAdminContext GetChild(pname as char):
        define variable i as integer no-undo.
        do i = 1 to extent(mChildContextList):
            if  mChildContextList[i]:serializename = pname then
                return mChildContextList[i].
        end.
    end method.    
    
    method protected void AddChild(cntxt as IDataAdminContext):
        define variable i as integer no-undo.
        define variable oldcntxt as IDataAdminContext extent no-undo.
        extent(oldcntxt) = extent(mChildContextList).
        oldcntxt = mChildContextList.
        extent(mChildContextList) = ?.
        extent(mChildContextList) = if extent(oldcntxt) = ? then 1 else extent(oldcntxt) + 1.
        do i = 1 to extent(oldcntxt):
            mChildContextList[i] = oldcntxt[i].
        end.
        KeyChanged:Subscribe(cntxt:ForeignKeyChanged).
        mChildContextList[i] = cntxt.        
    end method.    
   
/*    method protected void FetchEntityData():                                      */
/*        msg = GetRequest().                                                       */
/*        msg:SetTableQuery(Tablehandle:name,                                       */
/*               "for each " + Tablehandle:name + " where " + FindExpression(cKey)).*/
/*            FetchData(msg).                                                       */
/*        end.                                                                      */
/*    end method.                                                                   */
        
    method protected final void FetchData(msg as IFetchRequest):  
        define variable hds as handle no-undo.
        define variable hTbl  as handle extent no-undo.
        
        msg:Url = Service:Url.
         
        PageRequested = msg:IsPageRequest.
        
        hTbl = TrackDataset(msg:DataHandle,false).
        
        if not valid-object(ServiceAdapter) then
            undo, throw new UnsupportedOperationError("FetchData not supported in " + getClass():TypeName).
        
        ServiceAdapter:RequestComplete:Subscribe(DataRefreshed).        
        
/*                                                       */
/*        message this-object skip                       */
/*              "message" skip msg                       */
/*            skip "has changes" this-object:HasChanges()*/
/*        view-as alert-box.                             */
        ServiceAdapter:FetchData(msg).
        Count = ?.
        TrackTables(hTbl,true).    
        finally:
            ServiceAdapter:RequestComplete:Unsubscribe(DataRefreshed).        
        end finally.
        
    end method.
    
    method public void ExportLastSavedTree(pcfile as char):
        if valid-handle(LastSavedDataset) then 
            LastSavedDataset:write-json ("File",pcFile,yes).    
    end method.
    
    method public void ExportNormalized(pcfile as char):
        undo, throw new UnsupportedOperationError("ExportNormalized not supported in " + getClass():TypeName).  
    end method.
 
    method public handle extent HideColumns(cList as char):
        define variable i as integer no-undo. 
        define variable hflds as handle extent no-undo.
        define variable hfld  as handle no-undo.
        define variable cfld as character no-undo.
        extent(hflds) = num-entries(cList).
        do i = 1 to num-entries(cList):
            cfld = entry(i,cList).
            hfld =  TableHandle:default-buffer-handle:buffer-field(cfld).
            if hfld:serialize-hidden = false then
            do: 
                hfld:serialize-hidden = true. 
                hflds[i] = hfld. 
            end.
        end.
        return hflds.
    end method.
    
    method public handle extent HideUrlColumns():
        define variable i as integer no-undo. 
        define variable hflds as handle extent no-undo.
        define variable hfld  as handle no-undo.
        define variable cfld as character no-undo.
        define variable hbuff as handle no-undo.
        define variable iNum as integer no-undo.
        hBuff = TableHandle:default-buffer-handle.
        extent(hflds) = hBuff:num-fields.
        do i = 1 to hBuff:num-fields:
            hfld =  hBuff:buffer-field(i).
            if (hfld:serialize-name matches "*_url" or hfld:serialize-name = "url")
            and hfld:serialize-hidden = false then
            do: 
                hfld:serialize-hidden = true. 
                hflds[i] = hfld. 
            end.
        end.
        return hflds.
    end method.
    
    method public void ViewHiddenColumns(phdls as handle extent):
        define variable i as integer no-undo.
        do i = 1 to extent(phdls):
            if valid-handle(phdls[i]) then
               phdls[i]:serialize-hidden = false.
        end.    
    end method.
    
    /*** not in use  yet 
    /* exportlist is the opposite of export in the sense that the second paramter is displayed fields */
    method public void ExportList(pcfile as char,pcDispfields as char): 
        define variable cHiddenList as character no-undo. 
        cHiddenList = HiddenColumns(pcDispFields).
        this-object:Export(pcfile,cHiddenList).    
    end method.
    */
    
    method public void Export(pcfile as char,pcHidefields as char): 
        define variable clong as longchar no-undo.             
        define variable hflds as handle extent no-undo.
        define variable hUrlflds as handle extent no-undo.
        if pcHidefields > "" then
            hflds = HideColumns(pchidefields).
            
        if Total = ? and (valid-object(service) and service:url = "") then
        do:
            hUrlFlds = HideUrlColumns().    
            DatasetHandle:get-buffer-handle(1):write-json ("file",pcFile,yes).   
            ViewHiddenColumns(hUrlFlds).
        end.    
        else
        do:
            DatasetHandle:get-buffer-handle(1):write-json ("longchar",clong,yes).   
            substring(cLong,2,0) = LineFeed 
                                 /* need to add fields before we use MetaData
                                 + (if Total <> ? and not PageRequested then MetaData() else '') 
                                  */
                                 + (if valid-object(service) and service:url > "" then '  "success": true,' + LineFeed else "") 
                                 + (if Total <> ? then '  "total": ' + string(Total) + "," + LineFeed else '') 
                                 + '  '.
            
            copy-lob clong to file pcFile.
        end.
        if extent(hflds) <> ? then
            ViewHiddenColumns(hflds).
    end method.
    
    method private char MetaData ():
        return      ' "metaData": ~{ '                    + LineFeed 
                  + '   "root": "' + SerializeName + '",' + LineFeed 
                  + '   "totalProperty": "total",'        + LineFeed 
                  + '   "successProperty": "success",'    + LineFeed
                  + '   "start": ' + string(0) + ","      + LineFeed 
                  + '   "limit": ' + string(Count)        + LineFeed 
                  + '  ~},'                               + LineFeed
                  .        
    end method.    
    
    method public void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo. 
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
    method protected handle CloneTable ():
        define variable htbl as handle no-undo.
        define variable i as integer no-undo.
        create temp-table htbl.
        htbl:create-like(TableHandle:default-buffer-handle).
        htbl:temp-table-prepare (TableHandle:name).
        htbl:default-buffer-handle:serialize-name = TableHandle:default-buffer-handle:serialize-name.     
        do i = 1 to Tablehandle:default-buffer-handle:num-fields:
            htbl:default-buffer-handle:buffer-field(i):serialize-name = Tablehandle:default-buffer-handle:buffer-field(i):serialize-name.
        end.    
        return htbl.
    end.
    
    /* single table import of the entity from query/filtered context (flat - no tree) 
       Adds forein value to all records from the passed parameters. 
       pcParent - parent serializename
       pcValue - parent key  - foreign value
       pcMode - "replace" or "append".   
        */
    
    method public void ImportForParent(pcParent as char, pcValue as char,pcfile as char):
        define variable ltrack as logical no-undo.
        define variable array      as JsonArray no-undo.
        define variable csingleExt as character extent 1 no-undo.
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true.        
                
        array = ReadJSONArray(pcfile).
        csingleExt[1] = pcValue.  
        ReadForParent(pcParent,csingleExt,array).
        
        finally:
            TableHandle:tracking-changes = lTrack.
        end.      
    end method.
    
    method protected void ReadForParent(pcParent as char, pcValue as char extent,parray as JsonArray).
        define variable i as integer no-undo.
        do i = 1 to parray:Length:  
            ReadRowForParent(pcParent, pcValue ,parray:GetJsonObject(i)).
        end.        
    end method.    
    /*
    /* override to add foreign value for ImportForParent */
    method protected void ReadRowForParent(pcParent as char, pcValue as char,json as JSONObject).
        ReadRow(json,KeyFields).
    end method.    
    */
     /* override to add foreign value for ImportForParent */
    method protected void ReadRowForParent(pcParent as char, pcValue as char extent,json as JSONObject).
        ReadRow(json,GetClientKeyFields()).
    end method. 
       
    method protected void ReadRow(json as JSONObject).
        ReadRow(json,"").
    end method.
    
    method protected logical FindOrCreateFromJson(pcKeyFields as char, json as JSONObject):
        define variable cKeyValues as character extent no-undo.
        define variable i as integer no-undo.
        define variable cField as character no-undo.
        define variable hFld as handle no-undo.
        define variable hbuffer as handle no-undo.
        
        if pcKeyFields = "" or pcKeyFields = ? then 
            undo, throw new IllegalArgumentError("KeyFields not passed to FindOrCreateFromJson"). 
        
        /*
        if extent(pcKey) <> num-entries(KeyFields) then
            undo, throw new IllegalArgumentError("The keys passed to FindOrCreateFromJson has" 
                                                  + string(extent(pcKey)) + "extents while the "
                                                  + this-object:GetClass():TypeName 
                                                  + " KeyFields property has  " 
                                                  + string(num-entries(KeyFields)) 
                                                 + " entries. Cannot load JSON file."). 
    
        */
        hBuffer = TableHandle:default-buffer-handle.
        extent(cKeyValues) = num-entries(pcKeyFields).
        
        do i = 1 to num-entries(pcKeyFields):
            cField = entry(i,pcKeyFields).
            hFld = TableHandle:default-buffer-handle:buffer-field(cField).
            
            /* case sensitive  */
            if json:Has(hFld:serialize-name) then
                cKeyValues[i] = ReadJsonCharValue(cField,json).
            else do:
                cKeyValues[i] = hFld:default-value.
            end.
        end.
       
        TableHandle:default-buffer-handle:find-unique("where " + GetWhere(pcKeyFields,cKeyValues)) no-error.
       
        if not TableHandle:default-buffer-handle:avail then
        do:
            TableHandle:default-buffer-handle:buffer-create().
            do i = 1 to num-entries(pcKeyFields):
                cField = entry(i,pcKeyFields).
                hFld = TableHandle:default-buffer-handle:buffer-field(cField).
                hfld:buffer-value = cKeyValues[i].        
            end.     
        end.
        return TableHandle:default-buffer-handle:AVAIL.  
    end method.     
    
    method protected logical FindOrCreateFromJson(pcParentJoin as char,pcParentValues as char extent,pcKeyFields as char,pjson as JSONObject):
        define variable cKeyValues as character extent no-undo.
        define variable i as integer no-undo.
        define variable cField as character no-undo.
        define variable cFieldList as character no-undo.
        define variable iKey as integer no-undo.
        define variable iParent as integer no-undo.
        define variable hFld as handle no-undo.
        
        if pcKeyFields = "" or pcKeyFields = ? then 
            undo, throw new IllegalArgumentError("No KeyFields passed to FindOrCreateFromJson. Cannot load JSON file."). 
        
        if pcParentJoin = "" or pcParentJoin = ? then 
            undo, throw new IllegalArgumentError("No Parent join passed to FindOrCreateFromJson. Cannot load JSON file."). 
        
        if extent(pcParentValues) * 2 <> num-entries(pcParentJoin) then
            undo, throw new IllegalArgumentError("Parent join and ParentValues passed to FindOrCreateFromJson does not match. Cannot load JSON file."). 
        
        
        extent(cKeyValues) = num-entries(pcKeyFields).
        cFieldList = pcKeyFields.
        
        /* add parent values to key values
           Remove each entry from cFieldList, the fields that remain in cFieldList will have to be found in JSON  */
        do i = 2 to num-entries(pcParentJoin) by 2:
            iParent = iParent + 1.
            cField = entry(i,pcParentJoin).
            iKey = lookup(cField,pcKeyFields). 
            /* if the passed values is part one of the keyfields then use the value from the parameter */
            if iKey > 0 then 
            do:
               if extent(pcParentValues) lt iparent then 
                   undo, throw new IllegalArgumentError("The " + this-object:GetClass():TypeName + " join does not match the passed parent values. Cannot load JSON file."). 
                
                cKeyValues[iKey] = pcParentValues[iParent].
                entry(iKey,cFieldList) = "".
            end.
        end.
        
        /* remaining fields need to be read from JSON */  
        do i = 1 to extent(cKeyValues):
            cField = entry(i,cFieldList).
            if cField <> "" then
            do:
               hFld = TableHandle:default-buffer-handle:buffer-field(cField).
               /* case sensitive  */
               if pjson:Has(hFld:serialize-name) then
                   cKeyValues[i] = ReadJsonCharValue(cField,pjson).
               else do:
                   cKeyValues[i] = hFld:default-value.
               end.
            end.
        end.  
        
        TableHandle:default-buffer-handle:find-unique("where " + GetKeyWhere(cKeyValues)) no-error.
       
        if not TableHandle:default-buffer-handle:avail then
        do:
            TableHandle:default-buffer-handle:buffer-create().
            do i = 1 to num-entries(pcKeyFields):
                cField  = entry(i,pcKeyFields).
                hFld = TableHandle:default-buffer-handle:buffer-field(cField).
                hfld:buffer-value = cKeyValues[i].        
            end.     
        end.
        return TableHandle:default-buffer-handle:AVAIL.  
    end method.     
    
    /* @todo throw errr when not found  - needs testing */
    method protected char ReadJsonCharValue(pname as char,json as JSONObject):
        define variable hFld as handle no-undo.
        define variable cName as character no-undo.
        hFld = TableHandle:default-buffer-handle:buffer-field (pname) no-error.
        if not valid-handle(hFld) then 
            undo, throw new IllegalArgumentError("Field " + quoter(pname) + " not found in temp-table.").
        /* case sensitive */
        cName = hFld:serialize-name.
        if json:Has(cname) then
        do:
            case hFld:data-type:
                when "int64" then
                    return string(json:GetInt64(cname)).
                when "integer" then
                    return string(json:GetInteger(cname)).
                when "character" then
                    return json:GetCharacter(cname).
                when "logical" then
                    return string(json:GetLogical(cname)).
            end case.
        end.
        return ?.
         
    end method.    
    
    method protected void ReadRow(json as JSONObject,pcExceptColumns as char).
         define variable i as integer no-undo.
         define variable j as integer no-undo.
         define variable hbuf as handle no-undo.
         define variable hFld as handle no-undo.
         define variable cname as character no-undo.
         define variable childcntxt as IDataAdminContext no-undo.
         
         hbuf = TableHandle:default-buffer-handle.
         do i = 1 to hbuf:num-fields on error undo, throw:
             hFld = hbuf:buffer-field (i).
             if hFld:serialize-hidden = false 
             and lookup(hFld:name,pcExceptColumns) = 0 
             and json:Has(hFld:serialize-name) then
             do:
                 case hFld:data-type:
                     when "int64" then
                         hFld:buffer-value = json:GetInt64(hFld:serialize-name).
                     when "integer" then
                         hFld:buffer-value = json:GetInteger(hFld:serialize-name).
                     when "decimal" then
                         hFld:buffer-value = json:GetDecimal(hFld:serialize-name).
                     when "character" then
                         hFld:buffer-value = json:GetCharacter(hFld:serialize-name).
                     when "logical" then
                         hFld:buffer-value = json:GetLogical(hFld:serialize-name).    
                     when "date" then
                         hFld:buffer-value = json:GetDate(hFld:serialize-name).    
                     when "datetime" then
                         hFld:buffer-value = json:GetDatetime(hFld:serialize-name).    
                     when "datetime-tz" then
                         hFld:buffer-value = json:GetDatetimeTZ(hFld:serialize-name).    
                 end case.            
            end. 
              /*      
             catch e as Progress.Lang.Error :
             	 if e:GetMessageNum(1) = 7351 then
             	      undo, throw new IllegalArgumentError("JSON property " + cProps[i] + " not found in " + Name).
                 undo, throw e.
             end catch.*/
         end.
         ReadChildren(json).
    end method.    
    
    method protected void ReadChildren(json as JSONObject).
        define variable i as integer no-undo. 
        define variable childcntxt as IDataAdminContext no-undo.
        define variable rowInfo as IRow no-undo.    
        
        rowInfo = new RowBuffer(TableHandle:default-buffer-handle,KeyFields).
  
        /* loop through children and call ReadChild */
        do i = 1 to extent(mChildContextList):       
            if valid-object(mChildContextList[i]) then 
            do:
                if json:Has(mChildContextList[i]:SerializeName) then
                do:
                    mChildContextList[i]:ReadChild(rowInfo, json).
                end.
            end.   
        end.
    end method.
       
    method public void ImportNewForParent(pcParent as char, pcValue as char,pcfile as char):
        define variable hTbl as handle no-undo.
        define variable ltrack as logical no-undo.
        
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true.        
        
        htbl = CloneTable().
        ReadTable(htbl,pcfile,"Append", no).

        ReadNewForParent(pcparent,pcValue,htbl).
        
        finally:
            delete object htbl no-error. 
            TableHandle:tracking-changes = lTrack.
        end.      
    end method.
    
    /** ReadJsonRow returns the single object from the JSON file.
        The object can be in an array (prodataset style) or be a true 
        object in the file. 
        Throws an error if there is an array with more than one element */  
    method protected JsonObject ReadJsonRow(pcFile as char):
        define variable json       as JsonObject no-undo.
        define variable jsonOwner  as JsonObject no-undo.
        define variable array      as JsonArray no-undo.
        define variable parser     as ObjectModelParser no-undo.
        jsonOwner = ReadJsonFile(pcfile).
        do on error undo, throw: 
           json = jsonOwner:GetJsonObject(SerializeName).
           catch e as Progress.Lang.Error :
              /* Ignore 16060, which is thrown if the object is an array */
              if e:GetMessageNum(1) <> 16060 then 
                  undo, throw e. 	    	
           end catch. 
        end.
        if not valid-object(json) then
        do:      
            array = jsonOwner:GetJsonArray(SerializeName).  
            if array:Length > 1 then 
                undo, throw new IllegalArgumentError("More than one row encountered in import to " + Name + " row " ).
            json = array:GetJsonObject(1). 
        end.
        return json.
    end method.   
    
    method protected JsonObject ReadJsonFile (pcFile as char):
        define variable parser as ObjectModelParser no-undo.
        define variable json as JsonObject no-undo.
        
        parser = new ObjectModelParser().
        return cast(parser:ParseFile(pcfile),JsonObject).
    end method.
    
    /* returns json object from the json file*/
    method /*protected*/ public JsonArray ReadJsonArray (pcFile as char):
        define variable json as JsonObject no-undo.
        json = ReadJsonFile(pcfile).
        return json:GetJsonArray(SerializeName).           
    end method.
    
    method  protected  JsonArray ReadJsonArrayFromRoot (pcFile as char):
        define variable json as JsonObject no-undo.
        define variable jsonRoot as JsonObject no-undo.
        json = ReadJsonFile(pcfile).
        jsonRoot = json:GetJsonObject("root").
        return jsonRoot:GetJsonArray(SerializeName).           
    end method.
    
    /* override (usually with static for each) if importnew need to add foreign value */
    method protected void ReadNewForParent(pcParent as char, pcValue as char,hTbl as handle):
         undo, throw new UnsupportedOperationError("ReadNewForParent  in " + Name + " context").
    end method.
    
    /* import of JSON tree with root */
    method public void ImportTree(pcfile as char,pcMode as char):
        define variable ltrack as logical no-undo init true.
     
        if not TableHandle:tracking-changes then
        do:
           ltrack = false.
           TableHandle:tracking-changes = true.
        end.       
        ReadTable(TableHandle,pcfile,pcmode,yes). 
        finally:
            TableHandle:tracking-changes = ltrack.           
        end finally.       
    end method.
    
     
    /* single table import of the entity (flat - no tree)*/
    method public void Import(pcfile as char,pcMode as char):
        define variable ltrack as logical no-undo init true.
     
        if not TableHandle:tracking-changes then
        do:
           ltrack = false.
           TableHandle:tracking-changes = true.
        end.       
        ReadTable(TableHandle,pcfile,pcmode,no). 
        finally:
            TableHandle:tracking-changes = ltrack.           
        end finally.       
    end method.
    
    method private void ReadTable(phTbl as handle,pcfile as char,pcMode as char,plHasRoot as log):
        define variable cMsg        as character no-undo.
        define variable array       as JsonArray no-undo.      
        define variable jsonRow     as JsonObject no-undo.      
        define variable i           as integer no-undo.
        define variable lCreateOnly as logical no-undo.
        define variable cKeyFields  as character no-undo. 
        
        if pcMode = "Append" then
           lCreateOnly = true. 
        else if pcMode <> "Replace" then
           undo, throw new IllegalArgumentError("Read mode " + quoter(pcMode) +  "passed to ReadTable. Valid values are ""Replace"" or ""Append"" "). 
        
        if plHasRoot then 
            array = ReadJSONArrayFromRoot(pcfile). 
        else      
            array = ReadJSONArray(pcfile).        
        
        do i = 1 to array:length :        
            jsonRow = array:GetJsonObject(i).
            if lCreateOnly then
            do:
                TableHandle:default-buffer-handle:buffer-create().
                ReadRow(jsonRow).
            end.
            else do:
                cKeyFields = GetClientKeyFields().
                
                if FindOrCreateFromJSON(cKeyFields,jsonRow) then
                    ReadRow(jsonrow,cKeyFields).
            end.
        end. /* do i = 1 to array:length */   
    end method.   
    
    /* import single row  */
    method private void ReadRow(pcFile as char):        
        define variable lTrack as logical no-undo.
        define variable array      as JsonArray no-undo.
        define variable cValues    as character extent no-undo.
        define variable jsonObj    as JsonObject no-undo.
        
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true.  
        
        jsonObj = ReadJsonRow(pcFile).
        this-object:ReadKey(jsonObj,KeyFields).
        ReadRow(jsonObj,KeyFields).
      
        finally:
            TableHandle:tracking-changes = lTrack.      
        end finally.
    end method.
    
    method public void ReadChild(pParentRow as IRow,pjson as JSONObject):
        define variable array as JsonArray no-undo.
        define variable lTrack as logical no-undo.
        define variable i as integer no-undo.
        define variable cJoinfields as character no-undo.
        define variable cJoinValues as character extent no-undo.
        define variable jsonRow as JSONObject no-undo.
        
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true.
        
        array = pjson:GetJsonArray(SerializeName).
        
        cJoinFields = GetClientJoinFields(pParentRow:SerializeName).
        extent(cJoinValues) = int(num-entries(cJoinFields) / 2).
        do i = 1 to extent(cJoinValues):
            cJoinValues[(i * 2) - 1] = pParentRow:FieldValue((entry((i * 2) - 1,cJoinFields))). 
        end.            
        do i = 1 to array:length :        
            jsonRow = array:GetJsonObject(i).
            if FindOrCreateFromJSON(cJoinFields,cJoinValues,GetClientKeyFields(),jsonRow) then
            do:   
                /* default ReadRowForParent = ReadRow(pjson,GetClientKeyFields()).
                   @todo deprecate - make generic 
                   (currently needed/used for User to allow id or name/domain 
                    and sequenceValueContext   ) */                
                ReadRowForParent(pParentRow:SerializeName,pParentRow:KeyValues,jsonRow).
            end.
        end.
        finally:
            TableHandle:tracking-changes = lTrack.      
        end finally.
    end method.  
    
    method private char ShowValues(pcValues as char extent):
        define variable i       as integer no-undo.
        define variable cValue as character no-undo.
        do i = 1 to extent(pcValues):
            cValue = cValue 
                    + if pcValues[i]= ? then "?"  
                      else quoter(pcValues[i])
                    + " ".     
        end.
        return right-trim(cValue).    
    end method.
    
    method private logical CompareValues(pcValues1 as char extent,pcValues2 as char extent,pcStrength as char):
        define variable i       as integer no-undo.
        do i = 1 to extent(pcValues1):
            if pcValues2[i] <> ?   
            and not compare(pcValues1[i],"eq",pcValues2[i],pcStrength) then
                return false.  
        end.
        return true.    
    end method.
    
    /** Read key will check if the key in json matches current row
        The action for a non matching key depends on the CanEditKey property
        - Throws error if CanEditKey = false 
        - Change key and publish to children if CanEditKey = true */
         
    method private void ReadKey(pjson as JsonObject,pcKeyFields as char):
        define variable cValues as character extent no-undo.
        define variable cJsonValues as character extent no-undo.
        define variable pRowChange as IRowChange   no-undo.
       
        cValues =  GetValues(TableHandle:default-buffer-handle,pcKeyFields).
        cJsonValues = ReadValuesFromJson(pjson,pcKeyFields).       
        if not CompareValues(cJsonValues,cValues,"case-insensitive") then
        do:
            /** @todo call validateproperty on each value - catch */
            if CanEditKey = false then
                undo, throw new IllegalArgumentError(
                     "Cannot import json file with " 
                     + ShowValues(cJsonValues)
                     + " to " + name + " " + ShowValues(cValues) 
                     + ".").
            else do:
                SetValues(TableHandle:default-buffer-handle,pcKeyFields,cJsonValues).
                KeyChanged:Publish(new RowChange(SerializeName,pcKeyFields,cValues,cJsonValues)).
            end.
        end.
/*  allow case correction of key?? possibly use validateproperty  see above comment */    
/*   else if not CompareValues(cJsonValues,cValues,"case-sensitive") then     */
/*            SetValues(TableHandle:default-buffer-handle,pcKeyFields,cJsonValues).*/
/*                                                                                 */
    end method.
    
    method private character extent ReadValuesFromJson(pjson as JsonObject,pcFields as char):
        define variable cValues as character no-undo extent.
        define variable i       as integer no-undo.
        extent(cValues) = num-entries(pcFields).
        do i = 1 to extent(cValues):
            cValues[i] = ReadJsonCharValue(entry(i,KeyFields),pjson).
        end.    
        return cValues.
    end method.
       
    /* single row import of the entity (flat no tree) */     
    method public void ImportRow(pcfile as char, i as int).
        define variable hbuf as handle no-undo.
        if this-object:Find(i) then
            ReadRow(pcfile).      
              
    end method.
    
    
    /* single row import of the entity (flat no tree) */     
    method public void ImportRow(pcfile as char, c as char).      
        if this-object:Find(c) then
            ReadRow(pcfile).      
    end method.
    
    /* single row import of the entity (flat no tree) */     
    method public void ImportRow(pcfile as char, cKeys as char extent).      
        if this-object:Find(cKeys) then
            ReadRow(pcfile).      
    end method.
    
    method public void ImportRowTree(pcfile as char, i as int).
        if this-object:Find(i) then
            ReadRowTree(pcfile).
    end method.
    
    method public void ImportRowTree(pcfile as char, c as char extent).
        if this-object:Find(c) then
            ReadRowTree(pcfile).
    end method.
    
    method public void ImportRowTree(pcfile as char, c as char).
        if this-object:Find(c) then
            ReadRowTree(pcfile).
    end method.
    
    /** read current row from json file with children   */
    method public void ReadRowTree(pcfile as char).
       define variable array      as JsonArray no-undo.
       define variable json       as JsonObject no-undo.
       define variable lTrack     as logical no-undo init ?.
       
       array = ReadJSONArrayFromRoot(pcfile).  
       if array:Length > 1 then 
           undo, throw new IllegalArgumentError("More than one row encountered in import to " + Name + " row " ).
        
       json = array:GetJsonObject(1).
       
       if not ReadOnly then 
       do:
           lTrack = TableHandle:tracking-changes.
           TableHandle:tracking-changes = true.
       end.       
       this-object:ReadKey(json,KeyFields).
       if ReadOnly then 
           ReadChildren(json).
       else do:    
           lTrack = TableHandle:tracking-changes.
           TableHandle:tracking-changes = true.
           ReadRow(array:GetJsonObject(1),pcfile).
       end.
       finally:
           if lTrack <> ? then
               TableHandle:tracking-changes = lTrack.      
       end finally.
    end method. 
    
      /** set a property  
         @param rowid the rowid of the tt
         @param name property name
         @param value value
       
       */
    method public logical SetProperty(prid as rowid,pname as char,pvalue as char).
        define variable hBuff as handle no-undo. 
        define variable hFld as handle no-undo.
        define variable cMsg as character no-undo.
        define variable cOld as character no-undo.
        define variable cNew as character no-undo.
        hBuff = TableHandle:default-buffer-handle.
        
        hFld = hBuff:buffer-field(pname).
        if hbuff:rowid <> prid then 
            hBuff:find-by-rowid (prid).
       
        cold = hfld:buffer-value.
        ValidateProperty(pName,cold,pValue).
        hfld:buffer-value = pValue.
        cNew = hfld:buffer-value.
        ValueChanged(pName,cold,cNew).
        return true.
        
        catch e as Progress.Lang.Error :
        	if e:GetMessageNum(1) = 7351 then
        	do:
        	    /* change from buffer to property */
        	    cMsg = e:GetMessage(1).
        	    cMsg = Replace(cMsg,"buffer-field","Property").
        	    cMsg = Replace(cMsg,"buffer " + TableHandle:name,substr(TableHandle:name,3)).
        	    undo, throw new IllegalArgumentError(cmsg).
        	end.
        	undo, throw e.      	
        end catch.
         
    end method.
    
    /** override to manage change - not intended fro validation - validation should have been done */
    method protected void ValueChanged(pcfield as char,poldvalue as char,pnewvalue as char).  
        define variable cOldValues as character extent no-undo.
        define variable cNewValues as character extent no-undo.
        define variable iKey as integer no-undo.
        iKey = lookup(pcfield,KeyFields).
        if iKey > 0 then 
        do:
            /*publish changes (only case-insensitive - no need to update children for 
              case change - no case sensitive keys) */
            if not Compare(poldValue,"eq",pnewvalue,"case-insensitive") then
            do:
                cNewValues = GetValues(TableHandle:default-buffer-handle,KeyFields).
                cOldValues = cNewValues.
                coldValues[iKey] = poldvalue.
                KeyChanged:Publish(new RowChange(SerializeName,KeyFields,cOldValues,cNewValues)).
            end.
        end.    
    end method.
    
    /** override to validate other fields - make sure to call super */
    method protected void ValidateProperty(pcfield as char,poldvalue as char,pnewvalue as char).  
        if lookup(pcfield,KeyFields) > 0 and not CanEditKey then 
        do:
            if not Compare(poldValue,"eq",pnewvalue,"case-sensitive") then
                undo, throw new ReadOnlyPropertyError(this-object:Name,poldvalue,pcfield).
        end.
    end method.
     
    method protected void ValidateBuffer(hBuffer as handle):
    
    end method.  
    
    /** convert expression for QueryString - unknown = keep as is
          override in subclasses to handle advanced cases */
    method public character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        return ?.
    end method.
    
    method protected char IntegerExpression(pcColumn as char,pcOperator as char,pcValue as char):
        define variable iFrom as integer no-undo.
        define variable iTo as integer no-undo.
        define variable iVal as integer no-undo.
        define variable cExpression as character no-undo.
        define variable i as integer no-undo.
        define variable cColName as character no-undo.
        define variable cVallist as character no-undo.
        
        if num-entries(pcValue) > 1 or num-entries(pcValue,"-") = 2 then 
        do:
            ccolName = entry(num-entries(pccolumn,"."),pccolumn,".").
            
            if lookup(pcoperator,"=,eq") = 0 then
                undo, throw new IllegalArgumentError("The only valid operator for " + cColname + " with list of values or range of values is equals (eq,=)"). 
             
            if num-entries(pcValue,"-") = 2 then
            do:
                iFrom = int(entry(1,pcValue,"-")).
                iTo   = int(entry(2,pcValue,"-")).
                if iFrom > iTo then 
                    undo, throw new IllegalArgumentError("Invalid values in " + cColname + " range value " + quoter(pcValue)). 
                 
                return  "(" 
                        + pcColumn + " >= " + quoter(iFrom) 
                        + " and " 
                        + pcColumn + " <= " + quoter(iTo) 
                        + ")". 
            end.
            else do:
                
                do i = 1 to num-entries(pcValue):
                    iVal = int(entry(i,pcValue)).
        
                    if not ValidValue(pccolumn,iVal) then
                    do:
                        cVallist =  ValidValueList(pccolumn).
                        undo, throw new IllegalArgumentError(
                                        "Invalid " + ccolName + " value list " +  quoter(pcValue) + " found in query expression."
                                       + (if cVallist > "" 
                                          then " The valid values are " +  cVallist + "."
                                          else "") 
                                        ). 
                    end. 
                    cExpression = cExpression  
                                 + (if i = 1 then "" else " or ") 
                                 + pcColumn + " " + pcOperator +  " " + quoter(iVal). 
                    
                end. 
                return cExpression.
            end.        
        end.
        else if lookup(pcOperator,"=,eq") > 0 then 
        do:                                                                                                       
            if not ValidValue(pccolumn,int(pcValue)) then
            do:        
                cVallist =  ValidValueList(pccolumn).
                undo, throw new IllegalArgumentError(
                         "Invalid RecordPerBlock value " + pcValue + " found in query expression."
                         + (if cVallist > "" then " The valid values are " +  cVallist + "." else "")
                       ).
            end. 
        end.
        else return ?. 
        
    end method.  
    
    /** currently used by integerExpression only
       override in subclasses if validation needed in query */ 
    method protected logical ValidValue(pcColumn as char,pcValue as char):
        return true.
    end.
    
    /** currently used by integerExpression only
       override in subclasses if validation needed in query */ 
    method protected logical ValidValue(pcColumn as char,piValue as int):
        return true.
    end.
    
    /** currently used by integerExpression only
       override in subclasses if validation needed in query */ 
    method protected logical ValidValue(pcColumn as char,piValue as int64):
        return true.
    end.
    
    method protected logical ValidValue(pcColumn as char,plLog as logical):
        return true.
    end.
      
    /** currently used by integerExpression only  
       override in subclasses if validation needed in query */ 
    method protected char ValidValueList(pcColumn as char):
        return "".
    end method.
    
    method public character ColumnSortSource(pcColumn as char).
/*        if num-entries(pcColumn,".") > 1 then                                                             */
/*        do:                                                                                               */
/*            undo, throw new IllegalArgumentError("Reference " + quoter(pcColumn) + " in sort expression").*/
/*        end.                                                                                              */
        return pcColumn.
    end method.
    
    /** qualify columns for QueryString parsing
       subclasses should override to handle advanced cases like 
        qualified collection filters 
      */
    method public character ColumnSource(pcColumn as char):
        define variable hField  as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable cMsg as character no-undo. 
        
        if num-entries(pcColumn,".") > 1 then
        do:
            undo, throw new IllegalArgumentError("Reference " + quoter(pcColumn) + " in query expression"). 
        end.
        else
        do on error undo, throw:
            hBuffer = TableHandle:default-buffer-handle.
            hField = hBuffer:buffer-field(pcColumn).
        
            if valid-handle(hField) then 
                return hBuffer:name + "." + pcColumn.
            
            return pcColumn.
            catch e as Progress.Lang.Error :
                cMsg = e:GetMessage(1). 
                if e:GetMessageNum(1) = 7351 then
                do:
                    cMsg = replace(cMsg,"buffer-field ","").
                    cMsg = replace(cMsg,"buffer tt",""). 
                    cMsg = replace(cMsg,"(7351)","").            
/*                cmsg = "Query parser error " + cmsg.*/
                end.    
                undo, throw new IllegalArgumentError(cMsg).
            end catch.
        end.
    end method.
    
    method protected void Destroy().
        delete object this-object.
    end method.
     
     /** returns the query with the values inserted according to GetJoinFields
         - must match order of GetQueryHandles 
        @param serializename of parent   
        @param keyvalue can hold values for any datatype */ 
    method public character GetChildQuery(parentid as char,pcKeyValue as char).
        return "preselect each " 
               + TableHandle:name 
               + " where " 
               + GetChildJoinExpression(parentid,pcKeyValue).   
    end method.
    
    /** returns the query with the values inserted according to GetJoinFields 
        @param serializename of parent  
        @param keyvalues can hold values for any datatype */ 
    method public character GetChildQuery(parentid as char,pcKeyValues as char extent).
        return "preselect each " 
               + TableHandle:name 
               + " where " 
               + GetChildJoinExpression(parentid,pcKeyValues).   
    end method.
    
    /** returns the server query with the values inserted according to GetJoinFields          defaults to return the GetChildQuery 
        override if different query is needed on  
         @param serializename of parent   
         @param keyvalue can hold values for any datatype */    
    method public character GetServerChildQuery(parentid as char,pcKeyValue as char).
        return "for each " 
               + TableHandle:name 
               + " where " 
               + GetChildJoinExpression(parentid,pcKeyValue).   
    end method.
    
    /** returns the server query with the values inserted according to GetJoinFields 
         defaults to return the GetChildQuery 
        override if different query is needed on  
         @param serializename of parent   
         @param keyvalues can hold values for any datatype */ 
    method public character GetServerChildQuery(parentid as char,pcKeyValues as char extent).
        return "for each " 
               + TableHandle:name 
               + " where " 
               + GetChildJoinExpression(parentid,pcKeyValues).   
    end method.
    
    method public character GetJoinQuery(parentname as character).
        define variable cExpression as character no-undo.
        define variable cjoinFields as character no-undo.
        define variable i as integer no-undo.
        define variable joincntxt as IDataAdminContext no-undo.
        joincntxt = ContextScope:GetContext(parentname).
        if not valid-object(joincntxt) then
            undo, throw new IllegalArgumentError("Context not found for join with " + quoter(parentname)).
        cJoinFields = GetJoinFields(joincntxt:TableHandle:serialize-name).
        if cJoinfields = "" or cJoinfields = ? then
            undo, throw new IllegalArgumentError("JoinFields not defined for parent " + quoter(joincntxt:TableHandle:serialize-name)).
        cExpression = GetJoinExpression(joincntxt:TableHandle:name,cJoinfields).
        return cExpression.
    end method.
    
    method public character GetServerJoinQuery(parentname as character).
        define variable cExpression as character no-undo.
        define variable cjoinFields as character no-undo.
        define variable i as integer no-undo.
        define variable joincntxt as IDataAdminContext no-undo.
        joincntxt = ContextScope:GetContext(parentname).
        if not valid-object(joincntxt) then
            undo, throw new IllegalArgumentError("Context not found for join with " + quoter(parentname)).
        cJoinFields = GetServerJoinFields(joincntxt:TableHandle:serialize-name).
        if cJoinfields = "" or cJoinfields = ? then
            undo, throw new IllegalArgumentError("ServerJoinFields not defined for parent " + quoter(joincntxt:TableHandle:serialize-name)).
        cExpression = GetJoinExpression(joincntxt:TableHandle:name,cJoinfields).
        return cExpression.
    end method. 
    
    method public character GetJoinExpression(pcJoinTable as char,pcJoinfields as char).
        define variable cExpression as character no-undo.
        define variable i as integer no-undo.
        cExpression = "each " + pcJoinTable.
        do i = 1 to num-entries(pcJoinfields) by 2:
            cExpression = cExpression
                        + (if i = 1 then " where " else " and ")
                        +  pcJoinTable + "." + entry(i,pcJoinFields)
                        + " = "    
                        +  TableHandle:name + "." + entry(i + 1,pcJoinFields) . 
        end. 
        return cExpression.
    end method.
    
    method protected character GetChildJoinExpression(parentid as char,pcKeyValue as char).
        define variable cjoinFields as character no-undo.
        cJoinFields = GetJoinFields(parentid).
        if cJoinfields = "" then
            undo, throw new IllegalArgumentError("JoinFields not defined for parent " + quoter(parentid)).
        if num-entries(cJoinfields) <> 2 then
            undo, throw new IllegalArgumentError("JoinFields have the wrong number of entries for parent " + quoter(parentid)).
        return TableHandle:name + "." + entry(2,cJoinFields)
               + " = "    
               + quoter(pcKeyValue).
    end method.
    
    method protected character GetChildJoinExpression(parentid as char,pcKeyValues as char extent).
        define variable cjoinFields as character no-undo.
        define variable i as integer no-undo.
        define variable cExpression as character no-undo.
        cJoinFields = GetJoinFields(parentid).
        if cJoinfields = "" or cJoinfields = ? then
            undo, throw new IllegalArgumentError("JoinFields not defined for parent " + quoter(parentid)).
           
        if num-entries(cJoinfields) <> extent(pcKeyValues) * 2 then
            undo, throw new IllegalArgumentError("JoinFields and KeyValues do not match for parent " + quoter(parentid)).
        do i = 1 to extent(pcKeyValues):
            cExpression = cExpression
                        + (if i = 1 then "" else " and ")
                        +  TableHandle:name + "." + entry(i * 2,cJoinFields)
                        + " = "    
                        + quoter(pcKeyValues[i]). 
        end. 
        return cExpression.
    end method.
    
     
     /**  Get default buffer handles 
          to use in child query for parent  
        - must match order of GetChildQuery
        @param serializename of parent   
       */
    method public handle extent GetQueryHandles(parentid as char).  
        define variable h as handle extent 1 no-undo.
        h[1] = TableHandle:default-buffer-handle.
        return h.
    end method.
   
      
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	destructor public DataAdminContext ( ):
        define variable i as integer no-undo.
        delete object SaveDataset no-error. 
        delete object LastSavedDataset no-error. 
        /* may be dynamic */
        delete object DatasetHandle no-error.  
        if IsLocal then 
        do:
            do i = 1 to extent(mChildContextList):
               delete object mChildContextList[i] no-error.
            end.
            if valid-object(ContextScope) 
            and ContextScope:IsLocal /* and not ContextScope:IsLocalShared */ then
                delete object ContextScope.
        end. 
        ContextDeleted:publish ().   
	end destructor.
    
end class.
