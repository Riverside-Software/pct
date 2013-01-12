/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    File        : OperationError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug  2010
    Notes       : 
  ----------------------------------------------------------------------*/
/* error in error  */
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.DataAdminError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Error.OperationError inherits DataAdminError: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	 
	define  temp-table ttError no-undo 
        field num as int
        field errorobj as Object
        index idxname as unique num.
        	
	constructor public OperationError ( input pmsg as character ):
		super (input pmsg).
	end constructor.
    
    /* all errors are added as messages to the parent */ 
    method public void AddError(e as Error): 
        define variable i as integer no-undo.
        create ttError.
        do i = 1 to e:NumMessages:
            AddMessage(e:GetMessage(i),?).
        end.
        assign ttError.num        = NumMessages - 1.
               ttError.errorobj   = e.              
        
    end method.   
    
    method public Error GetError(i as int):
       
        find ttError where  ttError.num = i  no-error.
        if not avail ttError then 
            return ?. 
        return cast(ttError.errorobj,Error).  
    end method.    
    
end class.
