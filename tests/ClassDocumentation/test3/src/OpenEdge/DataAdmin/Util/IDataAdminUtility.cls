/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IDataAdminUtility
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 17:06:35 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.IUtilityRequest  from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.

interface OpenEdge.DataAdmin.Util.IDataAdminUtility:  
    /** set to true to export status */
    define public property Name           as char   no-undo get. set.
    define public property LogStatus      as logical no-undo get. set.
    /** optional status log type */
/*    define public property LogType        as char no-undo get. set.*/
    define public property StatusFileName as character  no-undo get. set.
    define public property StatusInterval as integer  no-undo get. set.
    define public property TaskName       as char  no-undo get. set.
    
    method public IUtilityRequest GetRequest().
    method public void SetResponse(response as IUtilityResponse).
    
    method public void ImportOptions(pcFile as char). 
    
    
end interface.