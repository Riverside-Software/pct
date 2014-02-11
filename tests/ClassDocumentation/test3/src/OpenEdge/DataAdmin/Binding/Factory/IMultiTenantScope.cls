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
    Created     : Tue Sep 13 12:33:09 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Factory.IIdentityScope from propath.

interface OpenEdge.DataAdmin.Binding.Factory.IMultiTenantScope inherits IIdentityScope:  
    define public property UserContext as UserContext no-undo get.  
    define public property DomainContext as DomainContext no-undo get.  
    define public property PartitionContext as PartitionContext no-undo get.  
    define public property SequenceContext as SequenceContext no-undo get.  
    define public property SequenceValueContext as SequenceValueContext no-undo get.  
    define public property TenantGroupMemberContext as TenantGroupMemberContext no-undo get.  
    define public property TenantGroupContext as TenantGroupContext no-undo get.  
    define public property TenantContext as TenantContext no-undo get.  
/*    define public property SchemaContext as SchemaContext no-undo get.*/
     
end interface.