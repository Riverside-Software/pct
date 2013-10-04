/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ITableSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:00:55 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.ITable from propath.

interface OpenEdge.DataAdmin.ITableSet inherits IDataAdminCollection: 
   
    define public property Schema as ISchema no-undo get.
   
    define public property ForceAllocation as char no-undo get.  
   
    method public logical CanFind(tablename as char).
    method public logical Contains(tableimpl as ITable).
    method public ITable Find(tablename as char).
    method public void ImportTree(pcfile as char,pcCollections as char).
 
    
end interface.
