/*************************************************************/
/* Copyright (c) 2011,2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Wraps info about a row for interobject messages/events
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Oct 08 15:09:48 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.RowBuffer implements IRow: 
	define private variable mBuffer as handle no-undo.
    define private variable mState as integer init ? no-undo.
    /** SerializeName is used in child and parent defintitions  */
    define public property SerializeName as character no-undo 
        get.
        private set. 
    
    /** is  - true means that values are not refrehsed 
            - use for message only don't store  */
    define public property IsSnapShot as logical no-undo 
        init false
        get. 
        
  	define public property Created as logical no-undo 
	    get():
	        if mState <> ? then
	             return mstate = row-created.
	        return mBuffer:row-state = row-created.    
	    end.
	   
    define public property Modified as logical no-undo 
        get():
            if mState <> ? then
                 return mstate = row-modified.
            return mBuffer:row-state = row-modified.    
        end.
       
	define public property FieldNames as character no-undo
	    init ? 
	    get():
	        define variable i as integer no-undo.
	        if FieldNames = ? then
	        do: 
	            do i = 1 to mbuffer:num-fields:
	                FieldNames = FieldNames 
	                           + (if i = 1 then "" else ",")
	                           + mbuffer:buffer-field(i):name.
	            end.    
	        end.    
	       return FieldNames.     
	    end.
	    private set. 

	define public property KeyFields as character no-undo 
	    get.
	    private set. 
	   
    /** returns the value that correspond to a single entry KeyFields for this row */
    define public property KeyValue as character  no-undo init ? 
        get.
        private set. 
       
    /** returns the integer value that correspond to a single entry KeyFields for this row */
    define public property KeyIntValue as integer  no-undo init ? 
        get.
        private set. 
    
    define public property KeyValues as character extent no-undo 
       get.
       private set. 

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    
    constructor public RowBuffer (pBuffer as handle,pstate as int,pKeyFields as char):
        this-object(pbuffer,pKeyFields).
        mstate = pState.   
    end method.
    
    constructor public RowBuffer (pBuffer as handle,pKeyFields as char):
        super().
        
        if not valid-handle(pBuffer) then
            undo, throw new UnknownValueError("RowImpl constructor","buffer-handle").
        if pBuffer:avail = false then 
            undo, throw new IllegalArgumentError("Buffer passed to RowImpl is not available.").
        KeyFields = pKeyFields.           
        SetKeyValues(pBuffer,pKeyFields).
        create buffer mBuffer for table pbuffer.
        SerializeName = pBuffer:serialize-name.
        mBuffer:find-by-rowid(pBuffer:rowid). 
    end constructor.
    
    constructor public RowBuffer (hBuffer as handle,pKeyFields as char,pFieldNames as char):
        this-object (hBuffer,pKeyFields).
        FieldNames = pFieldNames. 
    end constructor.
    
    constructor public RowBuffer (hBuffer as handle,pState as int,pKeyFields as char,pFieldNames as char):
        this-object (hBuffer,pState,pKeyFields).
        FieldNames = pFieldNames. 
    end constructor.
    
    method private char SetKeyValues(pBuffer as handle,pnames as char):
         define variable hField as handle no-undo. 
         define variable i as integer no-undo.
        
         if pnames = "" or pnames = ? then
             undo, throw new UnknownValueError("KeyFields vas not passed RowBuffer constructor.").
        
         /* the assumption is that only single key objects will need this without 
            context */
         if num-entries(pnames) = 1 then
         do:
             extent(KeyValues) = 1.
             hField = pBuffer:buffer-field(pnames).
             if hfield:data-type = "character" then
                KeyValue = hField:buffer-value.  
             else if hfield:data-type = "integer" then
                KeyIntValue = hField:buffer-value.  
             KeyValues[1] = hField:buffer-value.
         end.    
         else do:   
             extent(KeyValues) = num-entries(pnames).
             do i = 1 to num-entries(pnames):
                 hField = pBuffer:buffer-field (entry(i,pnames)).
                 KeyValues[i] = hField:buffer-value.
             end.    
         end. 
         catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("KeyFields does not match buffer. Error:  " + e:GetMessage(1)).  
         end catch. 
    end method. 
    
	method public character FieldValue( pcColumn as character ):
		define variable ifld as integer no-undo.
		define variable hfld as handle no-undo.
        if FieldNames = ? or lookup(pcColumn,FieldNames) > 0 then
        do:
            hFld = mBuffer:buffer-field(pccolumn) no-error.
            if valid-handle(hFld) then 
                 return hFld:buffer-value.
        end. 
        undo, throw new IllegalArgumentError("Invalid field name " + quoter(pccolumn) + " passed to FieldValue().").
	end method.
 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	destructor public RowBuffer ( ):
        delete object mbuffer no-error.
	end destructor.

end class.