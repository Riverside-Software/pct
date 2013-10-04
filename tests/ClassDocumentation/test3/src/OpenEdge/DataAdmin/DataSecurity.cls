/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : DataSecurity
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 
using Progress.Lang.Object from propath.

using OpenEdge.DataAdmin.Entity from propath.  
using OpenEdge.DataAdmin.DataAdminService from propath.  
using OpenEdge.DataAdmin.IDataSecurity from propath.
using OpenEdge.DataAdmin.ITablePermissionSet from propath.
using OpenEdge.DataAdmin.TablePermissionSet from propath.
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath. 
 

using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataDefinitionOptions from propath.
 
  
class OpenEdge.DataAdmin.DataSecurity inherits Entity implements IDataSecurity, IDataAdminElement, IDataAdminSerializable:  
        
    define public property TablePermissions as ITablePermissionSet     no-undo 
        get():
            define variable h as handle no-undo.
            if not valid-object(TablePermissions) then
            do:
                TablePermissions = cast(Context:GetChildCollection(name,"tablePermissions"),ITablePermissionSet).
            end.
/*            if not mTablesLoaded then*/
/*                FetchTables().       */
            return TablePermissions.     
        end.
        protected set.
   
	constructor public DataSecurity ( cntxt as IDataAdminContext ):
		super (input cntxt).
	end constructor.
		
	constructor public DataSecurity ( name as character ):
		super (input name).		
	end constructor.
    
    /* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
    
    method public void ExportLastSavedTree(pcFile as char). 
        this-object:context:ExportLastSavedTree(pcFile).  
    end method. 
   
    method public override void WriteTree(tree as IContextTree):
         Context:AddTreeTo(tree). 
    end method. 
   
    method private character GetFileExtension(pcfile as char):
        return entry(num-entries(pcfile,"."),pcfile,".").
    end method.
 
end class.
