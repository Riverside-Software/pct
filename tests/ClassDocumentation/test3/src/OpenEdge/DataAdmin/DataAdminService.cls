/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** 
   Purpose     : Data Admin Service with crud methods for 
                 collections (IDataAdminCollection) and 
                 entities (IDataAdminElement) 
   Syntax      : 
   Description : 
   Author(s)   : hdaniels
   Created     : Sat Jul 10 23:27:42 EDT 2010
   Notes       :  
   */
 
routine-level on error undo, throw.
using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.IDataAdminService from propath.

using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IAdministrator from propath.
using OpenEdge.DataAdmin.ISecurityOptions from propath.
using OpenEdge.DataAdmin.IArea from propath.

using OpenEdge.DataAdmin.IDataSecurity from propath.
using OpenEdge.DataAdmin.IDomain from propath.
using OpenEdge.DataAdmin.IAuthenticationSystem from propath.
using OpenEdge.DataAdmin.IExtent from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITablePermission from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.
using OpenEdge.DataAdmin.IUser from propath.
using OpenEdge.DataAdmin.IUserPermission from propath.
using OpenEdge.DataAdmin.IUserTablePermission from propath.
using OpenEdge.DataAdmin.Extent from propath.
using OpenEdge.DataAdmin.TenantGroupMember from propath.

using OpenEdge.DataAdmin.IAreaSet from propath. 
using OpenEdge.DataAdmin.IDomainSet from propath.
using OpenEdge.DataAdmin.IAuthenticationSystemSet from propath.
using OpenEdge.DataAdmin.ISchemaSet from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.ITableSet from propath.
using OpenEdge.DataAdmin.ITablePermissionSet from propath.
using OpenEdge.DataAdmin.ITenantSet from propath.
using OpenEdge.DataAdmin.IUserSet from propath.
using OpenEdge.DataAdmin.IUserPermissionSet from propath.
using OpenEdge.DataAdmin.IUserTablePermissionSet from propath.
 
using OpenEdge.DataAdmin.IPartitionMap from propath.
using OpenEdge.DataAdmin.ITenantGroupSet   from propath.
using OpenEdge.DataAdmin.IPartitionCollection from propath.
 
using OpenEdge.DataAdmin.DomainSet from propath.
using OpenEdge.DataAdmin.SchemaSet from propath.
using OpenEdge.DataAdmin.Schema from propath.
using OpenEdge.DataAdmin.TableSet from propath.
using OpenEdge.DataAdmin.UserSet from propath.
  
using OpenEdge.DataAdmin.ISequence from propath.
using OpenEdge.DataAdmin.ISequenceSet from propath.

using OpenEdge.DataAdmin.IRequestInfo from propath.

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminModel from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
 
using OpenEdge.DataAdmin.Binding.CreateContext from propath.
using OpenEdge.DataAdmin.Binding.SchemaChanges from propath.
using OpenEdge.DataAdmin.Binding.RowImpl from propath.
 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Factory.ServiceContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Message.FetchDefinitions from propath.
using OpenEdge.DataAdmin.Message.LoadDefinitions from propath.

using OpenEdge.DataAdmin.Error.DataError from propath.
using OpenEdge.DataAdmin.Error.OperationError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.NotFoundError from propath.

using OpenEdge.DataAdmin.Core.FileLogger from propath. 
using OpenEdge.DataAdmin.Util.IDataAdminUtility from propath.

