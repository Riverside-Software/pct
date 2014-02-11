/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ITenantGroupMemberSet of a Tenant or TenantGroup
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.

interface OpenEdge.DataAdmin.ITenantGroupMemberSet inherits IDataAdminCollection:  
      
    /** Add detail 
        @param ITenantGroupMember */
    method public logical Add(detail as ITenantGroupMember).   
 
    /** Contains detail 
        @param ITenantGroupMember */
    method public logical Contains(detail as ITenantGroupMember).
    
    /** Find detail by name  
        @param name - char key of other end of relation  */
    method public ITenantGroupMember Find(name as char).
    
    /** CanFind detail by name  
        @param name - char key  of other end of relation */
    method public logical CanFind(name as char).
    
    /** Remove detail 
        @param ITenantGroupMember */
    method public logical Remove(detail as ITenantGroupMember).
 
end interface.
