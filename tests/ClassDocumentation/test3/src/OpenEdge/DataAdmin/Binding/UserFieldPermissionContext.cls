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

using Progress.Json.ObjectModel.JsonObject from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.UserFieldPermission from propath.
using OpenEdge.DataAdmin.UserFieldPermissionSet from propath. 
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.UserFieldPermissionContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/userfieldpermission.i}
     
    define private dataset dsUserFieldPermission serialize-name "root" for ttUserFieldPermission.
    
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsUserFieldPermission:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttUserFieldPermission:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "UserRef,TableName,Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bPermission for ttUserFieldPermission.
            if Count = ? then
            do:
                Count = 0.
                for each bPermission:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public UserFieldPermissionContext (pScope as IContextScope):
        super ("UserFieldPermission",pScope).
    end constructor.
    
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy UserFieldPermission").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create UserFieldPermission row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "userTablePermissions" then 
                 return "UserRef,UserRef,name,TableName".
        end.
        return "".
    end.
    
    method override public void WriteTo( input writer as IContextWriter ):
        super:WriteTo(input writer).
    end method.
   
	method public override logical CanFind(name as character):
        undo, throw new UnsupportedOperationError("CanFind of UserFieldPermission with single key.").
    end.    
    
    method public  logical CanFind(ptable as char,pname as character):
        return can-find(ttUserFieldPermission 
                       where ttUserFieldPermission.Tablename = pTable
                       and ttUserFieldPermission.name = pname).            
    end.    
     
    method public override logical Find(name as character):
      undo, throw new UnsupportedOperationError("Find of UserFieldPermission with single key.").
    end.   
    
    method public logical Find(puserref as char,ptable as char,pname as character):
        find ttUserFieldPermission where ttUserFieldPermission.UserRef = pUserRef
                                   and   ttUserFieldPermission.Tablename = pTable
                                   and   ttUserFieldPermission.name = pname no-error.
        return avail ttUserFieldPermission.            
    end.
                                    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new UserFieldPermissionSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new UserFieldPermission(cntxt).
    end method.
    
    method public JsonObject GetJsonObjects(pcParent as char,hSerializebuffer as handle):
        define variable jsonRoot  as JsonObject no-undo.    
        define variable hField    as handle no-undo. 
       
        jsonRoot   = new JsonObject().   
        
        for each ttUserFieldPermission where ttUserFieldPermission.Tablename = pcParent:        
            hField = hSerializebuffer:buffer-field(ttUserFieldPermission.name).  
            if hField:serialize-hidden = false and not hfield:name matches "*url" then
            do:
                hField = hSerializebuffer:buffer-field(ttUserFieldPermission.name).    
                jsonRoot:Add(hField:serialize-name,GetJsonProperties()). 
            end.
        end.    
        return Jsonroot.
    end method.
    
    method public JsonObject  GetJsonProperties():
        define variable json  as JsonObject no-undo.    
        define variable jsonfields  as JsonObject no-undo.    
        json   = new JsonObject(). 
        json:Add("canRead",ttUserFieldPermission.CanRead).  
        json:Add("canWrite",ttUserFieldPermission.CanWrite). 
        return json.
    end method.
    
    method public void  JsonList(pjson as JsonObject,pcParent as char):
        define variable json  as JsonObject no-undo.    
        define variable jsonfields  as JsonObject no-undo.    
        define variable cName as character no-undo. 
        json   = new JsonObject().   
        for each ttUserFieldPermission where ttUserFieldPermission.Tablename = pcParent:        
            json   = new JsonObject().
            cName = lc(substr(ttUserFieldPermission.name,1,1)).
            cName = cName + substr(ttUserFieldPermission.name,2).
        
            pjson:Add(cName,json). 
            json:Add("canRead",ttUserFieldPermission.CanRead).  
            json:Add("canWrite",ttUserFieldPermission.CanWrite). 
        end.    
     
    end method.
end class.
