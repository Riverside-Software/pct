/*************************************************************/
/* Copyright (c) 2011,2012 by Progress Software Corporation  */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UserDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : nov 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath. 
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.UserDataSource inherits DataSource : 
   
    define variable msave as logical no-undo.
    define buffer b_domain for dictdb._Sec-Authentication-Domain.
    define private property TenantURL  as character no-undo get. set.
    define protected variable mBuffer as handle no-undo.
	define private variable mMapping as char
	   init  	
"Name,_Userid,~
Description,_description,~
TenantId,_user._tenantid,~
IsSqlOnly,_sql-only-user,~
GivenName,_given_name,~
MiddleInitial,_middle_initial,~
SurName,_surname,~
DomainName,_domain-name,~
Telephone,_Telephone,~
Email,_Email"
/*DomainId,_sec-authentication-domain._domain-id,~*/
     no-undo.
    
    constructor public UserDataSource (cParent as char,cWhere as char):      
        super (cParent + ",_user","dictdb." + cparent + ",dictdb.user", mMapping). 
        BaseQuery = "for each " + cParent + " no-lock, "
                  + " each _user where " + cWhere + " no-lock".
    end constructor.
     
	constructor public UserDataSource ( ):	    
		this-object (mMapping). 
    end constructor.
    
    constructor public UserDataSource (pcMapping as char):      
        super ("_user","dictdb._user", pcMapping). 
        BaseQuery = "for each _user no-lock".
    end constructor.
    
    constructor public UserDataSource (pcJoinTables as char,pcPhysicalJoinTables as char, pcQuery as char):      
        super ("_user," + pcJoinTables,
               "dictdb._user," + pcPhysicalJoinTables, 
               mMapping 
               + if lookup("_Domain",pcJoinTables) > 0 
                 then ",DomainId,_Domain._Domain-id"
                 else ""). 
        BaseQuery = "for each _user no-lock, " + pcQuery.
    end constructor.
    
    
        /* allow subclasses to override to not set call back even if we  have call back here */
    method protected logical SetCallBack(phBuffer as handle):
        phBuffer:set-callback("After-Row-fill","AfterUserRow").
        TenantUrl = url + "/tenants/".
    end method.
    
    method public final override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable lok as logical no-undo.
        SetCallBack(phBuffer).
        lok  = super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
      
        return lok.
    end method.
    
    method protected override logical PrepareQueryString (poQueryString as QueryString):         
        define variable isOk as logical no-undo.
        define variable cQuery as character no-undo.
        /*
        isOk = AddUniqueOrNone("_tenant",poQueryString).
        if isOk = ? then 
            undo, throw new IllegalArgumentError("UserDataSource prepare with non unique tenant reference. Use the tenant constructor.").
        */
        cQuery = poQueryString:BuildQueryString(Tables).
        isOk = QueryHandle:query-prepare(cQuery).       
        return isOk.
    end method.
    
    /** Save all  
         @param buffer the temp-table buffer handle with data */
    method public override logical Save(bufferHandle as handle):
        this-object:Save(bufferHandle,?).
    end method.     
    
    /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified) 
                      ? = all */
    method public override logical Save(bufferHandle as handle,piState as int):
      /*        CreateSaveSource("").*/
        mSave = true. 
        SaveUser(bufferHandle,piState).
        finally:
            mSave = false.
        end finally.
    end method.     
    
     /** SaveUser changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified) 
                      ? = all */
    method protected void SaveUser(phbuffer as handle,pistate as int):
     
        define variable hBeforeBuff as handle    no-undo.
        define variable lnew        as logical   no-undo. 
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable hDataset as handle no-undo.
        define variable isMultiTenant as logical   no-undo. 
                
        isMultiTenant = can-find(first DICTDB._tenant ). 
        if piState < 1 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
      
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttUserCopy"
                              + (if piState <> ? 
                                 then " where row-state(ttUserCopy) = " + string(piState)
                                 else "") 
                             ).    
        hquery:query-open().
        
        do while true:
            hquery:get-next.
            if not hBeforebuff:avail then 
                leave.
            
            if hBeforeBuff:row-state = row-deleted then 
            do:
                find dictdb._user where dictdb._user._domain-name = hBeforeBuff::DomainName 
                                  and   dictdb._user._userid = hBeforeBuff::name exclusive no-wait.
                   
                 delete dictdb._user.
            end.    
            else do:    
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                if hBeforeBuff:row-state = row-created then           
                do:
                    create dictdb._user.
                    assign
                        dictdb._user._userid = phBuffer::Name  
                        dictdb._user._password = ENCODE(phBuffer::PassWord).     
            
                    lnew = true. /* use NEW buffer ? */
                end. 
                else do:
                    find dictdb._user where dictdb._user._domain-name = phBuffer::DomainName 
                                      and   dictdb._user._userid = phBuffer::name exclusive no-wait.
                end.                                 
                
                /* use DomainId if modified since a parent rename in same transaction 
                   is doen after the child for modifify - 
                   (we know the Dominid is ok imn thia case ) */
                if pistate = row-modified then
                    find dictdb._sec-authentication-domain where _sec-authentication-domain._domain-id = phBuffer::DomainId no-lock. 
                else
                    find dictdb._sec-authentication-domain where _sec-authentication-domain._domain-name = phBuffer::Domainname no-lock. 
                
                assign        
                    dictdb._user._domain = phBuffer::DomainName  
                    dictdb._user._description  = phBuffer::Description               
                    dictdb._user._given_name = phBuffer::GivenName  
                    dictdb._user._middle_initial = phBuffer::MiddleInitial 
                    dictdb._user._surname = phBuffer::SurName       
                    dictdb._user._sql-only-user = phBuffer::IsSqlOnly  
                    dictdb._user._Telephone = phBuffer::Telephone       
                    dictdb._user._email = phBuffer::Email.
                  
                if hBeforeBuff::password <> phBuffer::password then
                   dictdb._user._password = ENCODE(phBuffer::PassWord).
                
                if isMultiTenant then 
                do:   
                    find dictdb._tenant where dictdb._tenant._tenantid = dictdb._user._tenantId no-lock . 
                    assign phBuffer::TenantName = dictdb._tenant._tenant-name     
                           phBuffer::TenantId   = dictdb._user._tenantid.  
                end.
                       
                hdataset = phBuffer:dataset.
                    
                AfterUserRow (dataset-handle hdataset  by-reference).
            end. /* else (not ddelete) */
        end.
        catch e as Progress.Lang.Error :    
            undo, throw new DataAccessError(
                new DataMapper("User,_user",
                mMapping),
                e). 
            
        end catch.       
        finally:
           delete object hquery no-error. 		
        end finally.   
    end method.    
    
    method public void AfterUserRow(dataset-handle hds):
        define variable hbuffer as handle    no-undo.
        define variable userurl as character no-undo. 
        define variable iusersrc   as integer no-undo.
        define variable husersrc as handle no-undo. 
        define buffer b_domain for dictdb._sec-authentication-domain.
        hBuffer = hds:get-buffer-handle("ttUser").
             /* TODO join in query faster? */
        if mSave = false then 
        do:
            if hBuffer::DomainId = 0 or hBuffer::DomainId = ? then 
            do:
                find b_domain where b_domain._domain-name = hBuffer::DomainName no-lock no-error. 
                /* there should always be a tenant... but */ 
                if avail b_domain then
                    hBuffer::DomainId = b_domain._domain-id.         
            end.    
                       
            if hBuffer::TenantId <> ? then 
            do:           
                find dictdb._tenant where dictdb._tenant._tenantid = hBuffer::TenantId no-lock no-error. 
                /* there should always be a tenant... but */ 
                if avail dictdb._tenant then
                    assign
                        hBuffer::TenantName = dictdb._tenant._tenant-name     
                        hBuffer::TenantId   = dictdb._tenant._tenantid.                     
            end.
        end. 
        
        assign
            hBuffer::DomainUrl  = url + "/domains/" 
                                + if hBuffer::DomainName = "" 
                                  then WebUtil:UrlEncode(" ") 
                                  else WebUtil:UrlEncode(hBuffer::DomainName) 
        
            hBuffer::Id        = hbuffer::Name  
                                 + if hBuffer::DomainName > "" 
                                   then "@" + hBuffer::DomainName 
                                   else ""            
            hBuffer::Password  = "********"
            hBuffer::url = url + "/users/" + WebUtil:UrlEncode(hBuffer::Id)
            hBuffer::UserPermissionUrl = url + "/userpermissions/" + WebUtil:UrlEncode(hBuffer::Id)
             .  
         
         if hBuffer::TenantName > "" then
             hBuffer::TenantUrl  = TenantURL + WebUtil:UrlEncode(hBuffer::TenantName).
       
        if hbuffer::Description = ? then       
            hbuffer::Description = "".
        if hbuffer::MiddleInitial = ? then       
            hbuffer::MiddleInitial = "".
    end method.                   
    
    /* This is the call back for the QueryString parsing. There is currently no mapping, but we override it in 
       order to return the ttPartition's parent keys to the Query. This allows us to extract the expression later.
       Because it is added as parent (i.e _tenant) we can also extract the actual query fields without these.        
    */
   
     method public override character ColumnSource(pcColumn as char):
        /* input to columnexpression */
        if pcColumn = "ttUser.TenantName" then 
        do:
            return "_tenant._tenant-name".    
        end.
        if pcColumn = "ttUserPermission.id" or pcColumn = "ttUser.id"  then 
             return "_user.id".
        else return super:ColumnSource(pcColumn).    
    end method.
    
    method public override character ColumnSortSource(pcColumn as char):
        if pcColumn = "ttUser.TenantName" then 
        do:
            return "_tenant._tenant-name".    
        end.
        if pcColumn = "_User.id" then 
        do:
            return "( _user._userid + '@' + _user._domain-name)".
        end.    
        return super:ColumnSortSource(pccolumn). 
    end method.
     
    method public override character ColumnExpression (pcColumn as char, pcOperator as char, pcValue as char):
        define variable cExpress as character no-undo.
        if pcColumn = "_User.id" then 
        do: 
            if index(pcValue,"@") > 0 
            and lookup(pcoperator,"EQ,=") > 0 then
                cExpress =  "(_user._userid " + pcOperator + " " + quoter(entry(1,pcValue,"@"))
                      +  " and _user._domain-name " + pcOperator + " " + quoter(entry(2,pcValue,"@"))
                      + ")".  
                            
            else
                cExpress = "( _user._userid + " 
                   +  "(if _user._domain-name = '' then '' else '@' + _user._domain-name) "
                        + pcOperator
                        + " "
                        + quoter(pcValue) + ")".
         
            return cExpress.
        end.
        
        return super:ColumnExpression(pccolumn,pcOperator,pcValue).     
   
    end method.  
    
    method protected override character FindTableJoinValues(pTable as char,pFind as char):
        case pTable:
            when "_tenant" then
                return FindTenantJoin(pFind).
            
        end case.
        return ?.
    end method.

    method private character FindTenantJoin(pFind as char):
        buffer dictdb._tenant:find-unique(pFind).
        return "_User._Tenantid = " + quoter(_Tenant._Tenantid).
    end method. 
    
end class.