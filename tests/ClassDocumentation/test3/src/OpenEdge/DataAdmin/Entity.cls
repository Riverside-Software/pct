 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : abstract implementation of IDataAdminElement
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Jun 23 22:17:38 EDT 2010
    Notes       : Currently not in use as class. 
                
                  
                 
                 - adds 25% (with empty subclass) overhead to newing of subclass
                  ... still very fast though ...
                 if the content of the classes becomes large then 
                 this may be useful
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Binding.RowBuffer from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.IllegalOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Entity abstract implements IDataAdminElement use-widget-pool: 
 
    define protected variable mDataset as handle no-undo.
    define protected variable mDefaultBuffer as handle no-undo.
    define protected variable mBuffer as handle no-undo.
    define private   variable mChild as logical no-undo.
    define private   variable mLocalContext as IDataAdminContext no-undo.
    
          
    define public property Name as char no-undo     
       get():
           if valid-handle(mBuffer) then
               return mBuffer::Name.
           else
               return Name. 
       end.
       set(pName as char):
           if valid-handle(mBuffer) then
           do:
               SetProperty("Name",pName).  
           end.
           else
               Name = pName.
       end. 

   define public property SerializeName as char no-undo 
       get():
           if valid-handle(mDefaultBuffer) then 
               return mDefaultBuffer:serialize-name.
           return "".       
       end.        

   define public property Error as error no-undo get.
              
   /** defines the databinding context (or scope?) for the instance.
       Used in Equals() to check entities with the same keys not 
       are equals if different context */
   define protected property Context  as IDataAdminContext no-undo 
       get. 
       protected set(cntxt as IDataAdminContext ):     
           
           mDefaultBuffer = cntxt:TableHandle:default-buffer-handle.
           mDataset = cntxt:DatasetHandle.        
           
           /* NewContext creates and positions this when we are moved/created in 
              another context  */
           if not valid-handle(mBuffer) then
           do:
               if not mDefaultBuffer:avail then 
                   cntxt:Find(name). 
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
           do:
               Context:RowDeleted:Unsubscribe(RowDeleted).
               Context:AddedToContext:Unsubscribe(NewContext).
           end.
           Context = cntxt.  
           Context:AddedToContext:Subscribe(NewContext).
           Context:RowDeleted:Subscribe(RowDeleted).   
       
       end.
 
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
    
    /** Tells whether the instance is in a collection or service 
        If false then the instance can be passed to the service:Create<Type> method */
    define public property Attached as logical no-undo 
        get():
            /** a context with Rootid belongs to a single instance and 
               (this one ) and is thus not attached */  
            return valid-object(Context) and Context:RootId = ?. 
            /*            and Context:IsLocalShared = false*/
                                               
        end.      
        
     /** Tells whether the instance is newly created (not saved to service). 
         Always true if Attached is false. Modified is always false when Created is true  */
     define public property Created as logical no-undo           
        get().
            if Attached and valid-handle(mbuffer) then
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
   
    define public property RequestInfo as IRequestInfo no-undo get. protected set.
   
    constructor public Entity (cntxt as IDataAdminContext):
        super ().    
        Context = cntxt.
    end constructor.
    
    constructor public Entity (cntxt as IDataAdminContext,preq as IRequestInfo):
        this-object(cntxt).    
        RequestInfo = preq.
    end constructor.
     
    constructor public Entity (pname as character):
        define variable localcntxt as IDataAdminContext no-undo.
        super ().
        localcntxt = CreateLocalContext().
        if valid-object(localcntxt) then
        do:
            localcntxt:CreateRootRow(pname).
            Context = localcntxt. 
            mLocalContext = localcntxt.
        end.
        else 
            Name = pname.     
    end constructor. 
    
    /* return local contaxt if needed (if entity has child collections).  */ 
    method protected abstract IDataAdminContext CreateLocalContext().
    
    method protected logical SetProperty(pcPropName as char, pcValue as char):
         return context:SetProperty(mBuffer:rowid,pcPropName,pcValue).  
    end method.    
    
    /** use IRow to pass state and info 
        @todo deprecate the overloads below this */
    method protected IDataAdminCollection GetChildCollection(pcchild as char):
        define variable childReq as IRequestInfo no-undo.
        define variable rowInfo as IRow no-undo.    
        rowInfo = new RowBuffer(mBuffer,if Attached then ? else row-created, Context:KeyFields).
        if valid-object(RequestInfo) then
        do:
            childReq = RequestInfo:Get(pcchild). 
            if valid-object(childReq) then
               return Context:GetChildCollection(rowInfo,childReq).
        end.     
        return Context:GetChildCollection(rowInfo,pcchild).          
    end method.
        
    method protected IDataAdminCollection GetChildcollection(pcKey as char,pcchild as char):
        define variable childReq as IRequestInfo no-undo.
        if valid-object(RequestInfo) then
        do:
            childReq = RequestInfo:Get(pcchild). 
            if valid-object(childReq) then
               return Context:GetChildCollection(pcKey,childReq).
        end.     
        return Context:GetChildCollection(pcKey,pcchild).
          
    end method.
    
    method protected IDataAdminCollection GetChildcollection(piKey as int,pcchild as char):
        define variable childReq as IRequestInfo no-undo.
        if valid-object(RequestInfo) then
        do:
            childReq = RequestInfo:Get(pcchild). 
            if valid-object(childReq) then
               return Context:GetChildCollection(piKey,childReq).
        end.     
        return Context:GetChildCollection(piKey,pcchild).
          
    end method.
    
    method protected IDataAdminCollection GetChildcollection(pcKeys as char extent,pcchild as char):
        define variable childReq as IRequestInfo no-undo.
        if valid-object(RequestInfo) then
        do:
            childReq = RequestInfo:Get(pcchild). 
            if valid-object(childReq) then
               return Context:GetChildCollection(pcKeys,childReq).
        end.     
        return Context:GetChildCollection(pcKeys,pcchild).
          
    end method.
    
    /* the context we attached to changed */
    method protected void NewContext(cntxt as IDataAdminContext):
        define variable hNewDefaultBuffer as handle no-undo. 
        define variable hNewBuffer as handle no-undo. 
        hNewDefaultbuffer = cntxt:TableHandle:default-buffer-handle.
        create buffer hNewBuffer for table hNewDefaultbuffer.
        hNewBuffer:serialize-name = hNewDefaultbuffer:serialize-name.
        
        hNewBuffer:find-unique ("where " + cntxt:GetKeyWhere(GetKeyValues())).
