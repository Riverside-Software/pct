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

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.ITablePermission from propath.

interface OpenEdge.DataAdmin.ITablePermissionSet inherits IDataAdminCollection: 
      
    method public logical CanFind(tablename as char).
    method public logical Contains(tableimpl as ITablePermission).
    method public ITablePermission Find(tablename as char).
 
    
end interface.
