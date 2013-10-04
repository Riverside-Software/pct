 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Parameters for prstrct  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 17:19:01 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.

class OpenEdge.DataAdmin.Message.ProstrctAddOnlineRequest implements IUtilityRequest,IUtilityResponse, IDataAdminMessage: 
    define property FileName as character no-undo get. set.
    
    define public property DataHandle as handle no-undo 
        get.
  
    define public property Service  as IDataAdminService no-undo 
        get. 
        set.
  
     /* identifier for the data service  */
    define public property EntityName as character no-undo
        init "Prostrct" 
        get .
    
    /* identifies the requester by name (published from service) */
    define public property SerializeName as character no-undo 
        get.
    
    /* identifies the requester (published from service) */
    define public property ContextId as character no-undo 
        get.
    
    /* external request id used to get here */    
    define public property Url as character no-undo 
        get.
        set.
    
    method public ITableResponse GetTableResponse(pcName as char):
        return ?.
    end method.
        
    method public handle SerializeMessage():     
    
    end method.
      
end class.