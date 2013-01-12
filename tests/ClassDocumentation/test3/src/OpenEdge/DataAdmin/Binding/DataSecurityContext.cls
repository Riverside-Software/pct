 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : DataSecurityContext
    Purpose     : Contains table and field permissions 
                  with the schema as the parent
                      
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : The Schema name is part of the unique key for tables 
                  and sequences in Data Dictionary.   
                - This context is not used/supported in the ABL API, 
                  since the only supported record is PUB and the 
                  DataAdminService GetTable(s) ando GetSequence(s) returns 
                  only data for PUB.  
               -  The context is used for REST to allow a unique key to 
                  lookup table (or a table's index or field) and sequence.  
   ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.

using OpenEdge.DataAdmin.Error.* from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.

class OpenEdge.DataAdmin.Binding.DataSecurityContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/schema.i}    
 
    define private dataset dsSchema serialize-name "root" for ttSchema .
           
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then
                DatasetHandle = CreateDataset().
            return DatasetHandle.
        end get.
        private set. 
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttSchema:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bschema for ttSchema.
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
    
    constructor public DataSecurityContext ():
        super ("DataSecurity").     
    end constructor.
        
	 
                                                            
    constructor public DataSecurityContext ( pscope as IServiceContextFactory):
        super ("DataSecurity",pscope).
        pscope:TablePermissionContext:Lazy = false.
        AddChild(pscope:TablePermissionContext). 
        define variable hField as handle no-undo.
        hField = TableHandle:default-buffer-handle:buffer-field("TablesUrl").
        hfield:serialize-hidden = true. 
    end constructor.
                         
    
    
	method public override character GetJoinFields(parentid as char):
	   
        return "".
      
    end.
    
    method public override void CopyTable(cntxt as IDataAdminContext):
        undo, throw new UnsupportedOperationError("CopyTable DataSecurity row").
	end method.
	
	method public override void CreateRow(entity as IDataAdminElement):
	    undo, throw new UnsupportedOperationError("Create DataSecurity row").
	end method. 
    
    method public override logical CanFind(name as character):
        return can-find(ttSchema where ttSchema.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttSchema where ttSchema.name = name no-error.
        return avail ttSchema.            
    end.    
    
/*    method public override void MergeChanges(pResponse as ISaveRequest).*/
/*                                                                        */
/*    end method.                                                         */
    
/*    method public override void MergeChanges(pResponse as ISaveRequest).*/
/*                                                                        */
/*        if not valid-object(pResponse) then                             */
/*            undo, throw new UnknownValueError("MergeChange","response").*/
/*                                                                        */
/*        MergeChanges(SaveDataset,pResponse:DataHandle).                 */
/*    end method.                                                         */
    
    
/*    method public void showtables():            */
/*        define variable cc as character no-undo.*/
/*        for each ttTable:                                                     */
/*            cc = cc + ttTable.name + chr(10).                                 */
/*                                                                              */
/*        end.                                                                  */
/*        for each ttField:                                                     */
/*            cc = cc + ttField.Tablename + "." + ttfield.name + chr(10).       */
/*        end.                                                                  */
/*        for each ttIndex:                                                     */
/*            cc = cc + "i " + ttindex.Tablename + "." + ttindex.name + chr(10).*/
/*        end.                                                                  */
/*        for each ttSequence:                                                  */
/*            cc = cc + ttSequence.name + chr(10).                              */
/*                                                                              */
/*        end.                                                                  */
/*                                         */
/*                                         */
/*            message cc view-as alert-box.*/
/*                                         */
/*    end method.                          */
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in DataSecurityContext").
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new DataSecurity(cntxt).
    end method. 
 
       
end class.
