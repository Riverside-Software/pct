/*************************************************************/
/* Copyright (c) 2010-2012 by Progress Software Corporation  */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : Partition
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jun 22 23:30:48 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.

using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Query.* from propath.
 
using OpenEdge.DataAdmin.Error.* from propath. 

class OpenEdge.DataAdmin.Partition implements IPartition,IDataAdminElement,IDataAdminSerializable use-widget-pool:  
    
    define private variable mDataset as handle no-undo.
    define private variable mDefaultBuffer as handle no-undo.
    define private variable mBuffer as handle no-undo. 
    define private variable mchild as logical no-undo.
	
	define public property Error     as error no-undo           get.           
    
    define public property IsMultiTenant  as logical no-undo    
        get():
            if valid-handle(mBuffer) then
               return  (mBuffer::TenantName <> "" and mBuffer::TenantName <> ?) 
                        or 
                       (mBuffer::TenantGroupName <> "" and mBuffer::TenantGroupName <> ?). 
                      
            return true. /* non case.. partitions should always have mbuffer. */
        end.           
    
    /** defines the context (or scope?) for the instance.
        Used in Equals() to check entities with the same keys not 
        are equals if different context */
       
    define protected property Context   as IDataAdminContext no-undo 
        get. 
        private set(cntxt as IDataAdminContext ):     
            mDefaultBuffer = cntxt:TableHandle:default-buffer-handle.
            if not valid-handle(mBuffer) then
            do:                
                if mDefaultBuffer:avail then
                do:       
                    create buffer mBuffer for table mDefaultBuffer.
                    mBuffer:serialize-name = mDefaultBuffer:serialize-name.
                    mBuffer:find-by-rowid(mDefaultBuffer:rowid).
                end.
                else 
                    undo, throw new IllegalArgumentError("Context set with no corresponding row").
            end.
            if valid-object(Context) then 
              Context:AddedToContext:Unsubscribe(NewContext).
           Context = cntxt.  
           Context:AddedToContext:Subscribe(NewContext).       
        end.
        
    define public property ContextId as char no-undo           
        get():
            if valid-object(Context) then 
            do:
                return Context:Id.
            end.
            return "".    
        end.    
    
    define public property Attached as logical no-undo 
        get():
            return valid-object(Context) and Context:RootId = ?. 
        end.      
        
    /** Tells whether the instance is newly created (not saved to service). 
        Always true if Attached is false. Modified is always false when Created is true  */
    define public property Created as logical no-undo           
        get().
            if valid-handle(mbuffer) then
                 return mBuffer:row-state = row-created.
            return true.
        end.
        
    /** Tells whether an instance is modified after it was read from the service. 
        Always false if Created. Can only be true for an Attached object.
         */
    define public property Modified as logical no-undo            
        get().
            if valid-handle(mbuffer) then
                 return mBuffer:row-state = row-modified.
            return false.
        end.
            
             
    define public property Service as IDataAdminService no-undo 
        get():
            if valid-object(Context) then
                /* can be unknown */
                return this-object:Context:Service. 
            return ?. 
        end. 
  
    define public property SerializeName as char no-undo 
        get():
            if valid-handle(mDefaultBuffer) then 
                return mDefaultBuffer:serialize-name.
            return "".       
        end.        
	
	define public property ObjectType as character no-undo 
    	get():
             return mBuffer::ObjectType.
        end.
    
    define public property Area as  IArea no-undo 
        get():
             define variable lTrack as logical no-undo. 
             if valid-handle(mBuffer) and mBuffer::AreaName > "" 
             and valid-object(Service) then
             do:
                 return Service:GetArea(mBuffer::AreaName).   
             end.
             return Area.
        end.
        set(parea as IArea).
            if IsMultiTenant = false then    
                undo, throw new ReadOnlyPropertyError(GetName(),"","Area","The " + ObjectType +  " is not multi-tenant enabled").         
            if not valid-object(parea) then
            do:
               undo, throw new UnknownValueError("Partition Area").
