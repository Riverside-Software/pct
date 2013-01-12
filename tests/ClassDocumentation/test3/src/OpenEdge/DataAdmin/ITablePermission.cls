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
    Created     : Thu Jun 10 00:12:35 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
 
using OpenEdge.DataAdmin.ISchema from propath.
 
using OpenEdge.DataAdmin.IFieldPermissionSet from propath.
 
 
interface OpenEdge.DataAdmin.ITablePermission inherits IDataAdminElement :  
   
    define public property Schema as ISchema no-undo get.  
    define public property Name as character no-undo get.  
    define public property Hidden as logical no-undo get.  
    define public property Frozen as logical no-undo get.  
    define public property CanRead as character no-undo get. set.
    define public property CanWrite as character no-undo get. set.
    define public property CanCreate as character no-undo get. set.
    define public property CanDelete as character no-undo get. set.
    define public property CanLoad as character no-undo get. set.
    define public property CanDump as character no-undo get. set.
    define public property FieldPermissions as IFieldPermissionSet no-undo   get.
end interface.
