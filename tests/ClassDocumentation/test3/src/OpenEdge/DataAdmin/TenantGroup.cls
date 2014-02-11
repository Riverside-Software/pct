/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TenantGroup
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
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.TenantGroup from propath.
using OpenEdge.DataAdmin.IPartitionMap from propath.
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.

using OpenEdge.DataAdmin.ITenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITenantSet from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminExporter from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath. 
using OpenEdge.DataAdmin.Entity from propath. 
using OpenEdge.DataAdmin.IRequestInfo  from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath. 
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath. 
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath. 
using OpenEdge.DataAdmin.Error.CreateOnlyPropertyError from propath. 
using OpenEdge.DataAdmin.Core.JSONWriter from propath.  
using OpenEdge.DataAdmin.Core.CodeWriter from propath.  
using OpenEdge.DataAdmin.Core.JSONLoader from propath.  

class OpenEdge.DataAdmin.TenantGroup inherits Entity implements ITenantGroup:
     
    define private variable mPartitionTable as handle no-undo. 
    define private variable mTenantGroupMembersTable as handle no-undo. 
       
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
      
    define public property Table as ITable no-undo                 
        get():
            if not valid-object(this-object:Table) then
            do:
                if valid-handle(mBuffer) then
                    return Service:GetTable(mBuffer::TableName).
            end.
            return this-object:Table. 
        end.
        set(pTable as ITable):
            if not valid-object(pTable) then 
                undo, throw new UnknownValueError("TenantGroup:Table").
            
            if valid-object(Service) then
                undo, throw new CreateOnlyPropertyError("TenantGroup",Name,"Table").
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TableName = pTable:Name.
            end.
            this-object:Table = pTable.
        end. 
 
      define public property Tenants as ITenantSet no-undo                 
          get():
              if not valid-object(Tenants) then
              do:
                  Tenants = cast(GetChildCollection("tenants"),ITenantSet).    
              end.
              return Tenants.
          end.
          private set.
      
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
    
      
     define public property Partitions as IPartitionMap no-undo    
        get():
            if not valid-object(Partitions) then
            do:   
                if not valid-object(context:Service) and not valid-object(context:TargetService) then
                    undo, throw new UnsupportedOperationError("Partitions are not available in a TenantGroup that is not newed, created or retrieved by a service.").  
                      
                Partitions = cast(GetChildCollection("partitions"),IPartitionMap).
            end.     
            return Partitions.
        end.
        private set.     
    
       
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
            if lookup(pDefaultAllocation,ValidDefaultAllocationList) = 0 then 
                undo, throw new InvalidPropertyValueError("TenantGroup",Name,"DefaultAllocation",pDefaultAllocation,ValidDefaultAllocationList).   
            
            if valid-handle(mBuffer) then
            do:
                Context:SetProperty(mBuffer:rowid,"DefaultAllocation",pDefaultAllocation).
            end.
            DefaultAllocation = pDefaultAllocation.
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
            if not valid-object(pDefaultIndexArea) then 
            do:
                undo, throw new UnknownValueError("DefaultIndexArea").          
            end.   
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::DefaultIndexAreaName = pDefaultIndexArea:Name.
            end.
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
        
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
        
    constructor public TenantGroup (cntxt as IDataAdminContext):
        super (cntxt).
    end constructor.
    
    constructor public TenantGroup (cntxt as IDataAdminContext,preq as IRequestInfo):
        super (cntxt,preq).
    end constructor.
      
    constructor public TenantGroup (cname as character):
        super (cname).             
    end constructor. 
    
    constructor public TenantGroup (cname as character, service as DataAdminService):
        this-object(cname).
    end constructor. 
    
    /* local context needed - child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return new TenantGroupContext().
    end method.
     
  
    method public logical Allocate():
        IsAllocated = true.
        return Partitions:Allocate(). 
    end method.        
        
/*    method override logical Equals(obj as Object):   */
/*        define variable tnt as TenantGroup no-undo.  */
/*        if super:Equals(obj) then                    */
/*            return true.                             */
/*        else do:                                     */
/*            tnt = cast(obj,TenantGroup).             */
/*            if  this-object:ContextId = tnt:ContextId*/
/*            and this-object:Name = tnt:Name then     */
/*                return true.                         */
/*        end.                                         */
/*        return false.                                */
/*        catch e as Error :                           */
/*            return false.                            */
/*        end catch.                                   */
/*    end method.                                      */
    
    method public override void Export():
        Export("area.json").
    end method.          
    
    method protected character GetCreateError():
        return "TenantGroup" + Name + " was not " 
               + (if valid-object(Service) 
                  then "created in service " + quoter(Service:Name) 
                  else "added to TenantGroupSet")
               + ".". 
    end method.
    
    method public override void WriteTree(tree as IContextTree):
        WriteTree(tree,"tenantGroupMembers,partitions").        
    end method.
    
    /* write specified collections (default all)
       See override in ExportTree(file,collection) that deals with tenants versus TenantGroupMembers for .p */
    method public override void WriteTree(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo.
        define variable cColl as character no-undo.
        
        tree:SetHandle(SerializeName,mDefaultBuffer,mDefaultBuffer:rowid).   
        
        do i = 1 to num-entries(pccollections):
           ccoll = entry(i,pccollections).
           case ccoll:
               when "partitions" then 
               do:
                   tree:SetJoin(SerializeName,"partitions","Name,TenantGroupName").
                   if valid-object(Partitions) then 
                        Partitions:WriteTree(tree,"").
               end.  
               when "tenantGroupMembers"  then 
               do:
                   tree:SetJoin(SerializeName,"tenantGroupMembers","Name,TenantGroupName").
                   if valid-object(TenantGroupMembers) then 
                        TenantGroupMembers:WriteTree(tree,"").
               end.
               when "tenants" then 
               do:
                   undo, throw new UnsupportedOperationError("Export or import of Tenants collection. Use TenantGroupMembers instead.").
/*                                                                                */
/*                   tree:SetJoin(SerializeName,"tenants","Name,TenantGroupName").*/
/*                   Tenants:WriteTree(tree,"").                                  */
               end.
               otherwise 
                   undo, throw new IllegalArgumentError("WriteTree collection " + quoter(ccoll)). 
 
           end.    
        end.
       
    end method.
    
    
   /*
      /* write specified collections (default all) */
    method public override void  WriteTree(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo.
        define variable cntxt as TenantGroupContext no-undo.
        define variable cColl as character no-undo.
        define variable hCopy as handle no-undo. 
        if not valid-object(Context) then
        do:
            cntxt = new TenantGroupContext().
            Attach(cntxt).
        end.
        
        tree:SetHandle(SerializeName,mDefaultBuffer,mDefaultBuffer:rowid).   
        
        do i = 1 to num-entries(pccollections):
           ccoll = entry(i,pccollections).
           case ccoll:
               when "partitions" then 
               do:
                   tree:SetJoin(SerializeName,"partitions","Name,TenantGroupName").
                   if valid-handle(mPartitionTable) then
                   do:
                       tree:SetHandle("partitions",mPartitionTable:default-buffer-handle).
                   end.
                   else do:                      
                       Partitions:WriteTree(tree,"").
                   end.
               end.  
               when "tenantgroupmembers" then 
               do:
                    tree:SetJoin(SerializeName,"tenantGroupMembers","Name,TenantGroupName"). 
                    if valid-handle(mTenantGroupMembersTable) then
                    do:
                        tree:SetHandle("tenantGroupMembers",mTenantGroupMembersTable:default-buffer-handle).
                    end.
                    else do:    
                        TenantGroupMembers:WriteTree(tree).                        
                    end.
               end.    
           end.    
        end.
        
    end method.
     */
    method public override void ExportTree(pcfile as char):
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
               undo, throw new UnsupportedOperationError("Cannot generate code for TenantGroupMembers. Use Tenants instead.").
        end.
        
        /* This will give error in writeTree, but code writer actually exports 
           code for Tenants when passing "TenantGroupMembers", so we just change it here */
        iPos = lookup("Tenants",pcCollectionList).
        if iPos > 0 then
        do:
            if GetFileExtension(pcfile) = "p" then
                entry(iPos,pcCollectionList) = "TenantGroupMembers".
        end.
        
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,pcCollectionlist).
    end method.     
    
    /**
    /* Copy partition table as it cannot be imported with non-primary group index 
       Copy tenantGroupMembers to support Delete of those not imported 
       (CopyChildTable will replace "tenantGroupDetails" )  */ 
    method public override void ImportTree(pcfile as char):
        define variable cntxt as TenantGroupContext no-undo.
        define variable reader as JSONLoader no-undo.        
        reader = new JSONLoader().
        cntxt  = cast(Context,TenantGroupContext).
        mPartitionTable = cntxt:CreateImportTable("partitions").      
        mTenantGroupMembersTable = cntxt:CreateImportTable("tenantGroupMembers").  
        reader:LoadFromFile(this-object,pcfile,"replace").
        /* destructor delete ds and auto deletes the tt */
        cntxt:CopyChildTable("partitions",mPartitionTable).
        cntxt:CopyChildTable("tenantGroupMembers",mTenantGroupMembersTable).
        finally:
            delete object mPartitionTable no-error.
            delete object mTenantGroupMembersTable no-error.
            delete object reader no-error.    
            		
        end finally. 
       
    end method.     
       ***/ 
    
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
