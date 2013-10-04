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
    Created     : July 2010
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IUserPermission  from propath.
 
interface OpenEdge.DataAdmin.IUserPermissionSet inherits IDataAdminCollection: 
    
    method public logical CanFind( id as char).
    method public logical Contains( usr as IUserPermission).
    method public IUserPermission Find( name as char).
     
end interface.
