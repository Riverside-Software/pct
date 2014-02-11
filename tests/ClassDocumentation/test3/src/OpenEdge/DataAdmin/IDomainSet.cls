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
using OpenEdge.DataAdmin.IDomain from propath.

interface OpenEdge.DataAdmin.IDomainSet  inherits IDataAdminCollection: 
    
    /** Remove the domain from the collection */
    method public logical Remove(domain as IDomain).
   
    /** Add the domain to the collection */
    method public logical Add(domain as IDomain).
    
    /** Return true if a Domain with the specified Name is in the collection */
    method public logical CanFind(name as char).
    
    /** Return true if the Domain is in the collection */
    method public logical Contains(domain as IDomain).
   
    /** Return the Domain with the specified Name from the collection.
        Returns unknown if not found. */
    method public IDomain Find(name as char).
end interface.