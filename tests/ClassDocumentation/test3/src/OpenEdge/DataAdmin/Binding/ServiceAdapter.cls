 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Handle data requests for a single service/database  
    Syntax      : new ServiceAdapter("sports2000").
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Aug 06 09:10:06 EDT 2010
    Notes       : The name of the service is the name of the database.   
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.FetchResponse from propath.
using OpenEdge.DataAdmin.Server.DataService from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath. 
 
class OpenEdge.DataAdmin.Binding.ServiceAdapter: 
 
    define public event RequestComplete  signature void (response as IFetchResponse ).
   
    define private variable DataService    as DataService no-undo.
    define private variable ConnectionPath as character no-undo.
    define private variable ConnectionName as character no-undo.
    
    define public property ServiceName as character   no-undo 
        get():
            if ServiceName = "" then 
                return ConnectionName.
            return ServiceName.                 
        end.
        private set.
        
    constructor public ServiceAdapter ():
		super ().		 
		/* Note - this will give connection error  on new dataadminservice. 
		  remove from here will move connection error to first request 
		  (this will likely be necessary if the service is split to run on a client) */
		GetDataService("").
		ServiceName = DataService:ServiceName.       
	end constructor.
    
    constructor public ServiceAdapter (name as char):
        super ().        
        ConnectionName = name.
        GetDataService(ConnectionName).
    end constructor.
    
    constructor public ServiceAdapter (path as char,name as char):
        super ().        
        /* this error is duplicated in DataAdminSercice so you should never reach here...*/
        if path = ? then
        do:
            undo, throw new UnknownValueError("ServiceAdapter constructor","path","Specify blank to connect to a database in the current directory or use the single character parameter constructor to use the ServiceAdapter with a connected database.").
        end.     
        
        ConnectionName = name.
        ConnectionPath = path.
        GetDataService(ConnectionPath,ConnectionName).
    end constructor.
       
    method public void FetchData(msg as IFetchRequest):
        RetrieveData(msg).
    end method.     
   
    /*
    method private void RetrieveData(msg as IFetchRequest):
        /* dummy compiler bug workaround */
        define variable da as IDataAccess no-undo. 
         
        this-object:GetDataAccess(msg:EntityName):FetchData(msg).
        
        RequestComplete:Publish(msg:SerializeName,msg:ContextId).  
    end method.
    */
    
    method private void RetrieveData(pmsg as IFetchRequest):
        define variable cDbname as character no-undo.
        define variable hcontextTable as handle no-undo.
        define variable hDs as handle no-undo.
        define variable hcopy as handle no-undo.
        define variable response as IFetchResponse no-undo.
        cDbname = ConnectionName.
        
        if pmsg:UseReplaceOnClient then 
        do on error undo, throw: 
            hds = pmsg:DataHandle.
            
            hContextTable = pmsg:SerializeMessage().
            create dataset hCopy.
            hCopy:create-like(hds).
            
            FetchOnServer(input-output cDbname,
                          connectionPath,
                          pmsg:EntityName,
                          pmsg:GetClass():TypeName,
                          pMsg:URL,
                          input-output table-handle hcontextTable  ,
                          /* some requests have input data for query */
                          input-output dataset-handle hCopy) .
            
/*            hds:copy-dataset(hCopy,yes,yes).*/
            
             response = new FetchResponse(pmsg:EntityName,hCopy,hcontextTable).
            
        end.
        else  /* NOT pmsg:UseReplaceOnClient */ 
        do:
            FetchOnServer(input-output cDbname,
                          connectionPath,
                          pmsg) .
            response = cast(pmsg,IFetchResponse).              
        end.
  
        ServiceName = cDbname.
  
        RequestComplete:Publish(response).  
        finally:
            /* delete the request dataset retrieved from the message if it is dynamic */
            if valid-handle(hds) and hds:dynamic then
            do: 
                delete object hds no-error. 
            end.
            delete object hCopy no-error.
        end finally.
    end method.

    method public ISaveRequest SaveData(  msg as ISaveRequest):
        define variable daservice as  DataService.
        
        daservice = GetDataService(ConnectionPath,ConnectionName).             
        ServiceName = daservice:ServiceName.
        return daservice:SaveData(  msg).
 
