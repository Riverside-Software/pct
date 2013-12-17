 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AreaSet
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
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
 
class OpenEdge.DataAdmin.AreaSet inherits DataAdminCollection implements IAreaSet: 
    
    constructor AreaSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
    
    constructor AreaSet(cntxt as IDataAdminContext):
        super(cntxt).
        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,AreaContext)) then 
            undo, throw new IllegalArgumentError("Invalid context type passed to AreaSet constructor"). 
   
    end constructor. 
    
    constructor AreaSet(cntxt as AreaContext):
        super(cntxt).  
    end constructor. 
    
    constructor AreaSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
      
	method override protected IDataAdminContext CreateLocalContext(  ):
		return new AreaContext().
	end method.
     
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IArea)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(area as IArea):
        if area:ContextId <> ContextId then 
            return false.
        if not CanFind(area:name) then
            return false.
        return area:Equals(this-object:Find(area:name)).      
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
 
    end method.  
   
    method override logical Equals(obj as Object): 
        define variable tset as AreaSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,AreaSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
            return false.   
        end catch.    
    end method.  
    
    method public IArea Find(areaname as char):
        return cast(Context:FindEntity(areaname),IArea). 
    end method.   
         
    method public IArea Find(areaNum as int):
        return cast(Context:FindEntity(areanum),IArea). 
    end method.    
    
    method public logical CanFind(areaname as char):
        return Context:CanFind(areaname).
    end method.   
         
    method public logical CanFind(areaNum as int):
        return Context:CanFind(areaNum).    
    end method.
    /**
    /* All - expand collections */
    method public override void WriteAllTo(writer as IDataAdminWriter):
        define variable partitions as IPartitionCollection no-undo.
        writer:WriteContext(Context). 
     
/*        partitions = Service:GetPartitions().*/
        /* the domains will write users, so we don't call that from here  */
/*        writer:WriteChild(cast(domains,IDataAdminSerializable),SerializeName,"Name,TenantName").*/
/*        writer:WriteChild(cast(Partitions,IDataAdminSerializable),SerializeName,"Name,TenantName").*/
    end method.    
   */   
    method override void PrepareExport():
    end method.    
    
    method override void PrepareExportTree():
        TableHandle:default-buffer-handle:buffer-field("ExtentsURL"):serialize-hidden = true.
    end method.    
     
    method protected override void PrepareExportList():
        TableHandle:default-buffer-handle:buffer-field("Number"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Type"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("NumExtents"):serialize-hidden = true.
/*        TableHandle:default-buffer-handle:buffer-field("ClusterSize"):serialize-hidden = true.    */
/*        TableHandle:default-buffer-handle:buffer-field("RecordsPerBlock"):serialize-hidden = true.*/
        TableHandle:default-buffer-handle:buffer-field("BlockSize"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("PartitionsURL"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("ExtentsURL"):serialize-hidden = true.
/*        TableHandle:default-buffer-handle:buffer-field("IsType2"):serialize-hidden = true.*/
    end method.
  
    method public override logical Add(o as Object):
        define variable inst as IArea no-undo.
        inst = cast(o,IArea). /* cast to get error */
        return this-object:Add(inst).
    end method.
    
    method public logical Add(area as IArea):
        if Contains(area) then
            return false.   
       
        area:Attach(Context).
      
        return true. 
    end method.    
end class.
