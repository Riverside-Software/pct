/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/** ------------------------------------------------------------------------
    Purpose     : Wrapper for passing row change info in messages/events 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : May 2012 
    Notes       :      
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Core.IElement from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
interface OpenEdge.DataAdmin.Binding.IRowChange inherits IRow:  
    /** returns the values that correspond to KeyFields for this row */
    define public property OldKeyValues as character extent no-undo get. 
/*    method public character OldFieldValue(pcColumn as char).*/
end interface.