/*                   undo, throw new InvalidPropertyValueError("Partition","","Area","unknown").*/
            end.    
            
            if valid-handle(mBuffer) then
            do:
               
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::AreaName = parea:Name.
            end.
            Area = parea.
        end.
    
    define public property AllocationState as char no-undo         
        get():
            if valid-handle(mBuffer) then
                return mBuffer::AllocationState.
            else
                return AllocationState. 
        end.
        set(pAllocationState as char):
            
            if ObjectType <> "Table" then
                undo, throw new ReadOnlyPropertyError(lc(ObjectType) + " " + lc(Context:name),"","AllocationState","Allocation state can only be changed in table partitions").
            
            if IsMultiTenant = false then    
                undo, throw new ReadOnlyPropertyError(GetName(),"","AllocationState","The " + ObjectType +  " is not multi-tenant enabled").         
            
            SetProperty("AllocationState",pAllocationState).

            /*  
            if not Created and AllocationState = "Allocated" then 
                undo, throw new ReadOnlyPropertyError(GetName(),"","AllocationState","The partition is already allocated").
            
            */
        end.    
    
    define public property BufferPool as char no-undo         
        get():
            if valid-handle(mBuffer) then
                return mBuffer::BufferPool.
            else
                return BufferPool. 
        end.
        set(pBufferPool as char):
            if lookup(pBufferPool,"Alternate,Primary") = 0 then
                 undo, throw new InvalidPropertyValueError ("Partition", "","BufferPool", pBufferPool, "Alternate,Primary").                      
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::BufferPool = pBufferPool.
            end.          
            BufferPool = pBufferPool.
        end.    

    define public property CanAssignAlternateBufferPool as logical no-undo         
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanAssignAlternateBufferPool.
            else
                return CanAssignAlternateBufferPool. 
        end.
     
	define public property Element as ISchemaElement no-undo 
        get():
            define variable tbl as ITable no-undo.
            define variable fld as IField no-undo.
            define variable idx as IIndex no-undo.
            if valid-handle(mBuffer)and valid-object(Service) then
            do:
               tbl = service:GetTable(mBuffer::Tablename). 
               case ObjectType:
                   when "Table" then
                      if valid-object(tbl) then 
                         return cast(tbl,ISchemaElement).
                   when "Field" then 
                   do:
                      fld = tbl:LOBFields:Find(mBuffer::FieldName).
                      if valid-object(fld) then 
                          return cast(fld,ISchemaElement). 
                   end.
                   when "Index" then 
                   do: 
                      idx = tbl:Indexes:Find(mBuffer::IndexName).
                      if valid-object(idx) then 
                          return cast(idx,ISchemaElement). 
                   end. 
               end.
            end.
            return ?.
        end.
        
    define public property TenantGroup as ITenantGroup no-undo 
        get():
            define variable lTrack as logical no-undo.
            if not valid-object(TenantGroup) 
            and valid-handle(mBuffer) and mBuffer::TenantGroupName > "" 
            and valid-object(Service) then
            do:
                return Service:GetTenantGroup(mBuffer::TenantGroupName).    
            end.
            return TenantGroup.
        end.
        private set(pTenantGroup as ITenantGroup).
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TenantGroupName = pTenantGroup:Name.
            end.
            TenantGroup = pTenantGroup.
        end.
    
	define public property Tenant as ITenant no-undo 
        get():
            define variable lTrack as logical no-undo. 
            if not valid-object(Tenant) 
            and valid-handle(mBuffer) and mBuffer::TenantName > "" 
            and valid-object(Service) then
            do:
                return Service:GetTenant(mBuffer::TenantName).    
            end.
            return Tenant.
        end.
        private set(pTenant as ITenant).
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TenantName = pTenant:Name.
            end.
            Tenant = pTenant.
        end.
    
    define public property RequestInfo as IRequestInfo no-undo get. protected set.
     
    constructor public Partition (cntxt as IDataAdminContext):
        super ().     
        Context = cntxt.
    end constructor.
      
    method public void Attach(cntxt as IDataAdminContext):   
        define variable oldcntxt as IDataAdminContext no-undo.
        define variable lLocal as logical no-undo.
        if not valid-object(cntxt) then
            undo, throw new UnknownValueError("Attach","context").  
        if ContextId = "" then
        do: 
            mchild = true.
            cntxt:CreateRow(this-object).
            Context = cntxt.
        end.
        else do:
            oldcntxt = Context.
            llocal = mbuffer:rowid = oldcntxt:Rootid.
            /* only once - after this we are managed by collection or added to service
               the mchild deals with only copying this into a context once 
               From the first copy the data is managed by its collection or service.
               
             */
            if not mChild then 
                cntxt:Copy(Context).    
            else 
                Context = cntxt.          
            
            mChild = true.           
        end.
         /* this is not handled in newcontext since root id always goes through here */    
        
        if valid-object(oldcntxt) 
        and llocal then 
            delete object oldcntxt.
        
    end method.
    
    
    /* the context we attached to changed */
    method protected void NewContext(cntxt as IDataAdminContext):
        define variable hNewDefaultBuffer as handle no-undo. 
        define variable hNewBuffer as handle no-undo. 
        hNewDefaultbuffer = cntxt:TableHandle:default-buffer-handle.
        create buffer hNewBuffer for table hNewDefaultbuffer.
        hNewBuffer:serialize-name = hNewDefaultbuffer:serialize-name.
        hNewBuffer:find-unique ("where " + Context:GetKeyWhere(GetKeyValues())).
        delete object mbuffer no-error.
        mBuffer = hNewBuffer.      
        Context = cntxt.
    end method.
    
    /*
    method private character GetKeyWhere(phHandle as handle):
        define variable cKeyFields as character  no-undo.
        define variable iField     as integer    no-undo.
        define variable cField     as character  no-undo.
        define variable cKeyWhere  as character  no-undo.
    
        if valid-handle(phHandle) then
        do iField = 1 to num-entries(Context:KeyFields):
           assign
              cField     = entry(iField,Context:KeyFields)
              cField     = entry(num-entries(cField,'.'),cField,'.')
              cKeyWhere  = cKeyWhere 
                         + (if iField > 1 then ' and ' else '')
                         + phHandle:name
                         + '.' 
                         + cField
                         + ' = ' 
                         + quoter(phHandle:buffer-field(cField):buffer-value,"'":U).
        end.
  
        return cKeyWhere. 

    end method.     
    */
    method public logical Allocate():
       
        if IsMultiTenant = false then    
            undo, throw new IllegalOperationError("Allocate non multi-tenant partition.").         
       
        if ObjectType = "Table" then
        do:
            if AllocationState <> "Allocated" then
            do:
                AllocationState = "Allocated".
                return true.
            end.
            return false.    
        end.
        else 
            undo, throw new UnsupportedOperationError("Allocate can only be performed in table partitions."). 
    end method. 
    
    /*
    method public logical Deallocate():
        if ObjectType = "Table" then
        do:
            if type-of(Context,PartitionContext) then 
            do:
                if valid-object(Tenant) then
                do:
                    return cast(Context,PartitionContext):DeallocateTenantTablePartition(Tenant:Name,Element:Name). 
                end.
                else if valid-object(TenantGroup) then
                    return cast(Context,PartitionContext):DeallocateGroupPartition(TenantGroup:Name). 
            end.
            else if type-of(Context,TenantPartitionQuery) then
            do:
                return cast(Context,TenantPartitionQuery):DeallocateTable(Element:Name).
            end.    
            else if type-of(Context,TenantGroupPartitionQuery) then
               return cast(Context,TenantGroupPartitionQuery):Deallocate().  
        end.
        else if AllocationState = "Allocated" then
        do:
            AllocationState = "None".
            return true.
        end.
        return false.    
    end method. 
    */
    
