 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : IDataAdminContext
    Purpose     : Provide data context for entities and collections
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Aug 05 01:10:52 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath .
using Progress.Json.ObjectModel.JSONObject from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IRowChange from propath.
using OpenEdge.DataAdmin.Binding.IIterable from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap from propath.

interface OpenEdge.DataAdmin.Binding.IDataAdminContext inherits IIterable,IQueryMap: 
     define public event RowCreated signature void (). 
     define public event RowDeleted signature void (). 
     define public event AddedToContext signature void (newContext as IDataAdminContext). 
     define public event ContextDeleted signature void (). 
     define public event ContextRefreshed signature void (tblResponse as ITableResponse). 
    
     /**  
        unique entity identifier, exposed as contextid in collections and entities
        and used in Equals for comparison. This is tied to the physical running TT. 
        This means that two different instances of the TT are considered to be different
        and have diffferent Id. The SerializeName is tied to the definition.   
     */ 
     
     define public property Id            as character no-undo  get.
     
     /**             
        unique entity identifier for serialization. The objects are in principle
        serialized as temp tables in the context at all the time, (except for detached entity
        classes), so this is really a TT identifier and is defined using the serialize-name
        definition of the TT. This is exposed externally through the REST api.
        It is unique within a service/connection.
     */    
     define public property SerializeName as character  no-undo  get.     
     
     /**  
        unique content identifier, exposed as Sourceid in collections. 
        This is tied to the physical query or temp-table if the collection contains all 
        Used to isolate updates in context.  
        Is the same as the Id for the Model itself 
        See collection SourceId
     */ 
     define public property ContentId as character no-undo  get.
     
     define public property KeyFields       as character  no-undo  get. 
    
/*     define public property IsShared      as logical no-undo  get.*/
     define public property IsLocal         as logical no-undo  get.
     
     define public property Service         as IDataAdminService no-undo  get. 
     
     define public property TargetService   as IDataAdminService no-undo  get. 
     
     define public property TableHandle     as handle  no-undo  get.
     
     define public property DatasetHandle as handle  no-undo  get.
     define public property LastSavedDataset as handle no-undo get. set.
     define public property Name          as char    no-undo  get. 
     define public property Count         as integer no-undo  get. 
     define public property Total         as integer no-undo  get.
     define public property ReadOnly      as logical  no-undo  get.   
     
     define public property RootId        as rowid no-undo  get.   
     
     define public property Lazy          as logical  no-undo  get.  set.
     
     method public logical HasChanges().
     
     method public IFetchRequest GetRequest().
     
     method public ISaveRequest GetSaveRequest().
     
/*     method public void ValidateChanges(pchngh as IDataChanges):*/
     
     method public void ValidateChanges(phDs as handle ):
     
    
     method public void ValidateQueryChanges(phQuery as handle):    
         
     method public void MergeChanges(pResponse as ISaveRequest).
      
     method public void MergeChanges(phChangeDataset as handle).
     /*
     method public void SaveRow(entity as IDataAdminElement).
     method public void SaveCollection(entity as IDataAdminCollection).
     */
     method public void CreateRow(entity as IDataAdminElement).
     
     method public void Copy(cntxt as IDataAdminContext).
       
     method public void MoveQueries(cntxt as IDataAdminContext).
     
     method public character TransformQuery(pQuery as char).
     
     method public void TransferMatchingRequests(pReq as IRequestInfo extent,pmsg as IFetchRequest):
     method public void TransferMatchingRequests(pReq as IRequestInfo,pmsg as IFetchRequest):
     
     /*
     
    /* resolve query columns for QueryString parsing */
     method public character ColumnSource(pcColumn as char).
     
     /* resolve query columnExpression for QueryString parsing - unknown = use as-is */
     method public character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        
       */
   
/*     method public void CopyTable(cntxt as IDataAdminContext).*/
     
     /** GetChild context  
       @param serializeName */
     method public IDataAdminContext GetChild(name as char).
     
     /** GetContext get a context from the scope/factory  
       @param serializeName */
