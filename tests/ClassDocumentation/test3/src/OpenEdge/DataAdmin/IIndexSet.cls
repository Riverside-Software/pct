/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** ------------------------------------------------------------------------
    Purpose     : Index set (collection) for indexes of a table 
                  with name as unique identifier
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:46:12 EDT 2010
    Notes       : Name is unique since the collection only has indexes 
                  for one table  
                  
------------------------------------------- */
 
using OpenEdge.DataAdmin.IDataAdminCollection  from propath.
using OpenEdge.DataAdmin.IIndex  from propath.

interface OpenEdge.DataAdmin.IIndexSet inherits IDataAdminCollection:  
    
    /** Can find index (of table)
     * @Returns true if the index withthis name is in the collection.
     * 
     * @param indexName
     */
    method public logical CanFind(indexName as char).
   
    /** Contains   
     * @Returns true if the index is in the collection.
     * @param IIndex  
     */
    method public logical Contains(indeximpl as IIndex).
   
    /** Returns the index with the specified Name from the collection. 
     * Returns unknown if the field doesn’t exist in the collection
     * 
     * @param IndexName character 
     */
    method public IIndex Find(indexName as char).
 
end interface.
