/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : Extent
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:30:19 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.  
using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.IDataAdminService.
using OpenEdge.DataAdmin.IExtent.
using OpenEdge.DataAdmin.IDataAdminElement.
using OpenEdge.DataAdmin.IDataAdminSerializable.
using OpenEdge.DataAdmin.IArea.
using OpenEdge.DataAdmin.IExtent.
using OpenEdge.DataAdmin.IRequestInfo.
using OpenEdge.DataAdmin.Core.JSONLoader.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

using OpenEdge.DataAdmin.Binding.AreaContext.
using OpenEdge.DataAdmin.Binding.ExtentContext.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.
using OpenEdge.DataAdmin.Error.IllegalArgumentError.
using OpenEdge.DataAdmin.Error.UnknownValueError.

class OpenEdge.DataAdmin.Extent implements IExtent, IDataAdminElement, IDataAdminSerializable:
    
    define private variable mDefaultBuffer as handle no-undo.
    define private variable mBuffer       as handle  no-undo. 
    define private variable mchild        as logical no-undo. 
    
    define public property SerializeName as char no-undo 
        get():
            if valid-handle(mDefaultBuffer) then 
                return mDefaultBuffer:serialize-name.
            return "".       
        end.        
        
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
   
    define public property Error     as error no-undo           get.        
    
    /** defines the context (or scope?) for the instance.
        Used in Equals() - entities with the same keys are not 
        equals if different context */ 
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
        Always false if New. Can only be true for an Attached object. */
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
   
    define public property Area as  IArea no-undo 
        get():        
             if  valid-object(Area) = false    
             and valid-handle(mBuffer) and mBuffer::AreaName > "" 
             and valid-object(Service) then
                 Area = Service:GetArea(mBuffer::AreaName).    
             return Area.
        end.
        set(parea as IArea).
            if not valid-object(parea) then
            do:
               undo, throw new UnknownValueError("Extent Area").
/*                   undo, throw new InvalidPropertyValueError("Partition","","Area","unknown").*/
            end.    
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::AreaName = parea:Name.
            end.
            Area = parea.
        end.
     /** The file name of the extent */
    define public property FileName as char no-undo           
        get():
            if valid-handle(mBuffer) then
                return mBuffer::FileName.
            else
                return FileName. 
        end.
        set(pFileName as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Description = pFileName.
            end.
            else
                FileName = pFileName.
        end. 
    
     /** The path of the extent - can be set instead of the file  */
     define public property Path as char no-undo           
         get():
            if valid-handle(mBuffer) then
                return mBuffer::Path.
            else
                return Path. 
         end.
         set(pPath as char):
             if valid-handle(mBuffer) then
             do:
                 Context:SetProperty(mBuffer:rowid,"Path",pPath).
             end.
             Path = pPath.
         end. 
         
    /** The number of the extent within the area */
    define public property Number  as int no-undo    
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Number.
            else
                return Number. 
        end.
    
     /** Is the extent fixed. */      
    define public property IsFixed as log no-undo 
        init no
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsFixed.
            else
                return IsFixed. 
        end.
        set(pIsFixed as log):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsFixed = pIsFixed.
            end.
            IsFixed = pIsFixed.
        end. 
    
    /** The Size of the extent in KB */
   define public property Size as int no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Size.
            else
                return Size. 
        end.
        set(pSize as int):
            if valid-handle(mBuffer) then
            do:
                 Context:SetProperty(mBuffer:rowid,"Size",string(pSize)).
            end.
            Size = pSize.
            Isfixed = pSize > 0.
        end. 
    define public property RequestInfo as IRequestInfo no-undo get. protected set.
       
    constructor Extent():
        super().
    end method.
    
    constructor Extent(cntxt as ExtentContext):
        super().
        Context = cntxt.      
    end method.
    
    constructor Extent(pArea as IArea,cntxt as AreaContext):
        super().
        Area = pArea.
        Context = cntxt.
    end method.
    
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
   
/*                                                                        */
/*     /* write the object with urls to children */                       */
/*    method public void WriteObjectTo(writer as IDataAdminWriter):       */
/*        writer:WriteContext(Context).                                   */
/*    end method.                                                         */
/*                                                                        */
/*    /* All - no children call WrtieObjectTo */                          */
/*    method public void WriteAllTo(writer as IDataAdminWriter):          */
/*        WriteObjectTo(writer).                                          */
/*    end method.                                                         */
/*                                                                        */
/*    /* write a short list of the data with url to details */            */
/*    method public void WriteListTo(writer as IDataAdminWriter):         */
/*        undo, throw new UnsupportedOperationError("Domain WriteListTo").*/
/*    end method.                                                         */
/*                                                                        */
    method public void WriteTree(tree as IContextTree):
        undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method.
  
/*     /* write specified collections (default all) */                               */
/*    method public void WriteTree(writer as IDataAdminWriter,pcCollections as char):*/
/*         WriteAllTo(writer).                                                       */
/*    end method.                                                                    */
    
    method public void WriteTree(tree as IContextTree,pcCollections as char):
        undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method.
       
    method public void ExportTree(pcfile as char):
        this-object:Export(pcFile).
    end method.     
    
    method public void ExportTree(pcfile as char,pcCollectionlist as char):
        undo, throw new UnsupportedOperationError("ExportTree " + quoter(pcCollectionlist)).       
    end method.     
    
    method public void Export():
        Export("extent.json").
    end method.          
    
    method public void Export(cFile as char):
        define variable htbl as handle no-undo.
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Export of new tenant").
        end.
        create temp-table htbl.
        htbl:create-like(mDefaultBuffer).
        htbl:temp-table-prepare ("ttTenant").
        htbl:default-buffer-handle:buffer-copy (mBuffer).
        htbl:default-buffer-handle:serialize-name = "tenant".     
        htbl:default-buffer-handle:write-json ("File",cFile,yes).   
    end method.
        
    method public void ImportTree(pcFile as char). 
        undo, throw new UnsupportedOperationError("ImportTree for Extent.").
    end method. 
 
    method public void Import(cFile as char):
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Import to new Extent that is not in a collection or service").
        end.
        Context:ImportRow(cFile,GetKeyValues()).
    end method.  
    
    method protected character extent GetKeyValues():
        define variable cKey as character no-undo.
        define variable hFld as handle no-undo. 
        define variable i as integer no-undo.
        define variable cValues as char extent 2 no-undo.
        
/*   oops does not compile due to name conflict
        extent(cValues) = num-entries(Context:KeyFields).*/
           
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
