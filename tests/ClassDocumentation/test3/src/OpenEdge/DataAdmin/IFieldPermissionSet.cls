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
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IFieldPermission from propath.
  
interface OpenEdge.DataAdmin.IFieldPermissionSet inherits IDataAdminCollection: 
 
    method public logical CanFind(fieldName as char).     
    method public logical Contains(fieldImpl as IFieldPermission). 
    method public IFieldPermission Find(fieldName as char).  
end interface.
