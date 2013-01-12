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
using OpenEdge.DataAdmin.Message.ITableRequest from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Message.TableRequest implements ITableRequest: 
    define property Name   as char no-undo get. private set.
    define property QueryString as char no-undo get. set.
    define property SearchString as char no-undo get. set.
    
    /** The number of records to return per page or batch */
    define property PageSize as integer no-undo get. set.
                     
    define property KeyValue as char no-undo get. set.
	define property Start as int no-undo get. set.
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public TableRequest (h as handle  ):
		super ().	
		Name             = h::TableName.
        QueryString      = h::QueryString.
        SearchString     = h::SearchString.
        PageSize         = h::PageSize.
        KeyValue         = h::KeyValue.
        Start            = h::Start.		
	end constructor.


end class.