/*************************************************************/
/* Copyright (c) 2012 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Illegal operation should be thrown when a method cannot be called, 
                  for example due to the state of the object
                  This is different than IllegalArgumentError, which should be used 
                  when there is something wrong with the arguments. 
                  This is also different than UnsupportedOperationError, which 
                  implies it could be supported in the future.        
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Jul 2012
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Error.DataAdminError.

class OpenEdge.DataAdmin.Error.IllegalOperationError inherits DataAdminError: 
    constructor public IllegalOperationError (pmsg as char):  
        super("Illegal operation: " + pmsg).
    end method. 
    
    constructor public IllegalOperationError (pmsg as char, e as Error):  
        super("Illegal operation: " + pmsg,e).
    end method. 
    
        
end class.
