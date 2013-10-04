/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
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
    Created     : Tue Jul 26 13:59:19 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
 
interface OpenEdge.DataAdmin.Message.IFetchResponse inherits IDataAdminMessage :  
    method public ITableResponse GetTableResponse(pcName as char).
       /* Set total (response after fill) */   
    method public void SetTableTotal (pcTable as char, piTotal as int):     
end interface.