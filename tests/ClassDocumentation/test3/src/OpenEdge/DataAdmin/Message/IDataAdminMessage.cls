/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IDataAdminMessage
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Sep 05 17:32:04 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface OpenEdge.DataAdmin.Message.IDataAdminMessage:  
    
/*------------------------------------------------------------------------
    File        : message.i
    Purpose     : 

    Syntax      : waiting for interface inheritance 

    Description : 

    Author(s)   : hdaniels
    Created     : Thu Oct 14 20:22:03 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
    define public property DataHandle as handle no-undo 
        get.
  
     /* identifier for the service adapter (directly to data access) */
    define public property EntityName as character no-undo 
        get.
    
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
        
      method public handle SerializeMessage():     
          
end interface.