/*        if Context:IsLocalShared then*/
/*        do:                          */
/*            mbuffer:buffer-delete.   */
/*        end.                         */
        delete object mbuffer no-error.
        mBuffer = hNewBuffer.      
        
        Context = cntxt.
    end method.
    
    /* the context we attached to deleted something changed */
    method protected void RowDeleted():   
        if not mbuffer:avail  then
        do:
            delete object this-object.  
        end.
    end method.
    
    method public void Attach(cntxt as IDataAdminContext):   
        define variable oldcntxt as IDataAdminContext no-undo.
        define variable lLocal as logical no-undo.
        if not valid-object(cntxt) then
            undo, throw new UnknownValueError("Attach","context").  
        
        if ContextId = "" then
        do: 
            mChild = true.
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
        and (oldcntxt = mLocalContext 
             or llocal) then
            delete object oldcntxt.
       
    end method.  
    
    method public void WriteTree(tree as IContextTree):
        undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method.
  
    method public void WriteTree(tree as IContextTree,pcCollections as char):
        undo, throw new UnsupportedOperationError("WriteTree to ContextTree - collection").        
    end method.
    
    method public void Export():
        Export("entity.json").
    end method.          
    
    method public void ExportTree(pcfile as char):
        mdataset:write-json ("File",pcFile,yes).     
    end method.     
    
    method public void ExportTree(pcfile as char,pcCollectionlist as char):
        undo, throw new UnsupportedOperationError("ExportTree " + quoter(pcCollectionlist)).       
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
        
        finally:
            delete object htbl no-error.
        end finally.
    end method.
    
    method public void ImportTree(pcFile as char). 
        define variable tree as IContextTree no-undo.
        tree = new ContextTree(). 
        WriteTree(tree).
        Context:ImportRowTree(pcfile,GetKeyValues()).
    end method. 
    
    /* @TODO - call context:ImportRow with GetKeyValue() and remove all override  */
    method public void  Import(cFile as char):
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Import to  " + this-object:GetClass():TypeName).
        end.
        Context:ImportRow(cFile,GetKeyValues()).
    end method. 
    
    /** @todo - deprecate - use GetKeyValues 
         workaround due to inconsistent key definition (and property reflection) 
         override in classes that does not use name */
    method protected char GetKeyValue():
        define variable hFld as handle no-undo.
        if valid-object(Context) and valid-handle(mBuffer) then
        do:
            if num-entries(Context:KeyFields) > 1 then
                undo, throw new IllegalOperationError("GetKeyValue called in " + this-object:GetClass():ToString() + " with Keyfields " + Context:KeyFields).
            hFld = mBuffer:buffer-field (Context:KeyFields).
            return string(hfld:buffer-value).
        end.   
        return this-object:Name.
    end method.
    
    /** currently trying to avoid single element integer keys 
        (ok in multiple keys)
    method protected char GetKeyType():
        return "character".
    end method.
     
    method protected char GetKeyIntValue():
        return this-object:Name.
    end method.
    **/
    
    method protected character extent GetKeyValues():
        define variable cKey as character no-undo.
        define variable hFld as handle no-undo. 
        define variable i as integer no-undo.
        define variable cValues as char extent no-undo.
        
        /* the assumption is that only single key objects will need this without 
           context */
        if valid-object(Context) = false then
        do:
            extent(cValues) = 1.
            cValues[1] = GetKeyValue().
        end.        
        else do:   
            extent(cValues) = num-entries(Context:KeyFields).
            
            do i = 1 to num-entries(Context:KeyFields):
                hFld = mBuffer:buffer-field (entry(i,Context:KeyFields)).
                cValues[i] = string(hfld:buffer-value).
            end.    
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
            if num-entries(cKeyFields) = 1 then
            do:
                 
                cOut = cOut + " " + GetKeyValue().
            end.
            else 
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

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	/**
	destructor public Entity ( ):
	    /* the record has beem deleted... *
        if valid-object(Context) and Context:Rootid <> ?  = mbuffer:rowid then
            delete object Context.
            
        else */
        
         if valid-object(Context) and Context:IsLocalShared 
             and valid-handle(mBuffer) and mbuffer:avail then
            
            mbuffer:buffer-delete().    
	end destructor.
     **/
     /*     
    method private character GetKeyWhere(phHandle as handle):
        return GetKeyWhere(phHandle,"").
    end method. 

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
 
end class.
 
