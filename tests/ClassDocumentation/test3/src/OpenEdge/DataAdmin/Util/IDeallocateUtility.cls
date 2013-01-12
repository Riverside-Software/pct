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
    Created     : 2012
    Notes       : 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.


using Progress.Lang.*.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.Util.IDataAdminUtility from propath.

interface OpenEdge.DataAdmin.Util.IDeallocateUtility inherits IDataAdminUtility: 
     define public property Tenant as ITenant no-undo get.  set. 
     define public property Table as ITable no-undo get.  set.
     define public property TenantGroup as ITenantGroup no-undo get.  set.
end interface.