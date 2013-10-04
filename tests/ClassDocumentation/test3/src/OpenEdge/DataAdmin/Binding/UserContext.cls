/*************************************************************/
/* Copyright (c) 2010-2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/ 
/*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using Progress.Json.ObjectModel.JsonObject from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath. 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.User from propath. 
using OpenEdge.DataAdmin.UserSet from propath. 
using OpenEdge.DataAdmin.IUser from propath. 
using OpenEdge.DataAdmin.IDomain from propath. 

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath. 
using OpenEdge.DataAdmin.Binding.Query.UserQuery from propath. 
using OpenEdge.DataAdmin.Binding.Query.DomainUserQuery from propath. 
using OpenEdge.DataAdmin.Binding.UserContext from propath. 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IIdentityScope from propath. 
using OpenEdge.DataAdmin.Message.IFetchResponse  from propath. 
using OpenEdge.DataAdmin.Message.ITableResponse  from propath. 
using OpenEdge.DataAdmin.Error.DataContextError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError  from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError  from propath.

class OpenEdge.DataAdmin.Binding.UserContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/user.i} 
    define private dataset dsUser serialize-name "root" for ttUser.
    define buffer buser for ttUser.
    define temp-table copytable reference-only like ttUser .  
    
    define private variable mRefresh as logical no-undo.
    
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsUser:handle.
        end get.
     
    define public property ContextFactory as IContextFactory  no-undo 
        get():
            return cast(ContextScope,IContextFactory) .
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttUser:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Id". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer buser for ttUser.
            
            if Count = ? then
            do:
                
                Count = 0.
                for each buser:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        public set.
    
    constructor public UserContext ():
        super ("User").
    end constructor.
        
/*	constructor public UserContext ( service as DataAdminService):*/
/*		super ("User",service).                                      */
/*	end constructor.                                              */
     
    constructor public UserContext ( pscope as IIdentityScope):
        super ("User",pScope). 
        
    end constructor.
    
	method public override character GetJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Name,TenantName".
            when "tenants.id" then
                return "Id,TenantId".    
            when "domains" then
                return "Name,DomainName".
        end.
    end.
    
    method public override character GetServerJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Id,TenantId".
        end.
        return super:GetServerJoinFields(parentid).
    end.
    
    
    /* override to use Name in JSON import  
    method protected override character GetClientKeyFields():
        return "Name,DomainName". 
    end method.
    */
    /*
    method public override character GetServerJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Id,TenantId".
        end.
        return super:GetServerJoinFields(parentid).
    end.
    */
	method public override void CreateRow(entity as IDataAdminElement):
	    /* the default syserror has all info */
	    CreateRow(cast(entity,IUser)).    
	end method.

    method protected override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
          
        hTbl = cntxt:TableHandle.
        
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false.
    end method.    
    
    method protected override void CopyTableForParent(pcparent as char, pcValue as char,cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        case pcparent:          
           when "tenants" then 
           do:
               CopyTable(table-handle hTbl by-reference,"T",pcValue).
           end.
           when "domains" then
               CopyTable(table-handle hTbl by-reference,"D",pcValue). 
           otherwise 
               undo, throw new IllegalArgumentError("UserContext:CopyTableForParent called with parent " + quoter(pcparent)).        
        end.
        
        Loaded = false.
    end method.    
    
    method private void CopyTable(input table copytable):
          CopyTable(table copytable by-reference,"","").
    end method.
    
	method private void CopyTable(input table copytable,pcType as char,pcValue as char):
	    define variable dataerror as DataContextError no-undo.    
	    define variable cDomain as character no-undo.
	    define variable dmn as IDomain no-undo.
        for each copytable on error undo, throw:  
            if valid-object(Service) and valid-object(copytable.Entity) then 
            do:
                ValidateUser(cast(copytable.Entity,IUser)).
            end.
            if pcType = "T" then
            do:
                if copytable.tenantname > "" and copytable.tenantname <> pcValue then 
                       undo, throw new IllegalArgumentError(
                              "User " + copytable.name + " belongs to another Tenant." ).
                
                if copytable.DomainName = "" and copytable.tenantname <> "Default" then 
                    undo, throw new IllegalArgumentError(
                              "User " + copytable.name + " has no Domain." ).
                
                /* need to read domain for save 
                   - we use the domain relation in the dataset 
                  (it is possible to change CreateDataset to have users right under
                   tenant, some work likely needed to use tenantname field -
                   - could make it easier to move validation to from create to save   ) */
                if valid-object(Service) then 
                do:
                    dmn = service:getDomain(copytable.DomainName). 
                    if not valid-object(dmn) then 
                        undo, throw 
                           new IllegalArgumentError(
                              "User " + copytable.name + " Domain " +  copytable.DomainName  + " does not exist.").
                     
                     if dmn:Tenant:name <> pcValue then
                        undo, throw 
                           new IllegalArgumentError(
                              "User " + copytable.name + " Domain " +  copytable.DomainName  + " belongs to another Tenant.").
             
                end.
                cDomain = copytable.DomainName.
            end.
            if pcType = "D" then
            do:
                if copytable.domainname > "" and copytable.domainname <> pcValue then 
                    undo, throw new IllegalArgumentError(
                              "User " + copytable.name + " belongs in another Domain." ).
           
               cDomain = if pctype = "D" then pcValue
                         else copytable.DomainName.
            end.
            do on error undo, throw:
                
                find buser where buser.name = copytable.name
                                 and buser.DomainName = cDomain no-error.
                 
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail buser then
                do:
                    create bUser.
                    buser.name = copytable.name.
                    buser.domainname = cDomain.               
                end.    
                catch e as Progress.Lang.Error :
                  
                    delete bUser.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("User",e).
                    else 
                       dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        temp-table ttUser:tracking-changes = true.
        for each copytable:
            create ttuser.    
            Count = Count + 1.
            buffer-copy copytable to ttuser.    
            if pctype = "D" then 
                ttUser.DomainName = pcValue.
            ttUser.id = ttUser.name 
                      + (if ttUser.DomainName > "" 
                         then "@" + ttUser.DomainName 
                         else "").
            OnRowCreated().
        end.
        temp-table ttUser:tracking-changes = false.
         
    end method.  
	
	method private character GetCreateError(userImpl as IUser):
        return this-object:GetCreateError(cast(userImpl,IDataAdminElement),userImpl:Name). 
    end method.
         
	method private void ValidateUser(userImpl as IUser):
	    define variable validateError as DataContextError no-undo.
	    define variable e1 as logical no-undo.
	    define variable e2 as logical no-undo.
        define variable e3 as logical no-undo.
        define variable e11 as logical no-undo.
        define variable e12 as logical no-undo.
        define variable e13 as logical no-undo.
        
/*        if valid-object(Service) then                                                                                      */
/*            assign                                                                                                         */
/*                e1 = user:Tenant:Service <> Service.                                                                       */
/*        assign                                                                                                             */
/*            e11 = not valid-object(user:Tenant)                                                                            */
/*            .                                                                                                              */
/*                                                                                                                           */
/*        if e1 or e11 /*or e2 or e3 or e11 or e12 or e13 */ then                                                            */
/*        do:                                                                                                                */
/*           validateError = new DataContextError(GetCreateError(user)).                                                     */
/*           if e1 then                                                                                                      */
/*               validateError:AddMessage("- The Tenant " + quoter(user:Tenant:Name) + " is not created in this service.",?).*/
/*           if e11 then                                                                                                     */
/*               validateError:AddMessage("- Tenant is undefined.",?).                                                       */
/*                                                                                                                           */
/*           undo, throw validateError.                                                                                      */
/*        end.                                                                                                               */
        
	end method.    
	
	/* called with tracking-changes */
    method protected override void ReadNewForParent(pcParent as char, pcValue as char,phTbl as handle):       
        case pcParent:
            when "tenants" then
            do:
                ReadNewForTenant(pcValue,table-handle phtbl by-reference).
            end.   
            otherwise 
                undo, throw new IllegalArgumentError("UserContext:ImportNewTableForParent parent" + quoter(pcParent)).
     
        end.     
    end method.
     
	method private void ReadNewForTenant(pcVal as char,input table copytable ):
        define variable dataerror as DataContextError no-undo.      
        for each copytable on error undo, throw:  
            
            find ttUser where ttUser.TenantName = pcVal
                        and   ttUser.Name = copytable.Name 
                        and   ttUser.DomainName = copytable.DomainName no-error.
            if avail ttUser then  
                undo, throw new IllegalArgumentError("Tenant " +  quoter(pcVal)
                                                     + " already has a User with Name " + quoter(copytable.Name ) 
                                                     +  " and Domain " +   quoter(copytable.DomainName)).
            create ttuser.
            buffer-copy copytable to ttUser .           
        end.
    end method. 
	
	/** also used for name only - domain is then added later */ 
	method protected override void InitRow(pId as char):
	    define variable cDomain as character no-undo.
        define variable cUserid as character no-undo.
	    validId(pId,output cUserid,output cDomain).  
        create ttUser. 
        assign ttUser.Domainname = cDomain
               ttUser.name = cUserid .  
	end method.
    
	method public void CreateRow(userImpl as IUser):
         CreateRow(userimpl,?). 
    end method.
	
	method public void CreateRow(userImpl as IUser,pcDomain as char):
        define variable validateError as DataContextError no-undo.
        define variable newdomain as IDomain no-undo.
	    define variable cDomain as character no-undo.
	    temp-table ttUser:tracking-changes = true.
	    ValidateUser(userImpl).
	    newdomain = userImpl:Domain.
         
	    if pcdomain <> ? then 
	    do: 
	        if valid-object(newdomain) then 
                undo, throw new IllegalArgumentError("Cannot add user " + quoter(userImpl:name) 
	                                                + " to Domain " + quoter(pcdomain) + "."
	                                                + " It already belongs to Domain " 
	                                                + quoter(newdomain:name)
	                                                ). 
	        cDomain = pcdomain.
	    end.
	    else if valid-object(newdomain) then
	    do:
	        cDomain = newDomain:name.
	    end.
	        
	    do on error undo, throw: 
	        Count = Count + 1.
	        create ttUser.
            assign 
                ttUser.Name            = userImpl:name
                ttUser.Entity          = userImpl
                ttUser.Id              = userImpl:Id
                ttUser.Name            = userImpl:Name
                ttUser.DomainName      = cDomain
         /*     ttUser.Tenant          = userImpl:Tenant:Name when valid-object(userImpl:Tenant).*/
                ttUser.Description     = userImpl:Description     
                ttUser.GivenName       = userImpl:GivenName
                ttUser.MiddleInitial   = userImpl:MiddleInitial
                ttUser.SurName         = userImpl:SurName
                ttUser.Password        = userImpl:Password
                ttUser.Telephone       = userImpl:Telephone 
                ttUser.Email           = userImpl:Email   
                .   
            OnRowCreated().      
            catch e as Error:  
                delete ttUser.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(userImpl),"User",e).  
            end catch.  
        end.
        finally:
            temp-table ttUser:tracking-changes = false.        		
        end finally.
    end method.
    
    method public override logical CanFind(pid as character):
        define variable cDomain as character no-undo.
        define variable cUserid as character no-undo.
        validId(pid,output cUserid,output cDomain).  
        return can-find(ttUser where ttUser.Domainname = cDomain
                               and   ttUser.name = cUserid).            
    end method.
     
    method public override logical Find(pid as character):
        define variable cDomain as character no-undo.
        define variable cUserid as character no-undo.
        
        validId(pid,output cUserid,output cDomain).  
        find ttUser where ttUser.Domainname = cDomain
                    and   ttUser.name = cUserid no-error.  
               
        return avail ttuser.            
    end method.
    
    method public logical CanFind(pid as char,pDomain as char):
        return can-find(ttUser where ttUser.Domainname = pDomain
                               and   ttUser.name = pid).                   
    end.     
     
    method public logical Find(pid as char,pDomain as char):
        find ttUser where ttUser.Domainname = pDomain
                    and   ttUser.name = pid no-error.  
        return avail ttUser.            
    end.     
     
    method private void validId(id as char,output puser as char, output pdomain as char): 
        if num-entries(id,"@") > 1 then 
            pdomain = entry(2,id,"@").
       
        puser = entry(1,id,"@").
             
    end method.
   
    /** create default filteredcontext that also handles parent/keyvalue as filter. */
    method override protected FilteredContext CreateFilteredContext(filter as char):
        return new UserQuery(this-object,filter).
    end method.
  
    /** create default filteredcontext with requestinfo  */
    method override protected FilteredContext CreateFilteredContext(pReq as IRequestInfo):
        return new UserQuery(this-object,pReq).
    end method.
  
    method override protected FilteredContext CreateFilteredContext(pparent as char,pkey as char,pReq as IRequestInfo):     
         case pparent:          
             when "domains" then
             do:              
                  return new DomainUserQuery(this-object,pkey,pReq).
             end.
             otherwise
                 return super:CreateFilteredContext(pparent,pkey,pReq).              
         end.        
    end method.
   
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):
        return new UserSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new User(cntxt).
    end method.
    
    method protected override void ReadRowForParent(pcParent as char, pcValue as char extent,pjson as JSONObject).
        case pcParent:
            when "tenants" then 
            do:
                ReadRowForTenant(pcValue[1],pjson).    
            end.
            otherwise 
                 undo, throw new IllegalArgumentError("ReadRowForParent " +  quoter(pcParent)).
        end case.         
    end method.    
    
    method private void ReadRowForTenant(pcVal as char,pjson as JSONObject):    
        define variable cId as character no-undo init ?.
        define variable cName as character no-undo init ?.
        define variable cDomainName as character no-undo init ?.
        define variable lUseid as logical no-undo.
        if pjson:Has("id") then
           cId = pjson:GetCharacter("id").
        if pjson:Has("name") then
            cName = pjson:GetCharacter("name").
        if pjson:Has("domainName") then
            cDomainName = pjson:GetCharacter("domainName").
        
        if cName = ? and cDomainName = ?  then
        do: 
            luseid = true.
            find ttUser where ttUser.TenantName = pcVal
                        and   ttUser.Id         = cId.
             
        end.
        else do:
            find ttUser where ttUser.TenantName = pcVal
                        and   ttUser.Name = cName 
                        and   ttUser.DomainName = cDomainName.       
        end.
        if avail ttUser then 
        do:
            ReadRow(pjson,"Id,Name,DomainName").
        end.
        catch e as Progress.Lang.Error :
        	if e:GetMessageNum(1) = 138 then
        	do:
        	    if luseid then
                    undo, throw new IllegalArgumentError("User " +  quoter(cid) + " was not found").
                else 
        	        undo, throw new IllegalArgumentError("User " +  quoter(cname) + " " + quoter(cDomainName) + " was not found").
            end.    
            else 
                undo, throw e.     
        end catch.   
            
    end method.
    
    method protected override char FindExpression(pusrid as char):
        define variable cDomain as character no-undo.
        define variable cUserid as character no-undo.
        
        validId(pusrid,output cUserid,output cDomain).  
        
        return  "ttUser.DomainName = " + quoter(cDomain) 
              + " and "
              + "ttUser.Name = " + quoter(cUserid) .
    end method.
    
    method public override void DataRefreshed(pResponse as IFetchResponse):
        define variable i as integer no-undo.
        define variable tblResponse as ITableResponse no-undo.
        define variable hBuffer  as handle no-undo.
        /*            hds:copy-dataset(hCopy,yes,yes).*/
        if mRefresh or pResponse:Entityname <> "user" 
        then
        do: 
            super:DataRefreshed(pResponse).
        end.
        else do:   
            /* user context refresh any joined parents retrieved */       
            tblResponse = pResponse:GetTableResponse("ttTenant").
            if valid-object(tblResponse) then   
            do:
                mRefresh = true.          
                ContextFactory:TenantContext:DataRefreshed(pResponse) .
                mRefresh = false.
            end.
            else do:
                tblResponse = pResponse:GetTableResponse("ttDomain").
                if valid-object(tblResponse) then  
                do: 
                    mRefresh = true. 
                    ContextFactory:DomainContext:DataRefreshed(pResponse) .
                    mRefresh = false.
                end.
                else 
                    super:DataRefreshed(pResponse).
            end.
        end.       
    end method.   
    
end class.