class OpenEdge.DataAdmin.DataAdminService implements IDataAdminService: 
    
	define public event ServiceDeleted     signature void ().
	
    define private variable ServiceAdapter as ServiceAdapter no-undo.
    define protected variable ContextFactory as IServiceContextFactory no-undo.
   
    define public property URL as char no-undo get. set.
    define public property ThrowDataErrors as logical no-undo init yes 
        get. 
        set.
    
    define public property TransactionLogger as FileLogger no-undo get. set.    
         
    define private property Error as OperationError no-undo 
        get. 
        set.  
 
    define public property Name as character no-undo 
        get(): 
            return ServiceAdapter:ServiceName.
        end. 
        private set. 
     
    define private property CurrentSchemaChanges as SchemaChanges no-undo 
        get.
        set.
           
    constructor public DataAdminService (  ):
        super ().
    	ServiceAdapter = new ServiceAdapter( ).
        ContextFactory = new ServiceContextFactory(this-object,ServiceAdapter).  
    end constructor.
       
    constructor public DataAdminService ( name as char ):     
        ServiceAdapter = new ServiceAdapter(name).     
        ContextFactory = new ServiceContextFactory(this-object,ServiceAdapter).  
    end constructor.
        
    constructor public DataAdminService ( path as char,name as char ):
        super ().
         /* this error is duplicated in ServiceAdapter*/
        if path = ? then
        do:
            undo, throw new UnknownValueError("Service constructor","path","Specify blank to connect to a database in the current directory or use the single character parameter constructor to use the Service with a connected database.").
        end.     
       
        ServiceAdapter = new ServiceAdapter(path,name).    
        ContextFactory = new ServiceContextFactory(this-object,ServiceAdapter).  
    end constructor.
        
    /* the service only supports one active context retrieved with GetShemaChanges */
    method public logical CancelSchemaChanges():
        CurrentSchemaChanges = ?.
    end method.
    
    /* the service only supports one active context retrieved with GetShemaChanges */
    /*method public logical DeleteSchemaChanges(pschema as ISchema):
        AssertUpdate(pSchema,CurrentSchemaChanges).
        CancelSchemaChanges().
    end method.*/
    
    method public logical CreateArea(area as IArea):
        return CreateElement(area,ContextFactory:AreaContext).
    end method.
   
    method public logical CreateAreas(areas as IAreaSet):
        return CreateCollection(areas,ContextFactory:AreaContext).
    end method.
   
    method public logical CreateDomain(domain as IDomain):
        return CreateElement(domain,ContextFactory:DomainContext).        
    end method.
   
    method public logical CreateDomains(domains as IDomainSet):
        return CreateCollection(domains,ContextFactory:DomainContext). 
    end method.
    
    method public logical CreateAuthenticationSystem(authenticationsystem as IAuthenticationSystem):
        return CreateElement(authenticationsystem,ContextFactory:AuthenticationSystemContext).         
    end method.
   
    method public logical CreateAuthenticationSystems(authenticationsystems as IAuthenticationSystemSet):
        return CreateCollection(authenticationsystems,ContextFactory:AuthenticationSystemContext). 
    end method.
    
    method public logical CreateTenantGroups(groups as ITenantGroupSet):
        return CreateCollection(groups,ContextFactory:TenantGroupContext). 
    end method.
    
    method public logical CreateTenantGroup(newgroup as ITenantGroup):
        return CreateElement(newGroup,ContextFactory:TenantGroupContext).        
    end method.
    
    method public logical CreateSequence(sequence as ISequence):
        return CreateElement(sequence,ContextFactory:SequenceContext).        
    end method.
    
    method public logical CreateSequences(sequences as ISequenceSet):
        return CreateCollection(sequences,ContextFactory:SequenceContext).        
    end method.
    
    method public logical CreateTenants(tenants as ITenantSet):
        return CreateCollection(tenants,ContextFactory:TenantContext). 
    end method.
    
    method public logical CreateTenant(tenant as ITenant):
        return CreateElement(tenant,ContextFactory:TenantContext).        
    end method.
       
    method public logical CreateUsers(users as IUserSet):
        return CreateCollection(users,ContextFactory:UserContext).        
    end method.
    
    method protected logical CreateCollection(coll as IDataAdminCollection, cntxt as IDataAdminContext):
        define variable newcontext as IDataAdminContext no-undo.
        AssertCreate(coll,cntxt).
        do on error undo, throw:
            newcontext = new CreateContext(cntxt).
            coll:Attach(newcontext).         
            catch e as Progress.Lang.Error:
                ErrorHandler(e).  
                return false.
            end catch.
        end.
        return UpdateCollection(coll,cntxt).
    end method.
    
    method protected logical CreateElement(elem as IDataAdminElement,cntxt as IDataAdminContext):
        define variable rowinfo as IRow no-undo.
        define variable response as ISaveRequest no-undo.
        AssertCreate(elem,cntxt).
        do on error undo, throw:
            elem:Attach(cntxt).
            if num-entries(cntxt:KeyFields) > 1 then
            do:
                rowinfo = GetRowInfo(elem,cntxt).
                response = cast(cntxt,IDataAdminModel):GetCreateRowRequest(rowinfo).
            end.
            else
                response = cast(cntxt,IDataAdminModel):GetCreateRowRequest().
            
            if not valid-object(response) then
                return false. 
            response = SaveData(response).
            cntxt:MergeChanges(response).
            catch e as Progress.Lang.Error:
                ErrorHandler(e).          
                return false.
            end catch.
        end.
        return true.
    end method.
    
    method public Error RemoveError():
        define variable err as Error no-undo.
        err = Error.
        Error = ?.
        return err.
    end.    
 
    method public Error GetError():
        return this-object:Error.
    end.    
    
    method public void ThrowError ():
        if valid-object(Error) then
        do:
            define variable err as Error no-undo.
            err = RemoveError(). 
            undo, throw err.
        end.
    end.    
    
    method public logical CreateUser(usr as IUser):
        return CreateElement(usr,ContextFactory:UserContext).         
    end method.
     
    method public logical DeleteDomain(domainName as char):
        define variable response as ISaveRequest no-undo.       
        define variable inst as IDomain no-undo.    
       
        inst = GetDomain(domainName).
        if not valid-object(inst) then 
            undo, throw new NotFoundError("Domain " + quoter(domainName) + " not found").  
        
        return DeleteElement(domainName,inst,ContextFactory:DomainContext).    
    end method.
     
    method public logical DeleteAuthenticationSystem(authenticationsystemName as char):
        define variable response as ISaveRequest no-undo.       
        define variable inst as IAuthenticationSystem no-undo.    
       
        inst = GetAuthenticationSystem(authenticationsystemName).
        if not valid-object(inst) then 
            undo, throw new NotFoundError("AuthenticationSystem " + quoter(authenticationsystemName) + " not found").  
        
        return DeleteElement(authenticationsystemName,inst,ContextFactory:AuthenticationSystemContext).    
    end method.
    
    method public logical DeleteTenant(tenantName as char):
        define variable response as ISaveRequest no-undo.       
        define variable inst as ITenant no-undo.       
        inst = GetTenant(tenantName).
        if not valid-object(inst) then 
            undo, throw new NotFoundError("Tenant " + quoter(tenantName) + " not found").  
              
        return DeleteElement(tenantName,inst,ContextFactory:TenantContext).    
     end method.
    
    method public logical DeleteTenantGroup(groupName as char):
        define variable response as ISaveRequest no-undo.       
        define variable inst as ITenantGroup no-undo.       
        inst = GetTenantGroup(groupName).
        if not valid-object(inst) then 
             undo, throw new NotFoundError("Partition group " + quoter(groupName) + " not found").  
              
        return DeleteElement(groupName,inst,ContextFactory:TenantGroupContext).    
 
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
    end method.
    
    method public logical DeleteSequence(seqname as char):
        define variable response as ISaveRequest no-undo.       
        define variable inst as ISequence no-undo.    
       
        inst = GetSequence(seqname).
        if not valid-object(inst) then 
            undo, throw new NotFoundError("Sequence " + quoter(seqname) + " not found").  
        
        return DeleteElement(seqName,inst,ContextFactory:SequenceContext).    
    end method.
    
    method public logical DeleteUser(usrId as char):
        define variable response as ISaveRequest no-undo.       
        define variable inst as IUser no-undo.    
       
        inst = GetUser(usrId).
        if not valid-object(inst) then 
            undo, throw new NotFoundError("User " + quoter(usrId) + " not found").  
        
        return DeleteElement(usrId,inst,ContextFactory:UserContext).    
    end method.
    
    method public IAdministrator GetAdministrator():
        return cast(ContextFactory:AdministratorContext:GetEntity(""),IAdministrator). 
    end method.
    
    method public ISecurityOptions GetSecurityOptions():
        return cast(ContextFactory:SecurityOptionsContext:GetEntity(""),ISecurityOptions). 
    end method.
    
    method public IArea GetArea(areaName as char):
        return cast(ContextFactory:AreaContext:GetEntity(areaName),IArea). 
    end method.
    
    method public IArea GetArea(pReq as IRequestInfo):
        CheckAreaReq(pReq).
        return cast(ContextFactory:AreaContext:GetEntity(pReq),IArea). 
    end method.
     
    method public IArea GetArea(areaNum as int):
        return cast(ContextFactory:AreaContext:GetEntity(areaNum),IArea). 
    end method.
       
    method public IAreaSet GetAreas():
        return cast(ContextFactory:AreaContext:GetCollection(),IAreaSet).
    end method.
    
    method public IAreaSet GetAreas(filter as char):
        return cast(ContextFactory:AreaContext:GetCollection(filter),IAreaSet).
    end method.
    
    method private void CheckAreaReq(preq as IRequestInfo):
        define variable extentReq as IRequestInfo no-undo. 
         /** the AreaNumExtents require all data on client, since it is using Count
            (would need to count created  ) */
        if valid-object(pReq) then
        do:
            extentReq = pReq:Get("extents").
            if valid-object(extentReq) then
            do:
                undo, throw new UnsupportedOperationError("Filter on extents is not supported.").
            end.
        end.    
    end method.
    
    method public IAreaSet GetAreas(preq as IRequestInfo):
        CheckAreaReq(pReq).
        return cast(ContextFactory:AreaContext:GetCollection(preq),IAreaSet).
    end method.
     
    method public IDataSecurity GetDataSecurity(pcKey as char):
        return cast(ContextFactory:DataSecurityContext:GetEntity(pcKey),IDataSecurity). 
    end method.
    
    method public IDomain GetDomain(domainName as char):
        return cast(ContextFactory:DomainContext:GetEntity(domainName),IDomain). 
    end method.
    
    method public IDomain GetDomain(req as IRequestInfo):
        return cast(ContextFactory:DomainContext:GetEntity(req),IDomain). 
    end method.
    
    method public IDomainSet GetDomains():
        define variable inst as IDomainSet no-undo.
        inst = cast(ContextFactory:DomainContext:GetCollection(),IDomainSet).
        return inst.
    end method.
   
    method public IDomainSet GetDomains(filter as char):
        return cast(ContextFactory:DomainContext:GetCollection(filter),IDomainSet).
    end method.
    
    method public IDomainSet GetDomains(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:DomainContext:GetCollection(pRequestInfo),IDomainSet).
    end method.
       
    method public IAuthenticationSystem GetAuthenticationSystem(name as char):
        return cast(ContextFactory:AuthenticationSystemContext:GetEntity(name),IAuthenticationSystem).
    end method.
    
    method public IAuthenticationSystemSet GetAuthenticationSystems():
        return cast(ContextFactory:AuthenticationSystemContext:GetCollection(),IAuthenticationSystemSet).
    end method.
    
    method public IAuthenticationSystemSet GetAuthenticationSystems(filter as char):
        return cast(ContextFactory:AuthenticationSystemContext:GetCollection(filter),IAuthenticationSystemSet).
    end method.
   
    method public IAuthenticationSystemSet GetAuthenticationSystems(req as IRequestInfo):
        return cast(ContextFactory:AuthenticationSystemContext:GetCollection(req),IAuthenticationSystemSet).
    end method.
      
    method public ITenantGroupSet GetTenantGroups():
        define variable inst as ITenantGroupSet no-undo.
        inst = cast(ContextFactory:TenantGroupContext:GetCollection(),ITenantGroupSet).   
        return inst.
    end method.
    
    method public ITenantGroupSet GetTenantGroups(filter as char):
        define variable inst as ITenantGroupSet no-undo.
        inst = cast(ContextFactory:TenantGroupContext:GetCollection(filter),ITenantGroupSet).   
        return inst.
    end method.
    
    method public ITenantGroupSet GetTenantGroups(pRequestInfo as IRequestInfo):
        define variable inst as ITenantGroupSet no-undo.
        inst = cast(ContextFactory:TenantGroupContext:GetCollection(pRequestInfo),ITenantGroupSet).   
        return inst.
    end method.
    
    method public ITenantGroup GetTenantGroup(groupName as char):
        define variable inst as ITenantGroup no-undo.
        inst = cast(ContextFactory:TenantGroupContext:GetEntity(groupName),ITenantGroup). 
        return inst.
    end method.
    
    method public ITenantGroup GetTenantGroup(groupId as int):
        define variable inst as ITenantGroup no-undo.
        inst = cast(ContextFactory:TenantGroupContext:GetEntity(groupId),ITenantGroup). 
        return inst.
    end method.
   
    method public ITenantGroup GetTenantGroup(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:TenantGroupContext:GetEntity(pRequestInfo),ITenantGroup). 
    end method.
       
    method public ISequence GetSequence(SeqName as char):
        return cast(ContextFactory:SequenceContext:GetEntity(SeqName),ISequence). 
    end method.
   
    method public ISequence GetSequence(reqInfo as IRequestInfo):
        return cast(ContextFactory:SequenceContext:GetEntity(reqInfo),ISequence). 
    end method.
   
    method public ISequenceSet GetSequences():
        return cast(ContextFactory:SequenceContext:GetCollection(),ISequenceSet).
    end method.
        
    method public ISequenceSet GetSequences(filter as char):
        return cast(ContextFactory:SequenceContext:GetCollection(filter),ISequenceSet).   
    end method.   
   
    method public ISequenceSet GetSequences(reqInfo as IRequestInfo):
        return cast(ContextFactory:SequenceContext:GetCollection(reqInfo),ISequenceSet).   
    end method.    
   
    /* the service only supports "pub" schema so no key parameter */
    method public ISchema GetSchema():
        return cast(ContextFactory:SchemaContext:GetEntity("PUB"),ISchema). 
    end method.
    
    /* the service only supports "pub" schema so no key parameter */
    method public ISchema GetSchema(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:SchemaContext:GetEntity(pRequestInfo),ISchema). 
    end method.
    
    /* the service only supports "pub" schema so no key parameter */
    method public ISchema GetSchema(collectionFilter as char):
        return cast(ContextFactory:SchemaContext:GetEntity("PUB"),ISchema). 
    end method.
    
    /* the service only supports "pub" schema so no key parameter */
    method public ISchema GetSchemaChanges(pcFile as char):
        define variable schemaobj as ISchema no-undo.
        define variable msg as FetchDefinitions no-undo.
        /*
        if not session:batch-mode then 
            undo, throw new UnsupportedOperationError("GetSchemas in online session").
        */
        if valid-object(CurrentSchemaChanges) then 
        do:
            undo, throw new UnsupportedOperationError ("GetSchemaChanges cannot be called before the previously requested changes have been updated, deleted or cancelled.").
        end.
        CurrentSchemaChanges = ContextFactory:GetSchemaDefinitionContext(pcFile).      
