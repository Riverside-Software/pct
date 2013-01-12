 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TablePermissionContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.TablePermissionSet from propath.
using OpenEdge.DataAdmin.TablePermission  from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
 
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
 
/*using OpenEdge.DataAdmin.Binding.FieldPermissionContext from propath.*/
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.TablePermissionContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/tablepermission.i}
     
    define private dataset dsTablePermission serialize-name "root" for ttTablePermission.
    define buffer bTablePermission for ttTablePermission.
    define temp-table copytable reference-only like ttTablePermission .  
    
    define variable mLastSavedTable as handle no-undo.
     
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then
                DatasetHandle = CreateDataset().
            return DatasetHandle.
        end get.
        private set. 
    
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttTablePermission:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return TableHandle:default-buffer-handle:Keys. 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bTablePermission for ttTablePermission.
            if Count = ? then
            do:
                Count = 0.
                for each bTablePermission:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
	constructor public TablePermissionContext ( pScope as IServiceContextFactory):
        super ("TablePermission",pscope).
        pscope:FieldPermissionContext:lazy = false.
        AddChild(pscope:FieldPermissionContext).
    end constructor.
    
	
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy TablePermission").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create TablePermission row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "schemas" then 
                return "Name,SchemaName".
        end.
    end.
      
    method public override void ExportLastSavedTree( pcfile as char ):
        define variable hDs as handle no-undo.
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().
        if valid-handle(mLastSavedTable) then  
            tree:SetHandle("tables",mLastSavedTable).
        tree:SetJoin("tables","partitions","Name,TableName").    
        
        hDs = tree:GetReadHandle().
        hDs:write-json ("File",pcFile,yes).        
    end method.
      
    method override public void WriteTo( input writer as OpenEdge.DataAdmin.Binding.IContextWriter ):
        super:WriteTo(input writer).
    end method.
   
	method public override logical CanFind(name as character):
        return can-find(ttTablePermission where ttTablePermission.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttTablePermission where ttTablePermission.name = name no-error.
        return avail ttTablePermission.            
    end.    
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new TablePermissionSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new TablePermission(cntxt). 
    end method. 
end class.
