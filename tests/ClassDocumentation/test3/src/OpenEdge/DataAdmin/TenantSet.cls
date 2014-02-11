 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TenantSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.  
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Core.CodeWriter from propath.

using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
class OpenEdge.DataAdmin.TenantSet inherits DataAdminCollection implements ITenantSet : 
   
    
    constructor TenantSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
    
    constructor TenantSet(cntxt as IDataAdminContext):
        super(cntxt).
        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,TenantContext)) then 
             undo, throw new IllegalArgumentError("Invalid context type passed to TenantSet constructor"). 
    end constructor. 
    
    constructor TenantSet(cntxt as TenantContext):
        super(cntxt).  
    end constructor. 
    
    constructor TenantSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        define variable cntxt as IDataAdminContext no-undo.
        return new TenantContext().
    end.     
    
    method public override logical Add(o as Object).  
        define variable inst as ITenant no-undo.
        inst = cast(o,ITenant).
        return this-object:Add(inst).
    end method.
    
    method public logical Add(tenant as ITenant).  
        if Contains(tenant) then
            return false.   
        tenant:Attach(Context).
        
        return true.
    end method.  
    
    method public override logical Remove(o as Object):
        define variable tnt as ITenant no-undo.
        tnt =  cast(o,ITenant).   
        return Remove(tnt).
    end method.  
    
    method public logical Remove(tenant as ITenant):
/*        if Contains(tenant) then*/
       
           return Context:Delete(tenant:Name).
    end method.  
   
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,ITenant)).   
        catch e as Progress.Lang.Error :
        	return false.	
        end catch.
    end method.
   
    method public logical Contains(tenant as ITenant):
        if tenant:ContextId <> ContextId then 
            return false.
        if not CanFind(tenant:name) then
            return false.
        return tenant:Equals(this-object:Find(tenant:name)).      
    end method.  
     
    method public ITenant Find(tenantname as char):
        return cast(Context:FindEntity(tenantname),ITenant).            
    end method.   
    
    method public ITenant FindByExternalId(ExtId as char):
        define variable req as IRequestInfo no-undo.
        req = new RequestInfo("ExternalId",string(ExtID)).
        return cast(Context:FindEntity(req),ITenant).            
        
    end method.   
    
    method public ITenant Find(tenantid as int):
        return cast(Context:FindEntity(tenantid),ITenant).     
    end method.    
    
    method public logical CanFind(tenantname as char):
        return Context:CanFind(tenantname).
    end method.   
         
    method public logical CanFind(tenantid as int):
        return Context:CanFind(tenantid).    
    end method.    
    
    method public logical CanFindByExternalId(ExtId as char):
        define variable tenantCntxt as TenantContext no-undo. 
        tenantCntxt = cast(Context,TenantContext).
        return tenantCntxt:CanFindByExternalId(ExtId).
    end.
     
    method public override void  ExportTree(pcfile as char,pcCollectionlist as char):
        define variable writer as IDataAdminExporter no-undo.
        define variable codewriter as CodeWriter no-undo.
        define variable fileext as character no-undo.
        define variable iPos as integer no-undo.
        fileExt = GetFileExtension(pcFile).
        case fileExt:
            /* deal with current limitations that does not handle the TenantGroups collection */  
            when "p" then do:
               /* The code writer actually support this, but it writes tenants, so externally 
                  we give error if actually asking for it (see below) */ 
               iPos = lookup("TenantGroupMembers",pcCollectionList).
               if iPos > 0 then
                   undo, throw new UnsupportedOperationError("Cannot generate code for TenantGroupMembers. Use TenantGroups instead.").
               
               /* for .p we generate code for TenantGroups when passing TenantGroupMembers, 
                  so we just fix the list internally. */
               iPos = lookup("TenantGroups",pcCollectionList).
               if iPos > 0 then 
                   entry(iPos,pcCollectionList) = "TenantGroupMembers".
            end.
            otherwise 
            do:
               iPos = lookup("TenantGroups",pcCollectionList).
               if iPos > 0 then
                    undo, throw new UnsupportedOperationError("Export of TenantGroups collection. Use TenantGroupMembers instead.").
               
            end.
        end.
            
        super:ExportTree(pcfile,pcCollectionlist). 
    end method. 
     
    method override protected void PrepareExport(  ):
