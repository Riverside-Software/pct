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
 
using OpenEdge.DataAdmin.ITable from propath.
 
using OpenEdge.DataAdmin.IUser from propath.
 
 
interface OpenEdge.DataAdmin.IUserFieldPermission inherits IDataAdminElement :   
   
    define public property Name as character no-undo get. 
    define public property CanRead as logical no-undo get.  
    define public property CanWrite as logical no-undo get.  
end interface.
