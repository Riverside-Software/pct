/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : PageRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Jul 20 00:32:29 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/
   
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.RequestInfo from propath.
using OpenEdge.DataAdmin.Rest.IPageRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.

class OpenEdge.DataAdmin.Rest.PageRequest inherits RequestInfo implements IPageRequest: 
    /** The default FillMode for this request. */
/*    define public property FillMode as char no-undo get. set.*/
    
		
	constructor public PageRequest (  ):
		super ().
	end constructor.

	constructor public PageRequest ( input pName as character ):
		super (pName).
	end constructor.

    /** Retrieve full page when page position is at beginning or end of result-set */
/*    define public property FullPage as logical no-undo get. set.*/

/*    /** The number of remaining pages to retrieve. If this is zero, then            */
/*        all data has been retrieved. This value is returned from the server/business*/
/*        component layer. */                                                         */
/*    define public property NumRemainingPages as integer no-undo get. set.           */
/*                                                                                    */
/*    define property RequestType as char no-undo get. set.*/

    /** context info/key for where to start appending page begin or end */
/*    define property PageContext as char no-undo get. set.*/
    define public property Start as int no-undo get. set.

end class.