/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IUserSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : July 2010
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IUser from propath.

interface OpenEdge.DataAdmin.IUserSet inherits IDataAdminCollection: 
/*    define public property Domain as IDomain no-undo*/
/*        get.                                        */
/*        set.                                        */
/*                                                    */
/*    define public property Tenant as ITenant no-undo*/
/*        get.                                        */
/*        set.                                        */
    
    
    /* temporary while waiting for interface inheritance */ 
 
    
    method public logical CanFind( name as char).
    method public logical Contains( usr as IUser).
    method public IUser Find( name as char).
    
    method public logical Add(usr as IUser).
    
       
end interface.
