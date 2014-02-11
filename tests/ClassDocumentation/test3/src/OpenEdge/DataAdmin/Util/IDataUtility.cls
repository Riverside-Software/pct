/*************************************************************/
 /* Copyright (c) 2011-2012 by progress Software Corporation.*/
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IDataUtility
    Purpose     : Common wrapper for data admin dump/load of sequences and tables
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.IDataAdminCollection.
using OpenEdge.DataAdmin.ITenantSet.
using OpenEdge.DataAdmin.IDataAdminService.

using OpenEdge.DataAdmin.Message.IUtilityRequest.
using OpenEdge.DataAdmin.Util.IDataAdminUtility.
 
interface OpenEdge.DataAdmin.Util.IDataUtility inherits IDataAdminUtility:  
    /** Directory for dump or load, must exist also on dump - blank = current */
    define public property Directory      as char no-undo get. set.
    define public property Service        as IDataAdminService  no-undo get.
    /** Specifies the tenants to include in the request when UseGroupSelection = false 
      'all, 'list'  - 'list' requires list of Tenants  - default = 'all' */
    define public property TenantSelection      as char   no-undo get. set.   
    
    /** List of Tenants when UseGroupSelection = false and TenantSelection = 'list' */
    define public property Tenants              as ITenantSet   no-undo get.   

   
end interface.