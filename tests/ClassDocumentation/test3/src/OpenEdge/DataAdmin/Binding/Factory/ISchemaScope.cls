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
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath.
interface OpenEdge.DataAdmin.Binding.Factory.ISchemaScope inherits IContextScope:  
    define public property FieldContext as FieldContext no-undo get.  
    define public property IndexContext as IndexContext no-undo get.  
    define public property PartitionContext as PartitionContext no-undo get.  
    define public property TableContext as TableContext no-undo get.  
    define public property SequenceContext as SequenceContext no-undo get.  
    define public property SequenceValueContext as SequenceValueContext no-undo get.  
    define public property SchemaContext as SchemaContext no-undo get.  
    define public property AllTableContext as AllTableContext no-undo get.   
end interface.