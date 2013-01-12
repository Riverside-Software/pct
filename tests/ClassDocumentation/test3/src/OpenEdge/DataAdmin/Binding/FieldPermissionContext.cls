 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : FieldPermissionContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.FieldPermission from propath.
using OpenEdge.DataAdmin.FieldPermissionSet from propath. 
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.FieldPermissionContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/fieldpermission.i}
     
    define private dataset dsFieldPermission serialize-name "root" for ttFieldPermission.
    define buffer bFieldPermission for ttFieldPermission.
    define temp-table copyFieldPermission reference-only like ttFieldPermission .  
 
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsFieldPermission:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttFieldPermission:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return TableHandle:default-buffer-handle:Keys. 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bFieldPermission for ttFieldPermission.
            if Count = ? then
            do:
                Count = 0.
                for each bFieldPermission:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
        
        
    constructor public FieldPermissionContext (pscope as IServiceContextFactory):
        super ("FieldPermission",pscope).
    end constructor.
    
   
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy FieldPermission").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create FieldPermission row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "tablePermissions" then 
                 return "Name,TableName".
        end.
        return "".
    end.
    
    method override public void WriteTo( input writer as IContextWriter ):
        super:WriteTo(input writer).
    end method.
   
	method public override logical CanFind(name as character):
        undo, throw new UnsupportedOperationError("CanFind of FieldPermission with single key.").
    end.    

    method public  logical CanFind(ptable as char,pname as character):
        return can-find(ttFieldPermission 
                       where ttFieldPermission.Tablename = pTable
                       and ttFieldPermission.name = pname).            
    end.    
    
    method public override logical Find(name as character):
        undo, throw new UnsupportedOperationError("Find of FieldPermission with single key.").
    end.   
     
    method public logical Find(ptable as char,pname as character):
        find ttFieldPermission where ttFieldPermission.Tablename = pTable
                               and ttFieldPermission.name = pname no-error.
        return avail ttFieldPermission.            
    end.   
     
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new FieldPermissionSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new FieldPermission(cntxt).
    end method.

/*    method public override void DataRefreshed(pResponse as OpenEdge.DataAdmin.Message.IFetchResponse):*/
/*        super:DataRefreshed(pResponse).                                                               */
/*        ShowPartitionData().                                                                          */
/*    end method.                                                                                       */
/*                                                                                                      */
/*    method protected void ShowPartitionData():                                                        */
/*        current-window:width = 200.                                                                   */
/*        for each ttFieldPermission with width 200:                                                    */
/*            display                                                                                   */
/*               ttFieldPermission.TableName                                                            */
/*               ttFieldPermission.Name                                                                 */
/*               .                                                                                      */
/*        end.                                                                                          */
/*                                                                                                      */
/*    end method.                                                                                       */
end class.
