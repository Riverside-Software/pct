/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ITenantMap
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenant from propath.

interface OpenEdge.DataAdmin.ITenantSet inherits IDataAdminCollection:  
     
    method public logical Add(tenant as ITenant).
    
    method public logical CanFind(tenantName as char).
    method public logical CanFind(tenantid as int).
    method public logical CanFindByExternalId(ExtId as char).
       
    method public logical Contains(tenant as ITenant).
     
    /** Find a tenant by name
     * 
     * @param TenantName character
     */
    method public ITenant Find(tenantName as char).
    method public ITenant FindByExternalId(ExtId as char).

    /**
     * 
     * @param Tenant 
     */
    method public logical Remove (tnt as ITenant).  
    method public ITenant Find(tenantid as int).
end interface.
