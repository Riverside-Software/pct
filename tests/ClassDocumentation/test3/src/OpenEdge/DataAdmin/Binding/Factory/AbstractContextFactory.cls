 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
     Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Aug 18 14:19:53 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminService  from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError  from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError  from propath.
using OpenEdge.DataAdmin.Error.NotFoundError  from propath.

using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Factory.AbstractContextFactory abstract implements IContextFactory: 
    define public property ServiceAdapter as ServiceAdapter no-undo get. private set. 
    define public property Service as IDataAdminService no-undo get. private set. 
    define public abstract property IsLocal as logical no-undo get.    
          
    define public property ExtentContext as ExtentContext no-undo 
        get():
            if not valid-object(ExtentContext) then 
            do:
                ExtentContext = new ExtentContext(this-object).       
            end.
            return ExtentContext.   
        end. 
        set.
    
    define public property AreaContext as AreaContext no-undo 
        get():
            if not valid-object(AreaContext) then 
            do:
                AreaContext = new AreaContext(this-object).       
            end.
            return AreaContext.   
        end. 
        set.
        
    define public property SequenceValueContext as SequenceValueContext no-undo 
        get():
            if not valid-object(SequenceValueContext) then 
            do:
                SequenceValueContext = new SequenceValueContext("PUB",this-object).       
            end.
            return SequenceValueContext.   
        end. 
        set.
     
    define public property UserContext as UserContext no-undo 
        get():
            if not valid-object(UserContext) then 
            do:
                UserContext = new UserContext(this-object).       
            end.
            return UserContext.   
        end. 
        set.
           
    define public property DomainContext as DomainContext no-undo 
        get():
            if not valid-object(DomainContext) then 
            do:
                DomainContext = new DomainContext(this-object).       
            end.
            return DomainContext.   
        end. 
        set.
    
    define public property AuthenticationSystemContext as AuthenticationSystemContext no-undo 
        get():
            if not valid-object(AuthenticationSystemContext) then 
            do:
                AuthenticationSystemContext = new AuthenticationSystemContext(this-object).       
            end.
            return  AuthenticationSystemContext.   
        end. 
        set.
        
    define public property FieldContext as FieldContext no-undo 
        get():
            if not valid-object(FieldContext) then 
            do:
                FieldContext = new FieldContext(this-object).       
            end.
            return FieldContext.   
        end. 
        set.
            
    define public property IndexContext as IndexContext no-undo 
        get():
            if not valid-object(IndexContext) then 
            do:
                IndexContext = new IndexContext(this-object).       
            end.
            return IndexContext.   
        end. 
        set.   
    
     define public abstract property PartitionContext as PartitionContext no-undo 
        get. set. 
              
    define public property TableContext as TableContext no-undo 
        get():
            if not valid-object(TableContext) then 
            do:
                TableContext = new TableContext(this-object).       
            end.
            return TableContext.   
        end. 
        set.   
    
    define public property AllTableContext as AllTableContext no-undo 
        get():
            if not valid-object(AllTableContext) then 
            do:
                AllTableContext = new AllTableContext(this-object).       
            end.
            return AllTableContext.   
        end. 
        set.       
        
    define public property SequenceContext as SequenceContext no-undo 
        get():
            if not valid-object(SequenceContext) then 
            do:
                SequenceContext = new SequenceContext(this-object).       
            end.
            return SequenceContext.   
        end. 
        set.   
    
     define public property TenantGroupMemberContext as TenantGroupMemberContext no-undo 
        get():
            if not valid-object(TenantGroupMemberContext) then 
            do:
                TenantGroupMemberContext = new TenantGroupMemberContext(this-object).       
            end.
            return TenantGroupMemberContext.   
        end. 
        set.
     
    define public property TenantGroupContext as TenantGroupContext no-undo 
        get():
            if not valid-object(TenantGroupContext) then 
            do:
                TenantGroupContext = new TenantGroupContext(this-object).       
            end.
            return TenantGroupContext.   
        end. 
        set.
        
    define public property TenantContext as TenantContext no-undo 
        get():
            if not valid-object(TenantContext) then 
            do:
                TenantContext = new TenantContext(this-object).       
            end.
            return TenantContext.   
        end. 
        set.
  
    define public property SchemaContext as SchemaContext no-undo 
        get():
            if not valid-object(SchemaContext) then 
            do:
                SchemaContext = new SchemaContext(this-object) .       
            end.
            return SchemaContext.   
        end. 
        set.
    
   
  
   /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    constructor public AbstractContextFactory (pservice as IDataAdminService,padapter as ServiceAdapter):
        super ().
       
        Service = pservice.
        ServiceAdapter = padapter.
    end constructor.
            
    method public IDataAdminContext GetCreateContext(cntxtname as char):
        define variable createcontext as CreateContext no-undo.
        createcontext = new CreateContext(GetContext(cntxtname)).   
    end method.
    
    method public IDataAdminContext GetFilterContext(cntxtname as char,filter as char):
        define variable filteredcontext as FilteredContext no-undo.
        filteredcontext = new FilteredContext(GetContext(cntxtname),filter).     
    end method.
        
    method public IDataAdminContext GetContext(pname as char):
        case pname:
            when "UserFieldPermission" or when "UserTablePermission" then
            do:
                undo, throw new UnsupportedOperationError
                          ("Context for " + quoter(pname) + " ." 
                           + chr(10)
                           + "is not managed by the service. The UserPermission manages this internally.").
            end.    
            otherwise 
                return GetInternalContext(pname). 
            
        end.
        catch e1 as NotFoundError  :
            undo, throw new NotFoundError("Context " + quoter(pname) + " was not found.").    
        end catch.  
        catch e2 as Progress.Lang.Error :
        	undo, throw e2.	
        end catch.        
    end method.
       
    method protected IDataAdminContext GetInternalContext(pname as char):
        case pname:
            when "Area" then
                return AreaContext.
            when "Domain" then
                return DomainContext.
            when "AuthenticationSystem" then
                return AuthenticationSystemContext.
            when "Extent" then
                return ExtentContext.
            when "Field" then
                return FieldContext.
            when "Index" then
                return IndexContext.
            when "Partition" then
                return PartitionContext.
            when "TenantGroup" then
                return TenantGroupContext.
            when "TenantGroupMember" then
                return TenantGroupMemberContext.
            when "Schema" then
                return SchemaContext.
            when "SchemaDefinition" then
                return SchemaContext.
            when "Sequence" then
                return SequenceContext.
            when "SequenceValue" then
                return SequenceValueContext.
            when "Table" then
                return TableContext.
            when "AllTable" then
                return AllTableContext.
            when "Tenant" then
                return TenantContext.
            when "User" then
                return UserContext.
        end.
        undo, throw new NotFoundError("Internal context " + quoter(pname) + " does not exist.").    
    end method.    
    
   
end class.
