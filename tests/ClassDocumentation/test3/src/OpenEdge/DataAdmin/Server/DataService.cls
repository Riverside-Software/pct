 /*************************************************************/
 /* Copyright (c) 2011,2012 by progress Software Corporation  */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Handle data requests for a single service/database 
                  This is the server side adapter
    Syntax      : new ServiceAdapter("sports2000").
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Aug 06 09:10:06 EDT 2010
    Notes       : Currently the name of the service is the name 
                  of the database.   
                 This is currently called directly from the client side ServiceAdapter
                 It could be run from a .p if the client is on a separate session  
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessFactory from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessFactory from propath.
using OpenEdge.DataAdmin.ServerCommand.ServerCommandFactory from propath.
using OpenEdge.DataAdmin.ServerCommand.IServerCommand from propath.
using OpenEdge.DataAdmin.Binding.Connection from propath.
using OpenEdge.DataAdmin.Binding.IConnection from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.ConnectionError from propath.

class OpenEdge.DataAdmin.Server.DataService: 
    define public event RequestCompleted signature void (name as char). 
    define public event RequestComplete  signature void (contextid as char,serializename as char).
   
    define protected property Connection as IConnection no-undo 
        get. 
        private set.
   
    define protected property DataAccessFactory as DataAccessFactory no-undo
       get(): 
           if not valid-object(DataAccessFactory) then
             DataAccessFactory = new DataAccessFactory(Connection:name).
            return DataAccessFactory.
       end.
       set.
    
    define protected property ServerCommandFactory as ServerCommandFactory no-undo
       get(): 
           if not valid-object(ServerCommandFactory) then
             ServerCommandFactory = new ServerCommandFactory(Connection:name).
            return ServerCommandFactory.
       end.
       set.
    
    define public property ServiceName as character   no-undo 
        get():
            return Connection:Name.
        end.
        private set.
    
    constructor public DataService ():
        this-object("").         
    end method.
    
    constructor public DataService (pname as char):
    
        define variable cpath as character no-undo.
        super ().
        
        if pname = "" or pname = ? then
        do:
            if num-dbs = 1 then 
                Connection = new Connection(ldbname(1)).      
            else if num-dbs > 1 then    
                undo, throw new ConnectionError("The service needs a database name when more than one database is connected.").
            else
                undo, throw new ConnectionError("No database is connected. One database needs to be connected to start the service without specifying a name.").
 
        ValidateConnection(  ).   
        end.
        else do:
            if index(pname,"~\") > 0 then 
                pname = replace(pname,"~\","/").
                
            if num-entries(pname,"/") > 1 then
            do:
                cpath = pname.
                entry(num-entries(cpath,"/"),cpath,"/")  = "". 
                cpath = right-trim(cPath,"/").
                pname = entry(num-entries(pname,"/"),pname,"/"). 
                Connection = new OpenEdge.DataAdmin.Binding.Connection(cpath,pname).
                Connection:Connect().
                
                ValidateConnection(  ).
   
            end.
            else 
            do:
                 
                Connection = new OpenEdge.DataAdmin.Binding.Connection(pname).
                   
                ValidateConnection(  ).
                        
            end.  
        end.
       
    end constructor.
    
    constructor public DataService ( path as char,name as char ):
        super ().
        Connection = new OpenEdge.DataAdmin.Binding.Connection(path,name).
        Connection:Connect().
        ValidateConnection(  ).
    end constructor.
    
    method public void FetchData(msg as IFetchRequest):
        RetrieveData(msg).
    end method.     
   
    method private void RetrieveData(msg as IFetchRequest):
        /* 1 dummy compiler bug workaround e 
           2 garbage collection bug workaround */
        define variable da as IDataAccess no-undo. 
        da = GetDataAccess(msg:EntityName).
        da:FetchData(msg). 
/*        this-object:GetDataAccess(msg:EntityName):FetchData(msg).*/
        RequestComplete:Publish(msg:SerializeName,msg:ContextId).  
    end method.
 
    method public IUtilityResponse ExecuteUtility(msg as IUtilityRequest):
        define variable util as IServerCommand no-undo.
        define variable response as IUtilityResponse no-undo.
        util = ServerCommandFactory:GetCommand(msg:EntityName).
        
        util:Execute(msg).
        response = util:GetResponse().
        /* currently no response */
         
        return response. 
/*        this-object:GetDataAccess(msg:EntityName):FetchData(msg).*/
    end method. 
 
  /*  
    method private void xxRetrieveData(name as char, datasetHdl as handle, url as char, filter as char):
        define var hCopy as handle no-undo.
       
        if name = "SchemaChanges" then 
            GetDataAccess(name):FetchData(datasetHdl,url,filter).
        else 
        do:
            create dataset hCopy.
            hCopy:create-like(datasetHdl).
            
            if filter > "" then 
                GetDataAccess(name):FetchData(hCopy,url,filter).
            else
                GetDataAccess(name):FetchData(hCopy, url).
         
            datasetHdl:copy-dataset(hCopy,yes,yes).

        end.
        RequestCompleted:Publish(name).  
    end method.
*/
    method public ISaveRequest SaveData(  msg as ISaveRequest):
       define variable da as IDataAccess no-undo. 
       da = GetDataAccess(msg:EntityName).
       return da:SaveData(msg).
 
    end method.   
    /*
    method public handle SaveData(name as char, datasetHdl as handle, url as char):
        define variable da as IDataAccess no-undo. 
        da = GetDataAccess(name).
        return da:SaveData(datasetHdl,url). 
        /* compiler confused:
        return GetDataAccess(name):SaveData(datasetHdl,url).*/
 
    end method.   
    
    method public handle SaveRow(name as char, bufferHdl as handle, url as char):
        define variable da as IDataAccess no-undo. 
        da = GetDataAccess(name).
        return da:SaveData(bufferHdl:handle,url). 
 
     /* compiler confused       
          return GetDataAccess(name):SaveData(bufferHdl:handle,url).*/
 
    end method. 
    */
    method private void ValidateConnection(  ): 
         define variable cpath as character no-undo. 
         define variable cFullName as character no-undo.
          
         if Connection:IsConnected = false then
         do: 
             if valid-object(Connection:Error) then 
             do:
                if Connection:Error:GetMessageNum(1) = 1012 then 
                    undo, throw new ConnectionError("Cannot connect to " + Connection:FullName + " when already connected to " + pdbname(Connection:Name)).
                /*else if Connection:Error:GetMessageNum(1) = 710 then 
                    undo, throw new ConnectionError("UserId/Password is incorrect. " ). 
                else */
                    undo, throw new ConnectionError(Connection:Error).
             end. 
             /* Errors when path is specified should have Connection:Error so the following 
                code block is likely unnecessary */    
             cpath = replace(Connection:path,"~\","/").
             if cPath <> ? then
             do:
                
                 /* Note we set Connection:Error in Connection:connect() so we will likely never 
                    get here. */
                 cFullName = (if cpath > "" then cpath + "/" + Connection:name else Connection:name). 
                        
                                     
                 if search(cFullName) = ? then
                     undo, throw new ConnectionError("Database " + cFullName + " was not found.").
                 else 
                     undo, throw new ConnectionError("Failed to connect to database " + cFullName + ".").
             end.
             else if Connection:Name > "" then 
             do: 
                 undo, throw new ConnectionError("Database " + Connection:Name + " is not connected."). 
     
             end.
             
             /* constructor handles blank name  
               - does not create a Connection if more or less than 1 db               
             else do: 
                 if num-dbs > 1 then
                    undo, throw new ConnectionError("The service needs a database name when more than one database is connected.").
                 
                 undo, throw new ConnectionError("No database is connected. There need to be one database connected to start the service without specifying a name.").
             end.        */
              
       
         end.
         
         if int(dbversion(Connection:Name)) lt 11 then 
             undo, throw new UnsupportedOperationError("The service requires database version 11 or higher.").
          
    end method.
     
    method public IDataAccess GetDataAccess(name as char):
        return DataAccessFactory:GetDataAccess(name).
    end method. 
     
end class.
