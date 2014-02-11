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
using OpenEdge.DataAdmin.ITablePermissionSet from propath.
 
interface OpenEdge.DataAdmin.IDataSecurity inherits IDataAdminElement:  
    define public property Name as character no-undo      get.
    define public property TablePermissions as ITablePermissionSet no-undo      get.    
    method public void ExportLastSavedTree(pcFile as char). 
end interface.