/*      CurrentSchemaChanges:TestData().*/
   
        schemaobj = cast(CurrentSchemaChanges:GetEntity("PUB"),ISchema).
      

        return schemaobj.  
    end method.
    
    method public logical LoadSchemaChanges(pcFile as char):
        define variable msg as LoadDefinitions no-undo.
        msg = new LoadDefinitions().
        msg:FileName = pcfile.
        run prodict/dump/_load_df.p(msg).   
        if valid-object(msg:Logger:Error) then
           undo, throw msg:Logger:Error.
        return true.   
    end method.
      
    method public ITable GetTable(tableName as char):
        return cast(ContextFactory:TableContext:GetEntity(tableName),ITable). 
    end method.
    
    method public ITable GetTable(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:TableContext:GetEntity(pRequestInfo),ITable). 
    end method.
      
    method public ITableSet GetTables():
        return cast(ContextFactory:TableContext:GetCollection(),ITableSet).
    end method.
    
    method public ITableSet GetTables(filter as char):
        return cast(ContextFactory:TableContext:GetCollection(filter),ITableSet).
    end method.
    
    method public ITableSet GetTables(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:TableContext:GetCollection(prequestInfo),ITableSet).
    end method.
    
    method public ITablePermission GetTablePermission(pcName as char ):
        return cast(ContextFactory:TablePermissionContext:GetEntity(pcName),ITablePermission).
    end method.
    
    method public ITablePermissionSet GetTablePermissions( ):
        return cast(ContextFactory:TablePermissionContext:GetCollection(),ITablePermissionSet).
    end method.
    
    method public ITablePermissionSet GetTablePermissions(filter as char):
        return cast(ContextFactory:TablePermissionContext:GetCollection(filter),ITablePermissionSet).
    end method.
    
    method public ITenant GetTenantByExternalId(extId as char):
        return cast(ContextFactory:TenantContext:GetTenantByExternalId(extId),ITenant). 
    end method.
 
    method public ITenant GetTenant(tenantId as int):
        return cast(ContextFactory:TenantContext:GetEntity(tenantId),ITenant). 
    end method.
    
    method public ITenant GetTenant(tenantName as char):
        return cast(ContextFactory:TenantContext:GetEntity(tenantName),ITenant). 
    end method.
    
    method public ITenant GetTenant(req as IRequestInfo):
        return cast(ContextFactory:TenantContext:GetEntity(req),ITenant). 
    end method.
    
    method public ITenantSet GetTenants(filter as char):
        return cast(ContextFactory:TenantContext:GetCollection(filter),ITenantSet).
    end method.
    
    method public ITenantSet GetTenants(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:TenantContext:GetCollection(pRequestInfo),ITenantSet).
    end method.
        
    method public ITenantSet GetTenants( ):
        return cast(ContextFactory:TenantContext:GetCollection(),ITenantSet).
    end method.
    
    method public IUser GetUser(usrID as char):
        return cast(ContextFactory:UserContext:GetEntity(usrID),IUser). 
    end method.
    
    method public IUserTablePermissionSet GetPermissions(pccollections as char):
        return cast(ContextFactory:PermissionContext:GetCollection(pcCollections),IUserTablePermissionSet).
    end method.
    
    method public IUserPermission GetUserPermission(usrID as char):
        return cast(ContextFactory:UserPermissionContext:GetEntity(usrID),IUserPermission). 
    end method.
    
    method public IUserPermissionSet GetUserPermissions():
        return cast(ContextFactory:UserPermissionContext:GetCollection(),IUserPermissionSet).
    end method.
    
    method public IUserPermissionSet GetUserPermissions(filter as char):
        return cast(ContextFactory:UserPermissionContext:GetCollection(filter),IUserPermissionSet).
    end method.
    
    /* todo - use UserContext somehow  */
    method private void ValidUserId(id as char, output pdomain as char,output puser as char): 
        if num-entries(id,"@") > 1 then 
            pdomain = entry(2,id,"@").
            
        puser   = entry(1,id,"@").
             
    end method.
    
    method public IUserSet GetUsers():
        return cast(ContextFactory:UserContext:GetCollection(),IUserSet).
    end method.
    
    method public IUserSet GetUsers(pcfilter as char):
        return cast(ContextFactory:UserContext:GetCollection(pcfilter),IUserSet).
    end method.   
    
    method public IUserSet GetUsers(pReq as IRequestInfo):
        return cast(ContextFactory:UserContext:GetCollection(pReq),IUserSet).
    end method.  
    
    method public  IArea NewArea(pname as char):
        return cast(NewEntity("Area",pname),IArea). 
    end method.
    
    method public  IAreaSet NewAreas():
        return cast(NewCollection("Area"),IAreaSet). 
    end method.
    
    method public IExtent NewExtent():
        return new Extent().
        /*  To use context the ExtentContext Copy need to handle defaulting the number  
            to the next in the list 
            return cast(ContextFactory:GetLocalContext("Extent"):CreateRootEntity(),IExtent).*/
    end method.

    method public ITenantGroupMember NewTenantGroupMember():
        return new TenantGroupMember().
        /*  this does work but we do not need context before added to service or collection   
            return cast(ContextFactory:GetLocalContext("Extent"):CreateRootEntity(),IExtent).*/
    end method.

    
    method public IDomain NewDomain(pname as char):
        return cast(NewEntity("Domain",pname),IDomain). 
    end method.
    
    method public  IDomainSet NewDomains():
        return cast(NewCollection("Domain"),IDomainSet). 
    end method.
    
    method public IAuthenticationSystem NewAuthenticationSystem(pname as char):
        return cast(NewEntity("AuthenticationSystem",pname),IAuthenticationSystem). 
    end method.
    
    method public IAuthenticationSystemSet NewAuthenticationSystems():
        return cast(NewCollection("AuthenticationSystem"),IAuthenticationSystemSet). 
    end method.
    
    method public ITenant NewTenant(pname as char):
        return cast(NewEntity("Tenant",pname),ITenant). 
    end method.
    
    method public ITenantSet NewTenants():
        return cast(NewCollection("Tenant"),ITenantSet). 
    end method.
    
    method public ITenantGroup NewTenantGroup(pname as char):
        return cast(NewEntity("TenantGroup",pname),ITenantGroup). 
    end method.
    
    method public ITenantGroupSet NewTenantGroups():
        return cast(NewCollection("TenantGroup"),ITenantGroupSet). 
    end method.
    
    method public ISequence NewSequence(pname as char):
        return cast(NewEntity("Sequence",pname),ISequence). 
    end method.
    
    method public ISequenceSet NewSequences():
        return cast(NewCollection("Sequence"),ISequenceSet). 
    end method.
    
    method public IUser NewUser(pname as char):
        return cast(NewEntity("User",pname),IUser). 
    end method.
    
    method public IUserSet NewUsers():
        return cast(NewCollection("User"),IUserSet). 
    end method.
    
    method protected IDataAdminElement NewEntity(pcType as char,pname as char):
        /* NOTE - must define context variable here or else the 
                  context gets garbage collected when NewEntity ends 
                  before the entity is returned */          
        define variable cntxt as IDataAdminContext no-undo.
        cntxt = ContextFactory:GetLocalContext(pcType).
             
        return  cntxt:CreateRootEntity(pname). 
    
    end method.
    
    method protected IDataAdminCollection NewCollection(pcType as char):
        /* NOTE - must define context variable here or else the 
                  context gets garbage collected when NewEntity ends 
                  before the entity is returned */          
        define variable cntxt as IDataAdminContext no-undo.
        cntxt = ContextFactory:GetLocalContext(pcType).
        return  cntxt:NewCollection(). 
    end method.
    
    method public logical UpdateArea(area as IArea):
        return UpdateElement(area:name,area,ContextFactory:AreaContext).
    end method.
    
    method public logical UpdateAreas(areas as IAreaSet):
        return UpdateCollection(areas,ContextFactory:AreaContext).
    end method.
   
    /* base update method (not used by all) */
    method protected logical DeleteElement(pkey as char,inst as IDataAdminElement,cntxt as IDataAdminContext):
        define variable saverequest as ISaveRequest no-undo.
        define variable requestinfo as IRequestinfo no-undo.
        define variable rowinfo as IRow no-undo.
        define variable lok as logical no-undo.
        AssertUpdate(inst,cntxt).
        requestinfo = inst:Requestinfo.
        rowinfo = GetRowInfo(inst,cntxt).
        /** @todo use keyvalues always - 
            added late must check if there are Delete(char) overrides before removal.
            of single key
        */ 
        if num-entries(rowinfo:KeyFields) = 1 then
            lok = cntxt:Delete(rowinfo:KeyValues[1]).
        else
            lok = cntxt:Delete(rowinfo:KeyValues). 
        if lok then
        do:
            saverequest = cast(cntxt,IDataAdminModel):GetDeleteRowRequest(rowinfo,requestinfo).
            if not valid-object(saverequest) then 
                return false.
            saverequest = SaveData(saverequest).
            cntxt:MergeChanges(saverequest). 
            return true.
        end.
        return false.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
    end method.    
    
