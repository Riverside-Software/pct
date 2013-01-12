 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : DataContextError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Error.DataContextError inherits DataError: 
    define variable mEntity as char no-undo.	
	
	 /* Adds the message as message 1 and returnvalue. */
    constructor public DataContextError (cMsg as char):
        super (cMsg).
    end constructor.
	
    /* Adds the passed message as message 1 and returnvalue. 
       The error is added as message 2 and inner error */
	constructor public DataContextError (cMsg as char, cEntity as char,  e as error):
        super (cMsg,e).
        mEntity = cEntity.
        AddMessage(e).   
    end constructor.
	
	/* Adds the passed error's message as message 1 and returnvalue. 
	   The error is also added as inner error */
	constructor public DataContextError (cEntity as char,  e as error):
	    super (TransformMessage(cEntity,e),e ).
	    mEntity = cEntity.
	end constructor.
    
    /* allow return of multiple message from multiple errors */
    method public void AddMessage(e as Error):
        AddMessage(TransformMessage(mEntity,e),?).
    end method.    

end class.
