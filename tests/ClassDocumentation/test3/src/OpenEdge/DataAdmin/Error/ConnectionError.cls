/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : used by DataService if db not found or connected
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 2011
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Error.DataAdminError.

class OpenEdge.DataAdmin.Error.ConnectionError inherits DataAdminError: 
     
    constructor public ConnectionError (e as Error):  
        super(ErrorString(e),e).
    end method. 
   
    constructor public ConnectionError (pmsg as char):  
        super(ErrorString(pmsg)).
    end method. 
    
    method private char ErrorString(e as Error):
        return ErrorString(if valid-object(e) then e:GetMessage(1) else ""). 
    end.   
       
    method private char ErrorString(pcMessage as char):
        return "The service did not start due to a connection failure"
               + if pcMessage = "" then "." else ":~n" + pcMessage.      
    end method.        
end class.
