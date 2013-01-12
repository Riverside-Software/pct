/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ITenantGroupSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenantGroup  from propath.   
 

interface OpenEdge.DataAdmin.ITenantGroupSet inherits IDataAdminCollection:  
  
    method public logical Add(newgroup as ITenantGroup).
    method public logical Remove(newgroup as ITenantGroup).
    method public logical CanFind(groupName as char).
    method public logical Contains(detail as ITenantGroup).
     
    /**
     * 
     * @param groupName
     */
    method public ITenantGroup Find(groupName as char).
 
    /**
     * 
     * @param groupId
     */
 
end interface.
