 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Response details for a table request  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 26 14:12:18 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Message.TableResponse implements ITableResponse: 
    define property Name as char  no-undo  
        get.
        private set.
    
    define property RequestType as character  no-undo  
        get. 
        private set.
    
    define property NextPosition as character  no-undo  
        get. 
        private set.
    
    define property PrevPosition as character  no-undo  
        get. 
        private set.
    
    define property Total as int  no-undo  
        get.
        private set.
    
    /** Purpose: receives the internal buffer of DataAdminMessage  
		@param 	Handle internal buffer of DataAdminMessage with the requested record available   																	  
    */
	constructor public TableResponse (h as handle):
		super ().	
		Name         = h::TableName.
		RequestType  = h::RequestType.
    	NextPosition = h::NextPosition.
        PrevPosition = h::PrevPosition.
        Total        = h::Total.
    end constructor.	
    
    /** standard response with no batching - not query no other info available */   
    constructor public TableResponse (pName as char):
        Name = pName.
        RequestType = "ALL".
        Total = ?. 
    end constructor.
     
end class.