  /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : Connection
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : July 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
   
using Progress.Lang.Error from propath.
using Progress.Lang.AppError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError.
using OpenEdge.DataAdmin.Binding.IConnection.
 
class OpenEdge.DataAdmin.Binding.Connection implements IConnection: 
    define stream batchprompt.
    define public property Error     as Error           no-undo get. set.  
    define public property Name      as char            no-undo get. set.  
    define public property Path      as char   init ?   no-undo get. set.  
    define public property HREF      as char            no-undo get. set.  
    define private variable mCreated as logical         no-undo.
    
    define public property FullName  as char            no-undo 
        get():
            define variable cForwardSlash as character no-undo init "/".
            define variable cBackSlash as character no-undo init "~\".
            if lookup(opsys,"MSDOS,WIN32":u) > 0 then
                return replace(Path,cForwardSlash,cBackSlash) + cBackSlash + name.
            else 
                return replace(Path,cBackSlash,cForwardSlash) + cForwardSlash + name.
        end.
           
    define public property ServerName as char      no-undo get. set.  
    define public property HostName as char        no-undo get. set.  
    
    define protected property IsNew as logical    no-undo get. private set.
    define public property IsCreated as logical    no-undo get.  
 
    define public property IsSingleUser as logical no-undo get. private set. 
    define public property IsMultiTenant as logical no-undo get.
    
    define public property IsConnected  as logical no-undo 
        get():
            if connected(Name) then
            do:
                if path = ? then 
                    return true.
                else  
                    return FullName = pdbname(name).
            end.  
            return false.  
        end.
        private set.
        
    constructor public Connection (pcPath as char, pcName as char):
        this-object(pcPath,pcName,no).  
    end constructor.
    
    constructor public Connection (pcPath as char, pcName as char, plNew as log):
        super ().   
        assign Path = pcPath
               Name = pcName
               mCreated = plNew.
    end constructor.
    
    constructor public Connection (pcName as char):
        super ().   
        assign Name = pcName.  
    end constructor.
       
    method public logical ConnectSingleUser():
        connect value("-db " + FullName + " -1").
        IsSingleUser = true.
        return connected(Name).
        catch e as Progress.Lang.Error :
        	Error = e.
        	return false.	
        end catch.
    end method.
    
    method public logical ConnectMultiUser():
        if Path <> ? and not IsConnected then
        do:
             connect value("-db " + FullName).               
             return connected(Name).
        end.     
        return false.
        catch e as Progress.Lang.Error :
            Error = e.
            return false.   
        end catch.
    end method.
    
    method logical Connect():
        define variable lok as logical no-undo.
        lok = ConnectMultiUser().
        if valid-object(this-object:Error) then 
        do: 
            if this-object:Error:GetMessageNum(1) = 1423 then
            do: 
                Error = ?.
                return ConnectSingleUser().
            end.
            return false.		
        end.
        return lok.
    end method.
    
    method logical Disconnect():
        if connected(Name) then
        do:
            disconnect value(Name).
        end.
        return not connected(Name).
    end method. 
    
    method public void SetMultitenant():
        os-command value(GetDLC() + "~\bin~\_dbutil " + Path + "~\" + Name  
                         + " –C enablemultiTenancy").
    end method.
    
    method logical Delete():
        define variable err as AppError no-undo.
        if connected(Name)  then
            undo, throw new AppError("Delete failed").

/*        if not isnew then*/
/*             undo, throw new DeleteFailedError().*/

      
        output stream batchprompt to "yes.txt".
        put stream batchprompt unformatted "Y".
        output stream batchprompt close.
 
        os-command  silent value(GetDLC() + "/bin/prodel " + FullName) + " < " + search("yes.txt")).
       
        os-delete value(search("yes.txt")). 
    end method.
     
    method logical CommitChanges():
    end method.
    
    method public logical Create(pcFrom as char):
        
        
/*       IF lNewInstance THEN                                        */
/*          create database FullName from olddb NEW-INSTANCE NO-ERROR.*/
    create database FullName from pcFrom.
        IsNew = true.
        return true.
        catch e as Error :
            return false.   
        end catch.
    end method.         
         
    method public logical Create():
        define variable emptyDb as character no-undo.
        emptyDb = GetDLC() + "/empty.db".
        return this-object:Create(emptyDb).
    end method.    
    
    
    
    method protected character GetDLC():
        define variable cDLC as character no-undo.
        if opsys = "Win32":U then /* Get DLC from Registry */
            get-key-value section "Startup":U key "DLC":U value cDLC.
        if (cDLC = "" or cDLC = ?) then 
        do:
            cDLC = os-getenv("DLC":U). /* Get DLC from environment */
        end.
        return cDLC.
    end method.
    
    method private char GetFileExtension(pcFile as char):
        define variable i as integer no-undo.
        i = num-entries(pcfile,".").
        if i > 1 then
           return entry(i,pcfile,".").
        else return "".    
    end method.    
end class.
