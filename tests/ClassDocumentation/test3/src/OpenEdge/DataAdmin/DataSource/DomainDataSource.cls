/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DomainDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : nov 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath. 
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.DomainDataSource inherits DataSource: 
    define buffer b_domain for dictdb._Sec-Authentication-Domain.
    define buffer b_tenant for dictdb._Tenant.
    define private variable msave as logical no-undo.
    define private variable mAccessDisp as character no-undo init "********".
   
	define private variable mMapping as char
	   init  	
"Name,_Domain-name,~
AuthenticationSystemName,_Domain-type,~
Description,_Domain-description,~
IsEnabled,_Domain-enabled,~
AuditingContext,~_Auditing-Context,~
TenantName,_tenant-name,~
Id,_Domain-Id,~
AccessCode,_Domain-access-code,~
SystemOptions,_PAM-options,~
RuntimeOptions,_Domain-runtime-options,~
TenantId,_Tenant._tenantId,~
Comments,_Domain-custom-detail"     
     no-undo.
/* Names decided in discussions for 11.1 changes       
Note: Consider removing Domain from the name. 
Seems a bit weird to have IDomain:DomainActions. 
DomainActions,_PAM-actions~  
DomainControl,_PAM-control~     
SystemPath,_PAM-library-path"
*/        
    constructor public DomainDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL. 
    end constructor.
    
	constructor public DomainDataSource ( ):	    
		super ("_sec-authentication-domain,_tenant","dictdb._sec-authentication-domain,dictdb._tenant", mMapping). 
		BaseQuery = "for each _sec-authentication-domain no-lock,"
		          + " each _tenant outer-join where _tenant._tenant-name = _sec-authentication-domain._tenant-name no-lock".
    end constructor.
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterDomainRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
    end method.
    
    /** Save all  
         @param buffer the temp-table buffer handle with data */
    method public override logical Save(bufferHandle as handle):
        return this-object:Save(bufferHandle,?).  
    end method.  
    
    /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified) 
                      ? = all */
    method public override logical Save(phBuffer as handle,piState as int):
        define variable hBeforeBuff as handle    no-undo.
        define variable lnew        as logical   no-undo. 
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable hDataset    as handle no-undo.
        define variable cAccess     as character no-undo.
        define variable cErrormap   as character no-undo.
        define variable lSaveEnabled as logical  no-undo.
        define variable lSaveOther   as logical  no-undo.
        define variable cChanges     as character no-undo.
        define variable logged_in_domain as character no-undo.
        
        if piState < 1 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
        
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttDomainCopy"    
                              + (if piState <> ? 
                                 then " where row-state(ttDomainCopy) = " + string(piState)
                                 else "")  
                             ).    
        hquery:query-open().
        
        do while true on error undo, throw:
            
            hquery:get-next.
            if not hBeforebuff:avail then 
                leave.
        
            if hBeforeBuff:row-state = row-deleted then 
            do:
                find b_domain where b_domain._domain-name = hBeforeBuff::Name exclusive no-wait.
                delete  b_domain.
            end.
            else do:
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
            
                if DatabaseInfo:IsMultiTenant then
                do: 
                    /* if mod then use Id since parent may be renamed in same transaction 
                       but the parent is updated after the this child 
                       (We know the id is set in this case, whihc is not the case with create) */
                    if pistate = row-modified then
                        find b_tenant where b_tenant._tenantid = phBuffer::TenantId no-lock no-error. 
                    else 
                        find b_tenant where b_tenant._tenant-name = phBuffer::TenantName no-lock no-error. 
                    
                    if not avail b_tenant then
                    do:
                        undo, throw new DataAccessError("Tenant " + quoter(phBuffer::Tenantname) + " does not exist").
                    end.    
                end.               
                else if phBuffer::Tenantname > "" then 
                    undo, throw new DataAccessError("Tenant " + quoter(phBuffer::Tenantname) + " is invalid." 
                                                 + " The Domain cannot have a Tenant in a database that is not multi-tenant.").
                
                if hBeforeBuff:row-state = row-created then 
                do:
                    create b_domain.
                    assign
                        b_domain._Domain-name = phBuffer::Name
                        cAccess = phBuffer::AccessCode
                        b_domain._Domain-access-code = AUDIT-POLICY:ENCRYPT-AUDIT-MAC-KEY(cAccess)
                        .
             
                end. 
                else do:
                    
                    find b_domain /* find using beforebuff::Name rather than Name */
                       where b_domain._domain-name = /*phbuffer::Name*/
                             hBeforeBuff::Name exclusive no-wait .
                    
                    if phBuffer::AccessCode <> mAccessDisp then
                    do:
                        cAccess = phBuffer::AccessCode.
                        b_domain._Domain-access-code = AUDIT-POLICY:ENCRYPT-AUDIT-MAC-KEY(cAccess).
                    end.  
                end.
                 
                /* You get "cannot change.." error if you assign any (some?) other field than 
                   enabled for a builtin domain. This check ensures that we avoid the message 
                   if this is the only change. Note that we intentionally assign other changes 
                   also if the record is a builtin to let core deal with the error message */
                cChanges = CompareBuffers(phbuffer,hBeforeBuff,"Entity","case-sensitive").
                /* rename a domain */
                assign logged_in_domain = SUBSTRING(userid("dictdb"),INDEX(userid("dictdb"),'@') + 1).
                if lookup("Name",cChanges) > 0 then do:
                    if b_domain._Domain-name EQ logged_in_domain then
                       undo, throw new UnsupportedOperationError("Renaming the domain with which the user has logged in is not allowed.").        
                    else
                       b_domain._Domain-name = phBuffer::Name.         
                end.
                if cChanges = "IsEnabled" then 
                    b_domain._Domain-enabled = phBuffer::IsEnabled.
                else
                    assign
                        b_domain._Domain-enabled = phBuffer::IsEnabled
                        b_domain._Domain-type = phBuffer::AuthenticationSystemName
                        b_domain._Domain-description = phBuffer::Description
                        b_domain._Tenant-name = phBuffer::TenantName when DatabaseInfo:IsMultiTenant
                        b_domain._Auditing-Context = phBuffer::AuditingContext
                        b_domain._PAM-options = phBuffer::SystemOptions
                        b_domain._Domain-runtime-options = phBuffer::RuntimeOptions
                        b_domain._Domain-custom-detail = phBuffer::Comments.
                             
                hdataset = phBuffer:dataset.
                buffer b_domain:buffer-validate ().    
                msave = true.
                AfterDomainRow (dataset-handle hdataset  by-reference).
                msave = false.
                /* TODO   - save-row-changes? */
            end. /* else (not delete)*/
        end. 
        return true. 
        catch e as Progress.Lang.Error :
            cErrormap = replace(mMapping,"AuthenticationSystemName","Authentication System").    
            undo, throw new DataAccessError(
                new DataMapper("Domain,b_domain,Authentication System,_sec-authentication-system",
                cErrormap),
                e). 
            
        end catch.          
        finally:
           delete object hQuery no-error. 		
        end finally.
                
    end method.    
    
    method public void AfterDomainRow(dataset-handle hds):
        define variable hbuffer as handle no-undo.
        define variable iSource as integer no-undo.
        assign
            hBuffer             = hds:get-buffer-handle("ttDomain")
            hBuffer::Url        = Url + "/domains/" + WebUtil:UrlEncode(hBuffer::Name) 
            hBuffer::UsersUrl   = hBuffer::Url + "/users" 
            hBuffer::AccessCode = mAccessDisp.
        
        /* we cannot create a builtin so the value is always correct on save
           (false if new, from read if update)  */    
        if not msave then   
        do:
            isource = lookup("_sec-authentication-domain",Tables).
            hBuffer::IsBuiltin = DataSourceHandle:get-source-buffer(isource)::_Domain-category <> 0.
        end.
        if hBuffer::TenantName > "" then
            hBuffer::TenantUrl = Url + "/tenants/" + WebUtil:UrlEncode(hBuffer::Tenantname ).
        
        if hBuffer::TenantName = "?" then
            hBuffer::TenantName = "Default".
    end method.                 
    
    method private char IsBuiltInExpression(istrue as log):
        if istrue then
            return  "(_sec-authentication-domain._Domain-category <> '0')". 
        else  
            return  "(_sec-authentication-domain._Domain-category = '0')". 
    end method.  
    
    method public override character ColumnSortSource(pcColumn as char):
        define variable iType as integer no-undo.      
        if pccolumn = "_sec-authentication-domain.IsBuiltIn" then
        do:
            return IsBuiltInExpression(true).
        end.
        return super:ColumnSortSource(pccolumn).   
    end. 
    
     /* convert  values in query to the expression required in the db */
    method public override character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        define variable iType as integer no-undo.
       
        if pccolumn = "_sec-authentication-domain.IsBuiltIn" then
        do:
            return IsBuiltInExpression(logical(pcValue)).
        end.
        return super:ColumnExpression(pccolumn,pcOperator,pcValue).   
   
    end. 
    
    /* rename table to match to right table when building  */
    method public override character ColumnSource (pcColumn as char):
        if pccolumn = "ttDomain.IsBuiltIn" then
        do:
            return "_sec-authentication-domain.IsBuiltIn".      
        end.
        else return super:ColumnSource(pccolumn).
    end method.     
    
end class.