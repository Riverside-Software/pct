 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TenantGroupSet
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

class OpenEdge.DataAdmin.TenantGroupSet inherits DataAdminCollection implements ITenantGroupSet : 
   
    
    constructor TenantGroupSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
    
    constructor TenantGroupSet(cntxt as IDataAdminContext):
        super(cntxt).
        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,TenantGroupContext)) then 
             undo, throw new IllegalArgumentError("Invalid context type passed to TenantGroupContext constructor"). 
    end constructor. 
    
    constructor TenantGroupSet(cntxt as TenantGroupContext):
        super(cntxt).  
    end constructor. 
    
    constructor TenantGroupSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        define variable cntxt as IDataAdminContext no-undo.
        return new TenantGroupContext().
    end.     
    
    method public override logical Add(o as Object):
        define variable seq as ITenantGroup no-undo.
        seq = cast(o,ITenantGroup). /* cast to get error */
        return this-object:Add(seq).
    end method.  
    
    method public logical Add(pGroup as ITenantGroup).  
        if Contains(pGroup) then
            return false.   
        pGroup:Attach(Context).
        
        return true.
    end method.  
    
    method public override logical Remove(o as Object):
        define variable seq as ITenantGroup no-undo.
        seq = cast(o,ITenantGroup). /* cast to get error */
        return Remove(seq).
    end method.  
    
    method public logical Remove(pseq as ITenantGroup):
        AssertNotNull(pseq,"TenantGroup").
        return Context:Delete(pseq:Name).
    end method.  
   
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,ITenantGroup)).   
        catch e as Progress.Lang.Error :
        	return false.	
        end catch.
    end method.
   
    method public logical Contains(pGroup as ITenantGroup):
        if pGroup:ContextId <> ContextId then 
            return false.
        if not CanFind(pGroup:name) then
            return false.
        return pGroup:Equals(this-object:Find(pGroup:name)).      
    end method.  
      
    method public ITenantGroup Find(groupname as char):
        return cast(Context:FindEntity(groupname),ITenantGroup ).    
    end method.   
    
    method public ITenantGroup Find(groupid as int):
        return cast(Context:FindEntity(groupid),ITenantGroup ).    
    end method.    
    
    method public logical CanFind(groupname as char):
        return Context:CanFind(groupname).
    end method.   
         
    method public logical CanFind(groupid as int):
        return Context:CanFind(groupid).    
    end method.    
     
    method public override void ExportTree(pcfile as char):
        define variable writer as IDataAdminExporter no-undo.
        define variable codewriter as CodeWriter no-undo.
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,"All").
    end method.      
    
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
                    undo, throw new UnsupportedOperationError("Cannot generate code for TenantGroupMembers. Use Tenants instead.").
                /* for .p we generate code for Tenants when passing TenantGroupMembers, 
                   so we just fix the list internally. */
                iPos = lookup("Tenants",pcCollectionList).
                if iPos > 0 then 
                   entry(iPos,pcCollectionList) = "TenantGroupMembers".
            end.
            otherwise 
            do:
               iPos = lookup("Tenants",pcCollectionList).
               if iPos > 0 then
                    undo, throw new UnsupportedOperationError("Export of Tenants collection. Use TenantGroupMembers instead.").
               
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
        define variable tset as TenantGroupSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,TenantGroupSet).  
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
        TableHandle:default-buffer-handle:buffer-field("TableUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("PartitionsUrl"):serialize-hidden = true.
   
    end method.    
    
   
end class.
