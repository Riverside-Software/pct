/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IAdministrator
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Jun 03 12:36:39 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
interface OpenEdge.DataAdmin.IAdministrator inherits IDataAdminElement :  
    define public property Administrators as char no-undo get. set.
     
end interface.