/*     method public IDataAdminContext GetContext(name as char).*/
     
     method public void AddTableTo(tree as IContextTree).
     method public void AddRowTo(tree as IContextTree,prid as rowid).
     method public void AddTreeTo(tree as IContextTree).
     method public void AddTreeTo(tree as IContextTree,parent as IDataAdminContext).
     method public void AddTreeTo(tree as IContextTree,parent as IDataAdminContext,pcCollections as char).
     method public void AddTreeTo(tree as IContextTree,pcCollections as char).
      
     method public void WriteTo(writer as IContextWriter).
     method public void WriteRowTo(writer as IContextWriter,pcKey as char).
     method public void WriteRowTo(writer as IContextWriter,piKey as int).
/*                                                                  */
     method public void DataRefreshed(response as IFetchResponse).

     
     /* returns the join field names (comma separated) from the passed serializename
        parameter ot serializename.propertyname that is passed in. 
        the fields are ordered parent,child  */ 
     method public character GetJoinFields(parentid as char).
     
     method public character extent GetKeyValues(pBuffer as handle).
     
     method public void ForeignKeyChanged(parentChange as IRowChange).
     
     /** need a place to use this -- AddTreeTo(parent...) is the right place, but
         it does not distunguish between client and server requests
      /* returns the server side join field names (comma separated) from the 
         passed serializename parameter ot serializename.propertyname that is passed in. 
         the fields are ordered parent,child
         The server join is for join on server when you request a hierarchy of data.
         i.e. no values  */ 
     method public character GetServerJoinFields(parentid as char).
     **/
     
     /** return a new collection - empty except defaults
         Only used once in the lifetime to create a local context (in a service). */
     method public IDataAdminCollection NewCollection().
     
     method public IDataAdminCollection GetCollection().    
     method public IDataAdminCollection GetCollection(filter as char).    
     method public IDataAdminCollection GetCollection(preq as IRequestInfo).
         
     method public IDataAdminCollection GetCollection(pParentRow as IRow,pReq as IRequestInfo).    
     method public IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as char).    
     method public IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as char extent).
     method public IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as char,preq as IRequestInfo).    
/*     method public IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as int,preq as IRequestInfo).*/
     method public IDataAdminCollection GetCollection(pcParentSerializename as char,pKey as char extent,preq as IRequestInfo).    
     /** get a child collection 
         @todo move to IDataAdminModel  */
     method public IDataAdminCollection GetChildCollection(pParent as IRow,preq as IRequestInfo).    
     method public IDataAdminCollection GetChildCollection(pParent as IRow,serializename as char).    
       /*  @todo deprecate the overlaods below  */
     method public IDataAdminCollection GetChildCollection(ckey as char,serializename as char).    
     method public IDataAdminCollection GetChildCollection(ikey as int,serializename as char).    
     method public IDataAdminCollection GetChildCollection(cKey as char extent,serializename as char).
     method public IDataAdminCollection GetChildCollection(pcKey as char,preq as IRequestInfo).
     method public IDataAdminCollection GetChildCollection(piKey as int,preq as IRequestInfo).
     method public IDataAdminCollection GetChildCollection(pcKey as char extent,preq as IRequestInfo).
     
    
     /** get a standalone entity - optional if int key - default to unsupported
         @param id integer key
         will be requested from server if necessary and can retrieve single table or 
         full tree of children or selected children (managed by IDataAdminContext */
     method public IDataAdminElement GetEntity(i as int).
     
     /** get a standalone entity - default to name (to be deprecated) or single KeyFields (new)
         optional - override to throw unsupported if not applicable
         @param name/id character key
         will be requested from server if necessary and can retrieve single table or 
         full tree of children or selected children (managed by IDataAdminContext */
     method public IDataAdminElement GetEntity(c as char).
     
     /** get a standalone entity -  
         @param requestInfo  
         will be requested from server if necessary and can retrieve single table or 
         full tree of children or selected children (managed by IDataAdminContext) */
     method public IDataAdminElement GetEntity(req as IRequestInfo).    
     
       /** find in current data (no service request)
           NOTE: The RequestInfo is only for support of find on alternate values
                 it is not stored in the instance and not used for collection filters  */
     method public IDataAdminElement FindEntity(req as IRequestInfo).
        
     /** find in current data (no service request) */
     method public IDataAdminElement FindEntity(i as int).
     /** find in current data (no service request) */
     method public IDataAdminElement FindEntity(c as char).
     
     /** find in current data (no service request) */
     method public IDataAdminElement FindEntity(c as char extent).
     
     /** return a new entity - empty except defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public IDataAdminElement CreateRootEntity().
     
     /** return a new entity - empty except for keys and defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public IDataAdminElement CreateRootEntity(i as int).
   
     /** return a new entity - empty except for keys and defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public IDataAdminElement CreateRootEntity(c as char).
   
     /** return a new entity - empty except for keys and defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public IDataAdminElement CreateRootEntity(pReq as IRequestInfo).
   
    /** create a new row - empty except defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). 
         */
    method public void CreateRootRow().
    
    /** returns a new querystring with passed criteria added to current */
