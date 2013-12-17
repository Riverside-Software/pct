 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UserPermissionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : Override for different data 
                    field mapping and afteruserrow 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.DataSource.UserDataSource from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.UserPermissionDataSource inherits UserDataSource  : 
   
    define variable msave as logical no-undo.
    define private property TenantURL  as character no-undo get. set.
    
    define public property ExternalIDValue as character no-undo get. private set.
    
	define private variable mMapping as char
	   init  "Name,_Userid,DomainName,_domain-name"
     no-undo.
    
    constructor public UserPermissionDataSource ( ):      
        super ( mMapping). 
    end constructor.
    
    /* override to not call back */
    method protected override logical SetCallBack(phBuffer as handle):
        phBuffer:set-callback("After-Row-fill","AfterUserRow").
    end method.
    
    method public override void AfterUserRow(dataset-handle hds):
        define variable hbuffer as handle    no-undo.
        define variable userurl as character no-undo. 
        hBuffer = hds:get-buffer-handle("ttUserPermission").
        
        assign
            hBuffer::DomainUrl  = url + "/domains/" 
                                + if hBuffer::DomainName = "" 
                                  then WebUtil:UrlEncode(" ") 
                                  else WebUtil:UrlEncode(hBuffer::DomainName) 
        
            hBuffer::Id        = hbuffer::Name  
                               + if hBuffer::DomainName > "" 
                                 then "@" + hBuffer::DomainName 
                                 else " ".            
            hBuffer::UserUrl = hBuffer::DomainUrl + "/users/" + WebUtil:UrlEncode(hBuffer::Name).
           
    end method.                   
    
    
    method public override logical Save(bufferHandle as handle):
        /*        CreateSaveSource("").*/
         undo, throw new UnsupportedOperationError("Save UserPermissionDataSource").
    end method.  
   
    method public override character ColumnExpression (pcColumn as char, pcOperator as char, pcValue as char):
        define variable cname   as character no-undo.
        define variable cDomain as character no-undo.
        define variable cExpress as character no-undo.
        
        /* Keep track of if there is search in id, in which case the UserData
           will create record if no user is found in order to execute the 
           request against field and table permission for an external id  */  
        if pcColumn = "_User.id" then 
        do: 
           if (pcoperator = "EQ") or  (pcoperator = "=") then
                ExternalIdValue = right-trim(pcvalue,"@").
        end.   
        
        return super:ColumnExpression(pccolumn,pcOperator,pcValue).     
   
    end method.  
    
                 
end class.