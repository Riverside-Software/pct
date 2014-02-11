 
 /*------------------------------------------------------------------------
    File        : ServiceContextFactory
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Sep 13 22:02:26 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.IDataAdminService  from propath.
using OpenEdge.DataAdmin.Binding.SchemaChanges from propath.
using OpenEdge.DataAdmin.Binding.AdministratorContext  from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext  from propath.
using OpenEdge.DataAdmin.Binding.PermissionContext  from propath.
using OpenEdge.DataAdmin.Binding.UserFieldPermissionContext  from propath.
using OpenEdge.DataAdmin.Binding.UserTablePermissionContext  from propath.
using OpenEdge.DataAdmin.Binding.FieldPermissionContext  from propath.
using OpenEdge.DataAdmin.Binding.TablePermissionContext  from propath.
using OpenEdge.DataAdmin.Binding.UserPermissionContext  from propath.
using OpenEdge.DataAdmin.Binding.DataSecurityContext  from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext  from propath.
using OpenEdge.DataAdmin.Binding.SecurityOptionsContext  from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter  from propath.
using OpenEdge.DataAdmin.Binding.Factory.AbstractContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Factory.LocalContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.NotFoundError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Factory.ServiceContextFactory inherits AbstractContextFactory implements IServiceContextFactory: 
     
     define public property AdministratorContext as AdministratorContext no-undo 
        get():
            if not valid-object(AdministratorContext) then 
            do:
                AdministratorContext = new AdministratorContext(this-object).       
            end.
            return AdministratorContext.   
        end. 
        set.
     
     
     define public property PermissionContext as PermissionContext no-undo 
        get():
            if not valid-object(PermissionContext) then 
            do:
                PermissionContext = new PermissionContext(this-object).                   
            end.
            return PermissionContext. 
        end. 
        set.
    
     define public property UserPermissionContext as UserPermissionContext no-undo 
        get():
            if not valid-object(UserPermissionContext) then 
            do:
                UserPermissionContext = new UserPermissionContext(this-object).       
            end.
            return UserPermissionContext.   
        end. 
        set.
     
     define public property FieldPermissionContext as FieldPermissionContext no-undo 
        get():
            if not valid-object(FieldPermissionContext) then 
            do:
                FieldPermissionContext = new FieldPermissionContext(this-object).       
            end.
            return FieldPermissionContext.   
        end. 
        set.
     
    define public property TablePermissionContext as TablePermissionContext no-undo 
        get():
            if not valid-object(TablePermissionContext) then 
            do:
                TablePermissionContext = new TablePermissionContext(this-object).       
            end.
            return TablePermissionContext.   
        end. 
        set.
      
      
    define public property DataSecurityContext as DataSecurityContext no-undo 
        get():
            if not valid-object(DataSecurityContext) then 
            do:
                DataSecurityContext = new DataSecurityContext(this-object).       
            end.
            return DataSecurityContext.   
        end. 
        set.
    
       define public override property PartitionContext as PartitionContext no-undo 
           get(): 

            if not valid-object(PartitionContext) then
            do:
                PartitionContext = new PartitionContext(this-object).
            end.
            return PartitionContext.
        end.
        set.
        
        define public property SecurityOptionsContext as SecurityOptionsContext no-undo 
        get():
            if not valid-object(SecurityOptionsContext) then 
            do:
                SecurityOptionsContext = new SecurityOptionsContext(this-object).                   
            end.
            return SecurityOptionsContext. 
        end. 
        set.
        
     /* override to be false... */
     define public override property IsLocal as logical  no-undo 
         get .
    
    constructor public ServiceContextFactory ( pservice as IDataAdminService, padapter as ServiceAdapter ):
        super (pservice, padapter).
    
    end constructor.
    
    method public IDataAdminContext GetContextBySerializeName(pname as char):
        define variable cname as character no-undo.
        if pname matches "indexes" then
            cname = "index".
        else if pname matches "*s" then
            cName = substr(pname,1,length(pname) - 1).
        else 
            undo, throw new NotFoundError("x").    
        return GetContext(cName).
        /* catch notfound from lower evel to return passed name and term that corresponds to api */
        catch e1 as NotFoundError :
            undo, throw new NotFoundError("Collection " + quoter(pname) + " was not found.").    
        end catch.
        catch e2 as Progress.Lang.Error :
        	undo, throw e2.	
        end catch.
    end method.
    
    method public IDataAdminContext GetLocalContext(pname as char):                
        define variable factory as IContextFactory no-undo.
        factory = new LocalContextFactory(this-object).
        return factory:GetContext(pname).
        /*
        case pname:
            when "Area" then
            do:
                
            end.
            when "Domain" then
            do:
            end.
            when "AuthenticationSystem" then
            do:
            end.
            when "Extent" then
            do:
            end.
            when "Field" then
            do:
            end.
            when "FieldPermission" then
            do:
            end.
            when "Index" then
            do:
            end.
            when "Partition" then
            do:
            end.
            when "TenantGroup" then
            do:
            end.
            when "TenantGroupMember" then
            do:
            end.
            when "Schema" then
            do:
            end.
            when "SchemaDefinition" then
            do:
            end.
            when "Sequence" then
            do:
            end.
            when "SequenceValue" then
            do:
            end.
            when "Table" then
            do:
            end.
            when "TablePermission" then
            do:
            end.
            when "Tenant" then
            do:
            end.
            when "User" then
            do:
            end.
                
        end.   
         */
    end method.
             
    method public SchemaChanges GetSchemaDefinitionContext(pcfile as char): 
        return new SchemaChanges(pcfile,this-object).       
    end method.
    
     method public UserTablePermissionContext GetUserTablePermissionContext():
        return new UserTablePermissionContext(this-object).
    end method.
    
    method public UserFieldPermissionContext GetUserFieldPermissionContext():
        return new UserFieldPermissionContext(this-object).
    end method.
    
    method protected override IDataAdminContext GetInternalContext(pname as char):
        case pname:
            when "FieldPermission" then
                return FieldPermissionContext.
            when "TablePermission" then
                return TablePermissionContext.
            when "UserFieldPermission" then
            do:
                return GetUserFieldPermissionContext().
            end.    
            when "UserTablePermission" then
            do: 
                return UserPermissionContext:GetChild("userTablePermissions").
            end.
            when "UserPermission" then
                return UserPermissionContext.
            
            otherwise return super:GetInternalcontext(pname).      
        end.
     end method.    
    
    
            
end class.