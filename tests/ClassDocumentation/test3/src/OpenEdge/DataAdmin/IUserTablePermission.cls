/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
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
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
 
using OpenEdge.DataAdmin.IUser from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IIndexSet from propath.
using OpenEdge.DataAdmin.IUserFieldPermissionSet from propath.
using OpenEdge.DataAdmin.IPartitionMap from propath.

interface OpenEdge.DataAdmin.IUserTablePermission inherits IDataAdminElement   :  
    
    define public property Name as character no-undo get.  
    define public property Hidden as logical no-undo get.  
    define public property Frozen as logical no-undo get.  
    define public property CanRead as logical no-undo get. 
    define public property CanWrite as logical no-undo get. 
    define public property CanCreate as logical no-undo get. 
    define public property CanDelete as logical no-undo get. 
    define public property CanLoad as logical no-undo get. 
    define public property CanDump as logical no-undo get. 
    define public property UserFieldPermissions as IUserFieldPermissionSet no-undo   get.
end interface.