/*    method public char NewQueryString(pcQuery as char,pcSort as char).*/
    
     
      /** create a new row - empty except defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public void CreateRootRow(i as int).
   
     /** create a new row - empty except defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public void CreateRootRow(c as char).
   
     /** create a new row - empty except defaults
         Sets RootId - Only used once in the lifetime  to create the top most record
         in local context (in a service). */
     method public void CreateRootRow(pReq as IRequestInfo).
   
 
     method public void ReadChild(parentRow as IRow,json as JSONObject).
    
     /** import single table for a single parent (used by FilteredContext) */
     method public void ImportForParent(pcparent as char, pckey as char,pcfile as char).
     /** import single new table for a single parent (used by FilteredContext) */
     method public void ImportNewForParent(pcparent as char, pckey as char,pcfile as char).
     
     /** import of the entity (flat no tree) */     
     method public void Import(pcfile as char,pcMode as char).
     /** import of the entity as tree with root node */     
     method public void ImportTree(pcfile as char,pcMode as char).
     
     /** single row import of the entity (flat no tree) */
     method public void ImportRow(pcfile as char, cKeyValues as char extent).           
     method public void ImportRow(pcfile as char, i as int).
     method public void ImportRow(pcfile as char, c as char).
     method public void ImportRowTree(pcfile as char, cKeyValues as char extent).           
     method public void ImportRowTree(pcfile as char, i as int).
     method public void ImportRowTree(pcfile as char, c as char).
    
     method public void Export(pcfile as char,pchidefields as char).
     method public void ExportLastSaved(pcfile as char).
     method public void ExportLastSavedTree(pcfile as char).
     method public void ExportNormalized(pcfile as char).
      
     /** optional delete
       @param key character   */
     method public logical Delete(c as char).
     
     /** optional delete
       @param key character   */
     method public logical Delete(i as int).
   
     
     /** optional delete  - throws UnsupportedOperationError if not valid/implemented
                @todo  throw dedicated error (extend UnsupportedOperationError ) for this that clearly 
                       says delete not allowed in public entity name when fully implemented in all context 
                       that support delete (as of current handled by non-extent method)
                       The single key should call this when this is done
                 )
       @param key character[] representing KeyFields  */
     method public logical Delete(c as char extent).
     
     /** optional CanFind - throws UnsupportedOperationError if not valid/implemented 
       @param key integer   */
     method public logical CanFind(i as int).
     
     /** optional Find - throws UnsupportedOperationError if not valid/implemented 
       @param key integer   */
     method public logical Find(i as int).
    
     /** optional CanFind - throws UnsupportedOperationError if not valid/implemented 
       @param key char   */
     method public logical CanFind(c as char).
     
     /** find in current data (no service request)
           NOTE: The RequestInfo is only for support of find on alternate values
                 it is not stored in the instance and not used for collection filters  */
     method public logical Find(req as IRequestInfo).
   
     
     /** optional Find - throws UnsupportedOperationError if not valid/implemented 
       @param key char   */
     method public logical Find(c as char).
     
     /** optional Find - throws UnsupportedOperationError if not valid/implemented 
         @param key char[] representing the KeyFields   */
     method public logical Find(c as char extent).
     
          /** FindOrigin - find row from origin rowid in row extracted with getchanges  
              @param rOriginid rowid from row in change dataset   */
     method public logical FindOrigin(rOriginid as rowid).
    
     /** set a property  
         @param rowid the rowid of the tt
         @param name property name
         @param value value  
       */
    method public logical SetProperty(pid as rowid,pname as char,pvalue as char).
    
    /** get a where expression from the passed extent using Keyfields */
    method public character GetKeyWhere(pcValues as char extent).     
end interface.