/*    /* base update method (not used by all) */                                                                */
/*    method protected logical UpdateElement(pkey as char,inst as IDataAdminElement,cntxt as IDataAdminContext):*/
/*        define variable saverequest as ISaveRequest no-undo.                                                  */
/*        AssertUpdate(inst,cntxt).                                                                             */
/*                                                                                                              */
/*        return true.                                                                                          */
/*        catch e as Progress.Lang.Error:                                                                       */
/*            ErrorHandler(e).                                                                                  */
/*            return false.                                                                                     */
/*        end catch.                                                                                            */
/*    end method.                                                                                               */
    
    /* base update method (not used by all) */
    method protected logical UpdateElement(pkey as char,inst as IDataAdminElement,cntxt as IDataAdminContext):
        define variable req as IRequestInfo no-undo.
        define variable response as ISaveRequest no-undo.
        AssertUpdate(inst,cntxt).
        req = inst:RequestInfo.
        response = cast(cntxt,IDataAdminModel):GetSaveRowRequest(pKey,req).
        if not valid-object(response) then 
            return false.
        response = SaveData(response).
        cntxt:MergeChanges(response).
        return true.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
        
    end method.    
    
     /* base update method (not used by all) */
    method protected logical UpdateElement(inst as IDataAdminElement,cntxt as IDataAdminContext):
        define variable req as IRequestInfo no-undo.
        define variable rowinfo as IRow no-undo.
        define variable response as ISaveRequest no-undo.
        
        define variable i          as integer no-undo.
        define variable cfield as character no-undo.
        AssertUpdate(inst,cntxt).
        req = inst:RequestInfo.
        rowinfo = GetRowInfo(inst,cntxt).
        response = cast(cntxt,IDataAdminModel):GetSaveRowRequest(rowinfo,req).
        if not valid-object(response) then 
            return false.
        response = SaveData(response).
        cntxt:MergeChanges(response).
        return true.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
        
    end method.    
       
      
    /* base update method  */
    method protected logical UpdateCollection(inst as IDataAdminCollection,cntxt as IDataAdminContext):
        define variable response as ISaveRequest no-undo.
        AssertUpdate(inst,cntxt).
        return UpdateContext(cntxt,inst:SourceId).
    end method.    
    
    /* base update method  */
    method protected logical UpdateContext(cntxt as IDataAdminContext,pSourceId as char):
        define variable response as ISaveRequest no-undo.
        response = cast(cntxt,IDataAdminModel):GetSaveRequest(pSourceId).
        response = SaveData(response).
        if not valid-object(response) then 
            return false.
        cntxt:MergeChanges(response).
        return true.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
    end method.    
    
    /* base update method (not used by all) */
    method protected logical UpdateContext(cntxt as IDataAdminContext):
        define variable saverequest as ISaveRequest no-undo.
        saverequest = cntxt:GetSaveRequest().
        saverequest = SaveData(saverequest).
        cntxt:MergeChanges(saverequest). 
        /* short version - debug unfriendly...
          cntxt:MergeChanges(SaveData(cntxt:GetSaveRequest())).*/
        return true.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
    end method.    
     
    method public logical UpdateDataSecurity(pinst as IDataSecurity ):
        return UpdateElement(pinst:name,pinst,ContextFactory:DataSecurityContext).
    end method.
       
    method public logical UpdateDomain(domain as IDomain):
        return UpdateElement(domain:name,domain,ContextFactory:DomainContext).
    end method.
    
    method public logical UpdateDomains(domains as IDomainSet):
        return UpdateCollection(domains,ContextFactory:DomainContext).
    end method.
    
    method public logical UpdateAuthenticationSystem(authenticationsystem as IAuthenticationSystem):
        return UpdateElement(authenticationsystem:name,authenticationsystem,ContextFactory:AuthenticationSystemContext).
    end method.
    
    method public logical UpdateAuthenticationSystems(authenticationsystems as IAuthenticationSystemSet):
        return UpdateCollection(authenticationsystems,ContextFactory:AuthenticationSystemContext).
    end method.
    
    method public logical UpdateSequence(seq as ISequence):
        return UpdateElement(seq,ContextFactory:SequenceContext).
    end method.
    
    method public logical UpdateSequences(sequences as ISequenceSet):
        return UpdateCollection(sequences,ContextFactory:SequenceContext).
    end method.
    
    method public logical UpdateTable(tableimpl as ITable):
        return UpdateElement(tableimpl:name,tableimpl,ContextFactory:TableContext).        
    end method.
    
    method public logical UpdateAdministrator(admin as IAdministrator):
        return UpdateElement("",admin,ContextFactory:AdministratorContext).        
    end method.
   
    method public logical UpdateSecurityOptions(secopt as ISecurityOptions):
        return UpdateElement("",secopt,ContextFactory:SecurityOptionsContext).        
    end method.
   
    method public logical UpdateTables(Tables as ITableSet):
        define variable response as ISaveRequest no-undo.
        
        response = SaveData(ContextFactory:TableContext:GetSaveRequest()).
        ContextFactory:TableContext:MergeChanges(response).        
         /* partitions may have been imported with table multitenant changes, but 
            does not exist until after the transaction,  save partition changes now  
            */
        do on error  undo, throw:
            
            if Tables:ForceAllocation > "" then 
                ContextFactory:TableContext:AllocateNewPartitions(Tables:ForceAllocation).
                
            if ContextFactory:TableContext:HasPartitionChanges() then
            do:
                
                response = SaveData(ContextFactory:TableContext:GetPartitionSaveRequest()).
                ContextFactory:TableContext:MergeChanges(response).
            end.
            catch e2 as Progress.Lang.AppError:
                e2:AddMessage("Note that all Partition changes were undone while Table changes were successfully completed",?).
                undo, throw e2.
            end. 
        end.
        
        return true.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
    end method.
    
    method public logical UpdateTablePermission(tableperm as ITablePermission):
        return UpdateElement(tableperm:name,tableperm,ContextFactory:TablePermissionContext).
    end method.
    
    method public logical UpdateTablePermissions(tableperms as ITablePermissionSet)  .  
        return UpdateCollection(tableperms,ContextFactory:TablePermissionContext).
    end method.
    
    method public logical UpdateTenantGroup(tenantGroup as ITenantGroup):
        return UpdateElement(tenantGroup:name,tenantGroup,ContextFactory:TenantGroupContext).
    end method.
    
    method public logical UpdateTenantGroups(tenantGroups as ITenantGroupSet):
        return UpdateCollection(tenantGroups,ContextFactory:TenantGroupContext).
    end method.  
    
    method public logical UpdateTenant(ptnt as ITenant):
         return UpdateElement(ptnt:name,ptnt,ContextFactory:TenantContext).
    end method.
    
    method public logical UpdateTenants(tenants as ITenantSet):
        return UpdateCollection(tenants,ContextFactory:TenantContext).
    end method.
     
    method public logical UpdateSchemaChanges(pschema as ISchema):
        define variable msg as LoadDefinitions no-undo.
        AssertUpdate(pSchema,CurrentSchemaChanges).
        
        CurrentSchemaChanges:Find(pschema:Name). 
        msg = cast(pschema:LoadOptions,LoadDefinitions).
        
        if pschema:LoadOptions:FileName > "" then
        do:    
            this-object:SaveData(msg).
        end.           
        pSchema:Attach(ContextFactory:SchemaContext). 
        return true.
    end method.
    
    method public logical UpdateSchema(pschema as ISchema):
        return UpdateElement(pschema:name,pschema,ContextFactory:SchemaContext).
    end method.
    
    /*   
    method public logical UpdateSchema(pschema as ISchema):
        AssertUpdate(pSchema,ContextFactory:SchemaContext). 
        ContextFactory:SchemaContext:Find(pschema:Name). 
        
        UpdatePartitions(). 
        
        return true.
        catch e as Progress.Lang.Error:
            ErrorHandler(e).          
            return false.
        end catch.
        
    end method.
    */
    /*todo - pass iPartitioncollection */
    method private logical UpdatePartitions( ):
        do on error undo, throw:
            return UpdateContext(ContextFactory:PartitionContext). 
            catch e as Progress.Lang.Error:
                ErrorHandler(e).          
                return false.
            end catch.
        end.
        return true.      
    end method.
   
