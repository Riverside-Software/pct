 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : abstract class for table,field and index
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Aug 05 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.ISchemaPartitionMap from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.AbstractSchemaElement  inherits Entity abstract implements ISchemaElement: 
    
    /** currently only PUB */
    define public property Schema as ISchema no-undo 
        get():
            if valid-handle(mBuffer) and valid-object(Service) 
            and mBuffer::SchemaName = "PUB" then 
                return Service:GetSchema().       
            return ?.          
        end.    
        
    define public property Area as IArea no-undo 
        get():
            if not valid-object(Area) then
            do: 
                if valid-handle(mBuffer) and mBuffer::AreaName > "" 
                and valid-object(Service) then do:
                   if mbuffer::AreaName > "" then 
                        Area = Service:GetArea(mBuffer::AreaName).            
                end. 
            end. 
            return Area.
        end.    
        private set.
    
    define public abstract property ObjectType as character no-undo 
        get.
    
    define public property Partitions as ISchemaPartitionMap no-undo  
        get():
            if not valid-object(Partitions) then
            do:
                if num-entries(Context:KeyFields) > 1 then 
                     Partitions = cast(GetChildCollection(GetKeyValues(),"partitions"),ISchemaPartitionMap).
                else
                     Partitions = cast(GetChildCollection(name,"partitions"),ISchemaPartitionMap).
           end.     
           return Partitions.
        end.
        private set.
    
    define public property Description as char no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Description.
             return Description.
        end.    
        
	constructor public AbstractSchemaElement (name as character ):
		super (input name).
	end constructor.
	
	constructor public AbstractSchemaElement (cntxt as IDataAdminContext ):
		super (input cntxt).
	end constructor.

    constructor public AbstractSchemaElement (cntxt as IDataAdminContext,pReq as IRequestInfo ):
        super (cntxt,pReq).
    end constructor.

end class.