/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IContextFactory
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Sep 13 17:51:00 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.

interface OpenEdge.DataAdmin.Binding.Factory.IContextScope:  
     define public property IsLocal as logical no-undo get.  
     define public property ServiceAdapter as ServiceAdapter no-undo get.  
     define public property Service as IDataAdminService no-undo get. 
     method public IDataAdminContext GetContext(pname as char).
end interface.