/*        RequestCompleted:Publish(name).*/
    end method.   
    /*
    method public handle SaveData(name as char, datasetHdl as handle, url as char):
        define variable daservice as  DataService.
        
        daservice = GetDataService(ConnectionPath,ConnectionName).             
        ServiceName = daservice:ServiceName.
        
        return daservice:SaveData(name,datasetHdl,url).
 
/*        RequestCompleted:Publish(name).*/
    end method.   
    */
    /*
    method public handle SaveRow(name as char, bufferHdl as handle, url as char):
        define variable daservice as  DataService.
        
        daservice = GetDataService(ConnectionPath,ConnectionName).             
        ServiceName = daservice:ServiceName.
        return daservice:SaveData(name,bufferHdl,url).
 
/*        RequestCompleted:Publish(name).*/
    end method. 
    */
    method public IUtilityResponse ExecuteUtility(msg as IUtilityRequest):
        define variable daservice as  DataService.
        daservice = GetDataService(ConnectionPath,ConnectionName).             
        ServiceName = daservice:ServiceName.
        return daservice:ExecuteUtility(msg).
 
         /*        RequestCompleted:Publish(name).*/
    end method. 
      
    /*  */
    method private void FetchOnServer (input-output pcDbName as char,
                                       pcPath as char,
                                       pcMsg as IFetchRequest):
        define variable daservice as  DataService.
        daservice = GetDataService(pcPath,pcdbname).      
        daservice:FetchData(pcMsg).        
        
        pcDbName = daservice:ServiceName.
        
    end method.
    
    /* this is the .p ... if on a separate session */
    method private void FetchOnServer (input-output pcDbName as char,
                                       pcPath as char,
                                       pcEntityName as char,
                                       pcMessageType as char,
                                       pcUrl as char, 
                                       input-output table-handle phMessage,
                                       input-output dataset-handle phDs):
        define variable daservice as  DataService no-undo.
        define variable msg as IFetchRequest no-undo.     
        define variable hMsgIn as handle no-undo. 
        daservice = GetDataService(pcPath,pcdbname).        
        /*        msg  = new FetchRequest(ds,hmessage) .*/
        
        /* This roundtrip is likely not optimal, but the message currently has a 
           static definition, so a deep copy is needed (or...?) 
           Look at adm2 serverside code fetch..64 that resolves this for static and 
           dynamic SDOs  */  
        hMsgin = phmessage.
        msg = dynamic-new pcMessageType (pcEntityName,phDs,phmessage).
        msg:URL = pcURl.
        daservice:FetchData(msg).      
        phmessage = msg:SerializeMessage().
       /** DO NOT DELETE msg! 
           This has a static tt and cannot be deleted as the message tt will disappear
           and total will not be returned     
        delete object msg. **/
        pcDbName = daservice:ServiceName.
        finally:
            /* not sure if the first one here makes any difference  */
            delete object phmessage no-error.
            /* standard server side cleanup for table and dataset out parameters */
            delete object hMsgIn no-error.
            delete object phds no-error.         		
        end finally.
    end method.
    
    /* blank path is supported so we use ? to signal no path */
    method private DataService GetDataService(pcname as char):
        return GetDataService(?,pcname).
    end method.
    
   /* not needed or belongs on server side if split on appserver 
           (connects to database) */
    method private DataService GetDataService(pcpath as char,pcname as char):
        
        if not valid-object(DataService) then
        do: 
            if pcname = "" then
               DataService = new DataService().                       
            else if pcpath = ? then
               DataService = new DataService(pcname).                       
            else
               DataService = new DataService(pcpath,pcname).                          
        
        end.
        return DataService.
    end.    
     
end class.
