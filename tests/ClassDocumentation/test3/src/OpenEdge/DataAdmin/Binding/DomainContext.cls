/*************************************************************/
/* Copyright (c) 2010-2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    File        : DomainContext
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
using OpenEdge.DataAdmin.Domain from propath. 
using OpenEdge.DataAdmin.DomainSet from propath. 
using OpenEdge.DataAdmin.IDomain from propath. 
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath. 
using OpenEdge.DataAdmin.Binding.Query.TenantDomainQuery from propath. 
using OpenEdge.DataAdmin.Binding.UserContext from propath. 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
using OpenEdge.DataAdmin.Binding.IRow from propath. 
using OpenEdge.DataAdmin.Error.DataContextError from propath.
using OpenEdge.DataAdmin.Binding.Factory.IIdentityScope from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError  from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError  from propath.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError  from propath.
class OpenEdge.DataAdmin.Binding.DomainContext inherits DataAdminContext :

    {daschema/domain.i} 
    define private dataset dsDomain serialize-name "root" for ttDomain.
    define buffer bdomain for ttDomain.
    define temp-table copytable reference-only like ttDomain .  
   
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsDomain:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttDomain:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bdomain for ttDomain.
            if Count = ? then
            do:
                Count = 0.
                for each bdomain:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public DomainContext (users as UserContext):
        super ("Domain").
        AddChild(users).
    end constructor.

    constructor public DomainContext ():
        super ("Domain"). 
        AddChild(new UserContext()).
    end constructor.
    
    constructor public DomainContext (pscope as IIdentityScope):
        super ("Domain",pscope). 
        AddChild(pscope:UserContext).
        CanEditKey = true.
    end constructor.
        
	method public override character GetJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Name,TenantName".
        end.
    end.
 	/*
 	method public override character GetClientJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Name,TenantName".
        end.
        return super:GetClientJoinFields(parentid).
    end.
 	 
 	/* override to use Name in JSON import  */
    method protected override character GetClientKeyFields():
        return "Name". 
    end method.
 	*/
 	
	method public override void CreateRow(entity as IDataAdminElement):
	    /* the default syserror has all info */
	    CreateRow(cast(entity,IDomain)).    
	end method.

    method protected override void CopyTableForParent(pRow as IRow,cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        case pRow:SerializeName:          
            when "tenants" then
                CopyTable(table-handle hTbl by-reference,pRow:KeyIntValue,pRow:FieldValue("Name")). 
            otherwise 
                undo, throw new IllegalArgumentError("DomainContext:CopyTableForParent called with IRow " + quoter(prow:SerializeName)).        
        end.
        
        Loaded = false.
    end method.    
    
    method protected override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false.
    end method.    
    
    method override protected FilteredContext CreateFilteredContext(pRow as IRow,pReq as IRequestInfo):     
        case pRow:SerializeName :          
            when "tenants" then
                return new TenantDomainQuery(this-object,pRow,pReq).
            otherwise
                return super:CreateFilteredContext(pRow,pReq).              
        end.        
    end method.
    
    method private void CopyTable(input table copytable):
        CopyTable(input table copytable by-reference,?,"").  
    end method.
   
	method private void CopyTable(input table copytable,pcTenantId as int,pcTenantName as char):
        define variable dataerror as DataContextError no-undo.      
        for each copytable on error undo, throw:  
            if valid-object(Service) and valid-object(copytable.Entity) then 
            do:
                ValidateDomain(cast(copytable.Entity,IDomain)).
            end.
            do on error undo, throw:
                find bdomain where bdomain.name = copytable.name no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail bdomain then
                do:
                    create bDomain.
                    bdomain.name = copytable.name.               
                end.    
                catch e as Progress.Lang.Error :
                    delete bDomain.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("Domain",e).
                    else 
                        dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        temp-table ttDomain:tracking-changes = true.
        for each copytable:
            create ttdomain.    
            Count = Count + 1.
            buffer-copy copytable to ttdomain.    
            if pcTenantname > "" then  
            do:
                assign
                    ttdomain.TenantId = pcTenantId
                    ttdomain.TenantName= pcTenantName.
            end.
            OnRowCreated().
        end.
        temp-table ttDomain:tracking-changes = false.
            
    end method.  
	
	method private character GetCreateError(domain as IDomain):
        return this-object:GetCreateError(cast(domain,IDataAdminElement),domain:Name). 
    end method.
    
   /* method protected override void ValidateBuffer(phDomain as handle):
        define variable hBefore as handle no-undo.
/*        ValidateGroup(phTenant::Name,phTenant::Type).*/
    
        if phDomain:row-state = row-modified then
        do:
            hBefore = phDomain:before-buffer.
            hbefore:find-by-rowid(phDomain:before-rowid).
            if phDomain::Name <> hBefore::Name then
               undo, throw new ReadOnlyPropertyError(Name,phDomain::Name,"Name").
        end.    
        
    end method. */     
    
         
	method private void ValidateDomain(domain as IDomain):
	    define variable validateError as DataContextError no-undo.
	    define variable e1 as logical no-undo.
/*	    define variable e2 as logical no-undo.   */
/*        define variable e3 as logical no-undo.*/
        define variable e11 as logical no-undo.
/*        define variable e12 as logical no-undo.*/
/*        define variable e13 as logical no-undo.*/

/*        e11 = not valid-object(domain:Tenant).*/
        /* 
        if not e11 and valid-object(Service) then
            assign
                e1 = domain:Tenant:Service <> Service.
        */
        if e1 or e11 /*or e2 or e3 or e11 or e12 or e13 */ then
        do:
           validateError = new DataContextError(GetCreateError(domain)). 
           if e1 then 
               validateError:AddMessage("- The Tenant " + quoter(domain:Tenant:Name) + " is not created in this service.",?).              
           if e11 then 
               validateError:AddMessage("- Tenant is undefined.",?).              
           
           undo, throw validateError.       
        end.
        
	end method.    
	
	method public void CreateRow(domain as IDomain):
	    define variable validateError as DataContextError no-undo.
       
	    temp-table ttDomain:tracking-changes = true.
	    ValidateDomain(domain).
	    
	    do on error undo, throw: 
	        Count = Count + 1.
	        create ttDomain.
            assign 
                ttDomain.Name            = domain:name
                ttDomain.AuthenticationSystemName  = if valid-object(domain:AuthenticationSystem) 
                                           then domain:AuthenticationSystem:Name
                                           else ""
                ttDomain.Description     = domain:Description  
                ttDomain.Comments        = domain:Comments    
                ttDomain.TenantName      = if valid-object(domain:Tenant) then domain:Tenant:Name
                                           else ""    
                ttDomain.IsEnabled       = domain:IsEnabled
                ttDomain.AuditingContext = domain:AuditingContext
                ttDomain.AccessCode      = domain:AccessCode
                ttDomain.RuntimeOptions  = domain:RuntimeOptions
                .   
            OnRowCreated().      
            catch e as Error:  
                delete ttDomain.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(domain),"Domain",e).  
            end catch.  
        end.
        finally:
            temp-table ttDomain:tracking-changes = false.        		
        end finally.
    end method.
    
    method public override logical CanFind(name as character):
        return can-find(ttDomain where ttdomain.name = name).            
    end.     
     
    method public override logical Find(name as character):
        find ttDomain where ttdomain.name = name no-error.
        return avail ttdomain.            
    end.     
    
    method public logical CanFindTenantDomain(ptenant as char,name as character):
        return can-find(ttDomain where ttdomain.Tenantname = ptenant
                                 and   ttdomain.name = name).            
    end.     
     
    method public logical FindTenantDomain(ptenant as char,name as character):
        find ttDomain where ttdomain.Tenantname = ptenant
                      and   ttdomain.name = name no-error.
        return avail ttdomain.            
    end.     
    /*
    
    method public logical CanFindTenantDomain(ptenantid as int,pname as character):
        return can-find(ttDomain where ttdomain.TenantId = ptenantid
                                 and   ttdomain.name = pname).            
    end.     
     
    method public logical FindTenantDomain(ptenantid as int,pname as character):
        find ttDomain where ttdomain.TenantId = ptenantid
                      and   ttdomain.name = pname no-error.
        return avail ttdomain.            
    end.     
    */
    
    /* called with tracking-changes */
    method protected override void ReadNewForParent(pcParent as char, pcValue as char,phTbl as handle):       
        case pcParent:
            when "tenants" then
            do:
                ReadNewForTenant(pcValue,table-handle phtbl by-reference).
            end.   
            otherwise 
                undo, throw new IllegalArgumentError("DomainContext:ImportNewTableForParent parent" + quoter(pcParent)).
     
        end.     
    end method.
    
    method private void ReadNewForTenant(pcVal as char,input table copytable ):
        define variable dataerror as DataContextError no-undo.      
        for each copytable on error undo, throw:  
            
            find ttDomain where ttDomain.TenantName = pcVal
                          and   ttDomain.Name = copytable.Name  no-error.
            if avail ttDomain then  
                undo, throw new IllegalArgumentError("Tenant " +  quoter(pcVal)
                                                     + " already has a Domain with Name " + quoter(copytable.Name ) ).
            create ttDomain.
          
            ttDomain.TenantName = pcVal.
            buffer-copy copytable except TenantName to ttDomain.           
        end.
    end method. 
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new DomainSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Domain(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(req as IRequestInfo):
        return new Domain(this-object,req).
    end method.
    
/*    method public void ShowData():                                        */
/*        define variable cc as character no-undo.                          */
/*        for each ttDomain:                                                */
/*            cc = cc + chr(10)                                             */
/*            + "Name: " + ttDomain.Name + " tenant: " + ttDomain.TenantName*/
/*            + " state " + string(buffer ttDomain:row-state).              */
/*                                                                          */
/*         end.                                                             */
/*        message cc                                                        */
/*        view-as alert-box.                                                */
/*    end.                                                                  */
    
    method public override character ColumnSource(pcColumn as char):
        if pccolumn = "type" or pcColumn = "AuthenticationSystem.Name" then 
            return "ttDomain.AuthenticationSystemName".
        return super:ColumnSource(pccolumn).
    
    end method.

	 
end class.
