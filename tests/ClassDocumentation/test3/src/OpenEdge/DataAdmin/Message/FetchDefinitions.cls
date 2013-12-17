 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : LoadDefinitions
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Oct 15 21:09:39 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.IRequestInfo from propath.

using OpenEdge.DataAdmin.Binding.DataDefinitionOptions from propath.
using OpenEdge.DataAdmin.Binding.DataDefinitionParser from propath.

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Message.TableResponse from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

routine-level on error undo, throw.

/* implements IFetchRequest for OpenEdge.DataAdmin service layer and data access 
              inherits DataDefinitionOptions for prodict */
class OpenEdge.DataAdmin.Message.FetchDefinitions inherits DataDefinitionOptions 
                                                 implements IFetchRequest, IFetchResponse: 
    /* false - pass data to server (?)*/
    define public property UseReplaceOnClient as logical no-undo get. set.
 
    define public property DataHandle as handle no-undo 
        get.
        set. 
    
    define public property IsPageRequest as logical no-undo get. set.
    
    define public property Url as character no-undo 
        get.   
        set(pUrl as char):
           if valid-object(Logger) then
           do:
               cast(Logger,DataDefinitionParser):url = purl.
           end.
           Url = purl.     
        end.
        
    define public property ContextId as character no-undo 
        get.
        private set.    
    
    define public property SerializeName as character no-undo 
        get.
    
    /* identifier for the service adapter (directly to data access) */
    define public property EntityName as character no-undo 
        get.
        private set.
        
    constructor public FetchDefinitions (name as char,cntxt as char,h as handle ):
        super().          
        ContextId = cntxt.
        Datahandle = h.
        EntityName = name.
        Logger = new DataDefinitionParser(h,url).
    end constructor.
    
    method public logical HasTable (pcTable as char).
        define variable h as handle no-undo.
        if valid-handle(DataHandle) then
            h = DataHandle:get-buffer-handle (pcTable).
        return valid-handle(h).   
    end method. 
    
    method public char GetTableQuery (pcTable as char):
         undo, throw new UnsupportedOperationError("GetTableQuery in FetchDefinitions").
    end method.
    
    method public void SetTablePageRequest (pcTable as char, pisize as int):     
        SetTablePageRequest(pcTable, pisize, 0).
    end method.    
    
    method public void SetTablePageRequest (pcTable as char, pisize as int, pistart as int):     
         undo, throw new UnsupportedOperationError("SetTablePageRequest in FetchDefinitions").
    end method.
    
    method public void SetTableQuery (pcTable as char, pcQuery as char):
        /* nothing needed -  this is called to set name = PUB, but this is default */  
    end method.
    
    method public void SetTableTotal (pcTable as char, pitot as int):
         undo, throw new UnsupportedOperationError("SetTableTotal in FetchDefinitions").
    end method.
    
    
    method public handle SerializeMessage():  
       undo, throw new UnsupportedOperationError("SerializeMessage in FetchDefinitions").
    end.
    
    method public void AddRequest (prequest as IRequestInfo):
         undo, throw new UnsupportedOperationError("AddRequest in FetchDefinitions"). 
    end.
    
    method public void SetTableRequestType (pcTable as char, pcType as char):     
        undo, throw new UnsupportedOperationError("SetTableRequestType in FetchDefinitions"). 
    end method.    
    
    method public char GetTableRequestType (pcTable as char):
        undo, throw new UnsupportedOperationError("GetTableRequestType in FetchDefinitions"). 
    end method.    
    
    method public ITableRequest GetTableRequest (pcname as char):
        undo, throw new UnsupportedOperationError("GetTableRequest in FetchDefinitions"). 
    end.
    
    method public ITableResponse GetTableResponse(pcName as char):
        define variable h as handle no-undo.
        h = DataHandle:get-buffer-handle (pcName) no-error.
        if valid-handle(h) then
            return new TableResponse(pcName).
        return ?.
    end method.   
          
end class.