/*        buffer ttTenant:handle:buffer-field("URL"):serialize-hidden = true.*/
    end method.    
     
    method override protected void PrepareExportTree():
        TableHandle:default-buffer-handle:buffer-field("PartitionsURL"):serialize-hidden = true.
    end method.      
    
    method override logical Equals(obj as Object): 
        define variable tset as TenantSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,TenantSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
        	return false.	
        end catch.    
    end method.
    
 
    /**
     * 
     * @param context 
     */
     /*
    method public override void Attach(cntxt as IDataAdminContext).
    
        define variable oldcontext as IDataAdminContext no-undo.
        if not valid-object(cntxt) then
            undo, throw new UnknownValueError("Attach","context").  
        
        cntxt:Copy(this-object:Context).                     
        if valid-object(mpartitions) then 
        do:
            cntxt:Service:AttachPartitions(mpartitions).
        end.        
        oldcontext = this-object:Context.  
        this-object:Context = cntxt.
        OnContextChanged().
        if not oldcontext:IsShared then
            delete object oldcontext.        
  
    end method.
    */
       
    /* All - expand collections */
/*    method public override void WriteAllTo(writer as IDataAdminWriter):                                 */
/*        undo, throw new UnsupportedOperationError("WriteAllTo TenantSet.").                             */
/*                                                                                                        */
/*        writer:WriteContext(Context).                                                                   */
/*        if not valid-object(Service) then                                                               */
/*        do:                                                                                             */
/*            if not valid-object(mpartitions) then                                                       */
/*                mpartitions = new PartitionSchemaMap().                                                 */
/*            writer:WriteChild(cast(mpartitions,IDataAdminSerializable),SerializeName,"Name,TenantName").*/
/*/*            writer:WriteChild(cast(domains,IDataAdminSerializable),SerializeName,"Name,TenantName").*/*/
/*        end.                                                                                            */
/*        else do:                                                                                        */
/*            if not valid-object(mPartitions) then                                                       */
/*                mpartitions = Service:GetTenantPartitions().                                            */
/*            writer:WriteChild(cast(mpartitions,IDataAdminSerializable),SerializeName,"Name,TenantName").*/
/*/*            writer:WriteChild("domains",SerializeName,"Name,TenantName").*/                           */
/*        end.                                                                                            */
/*/*        partitions = Service:GetPartitions().*/                                                       */
/*        /* the domains will write users, so we don't call that from here  */                            */
/*                                                                                                        */
/*    end method.                                                                                         */

/*    /* write a short list of the data with url to details */            */
/*    method public override void WriteListTo(writer as IDataAdminWriter):*/
/*        writer:WriteContextList(Context,"Name,Id,Description,AreasUrl").*/
/*    end method.                                                         */
    
    method override protected void PrepareExportList():
/*        TableHandle:default-buffer-handle:buffer-field("Type"):serialize-hidden = true.*/
/*        mTableHandle:default-buffer-handle:buffer-field("Description"):serialize-hidden = true.*/
/*        TableHandle:default-buffer-handle:buffer-field("ExternalId"):serialize-hidden = true.*/
        TableHandle:default-buffer-handle:buffer-field("DefaultDataAreaName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DefaultIndexAreaName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DefaultLobAreaName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DefaultDataAreaUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DefaultIndexAreaUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DefaultLobAreaUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DefaultAllocation"):serialize-hidden = true. 
        TableHandle:default-buffer-handle:buffer-field("PartitionsURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantGroupMembersURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("DomainsURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("SequenceValuesURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("UsersURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("AreasURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("IsAllocated"):serialize-hidden = true. 
    /*    TableHandle:default-buffer-handle:buffer-field("IsDataEnabled"):serialize-hidden = true.*/ 
  
    end method.    
    
   
end class.
