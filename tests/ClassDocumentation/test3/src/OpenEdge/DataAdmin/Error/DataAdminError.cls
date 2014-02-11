/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DataAdminError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 17 12:51:36 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
/* error in error  */
routine-level on error undo, throw.

using Progress.Lang.AppError from propath.
using Progress.Lang.Error from propath.

class OpenEdge.DataAdmin.Error.DataAdminError abstract inherits AppError: 
    define public property InnerError as Error no-undo 
        get.
        protected set.
    
    define public property HTTPErrorNum as integer no-undo 
        init 500
        get.
        set.
        
    constructor public DataAdminError (pmsg as char):   
        /* Need to set both returnvalue and addmessage in order to 
           get the message displayed with regular error (no catch)
           It is the returnvalue that will be shown.... 
        */
        super (pmsg).
        AddMessage(pmsg,?). 
/*    this-object:ReturnValue = pmsg.*/
    end constructor.     
     
    constructor public DataAdminError (pmsg as char, innErr as Error):   
        this-object(pmsg).
        InnerError = innErr.
    end constructor.    
    
    
end class.
 
