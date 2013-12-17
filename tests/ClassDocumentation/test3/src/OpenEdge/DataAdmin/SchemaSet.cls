 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SchemaMap
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Jun 11 19:37:03 EDT 2010
    Notes       : This collection is not used/supported in the ABL API, 
                  since the only supported record is PUB and the 
                  DataAdminService GetTable(s) ando GetSequence(s) returns 
                  only data for PUB. If other schemas than PUB is to be 
                  supported it will likely be done with separate requests 
                  i.e. GetSQLTable(s) or GetSysTable(s)
                - The collecton is used for REST to allow a unique key to 
                  lookup table (or a table's index or field) and sequence.  
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.  
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.
 
class OpenEdge.DataAdmin.SchemaSet inherits DataAdminCollection implements ISchemaSet: 
    
    /* schemas is only supported in REST  
    constructor SchemaSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
    */
    constructor SchemaSet(cntxt as SchemaContext):
        super(cntxt).  
    end constructor. 
    
    constructor SchemaSet(cntxt as SchemaChanges):
        super(cntxt).  
    end constructor. 
    
    constructor SchemaSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        undo, throw new UnsupportedOperationError("CreateLocalContext for SchemaSet").
    end.     
            
    method public logical CanFind(cname as char):
        undo, throw new UnsupportedOperationError("CanFind in SchemaSet").
    end method.
    
    method public ISchema Find(cname as char):
        undo, throw new UnsupportedOperationError("Find in SchemaSet").        
    end method.
       
    method public override logical Contains(obj as Object):
        undo, throw new UnsupportedOperationError("Contains in SchemaSet"). 
    end method.
    
    method public logical Contains(schemaImp as ISchema):
        undo, throw new UnsupportedOperationError("Contains in SchemaSet").
    end method.
     
	method override protected void PrepareExport(  ):
    end method.

	method override protected void PrepareExportTree(  ):
	end method.
	
	method override protected void PrepareExportList(  ):
	end method.
        
end class.
