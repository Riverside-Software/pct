 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Option for Schema definitions 
                      
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 2010
    Notes       : 
   ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.

using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Binding.DataFileContext inherits DataAdminContext implements IDataAdminContext: 
    
   {daschema/filestatus.i}
       
    define private dataset dsfilestatus serialize-name "root" for ttfilestatus.
    
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsfilestatus:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttfilestatus:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "FileName". 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bschema for ttfilestatus.
            if Count = ? then
            do:
                Count = 0.
                for each bschema:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public DataFileContext ():
        super ("DataFile").
    end constructor.
        /*
	constructor public OptionContext ( service as DataAdminService):
		super ( "Options",service).
	end constructor.
	*/
/*	method public void LoadInstances().                                           */
/*        undo, throw new UnsupportedOperationError("Load instances for Schema").*/
/*    end method.                                                                */
/*                                                                               */
/*    method protected void UnLoadInstances().                                   */
/*        undo, throw new UnsupportedOperationError("Load instances for Schema").*/

	method public void DataRefreshed( input pResponse as OpenEdge.DataAdmin.Message.IUtilityResponse ):
		define variable i as integer no-undo.
        define variable TblResponse as ITableResponse no-undo.
        define variable hNewBuffer  as handle no-undo.
        /*            hds:copy-dataset(hCopy,yes,yes).*/
        Service = pResponse:service.
        TblResponse = pResponse:GetTableResponse(TableHandle:Name).
        if valid-object(TblResponse) then
        do:
            hNewBuffer = pResponse:DataHandle:get-buffer-handle (TableHandle:Name).              
            if hNewBuffer:table-handle <> Tablehandle then
            do:
                Tablehandle:copy-temp-table(hNewBuffer,yes,yes).
            end.
            /* refresh queries */
            FireContextRefreshed(TblResponse).
         end.           
	end method.

	method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
	method public override void CopyTable(cntxt as IDataAdminContext).
	    undo, throw new UnsupportedOperationError("Copy DataFile").
	end method. 
     
	method public override void CreateRow(entity as IDataAdminElement):
	    undo, throw new UnsupportedOperationError("Create DataFile row").
	end method. 
    
    method public override logical Find(pname as character):
         find ttFileStatus where ttFileStatus.FileName = pname no-error.
         return avail ttFileStatus.
    end.    
     
    method public override logical CanFind(pname as character):
        return can-find(ttFileStatus where ttFileStatus.FileName = pname).
    end.    
    
    method public override logical Find(pnum as int):
         find ttFileStatus where ttFileStatus.TableSequence = pnum  no-error.
         return avail ttFileStatus.
    end.    
     
    method public override logical CanFind(pnum as int):
        return can-find(ttFileStatus where ttFileStatus.TableSequence = pnum).
    end.    
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new DataFileList(cntxt) .
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new DataFile(cntxt) .
    end method.
        
end class.
