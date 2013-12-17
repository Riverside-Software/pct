/*************************************************************/
/* Copyright (c) 2012 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : ForbiddenOperationError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2012
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 
using Progress.Lang.* from propath.
using Progress.Lang.AppError from propath.
using OpenEdge.DataAdmin.Error.DataAdminError.


class OpenEdge.DataAdmin.Error.ForbiddenOperationError inherits DataAdminError: 
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    constructor public ForbiddenOperationError (msg as char, e as Error ):
        
        super ("Forbidden operation" 
               + if msg <> "" then ": " + msg else "",e).
        HTTPErrorNum = 403. /* Forbidden   */       
    end constructor.
    
	constructor public ForbiddenOperationError (msg as char ):
	    this-object(msg,?).   
	end constructor.
   
    constructor public ForbiddenOperationError (  ):
        this-object("").
    end constructor.
end class.
