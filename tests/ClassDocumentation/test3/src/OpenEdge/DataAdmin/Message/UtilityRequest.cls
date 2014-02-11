 /*************************************************************/
 /* Copyright (c) 2010,2012 by Progress Software Corporation. */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UtilityRequest.cls
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Sep 30   2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.Message.DataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
routine-level on error undo, throw.

/** currenty we use the same for request and response */
class OpenEdge.DataAdmin.Message.UtilityRequest 
                        inherits DataAdminMessage
                        implements IUtilityRequest, IUtilityResponse    : 
     
    /* init true 
       - replace on client - append on server (complex queries)
       - better separation - deep copy from dataaccess (overhead, but small - ?)
       - can be split to run on server (see serviceAdapter) 
      */   
    define public property UseReplaceOnClient as logical init true no-undo get. set.
    define property Service as IDataAdminService no-undo get. set.     
    constructor public UtilityRequest (pname as char,h as handle ):
		super (pname,h). 
	end constructor.
    
end class.