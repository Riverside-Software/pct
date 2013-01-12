/*************************************************************/
/* Copyright (c) 2011 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Wraps info about a row key change for interobject messages/events
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Oct 08 15:09:48 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IRowChange from propath.
using OpenEdge.DataAdmin.Binding.RowImpl from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.RowChange inherits RowImpl implements IRowChange: 
    define public property OldKeyValues as character extent no-undo 
       get.
       private set. 

    constructor public RowChange (pSerializename as char,pKeyFields as char,pOldKeyValues as char extent,pNewFieldValues as char extent):
        super (pSerializename,row-modified,pKeyFields,pNewFieldValues).
        OldKeyValues = pOldKeyValues.
    end constructor.    

end class.