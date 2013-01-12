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
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Binding.OptionContext inherits DataAdminContext implements IDataAdminContext: 
    
   {daschema/options.i}
       
    define private dataset dsOptions serialize-name "root" for ttOptions
       .
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsOptions:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttOptions:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bschema for ttOptions.
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
    
    constructor public OptionContext ():
        super ("Options").
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
/*    end method.                                                                */
    
	method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
	method public override void CopyTable(cntxt as IDataAdminContext).
	    undo, throw new UnsupportedOperationError("Copy Option").
	end method. 
     
	method public override void CreateRow(entity as IDataAdminElement):
	    undo, throw new UnsupportedOperationError("Create Option row").
	end method. 
    
    method public override logical CanFind(name as character):
         undo, throw new UnsupportedOperationError("CanFind Option").  
    end.    
     
    method public override logical Find(name as character):
        undo, throw new UnsupportedOperationError("Find Option").
    end.    
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in OptionContext").
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        undo, throw new UnsupportedOperationError("CreateEntity in OptionContext").
    end method.
        
end class.
