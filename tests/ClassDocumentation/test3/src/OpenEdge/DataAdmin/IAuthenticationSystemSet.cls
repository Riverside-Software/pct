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
    Created     : 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.IDataAdminCollection from propath.

using OpenEdge.DataAdmin.IAuthenticationSystem from propath.
 
interface OpenEdge.DataAdmin.IAuthenticationSystemSet inherits IDataAdminCollection: 
    method public logical Remove(domtype as IAuthenticationSystem).
    method public logical Add(domtype as IAuthenticationSystem).
    method public logical CanFind(name as char).     
    method public logical Contains(domtype as IAuthenticationSystem). 
    method public IAuthenticationSystem Find(name as char).  
end interface.
