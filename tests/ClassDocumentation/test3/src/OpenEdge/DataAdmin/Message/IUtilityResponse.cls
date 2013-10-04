/*************************************************************/
 /* Copyright (c) 2012 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Sep 05 17:32:04 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
 
interface OpenEdge.DataAdmin.Message.IUtilityResponse inherits IDataAdminMessage:  
 	define property Service as IDataAdminService no-undo get. set.
 	method public ITableResponse GetTableResponse(pcName as char).
  	      
end interface.