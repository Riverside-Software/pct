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
using OpenEdge.DataAdmin.IDomain from propath.
using OpenEdge.DataAdmin.IUserTablePermissionSet from propath.

interface OpenEdge.DataAdmin.IUserPermission inherits IDataAdminElement:  
     define public property Id                   as character no-undo get.  
     define public property Name                 as character no-undo get. 
     define public property Domain               as IDomain   no-undo get.  
     define public property UserTablePermissions as IUserTablePermissionSet   no-undo get.  
    
  
end interface.
