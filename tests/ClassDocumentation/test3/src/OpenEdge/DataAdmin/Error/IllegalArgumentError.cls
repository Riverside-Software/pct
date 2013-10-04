/*************************************************************/
/* Copyright (c) 2010,2012 by progress Software Corporation  */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Illegal argument should be thrown when there is something
                  wrong with the arguments/parameters passed to a method. 
                  This is different than IllegalOperationError, which should be 
                  thrown when a method cannot be called, for example due to the 
                  state of the object
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Jul 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Error.DataAdminError.

class OpenEdge.DataAdmin.Error.IllegalArgumentError inherits DataAdminError: 
    constructor public IllegalArgumentError (pmsg as char):  
        super("Illegal argument: " + pmsg).
    end method. 
    
    constructor public IllegalArgumentError (pmsg as char, e as Error):  
        super("Illegal argument: " + pmsg,e).
    end method. 
    
        
end class.
