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
    @Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
 
using OpenEdge.DataAdmin.AbstractSchemaElement from propath.
using OpenEdge.DataAdmin.ITable from propath.  
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.IIndex from propath.
using OpenEdge.DataAdmin.ISchemaPartitionMap from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Binding.IndexContext from propath.

class OpenEdge.DataAdmin.IndexImpl final  inherits AbstractSchemaElement  implements IIndex : 
          
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
            return "Index". 
        end.
           
     /** Readonly property that returns true if the index is active  */
    define public property IsActive      as logical   no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsActive.
            else
                return IsActive.  
        end.  
    
    /** Readonly property that returns true if the index is unique  */
    define public property IsUnique      as logical   no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsUnique.
            else
                return IsUnique. 
        end.  
    
    /** Readonly property that returns true if the index is the primary index  */
    define public property IsPrimary     as logical   no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsPrimary.
            else
                return IsPrimary. 
        end.  
    
    /** Readonly property that returns true if the index is a word index  */
    define public property IsWordIndex   as logical   no-undo    
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsWordIndex.
            else
                return IsWordIndex. 
        end.  
     
         
    /* not supported 
    /** lists all Field of the Index */ 
    define public property Fields as IFieldSet no-undo     
        get():
         end.
        protected set.
    */
        
      
   
   /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public IndexImpl ( cntxt as IDataAdminContext ):
	 	super (cntxt).
	end constructor.
    
    method public override void Export():
        Export("index.json").
    end method.          
    
    /* No local context needed - currently not used to create    */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
     
 end class.