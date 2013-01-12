/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ISequenceSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.ISequence from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
 
 

interface OpenEdge.DataAdmin.ISequenceSet inherits IDataAdminCollection:  
    
    method public logical Add(seq as ISequence).    
    method public logical CanFind(seqName as char).
    method public logical Contains(seq as ISequence).
    method public ISequence Find(seq as char).
end interface.
