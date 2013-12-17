 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
   Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Sep 30   2010
    Notes       : This class currently has methods required by 
                  subinterfaces (since the TT is defined here)
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.*.

using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Message.TableResponse from propath.
using OpenEdge.DataAdmin.Rest.IPageRequest from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Message.DataAdminMessage implements IDataAdminMessage: 
    /* normalize message if this is changed to 
        go over an appserver connection with more than one message  
    define temp-table ttMessage
        field Entity as char 
        field SerializeName as char
        field Contextid as char
        index idxMsg as primary unique entity.
    */ 
    define protected temp-table ttTableMessage
        field Entity        as char 
        field TableName     as char
        field RequestType   as char
        field KeyValue      as char
/*        field SerializeName as char */
        field FullPage      as logical
        field Contextid     as char
        field QueryString   as char
        field SearchString  as char
        field PageContext   as char
        field PageSize      as int
        field Start          as int
        field PrevPosition  as char
        field NextPosition  as char
        field Total         as int  init ?
         index idxMsg as primary unique entity tablename.
    
    define buffer bMsg for ttTableMessage.
    
    define private variable mNames as char no-undo.
              
    define public property DataHandle as handle no-undo 
        get.
        set. 
    
    define public property Url as character no-undo 
        get.
        set. 
    
    define public property ContextId as character no-undo 
        get.
        private set.
    
    define public property SerializeName as character no-undo 
        get():
            return DataHandle:get-buffer-handle (1):serialize-name.
        end.
   
    /* identifier for the service adapter (directly to data access) */
    define public property EntityName as character no-undo 
        get.
        private set.
       
    constructor public DataAdminMessage (h as handle ):
		super ().	
		DataHandle = h.
	end constructor.
  
    constructor public DataAdminMessage (name as char, hds as handle, hMsg as handle):
        this-object (hds).  
        EntityName = name. 
        inputMessage(table-handle hmsg). 
    end constructor.
  
    /*
    constructor public DataAdminMessage (h as handle, pcurl as char ):
        this-object (h).   
        Url = pcurl.    
    end constructor.
    
    constructor public DataAdminMessage (ctnxt as char,h as handle, pcurl as char ):
        this-object (h,pcurl).   
        ContextId = ctnxt.    
    end constructor.
    */
    constructor public DataAdminMessage (name as char,ctnxt as char,h as handle):
        this-object(name,h).
        ContextId = ctnxt. 
    end constructor.
    
    constructor public DataAdminMessage (name as char,h as handle):
        super().  
        EntityName = name.   
        DataHandle = h.   
    end constructor.
    
    method private void inputMessage(table ttTableMessage):
         
    end.    
    
    method public handle SerializeMessage():  
        return temp-table ttTableMessage:handle.            
    end.
    
    /** makes the protected temptable available for subclasses */
    method protected handle FindOrCreateTable(pcTable as char):
        AssertTable(pcTable).
      
        find ttTableMessage where ttTableMessage.TableName   = pctable no-error.
        if not avail ttTableMessage then 
        do:
            create ttTableMessage.
            assign 
                    ttTableMessage.TableName   = pctable
                    ttTableMessage.Entity      = this-object:EntityName  
                    ttTableMessage.Contextid   = this-object:Contextid. 
        
        end.
        return buffer ttTableMessage:handle.
    end method.
    
    /** Set query for table  */   
    method public void SetTableQuery (pcTable as char, pcQuery as char):     
        
        FindOrCreateTable(pctable).
        ttTableMessage.QueryString = pcQuery.         
/*        DataHandle:top-nav-query(pcTable):query-prepare(pcQuery).*/
    end method.    
    
    
    
    
    method protected void AssertTable(pcTable as char):
        define variable hBuffer as handle no-undo.
        hbuffer = DataHandle:get-buffer-handle(pctable).
        if not valid-handle(hbuffer) then 
           undo, throw new IllegalArgumentError("Invalid table name " + quoter(pctable) + " passed to message table method."). 
    end method.    
     
    method public override character ToString():
        define variable c as character no-undo.
        c = super:ToString(). 
        return c +  MessageString().
    end.    
    
    /** used to get existing table request data to pass to GetTableResponse or GetTableRequest
        caller must use the handle - the buffer is private */
    method protected handle GetRow(pcTable as char):   
        find bMsg where bMsg.TableName = pctable no-error.
        if avail bMsg then 
           return buffer bMsg:handle.
        return ?.      
    end method.   
    
    /* currently FetchRequest also implements IFetchResponse so this is needed by
       both FetchResponse and FetchRequest */   
    method public ITableResponse GetTableResponse(pcName as char):
        define variable h as handle no-undo.
        h = GetRow(pcname).
         
        if valid-handle(h) then 
        do:
            return new TableResponse(h).
        end.
        else do: /* return a default response if table in dataset */
            h = DataHandle:get-buffer-handle (pcName) no-error.
            if valid-handle(h) then
                return new TableResponse(pcName).
        end.
        
        return ?.
    end method.   
    
    method protected character MessageString():
        define variable i as integer no-undo.
        define variable cname as character no-undo.
        define variable hBuf as handle no-undo.
        define variable cQuery as character no-undo.
        define variable cString as character no-undo.
        if valid-handle(DataHandle) then
        do i = 1 to DataHandle:num-buffers:
           hBuf  = DataHandle:get-buffer-handle(i).
           cName = hbuf:name.
           cString = cString + "~n" 
                   + (if cQuery > "" then cQuery else cName)
                   + " " + string(hBuf:table-handle:has-records)   .     
        end.     
        return cString.
    end.    
end class.