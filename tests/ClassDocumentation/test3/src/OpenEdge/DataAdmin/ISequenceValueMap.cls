/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Sequence value map for sequence or tenant - maps to the opposite 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.ISequenceValue from propath.
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
 
 
/** Sequence value map for sequence or tenant - maps to the opposite */
interface OpenEdge.DataAdmin.ISequenceValueMap inherits IDataAdminCollection:  
    
    /** returns true if the map has the key  
        - The key is ITenant when the owner of this collection is an ISequence. 
        - The key is ISequence when the owner of this collection is an ITenant. */
    method public logical ContainsKey(elem as IDataAdminElement).
    
    /** returns true if the map has the passed sequence value */
    method public logical ContainsValue(seq as ISequenceValue).
    
    /** returns the sequence value mapped to the passed IDataAdminElement key.
        - The key is ITenant when the owner of this collection is an ISequence. 
        - The key is ISequence when the owner of this collection is an ITenant. */
    method public ISequenceValue Get(elem as IDataAdminElement).
    
end interface.
