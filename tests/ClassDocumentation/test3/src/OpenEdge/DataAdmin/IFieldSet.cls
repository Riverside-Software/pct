/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** ------------------------------------------------------------------------
    Purpose     : Field set (collection) for fields of a table 
                  with name as unique identifier
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:48:35 EDT 2010
    Notes       : 
  --------------------------------------------------------------------- */
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IField from propath.

interface OpenEdge.DataAdmin.IFieldSet inherits IDataAdminCollection: 
   
    /** Return true if a Field with the specified Name is in the collection 
      * @param fieldName character */ 
    method public logical CanFind(fieldName as char).     
   
    /** Return true if the IField is in the collection    
      * @param fieldReference IField   */ 
    method public logical Contains(fieldImpl as IField). 
    
    /** Return a Field with the specified Name from the collection.
      *  Returns unknown if not found. 
      * @param fieldName character */ 
    method public IField Find(fieldName as char).  
end interface.