/*     /* write the object with urls to children */                                  */
/*    method public void WriteObjectTo(writer as IDataAdminWriter):                  */
/*        writer:WriteContext(Context).                                              */
/*    end method.                                                                    */
/*                                                                                   */
/*    /* All - no children call WrtieObjectTo */                                     */
/*    method public void WriteAllTo(writer as IDataAdminWriter):                     */
/*        WriteObjectTo(writer).                                                     */
/*    end method.                                                                    */
/*                                                                                   */
/*     /* write specified collections (default all) */                               */
/*    method public void WriteTree(writer as IDataAdminWriter,pcCollections as char):*/
/*         WriteAllTo(writer).                                                       */
/*    end method.                                                                    */
    
    method public void WriteTree(tree as IContextTree,pcCollections as char):
       undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method.
    
    method public void WriteTree(tree as IContextTree):
        undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method.
     
    method public void ExportTree(pcfile as char):
        this-object:Export(pcFile).
    end method.     
    
    method public void ExportTree(pcfile as char,pcCollectionlist as char):
        undo, throw new UnsupportedOperationError("ExportTree " + quoter(pcCollectionlist)).       
    end method.     
    
    method public void Export(  ):
         Export("partition.json").
    end method.
    
    method public void Export(cFile as char):
        define variable htbl as handle no-undo.
        if not valid-handle(mDefaultBuffer) then
        do:
        
            undo, throw new UnsupportedOperationError("Export of " + this-object:GetClass():TypeName).
        end.              
        create temp-table htbl.
        htbl:create-like(mDefaultBuffer).
        htbl:temp-table-prepare (mDefaultBuffer:name).
        htbl:default-buffer-handle:buffer-copy (mBuffer).
        htbl:default-buffer-handle:serialize-name = mDefaultBuffer:serialize-name .    
        htbl:default-buffer-handle:write-json ("File",cFile,yes).
        delete object htbl.   
    end method.
        
    method public void ImportTree(pcFile as char). 
        undo, throw new UnsupportedOperationError("ImportTree of single Partition.").        
    end method. 
 
    method public void Import(cFile as char):
        undo, throw new UnsupportedOperationError("Import of single Partition.").        
    end method.   
    
    method protected character extent GetKeyValues():
        define variable cKey as character no-undo.
        define variable hFld as handle no-undo. 
        define variable i as integer no-undo.
        define variable cValues as char extent no-undo.
        
        extent(cValues) = num-entries(Context:KeyFields).
        do i = 1 to num-entries(Context:KeyFields):
           hFld = mBuffer:buffer-field (entry(i,Context:KeyFields)).
           cValues[i] = string(hfld:buffer-value).
        end. 
        return cValues.
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("KeyFields does not match buffer" + e:GetMessage(1)).  
        end catch. 
    end method. 
    
    method override final logical Equals(obj as Object):
        define variable lOk as logical no-undo.
        lok = super:Equals(obj).
        if not lok and obj:GetClass() = GetClass() then
        do:
            lok = obj:ToString() = ToString().
        end.
        return lok.
        
    end method.
    
    method private character GetName ():
        return GetName(mBuffer). 
    end method.
      
    method private character GetName (phbuffer as handle):
         define variable cName as character no-undo.
         define variable ckey as character no-undo.
         define variable cTenant as character no-undo.
         define variable cGroup as character no-undo.
         ckey = phBuffer::Tablename. 
         cTenant = phbuffer::Tenantname.
         cGroup = phbuffer::TenantGroupName.
         if cTenant = ? or cTenant = "" then
            
         if phbuffer::ObjectType = "field" then
             cKey = cKey + " " + phBuffer::Fieldname.
         else if phbuffer::ObjectType = "index" then
             cKey = cKey + " " + phBuffer::Indexname.  
        
         cName = "Partition for " + phbuffer::ObjectType + " " + quoter(cKey) 
              + if cTenant > "" then " Tenant " + quoter(cTenant)
                else if cGroup > "" then " Group " + quoter(cGroup)
                else "".
         
         return if cName = ? then "<unknown>" else cName.    
    end method.    
    
    method protected logical SetProperty(pcPropName as char, pcValue as char):
        return context:SetProperty(mBuffer:rowid,pcPropName,pcValue).  
    end method.    
      
    method public final override char ToString():
        define variable cKeyFields as character no-undo.
        define variable i as integer no-undo.
        define variable hField as handle no-undo.
        define variable cOut as character no-undo.
        cout = super:ToString(). 
        
        if valid-object(Context) then
        do:
            cOut = Contextid.
            cKeyFields = Context:KeyFields.
             
            do i = 1 to num-entries(cKeyFields).
              hfield = mBuffer:buffer-field (entry(i,cKeyfields)).
              if valid-handle(hField) then 
              do:
                  cOut = cOut 
                       + " "  
                       + (if hField:buffer-value <> ? then hField:buffer-value else "?") 
                       .
              end.
              else
                  undo, throw New IllegalArgumentError("KeyFields does not match object.").  
            end.  
        end.
        return cout.
    end method.    
end class.
