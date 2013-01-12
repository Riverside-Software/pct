 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
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
    Created     : 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.
using OpenEdge.DataAdmin.TenantGroupMember from propath.
 
using OpenEdge.DataAdmin.Support.TenantTenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.Support.TenantGroupTenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.IContextTree from propath. 
using OpenEdge.DataAdmin.Binding.ContextTree from propath. 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IMultiTenantScope from propath. 
 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.DataContextError from propath.

using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.

class OpenEdge.DataAdmin.Binding.TenantGroupMemberContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/tenantgroupmember.i} 
    define private dataset dsTenant serialize-name "root" for ttTenantGroupMember.
    define buffer bTenantGroupMember for ttTenantGroupMember.
    define temp-table copytable reference-only like ttTenantGroupMember.
      
    define temp-table ttPartitionIdRequest no-undo
        field partitionid as int
        field tenantname as char
        index partname as  unique tenantname
        index partidx as primary unique partitionid.
        
    define variable mCreate as logical no-undo.
      
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then 
                DatasetHandle  = dataset dsTenant:handle.
            return DatasetHandle.
        end get.
        private set.
        
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttTenantGroupMember:handle.
    	end get.
   
    define public override property KeyFields as character  no-undo  
        get():
            return "TenantGroupName,TenantName". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bTenantGroupMember for ttTenantGroupMember.
            if Count = ? then
            do:
                Count = 0.
                for each bTenantGroupMember:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public TenantGroupMemberContext ():
     
         super ("TenantGroupMember").                                    
 
    end constructor.
    
    constructor public TenantGroupMemberContext (pscope as IMultiTenantScope):
     
         super ("TenantGroupMember",pScope).                                    
 
    end constructor.
 	
	method public override void CreateRow(entity as IDataAdminElement):
	    /* the default syserror has all info */
	    CreateRow(cast(entity,ITenantGroupMember)).    
	end method.
	
    method public override character GetJoinFields(parentid as char):
        case parentid: 
            when "tenants" then          
                return "Name,TenantName".
            when "tenantGroups" then          
                return "Name,TenantGroupName".
        end.
    end.
    
    method override public void WriteTo( input writer as OpenEdge.DataAdmin.Binding.IContextWriter ):
        super:WriteTo(input writer).
    end method.
 
    method public override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false. 
    end method. 
   
    method public void ReplaceTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        ReplaceTable(table-handle hTbl by-reference). 
        Loaded = false. 
    end method. 
   
    method private void ReplaceTable(input table copytable):
        define variable dataerror as DataContextError no-undo.      
       
        temp-table ttTenantGroupMember:tracking-changes = true.
        for each bTenantGroupMember on error undo, throw: 
            find copytable where copytable.Tenantname = bTenantGroupMember.Tenantname  
                            and  copytable.TenantGroupname  = bTenantGroupMember.TenantGroupname no-error.
            if not avail copytable then
            do:              
               delete bTenantGroupMember.
               Count = Count - 1. 
            end.
        end.     
        for each copytable on error undo, throw:  
            find bTenantGroupMember where bTenantGroupMember.Tenantname = copytable.Tenantname 
                                         and bTenantGroupMember.TenantGroupname = copytable.TenantGroupname  no-error.
            /* force error message 
               - DataError will transform progress message 
                 to "entity" message */
            if not avail bTenantGroupMember then
            do:
                create bTenantGroupMember.
                assign
                    bTenantGroupMember.Tenantname = copytable.Tenantname 
                    bTenantGroupMember.TenantGroupname = copytable.TenantGroupname.
                Count = Count + 1.
                OnRowCreated().
            end.   
             
            catch e as Progress.Lang.Error :
                delete bTenantGroupMember.
                if not valid-object(DataError) then 
                    dataError = new DataContextError("TenantGroup",e).
                else 
                   dataError:AddMessage(e).                     
            end catch. 
        end.    
        temp-table ttTenantGroupMember:tracking-changes = false.                     
    end method.  
    
	method private void CopyTable(input table copytable):
	    define variable dataerror as DataContextError no-undo.      
        for each copytable on error undo, throw:  
