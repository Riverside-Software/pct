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
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IUserTablePermission from propath.
 
interface OpenEdge.DataAdmin.IUserTablePermissionSet inherits IDataAdminCollection: 
   
    define public property Schema as ISchema no-undo get.
    
    method public logical CanFind(tablename as char).
    method public logical Contains(tableimpl as IUserTablePermission).
    method public IUserTablePermission Find(tablename as char).
 
    method public void ExportNormalized(pcfilename as char).
    
end interface.
