 
 /*------------------------------------------------------------------------
    File        : SecurityOptionsSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : Thu Nov 24 18:04:51 IST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.ISecurityOptions from propath.
  
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.SecurityOptionsSource: 
 /* {prodict/misc/misc-funcs.i}*/
 
 
/*    ------------------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */
    constructor public SecurityOptionsSource (  ):
        super (). 
    end constructor.
       
    method public void Fill(hbuffer as handle):
        if num-dbs EQ 0 then
          undo , throw  new AppError("No database connected!" + "~n" +
            "You must be connected to a database to acces this tool!").
        
        hBuffer:buffer-create ( ).
        find first DICTDB._db where DICTDB._db._db-local = true  no-lock.
   
        for each DICTDB._db-option where DICTDB._db-option._db-recid = RECID(DICTDB._db) 
            and   DICTDB._db-option._db-option-type =  2 no-lock:

          if DICTDB._db-option._db-option-code =  "_pvm.noBlankUser" then 
            assign hBuffer::DisallowBlankUserid = logical(DICTDB._db-option._db-option-value). 
          if DICTDB._db-option._db-option-code =  "_pvm.recordSessions" then 
            assign hBuffer::RecordAuthenticatedSessions = logical(DICTDB._db-option._db-option-value). 
          if DICTDB._db-option._db-option-code =  "_pvm.RuntimePermissions" then 
            assign hBuffer::UseRuntimePermissions = logical(DICTDB._db-option._db-option-value). 
          if DICTDB._db-option._db-option-code =  "_pvm.useAppRegistry" then 
            assign hBuffer::TrustApplicationDomainRegistry = logical(DICTDB._db-option._db-option-value). 
        end.
    end method.    
    
    method public void Save(phbuffer as handle):
        define variable hBeforeBuff as handle    no-undo.  
        define variable secOptions  as ISecurityOptions no-undo.
        
        if num-dbs EQ 0 then
          undo , throw  new AppError("No database connected!" + "~n" +
            "You must be connected to a database to acces this tool!").
        
        hBeforeBuff = phBuffer:before-buffer.
        
        if hBeforeBuff:row-state = row-created then
            undo, throw new UnsupportedOperationError("Create SecurityOptions"). 
        if hBeforeBuff:row-state = row-deleted then
            undo, throw new UnsupportedOperationError("Delete SecurityOptions"). 
        phBuffer:find-first().
        
        /* add code from _db-optn.p here. also modify code where _db-optn gets called */
        find first DICTDB._db where DICTDB._db._db-local = true  no-lock.
        
        for each  DICTDB._db-option where DICTDB._db-option._db-recid = RECID(DICTDB._db) 
            and   DICTDB._db-option._db-option-type =  2 :

          if DICTDB._db-option._db-option-code =  "_pvm.noBlankUser" 
          and phBuffer::DisallowBlankUserid NE DICTDB._db-option._db-option-value then 
            assign DICTDB._db-option._db-option-value = phBuffer::DisallowBlankUserid. 
          if DICTDB._db-option._db-option-code =  "_pvm.recordSessions" 
          and phBuffer::RecordAuthenticatedSessions NE LOGICAL(DICTDB._db-option._db-option-value) then 
            assign DICTDB._db-option._db-option-value = phBuffer::RecordAuthenticatedSessions. 
          if DICTDB._db-option._db-option-code =  "_pvm.RuntimePermissions"  
          and phBuffer::UseRuntimePermissions NE LOGICAL(DICTDB._db-option._db-option-value) then 
            assign DICTDB._db-option._db-option-value = phBuffer::UseRuntimePermissions. 
          if DICTDB._db-option._db-option-code =  "_pvm.useAppRegistry" 
          and phBuffer::TrustApplicationDomainRegistry NE LOGICAL(DICTDB._db-option._db-option-value) then  
            assign DICTDB._db-option._db-option-value = phBuffer::TrustApplicationDomainRegistry. 
       end.
        
        catch e as AppError  :
            undo, throw  e.     
        end catch.
        
        catch e2 as Error  :
            undo, throw new DataAccessError(e2).
        end.
    end method.
    
end class.