/*    method public logical AttachPartitions(partitions as IPartitionMap):
        do on error undo, throw:
            partitions:Attach(ContextFactory:PartitionContext).
/*            SaveData(PartitionContext).*/
            catch e as Progress.Lang.Error:
                ErrorHandler(e).          
                return false.
            end catch.
        end.
        return true.
    end method.
  */ 
    method public logical UpdateUser(usr as IUser):
        return UpdateElement(usr:id,usr,ContextFactory:UserContext).
    end method.
    
    method public logical UpdateUsers(users as IUserSet):
         return UpdateCollection(users,ContextFactory:UserContext).
    end method.
    
    method public void ExecuteUtility(putility as IDataAdminUtility):
        define variable msg as IUtilityRequest  no-undo.
        define variable response as IUtilityResponse no-undo.
       
        msg = putility:GetRequest().
        
        msg:Url = URL.
        if valid-object(TransactionLogger) then
            TransactionLogger:Log("Execute " + msg:EntityName + " start").
        response = ServiceAdapter:ExecuteUtility(msg).
        if valid-object(TransactionLogger) then
            TransactionLogger:Log("Execute " + msg:EntityName + " complete").
        if valid-object(response) then    
            response:Service = this-object.   
        putility:SetResponse(response). 
    end method.
      
    method protected void ErrorHandler(e as Error):    
        if not ThrowDataErrors and type-of(e,DataError) then
        do: 
            if not valid-object(Error) then
                Error = new OperationError("Operation error in Service " +  Name).
            Error:AddError(e).        
        end.
        else 
        do:    
            undo, throw e.
        end.    
    end method.   
    
    method protected void AssertUpdate(entity as IDataAdminElement,context as IDataAdminContext):
        if not valid-object(entity) then 
            undo, throw new UnknownValueError("Update" + context:name,context:name).    
        if entity:ContextId = "" or not valid-object(entity:Service) then
            undo, throw new IllegalArgumentError("The " + context:name 
            + " passed to Update" + context:name +  " is new and and must be created before it can be updated.").     
        if context:Id <> entity:ContextId then
            undo, throw new IllegalArgumentError("The " + context:name 
            + " passed to Update" + context:name +  " belongs in a different service.").
    end.
    
    method protected void AssertUpdate(coll as IDataAdminCollection,serviceContext as IDataAdminContext):
        define variable cname as character no-undo.
        cname = serviceContext:name + "Set".
        if not valid-object(coll) then 
            undo, throw new UnknownValueError("Update" + serviceContext:name + "s",cname).  
        if coll:ContextId = "" then
            undo, throw new IllegalArgumentError("The " + cname + " is not created in the service").     
        if serviceContext:Id <> coll:ContextId then
            undo, throw new IllegalArgumentError("The " + cname + " belongs in a different service").
        
    end.    
        
    method protected void AssertCreate(entity as IDataAdminElement,context as IDataAdminContext):
         if not valid-object(entity) then 
            undo, throw new UnknownValueError("Create" + context:name,context:name).  
         if entity:Attached then 
            undo, throw new IllegalArgumentError("The " + context:name + " passed to Create" + context:name + " already belongs in a collection or service.").           
         if context:Id = entity:ContextId then
            undo, throw new IllegalArgumentError("The " + context:name + " already exists in this service").        