/*            if valid-object(Service) and valid-object(copytable.Entity) then*/
/*            do:                                                             */
/*                ValidateTenant(cast(copytable.Entity,ITenant)).             */
/*            end.                                                            */
            do on error undo, throw:
                find bTenantGroupMember where bTenantGroupMember.Tenantname = copytable.Tenantname 
                                             and bTenantGroupMember.TenantGroupname = copytable.TenantGroupname  no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail bTenantGroupMember then
                do:
                    create bTenantGroupMember.
                    assign
                    bTenantGroupMember.Tenantname = copytable.Tenantname 
                    bTenantGroupMember.TenantGroupname = copytable.TenantGroupname.
               
                end.    
                catch e as Progress.Lang.Error :
                    delete bTenantGroupMember.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("PartititonGroup",e).
                    else 
                       dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        temp-table ttTenantGroupMember:tracking-changes = true.
        for each copytable:
            create ttTenantGroupMember.    
            Count = Count + 1.
            buffer-copy copytable to ttTenantGroupMember.    
            OnRowCreated().
        end.
        temp-table ttTenantGroupMember:tracking-changes = false.
            
    end method.  
	
	method private character GetCreateError(tenantGroupDetail as ITenantGroupMember):
        return this-object:GetCreateError(cast(tenantGroupDetail,IDataAdminElement),tenantGroupDetail:Tenant:Name). 
    end method. 
	
	method public void CreateRow(groupName as character, tenantName as character):
	    if groupName = "" or groupname = ? then 
              undo, throw new IllegalArgumentError("TenantGroup not defined ").  
        if tenantName = "" or tenantName = ? then 
                undo, throw new IllegalArgumentError("Tenant not defined ").  
         CreateRow(groupName,tenantName,?).
    end method.
         
    method private void CreateRow(groupName as character, tenantName as character,tenantGroupDetail as ITenantGroupMember):
        define variable lTrack as logical no-undo.
        lTrack = temp-table ttTenantGroupMember:tracking-changes .
        temp-table ttTenantGroupMember:tracking-changes = true.
        
        Count = Count + 1.
         
        create ttTenantGroupMember.
        assign ttTenantGroupMember.TenantGroupName = groupname
               ttTenantGroupMember.TenantName = tenantName      
               ttTenantGroupMember.Entity = tenantGroupDetail .
        
        OnRowCreated().      
        catch e as Error:  
            delete ttTenantGroupMember.
            Count = Count - 1.
            if type-of(e,IllegalArgumentError) then
                undo, throw e.
            undo, throw new DataContextError("TenantGroup and Tenant",e).  
        end catch.  
        finally:
            temp-table ttTenantGroupMember:tracking-changes = lTrack.             
        end finally.
                  
    end method.
	
	method public void CreateRow(tenantGroupDetail as ITenantGroupMember):
	     
	    
/*	    if valid-object(Service) then*/
/*	       ValidateTenant(tenant).   */
/*	                                  */
         if not valid-object(tenantGroupDetail:TenantGroup) then 
            undo, throw new IllegalArgumentError(
            GetCreateError(tenantGroupDetail) 
            + "~nTenantGroup not defined ").  
              
         if not valid-object(tenantGroupDetail:Tenant) then
            undo, throw new IllegalArgumentError(
            GetCreateError(tenantGroupDetail)  
            + "~nTenant not defined ").  
             
        CreateRow(tenantGroupDetail:TenantGroup:Name,tenantGroupDetail:Tenant:Name,tenantGroupDetail).
             
    end method.
    
    method public override logical CanFind(name as character):
        undo, throw new UnsupportedOperationError("CanFind with character key. Use CanFind(groupname as char,tenantname as char).").           
    end.    
     
    method public logical CanFind(groupName as character, tenantName as character):
        return can-find(ttTenantGroupMember where ttTenantGroupMember.TenantGroupName = groupname
                                                 and ttTenantGroupMember.TenantName = tenantName).       
    end.    
    
    method public override logical Find(name as character):
        undo, throw new UnsupportedOperationError("Find with character key. Use Find(groupname as char,tenantname as char).").           
    end.    
    
    method public logical Find(groupName as character, tenantName as character):
        find ttTenantGroupMember where ttTenantGroupMember.TenantGroupName = groupname
                                      and ttTenantGroupMember.TenantName = tenantName no-error.       
        
        return avail ttTenantGroupMember.  
    end.    
    
    method public logical Delete(groupName as character, tenantName as character):
        define variable lTrack as logical no-undo.
        if this-object:Find(groupName,tenantName) then  
        do:
            return Remove().
        end. 
/*        else                                                                                         */
/*            undo, throw new DataContextError('Delete failed. Cannot find Partition Group Detail for '*/
/*                                            + 'Tenant ' + quoter(detail:TenantGroup:Name)         */
/*                                            + 'Partition Group ' + quoter(detail:Tenant:Name) ).     */
/*                                                                                                     */
        
        return false.
    end.    
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):        
        undo, throw new UnsupportedOperationError("CreateCollection with context only (no key).").           
     end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new TenantGroupMember (cntxt).
    end method.
   
    method override protected IDataAdminCollection CreateCollection(pparent as char,cntxt as FilteredContext):     
        case pparent:
            when "tenants" then
            do:
                return new TenantTenantGroupMemberSet(cntxt).  
            end.                 
            when "tenantGroups" then
            do:
                return new TenantGroupTenantGroupMemberSet(cntxt). 
            end.                 
            otherwise
                return super:CreateCollection(pparent,cntxt).        
        end case.    
        
    end method.
    
    method protected override handle CreateSaveDataset():
        return CreateDataset("tenantGroupMembers").       
    end method.
    
    method protected override char FindExpression(i as int):
        undo, throw new UnsupportedOperationError("FindExpression with integer key").  
    end method.
    
    method protected override char FindExpression(c as char):
        undo, throw new UnsupportedOperationError("FindExpression with character key").  
    end method.
 
 
end class.
