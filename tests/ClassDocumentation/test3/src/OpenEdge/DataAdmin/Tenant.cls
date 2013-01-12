/*************************************************************/
/* Copyright (c) 2010,2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    File        : Tenant
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Jun 12 21:20:19 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.Error from propath.
using Progress.Lang.Object from propath.

using OpenEdge.DataAdmin.DataAdminService from propath. 
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.IPartitionMap from propath.
using OpenEdge.DataAdmin.ITenantGroupSet from propath.
using OpenEdge.DataAdmin.ITenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.IDomainSet from propath.
using OpenEdge.DataAdmin.IUserSet from propath.
using OpenEdge.DataAdmin.ISequenceValueMap from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminExporter from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath. 
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Tenant from propath.

using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.

using OpenEdge.DataAdmin.Error.DataAdminError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.ForbiddenOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath. 
using OpenEdge.DataAdmin.Error.DataError from propath. 
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath. 
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath. 
using OpenEdge.DataAdmin.Error.CreateOnlyPropertyError from propath. 
using OpenEdge.DataAdmin.Error.ValidationError from propath. 
using OpenEdge.DataAdmin.Core.JSONWriter from propath.  
using OpenEdge.DataAdmin.Core.CodeWriter from propath.  

class OpenEdge.DataAdmin.Tenant inherits Entity implements ITenant:
    /* implements ITenant, IDataAdminElement, IDataAdminSerializable */  
    define private property ValidTypeList as char 
       init "Regular,Super"
       get.
          
    define private property ValidDefaultAllocationList as char 
       init "Immediate,Delayed,None"
       get.
         
    define private variable mChild as logical no-undo. 
    
    define public property Id as int init ? no-undo             
        get():
            if valid-handle(mBuffer) then
                return mBuffer::id.
            else
                return Id.    
        end.
    
    define public property Type as character no-undo           
       init "Regular"
       get():
           if valid-handle(mBuffer) then
               return mBuffer::Type.
           else do:
               return Type. 
           end.    
        end.
        set(pType as character):
            if valid-object(Service) then
            do:
                undo, throw new CreateOnlyPropertyError("Tenant",Name,"Type").
            end.     
            if pType = "Default" then 
                undo, throw new ValidationError("Tenant",Name,"Type","cannot be set to ~"Default~". There can only be one default Tenant").   
            
            if lookup(pType,ValidTypeList) = 0 then 
                undo, throw new InvalidPropertyValueError("Tenant",Name,"Type",pType,ValidTypeList).   
            if valid-handle(mBuffer) then
            do:
                Context:SetProperty(mBuffer:rowid,"Type",pType).
            end.
            Type = pType.
        end.    
    
    define public property ExternalID as char no-undo           
        get():
            if valid-handle(mBuffer) then
                return mBuffer::ExternalID.
            else
                return ExternalID. 
        end.
        set(pExternalID as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::ExternalID = pExternalID.
            end.
            else
                ExternalID = pExternalID.
        end.    
       
    define public property Description as char no-undo         
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Description.
            else
                return Description. 
        end.
        set(pDescription as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Description = pDescription.
            end.
            else
                Description = pDescription.
        end.    
    
    define public property DefaultAllocation as char no-undo                 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::DefaultAllocation.
            else
                return DefaultAllocation. 
        end.
        set(pDefaultAllocation as char):
            if Type = "Super" or Type = "Default" then
            do:
                undo, throw new ReadOnlyPropertyError("Tenant",Name,"Type",
                     "The property is not editable for super and default Tenants" 
                                                      ).
            end.     
            if lookup(pDefaultAllocation,ValidDefaultAllocationList) = 0 then 
                undo, throw new InvalidPropertyValueError("Tenant",Name,"DefaultAllocation",pDefaultAllocation,ValidDefaultAllocationList).   
         
                
            if valid-handle(mBuffer) then
            do:
                Context:SetProperty(mBuffer:rowid,"DefaultAllocation",pDefaultAllocation).
            end.
            DefaultAllocation = pDefaultAllocation.
        end.    
          
    define public property IsDataEnabled as logical no-undo  
        init true        
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsDataEnabled.
            else
                return IsDataEnabled. 
        end.
        set(pIsDataEnabled as logical):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsDataEnabled = pIsDataEnabled.
            end.
            else
                IsDataEnabled = pIsDataEnabled.
        end. 

    define public property IsAllocated as logical no-undo          
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsAllocated.
            else
                return IsAllocated. 
        end.
        protected set(pIsAllocated as logical):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsAllocated = pIsAllocated.
            end.
            else
                IsAllocated = pIsAllocated.
        end. 

    define public property DefaultDataArea as IArea no-undo   
        get():
            if not valid-object(DefaultDataArea) then
            do: 
                if valid-handle(mBuffer) and mBuffer::DefaultIndexAreaName > "" 
                and valid-object(Service) then
                   DefaultDataArea = Service:GetArea(mBuffer::DefaultDataAreaName).            
            end.
            return DefaultDataArea.
        end.
        set(pDefaultDataArea as IArea):
            if Type = "Super" or Type = "Default" then
            do:
                undo, throw new ReadOnlyPropertyError("Tenant",Name,"Type",
                     "The property is not editable for super and default Tenants" 
                                                        ).     
            end.
            if not valid-object(pDefaultDataArea) then 
            do:
                undo, throw new UnknownValueError("DefaultDataArea").          
            end.
            if valid-handle(mBuffer) then
                Context:SetProperty(mBuffer:rowid,"DefaultDataAreaName",pDefaultDataArea:Name).
            DefaultDataArea = pDefaultDataArea.
        end. 
    
    define public property DefaultIndexArea as IArea no-undo     
        get():
            if not valid-object(DefaultIndexArea) then
            do: 
                if valid-handle(mBuffer) and mBuffer::DefaultIndexAreaName > "" 
                and valid-object(Service) then
                    DefaultIndexArea = Service:GetArea(mBuffer::DefaultIndexAreaName).            
            end.
            return DefaultIndexArea. 
        end.
        set(pDefaultIndexArea as IArea):
            if Type = "Super" or Type = "Default" then
            do:
                undo, throw new ReadOnlyPropertyError("Tenant",Name,"DefaultIndexArea",
                     "The property is not editable for super and default Tenants" 
                                                      ).
            end.   
            if not valid-object(pDefaultIndexArea) then 
            do:
                undo, throw new UnknownValueError("DefaultIndexArea").          
            end.   
            if valid-handle(mBuffer) then
                Context:SetProperty(mBuffer:rowid,"DefaultIndexAreaName",pDefaultIndexArea:Name).
            DefaultIndexArea = pDefaultIndexArea.
        end. 
        
    define public property DefaultLobArea   as IArea no-undo    
        get():
            
            if not valid-object(DefaultLobArea) then
            do: 
                if valid-handle(mBuffer) and mBuffer::DefaultLobAreaName > "" 
                and valid-object(Service) then
                    DefaultLobArea = Service:GetArea(mBuffer::DefaultLobAreaName).            
            end.
            return DefaultLobArea. 
        end.
        set(pDefaultLobArea as IArea):
            if Type = "Super" or Type = "Default" then
            do:
                undo, throw new ReadOnlyPropertyError("Tenant",Name,"DefaultLobArea",
                     "The property is not editable for super and default Tenants" 
                                                      ).
            end.  
            if not valid-object(pDefaultLobArea) then 
            do:
               undo, throw new UnknownValueError("DefaultLobArea").          
            end.         
            if valid-handle(mBuffer) then
                Context:SetProperty(mBuffer:rowid,"DefaultLobAreaName",pDefaultLobArea:Name).
            DefaultLobArea = pDefaultLobArea.
        end. 
        
/*    define public property SequenceBlock as int no-undo*/
/*        get():                                         */
/*            return mBuffer::SequenceBlock.             */
/*        end.                                           */
/*        set.                                           */
        
    define public property Partitions as IPartitionMap no-undo  
        get():
            if not valid-object(Partitions) then
            do:
                if not valid-object(context:Service) and not valid-object(context:TargetService) then
                    undo, throw new UnsupportedOperationError("Partitions are not available in a Tenant that is not newed, created or retrieved by a service.").  
                Partitions = cast(GetChildCollection("partitions"),IPartitionMap).
/*                Partitions:Tenant = this-object.*/
       
           end.     
           return Partitions.
        end.
        private set.
    
    define public property SequenceValues as ISequenceValueMap no-undo      
        get():
            define variable err as Error no-undo.
            if not valid-object(SequenceValues) then
            do:
                SequenceValues = cast(GetChildCollection("sequenceValues"),ISequenceValueMap).
            end.
            return SequenceValues.
            catch e as DataAdminError :
                err =  e:InnerError.
                if valid-object(err) then 
                do:
                    if err:GetMessageNum(1) = 15956 then 
                         undo, throw new ForbiddenOperationError("SequenceValues for other tenants can only be accessed by a super-tenant.", e).
                end. 
                undo, throw e.   
            end catch.
        end.     
        private set.
     /* ROhit- change name to use ID instead */
     
    define public property TenantGroups as ITenantGroupSet no-undo                 
        get():
            if not valid-object(TenantGroups) then
            do:
                TenantGroups = cast(GetChildCollection("tenantGroups"),ITenantGroupSet).
                
            end.
            return TenantGroups.
        end.
        private set .
    
    define public property TenantGroupMembers as ITenantGroupMemberSet no-undo                 
        get():
            if not valid-object(TenantGroupMembers) then
            do:
                TenantGroupMembers = cast(GetChildCollection("tenantGroupMembers"),ITenantGroupMemberSet).
/*                TenantGroupMembers:Tenant = this-object.*/
            end.
            return TenantGroupMembers.
        end.
        private set .
    
      
    define public property Domains as IDomainSet no-undo  
        get():
            if not valid-object(Domains) then
            do:             
                Domains = cast(GetChildCollection("domains"),IDomainSet).
            end.         
            return Domains.     
        end.
        private set.
     
     define public property Users as IUserSet no-undo  
        get():
            if not valid-object(Users) then
            do:
                Users = cast(GetChildCollection("users"),IUserSet).
/*                Users:Tenant = this-object.*/
                /*
                if valid-object(Service) then 
                do:
                     Users = Service:GetUsers(serializename + ".id/" + string(id)).     
                     Users:Tenant = this-object. 
                end.
                */                        
            end.         
            return Users.     
        end.
        private set. 
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
        
    constructor public Tenant (cntxt as IDataAdminContext):
        super (cntxt). 
    end constructor.
   
    constructor public Tenant (cntxt as IDataAdminContext,preq as IRequestInfo):
        super (cntxt,pReq). 
    end constructor.
      
    constructor public Tenant (cname as character):
        super (cname).
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext(): 
        return new TenantContext().  
    end method.
    
    method public logical Allocate():
        IsAllocated = true.
        return Partitions:Allocate().
    end method.        
    
    method public void RemoveData():
    end method.   
        
    method public override void Export():
        Export("area.json").
    end method.          
    
    method protected character GetCreateError():
        return "Tenant" + Name + " was not " 
               + (if valid-object(Service) 
                  then "created in service " + quoter(Service:Name) 
                  else "added to TenantSet")
               + ".". 
    end method.
    
    method public override void WriteTree(tree as IContextTree):
        WriteTree(tree,"domains,partitions,tenantGroupMembers").        
    end method.
    
      /* write specified collections (default all)
         See override in ExportTree(file,collection) that deals with tenantGroups versus TenantGroupMembers for .p */
    method public override void WriteTree(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo.
        define variable cntxt as TenantContext no-undo.
        define variable cColl as character no-undo.
        
        if not valid-object(Context) then
        do:
            cntxt = new TenantContext().
            Attach(cntxt).
        end.
        
        tree:SetHandle(SerializeName,mDefaultBuffer,mDefaultBuffer:rowid).   
        do i = 1 to num-entries(pccollections):
           ccoll = entry(i,pccollections).
           case ccoll:
               when "partitions" then 
               do:
                   tree:SetJoin(SerializeName,"partitions","Name,TenantName").
                   Partitions:WriteTree(tree,"").
               end.  
               when "domains" then 
               do:
                   tree:SetJoin(SerializeName,"domains","Name,TenantName").
                   Domains:WriteTree(tree,"users").
               end.  
               when "users" then 
               do:
                   tree:SetJoin(SerializeName,"domains","Name,TenantName").
                   Users:WriteTree(tree,"users").
               end.  
               when "tenantGroupMembers" then 
               do:
                   tree:SetJoin(SerializeName,"tenantGroupMembers","Name,TenantName").
                   TenantGroupMembers:WriteTree(tree,"").
               end.    
               otherwise 
                   undo, throw new IllegalArgumentError("WriteTree collection " + quoter(ccoll)). 
 
           end.    
        end.
       
    end method.
     
    method public override  void ExportTree(pcfile as char):
        define variable writer as IDataAdminExporter no-undo.
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,"All").
    end method.     
    
    /** override to get codewriter if .p and to handle collections for this */
    method public override void ExportTree(pcfile as char,pcCollectionlist as char):
        define variable writer as IDataAdminExporter no-undo.
        define variable iPos as integer no-undo.
       
        /* The code writer support this, but it writes tenants, so externally 
            we give error if actually asking for it (see below) */ 
        iPos = lookup("TenantGroupMembers",pcCollectionList).
        if iPos > 0 then
        do:
            if GetFileExtension(pcfile) = "p" then
               undo, throw new UnsupportedOperationError("Cannot generate code for TenantGroupMembers. Use TenantGroups instead.").
        end.
        
        /* This will give error in writeTree, but code writer actually exports 
           code for Tenants when passing "TenantGroupMembers", so we just change it here */
        iPos = lookup("TenantGroups",pcCollectionList).
        if iPos > 0 then
        do:
            if GetFileExtension(pcfile) = "p" then
                entry(iPos,pcCollectionList) = "TenantGroupMembers".
        end.
        
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,pcCollectionlist).
    end method.     
     
    method private char GetFileExtension(pcFile as char):
       define variable i as integer no-undo.
       i = num-entries(pcfile,".").
       if i > 1 then
           return entry(i,pcfile,".").
       else return "".    
    end method.   
    
    method protected IDataAdminExporter GetExporter(pcFile as char):
        define variable i as integer no-undo.
        define variable fileext as character no-undo.
        fileExt = GetFileExtension(pcFile).
        case fileExt:
            when "p" then
                return new CodeWriter().
            when "json" then  
                return new JSONWriter().
            otherwise 
                undo, throw new IllegalArgumentError("Export to file with extension " + quoter(fileext)). 
        end.
    end method.
    
    
end class.
