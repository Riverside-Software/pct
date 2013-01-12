/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TableSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Jun 11 19:37:03 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.  
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath. 
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Binding.OptionContext from propath.
using OpenEdge.DataAdmin.Core.JSONLoader from propath.
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath.
class OpenEdge.DataAdmin.TableSet inherits DataAdminCollection implements ITableSet : 
      
   /** currently only PUB supported */
    define public property Schema as ISchema no-undo 
        get():
            if valid-object(Service) then 
                return Service:GetSchema().       
            return this-object:Schema.          
        end.    
            
    define public property ForceAllocation as char no-undo 
        get. 
        private set(force as char):
            if lookup(force,"All,Delayed,") = 0 then 
                undo, throw new InvalidPropertyValueError("ForceAllocation",force,"All,Delayed,").
        end.  
   
    define private property OptionContext as OptionContext no-undo 
        get():
            if not valid-object(OptionContext) then 
            do:
                OptionContext = new OptionContext( ).
/*              OptionContext:TableHandle:default-buffer-handle:buffer-create().*/
            end.
            return OptionContext.    
        end. 
          
        set.
    
    constructor TableSet(cntx as IDataAdminContext):
        super(cntx).     
    end constructor.   
         
    method protected override IDataAdminContext CreateLocalContext():
        return new TableContext().
    end.      
     
    method public logical CanFind(tablename as char):
           return Context:CanFind(tablename).
    end method.
    
     method public ITable Find(tablename as char):
        return cast(Context:FindEntity(tablename),ITable). 
    end method.
    
     /* write specified collections (default all) */
    method public override void WriteTree(tree as IContextTree,pcCollections as char):
        if lookup("options",pcCollections) > 0 then
        do:
             OptionContext:AddTableTo(tree). 
        end.
        if lookup("partitions",pcCollections) > 0 then
        do:
            context:AddTreeTo(tree,"partitions").
        end.    
    end method.
    
    method public override void ImportTree(pcFile as char). 
        define variable reader as JSONLoader no-undo.        
        reader = new JSONLoader().
        reader:LoadFromFile(this-object,pcfile,"Replace").  
    end method. 
    
    method public void ImportTree(pcfile as char,pcCollections as char):        
        define variable reader as JSONLoader no-undo.        
        reader = new JSONLoader().
        reader:LoadFromFile(this-object,pcfile,"replace",pcCollections).  
        if lookup("options",pcCollections) > 0 then
        do:
            SetOptions().
        end.      
    end method.     
    
    method public override logical Contains(obj as Object):
        define variable tbl as ITable no-undo. 
        tbl = cast(obj,ITable).
        return contains(tbl).
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.

    method public logical Contains(tableImp as ITable):
        if tableImp:ContextId <> ContextId then 
            return false.
        return CanFind(tableImp:name).  
    end method. 
   
    method override protected void PrepareExport(  ):
    end method.

    method override protected void PrepareExportTree(  ):
    end method.
    
    method override protected void PrepareExportList(  ):
    end method.
   
    method private void SetOptions():
        define variable hbuffer as handle no-undo.
        hBuffer = OptionContext:TableHandle:default-buffer-handle.
        hBuffer:find-first().
        ForceAllocation = hbuffer::ForceAllocation.
    end method.
   
end class.
