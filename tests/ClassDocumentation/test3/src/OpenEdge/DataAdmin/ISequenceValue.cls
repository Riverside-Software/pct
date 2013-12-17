/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ISequenceValue
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ISequence from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
 

interface OpenEdge.DataAdmin.ISequenceValue inherits IDataAdminElement 
                                               /* IEntrySet */:  
    
    /** The Sequence of the value */
    define public property Sequence       as ISequence no-undo get. 
    
    /** The Tenant of this sequence value */
    define public property Tenant         as ITenant no-undo get. 
    
    /** The current value for the sequence and tenant */
    define public property CurrentValue   as int64 no-undo get. set.
      
end interface.
