/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
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
    Created     : Tue Sep 13  2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath. 
interface OpenEdge.DataAdmin.Binding.Factory.ISecurityScope /*inherits IContextScope*/ :  
    define public property AdministratorContext as AdministratorContext no-undo get.  
    define public property DataSecurityContext as DataSecurityContext no-undo get.  
    define public property FieldPermissionContext as FieldPermissionContext no-undo get.  
   
    define public property TablePermissionContext as TablePermissionContext no-undo get.  
    define public property UserPermissionContext as UserPermissionContext no-undo get.  

    define public property SecurityOptionsContext as SecurityOptionsContext no-undo get. set.  
      
end interface.