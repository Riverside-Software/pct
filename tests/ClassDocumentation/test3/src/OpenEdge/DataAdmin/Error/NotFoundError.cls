/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : NotFoundError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 2010
    Notes       : 404 message - use when resource in url not found 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Error.DataAdminError.
using OpenEdge.DataAdmin.Error.NotFoundError.

class OpenEdge.DataAdmin.Error.NotFoundError inherits DataAdminError: 
    constructor public NotFoundError (pmsg as char):  
        super(pmsg).
        HTTPErrorNum = 404.
    end method. 
  
end class.
