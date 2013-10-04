/*************************************************************/
/* Copyright (c) 2010,2012 by progress Software Corporation  */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Unsupported operation error should be thrown when an operation
                  is not supported, implying that it may be supported in the future 
                  There is also an IllegalOperationError, which is slightly 
                  stronger/sticter and should be thrown when a method cannot be 
                  called for example due to the state of the object
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Jul 04 09:07:13 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 
using Progress.Lang.* from propath.
using Progress.Lang.AppError from propath.
using OpenEdge.DataAdmin.Error.DataAdminError.


class OpenEdge.DataAdmin.Error.UnsupportedOperationError inherits DataAdminError: 
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    constructor public UnsupportedOperationError (msg as char, e as Error ):
        
        super ("Unsupported operation" 
               + if msg <> "" then ": " + msg else "",e).
        HTTPErrorNum = 501. /*501 not implemented */       
    end constructor.
    
	constructor public UnsupportedOperationError (msg as char ):
	    this-object(msg,?).   
	end constructor.
   
    constructor public UnsupportedOperationError (  ):
        this-object("").
    end constructor.
end class.
