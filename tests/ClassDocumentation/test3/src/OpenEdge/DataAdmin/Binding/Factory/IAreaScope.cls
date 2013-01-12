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
 
interface OpenEdge.DataAdmin.Binding.Factory.IAreaScope inherits IContextScope:  
    define public property AreaContext as AreaContext no-undo get.    
    define public property ExtentContext as ExtentContext no-undo get. 
    define public property PartitionContext as PartitionContext no-undo get.     
end interface.