/*        if entity:ContextId <> "" and valid-object(entity:Service) then                                                 */
/*            undo, throw new IllegalArgumentError("The " + context:name + " already belongs in a collection or service").*/
    end method.
    
    method protected void AssertCreate(coll as IDataAdminCollection,serviceContext as IDataAdminContext):
        define variable cname as character no-undo.
        cname = serviceContext:name + "Set".
        if not valid-object(coll) then 
            undo, throw new UnknownValueError("Create" + serviceContext:name + "s",cname).  
        if serviceContext:Id = coll:ContextId then
            undo, throw new IllegalArgumentError("The " + cname + " already exists in this service").
        if valid-object(coll:Service) then
        do:
            if coll:HasChanges then 
                undo, throw new IllegalArgumentError("The " + cname + " has uncommitted changes for another service").     
        end.
    end method.
    
    method protected ISaveRequest SaveData(msg as ISaveRequest):
        msg:Url = Url.
        if valid-object(TransactionLogger) then
            TransactionLogger:Log("Save " + msg:serializename + " start").
        msg = ServiceAdapter:SaveData(msg).    
        if valid-object(TransactionLogger) then
            TransactionLogger:Log("Save " + msg:serializename + " complete").
/*        RequestCompleted:Publish(msg:SerializeName,msg:ContextId).*/
        return msg.
    end method.
    
    method protected IRow GetRowInfo(inst as IDataAdminElement,cntxt as IDataAdminContext):
        define variable cKeyValues as character extent no-undo .
        cKeyValues = GetPropertyValues(inst,cntxt:KeyFields).
        return new RowImpl(cntxt:SerializeName,?,cntxt:KeyFields,cKeyValues).
    end method.
        
    method protected char extent GetPropertyValues(inst as IDataAdminElement,pcKeyFields as char):
        define variable cKeyValues as character extent no-undo.  
        define variable i          as integer no-undo.
        define variable cField     as character no-undo.
        define variable obj        as Object no-undo.
        extent(cKeyValues) = num-entries(pcKeyFields).
        do i = 1 to num-entries(pcKeyFields):
            cfield = entry(i,pcKeyFields).
            if cfield = "schemaname" then
            do: 
                cfield = "schema".
                obj  = inst:GetClass():GetPropertyValue (inst,cfield).
                cKeyValues[i] = obj:GetClass():GetPropertyValue (obj,"name").
            end.
            else
                cKeyValues[i] = inst:GetClass():GetPropertyValue (inst,cfield). 
        end.
        return cKeyValues.
    end method.     
    
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	
	destructor public DataAdminService ( ):
         /* service adapter holds dataservice whihc holds datacessfactory */
         delete object ServiceAdapter no-error.
         /* contextfactory hold all context objects */
         delete object ContextFactory no-error.
         
         ServiceDeleted:Publish().
	end destructor.
    
end class.
