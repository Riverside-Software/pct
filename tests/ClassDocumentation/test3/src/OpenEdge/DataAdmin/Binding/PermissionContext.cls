 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
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

using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.UserTablePermissionSet from propath.
using OpenEdge.DataAdmin.UserTablePermission  from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.UserFieldPermissionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.QueryContext from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.

/*using OpenEdge.DataAdmin.Binding.FieldPermissionContext from propath.*/
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
/*using OpenEdge.DataAdmin.Message.IFetchResponse from propath.*/
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.PermissionContext inherits DataAdminContext implements IDataAdminContext: 
    
    /* currenly using the usertablepermission */
    {daschema/usertablepermission.i}
     
    define private dataset dsTablePermission serialize-name "root" for ttUserTablePermission.  
    define private variable mUsercntxt as UserFieldPermissionContext no-undo.     
    define variable mRequestDataset as handle no-undo.
    define private variable NewFactory as IServiceContextFactory no-undo.     
     
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then
                DatasetHandle = CreateDataset().
            return  DatasetHandle.   
        end get.
        private set.
        
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttUserTablePermission:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bPerm for ttUserTablePermission.
            if Count = ? then
            do:
                Count = 0.
                for each bPerm:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
  
  	constructor public PermissionContext (pscope as IServiceContextFactory):
       
        super ("Permission",pscope).
        mUsercntxt = pscope:GetUserFieldPermissionContext().
        mUsercntxt:Lazy = false.
        AddChild(mUsercntxt).
        NewFactory = pScope.  
    end constructor.
    
	
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy Permission").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create Permission row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
/*        case parentid:                 */
/*            when "userPermissions" then*/
/*                return "Id,UserRef".   */
/*        end.                           */
    end.
    
	method public override logical CanFind(name as character):
        return can-find(ttUserTablePermission where ttUserTablePermission.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttUserTablePermission where ttUserTablePermission.name = name no-error.
        return avail ttUserTablePermission.            
    end.    
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new UserTablePermissionSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new UserTablePermission(cntxt). 
    end method. 
    
	method public IFetchRequest GetRequest(pcCollections as char):
		define variable tree  as ContextTree no-undo.
	    define variable msg   as IFetchRequest no-undo.
	    define variable cntxt as IDataAdminContext no-undo.
    	define variable i as integer no-undo.
    	define variable cvalues as character no-undo.
       
        define variable cwhere as character no-undo.       
        define variable cFieldwhere as character no-undo.       
       
        cWhere = "for each " + TableHandle:name. 
        cFieldWhere = "for each ttUserFieldPermission". 
   
        tree = new ContextTree().
		
		AddTreeTo(tree).
	 	do i = 1 to num-entries(pcCollections):
    	    cntxt = NewFactory:GetContextBySerializeName(entry(i,pcCollections)).	
    	     
	 	    tree:SetHandle(cntxt:TableHandle:serialize-name,cntxt:TableHandle).
            cWhere = cWhere
                    + (if i = 1 then " where " else " or ") 
                    + TableHandle:name + "." + KeyFields 
                    + " = " 
                    + quoter(cntxt:TableHandle:name).	 	
            cFieldWhere = cFieldWhere
                    + (if i = 1 then " where " else " or ") 
                    + "ttUserFieldPermission.TableName " 
                    + " = " 
                    + quoter(cntxt:TableHandle:name).       
        end.
		mRequestDataset = tree:GetReadHandle().
		msg =  new FetchRequest(Name,Id,mRequestDataset).
		msg:SetTableQuery("ttUserTablePermission",cWhere).
        msg:SetTableQuery("ttUserFieldPermission",cfieldWhere).
		msg:UseReplaceOnClient = false.
		return msg.
		
	end method.
    
    method private IDataAdminContext GetContexctBySerializeName(pcName as char).
        return  NewFactory:GetContextBySerializeName(pcname).
      
       end method.
 	          
    method public override IDataAdminCollection GetCollection(filter as char).
        define variable cntxt  as IDataAdminContext no-undo.
        define variable coll   as  IDataAdminCollection no-undo.
        define variable msg    as IFetchRequest no-undo.
        define variable cWhere as character no-undo.
        if valid-object(Service) then   
        do:
            msg = GetRequest(filter).
            cWhere = msg:GetTableQuery("ttUserTablePermission").      
            cntxt = new QueryContext(this-object,cWhere,TableHandle:default-buffer-handle).
             
            if Lazy then
            do:
                FetchData(msg).
            end.
                 
        end.
        else
            cntxt = this-object.
        coll = CreateCollection(cntxt).
        if not valid-object(coll) then 
            undo, throw new UnsupportedOperationError(GetClass():TypeName + ":GetCollection(filter)").     
         return coll.   
    end method.
    
    method public JsonObject GetJsonObjects():
        define variable jsonRoot  as JsonObject no-undo.    
        define variable hBuffer as handle no-undo. 
        define variable cname as character no-undo.
        jsonRoot   = new JsonObject().   
        for each ttUserTablePermission on error undo,throw:        
            hBuffer = mRequestDataset:get-buffer-handle(ttUserTablePermission.name).  
  
/*            cname =  lc(substr(ttUserTablePermission.name,3) + "s") .*/
            jsonRoot:Add(hBuffer:serialize-name,GetJsonProperties(hBuffer)). 
        end.    
        return Jsonroot.
    end method.
    
    method public JsonObject  GetJsonProperties(phSerializebuffer as handle):
        define variable json  as JsonObject no-undo.    
        define variable jsonfields  as JsonObject no-undo.    
        json   = new JsonObject(). 
        json:Add("canRead",ttUserTablePermission.CanRead).  
        json:Add("canWrite",ttUserTablePermission.CanWrite).  
        json:Add("canCreate",ttUserTablePermission.CanCreate).  
        json:Add("canDelete",ttUserTablePermission.CanDelete).  
        json:Add("canLoad",ttUserTablePermission.CanLoad).  
        json:Add("canDump",ttUserTablePermission.CanDump).  
         
        json:Add("fields",mUsercntxt:GetJsonObjects(ttUserTablePermission.name,phSerializebuffer)).
        return json.
    end method.
   
    method public override void ExportNormalized (pcfile as char):
        define variable jsonroot as JsonObject no-undo.    
        jsonroot  = GetJsonObjects().
        jsonroot:WriteFile(pcfile, TRUE).
        delete object mRequestDataset.
    end method.
    
    /* this is needed if UseReplaceOnClient is not set to false in GetRequest 
    method public override void DataRefreshed(pResponse as IFetchResponse): 
         super:DataRefreshed(pResponse).
         if pResponse:EntityName = 'Permission' then
         do:
             create dataset mRequestdataset.
             mRequestdataset:create-like(pResponse:DataHandle).
             mRequestdataset:copy-dataset(pResponse:DataHandle).
         end.
          
    end method.
    */
end class.
