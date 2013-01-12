/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
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
    Created     : Wed Jun 23 22:05:15 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
 
using OpenEdge.DataAdmin.AbstractSchemaElement from propath.
using OpenEdge.DataAdmin.ITable from propath.  
using OpenEdge.DataAdmin.IField from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Binding.IndexContext from propath.

class OpenEdge.DataAdmin.FieldImpl final  inherits AbstractSchemaElement  implements IField : 
          
    define public property Table as ITable no-undo 
        get():
            if not valid-object(this-object:Table) and valid-handle(mBuffer) and valid-object(Service) then
            do:
                 this-object:Table = service:GetTable(mBuffer::Tablename). 
            end.
            return this-object:Table.
        end.
        private set.     
             
    define public override property ObjectType as character no-undo 
        get():
            return "Field". 
        end.
    
   define public property DataType as character no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::DataType.
            else
                return DataType. 
        end.  
                    
      
   
   /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
        
    constructor public FieldImpl ( cntxt as IDataAdminContext ):
        super (cntxt).
    end constructor.
    
    
       
    method public override void Export():
        Export("fields.json").
    end method.          
    
    /* No local context needed - currently not used to create    */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
     
 end class.