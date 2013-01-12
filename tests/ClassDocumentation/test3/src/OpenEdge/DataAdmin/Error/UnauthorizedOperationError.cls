/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UnauthorizedOperationError
    Purpose     : 
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


class OpenEdge.DataAdmin.Error.UnauthorizedOperationError inherits DataAdminError: 
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    constructor public UnauthorizedOperationError (msg as char, e as Error ):
        
        super ("Unauthorized operation" 
               + if msg <> "" then ": " + msg else "",e).
        HTTPErrorNum = 401. /* Unauthorized   */       
    end constructor.
    
	constructor public UnauthorizedOperationError (msg as char ):
	    this-object(msg,?).   
	end constructor.
   
    constructor public UnauthorizedOperationError (  ):
        this-object("").
    end constructor.
end class.
