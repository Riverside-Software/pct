/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IIterable
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Aug 06 13:15:05 EDT 2011
    Notes       : Not externally supported
                  This is currently only implemented by other internal 
                  interfaces, but could in theory be implemented by a public 
                  class. This should be done in the class as this should not
                  be implemented by a public interface. 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.

interface OpenEdge.DataAdmin.Binding.IIterable:
    /** iteratorHandle implements IIterable allows IIterator to use existing query or tablehandle  */ 
    define property IteratorHandle as handle no-undo get.  
    define property Table as char no-undo get. 
    
    /** fieldname in iteratorHandle that hold the object */ 
    define property EntityFieldName as char no-undo get. 
    
    /** Find the entity (factory method that really belongs in subinterfaces since it is also used by
                        other than iterator)
        Is considered internal.                    
              
        @param handle iterating handle positioned to the record to be found 
                      does not need to be the same as IteratorHandle, but it should be of type  
                      "query" if IteratorHandle or "buffer id iteratorhandle is TempTable  */
    method public IDataAdminElement FindEntity(phdl as handle).
    
    /** Remove the entity. (factory method that really belongs in subinterfaces since it is also used by
                             other than iterator)
        Is considered internal.                    
        @param handle iterating handle positioned to the record to be found 
                      does not need to be the same as IteratorHandle, but it should be of type  
                      "query" if IteratorHandle or "buffer id iteratorhandle is TempTable  */
    method public logical Remove(phdl as handle).
   
end interface.

