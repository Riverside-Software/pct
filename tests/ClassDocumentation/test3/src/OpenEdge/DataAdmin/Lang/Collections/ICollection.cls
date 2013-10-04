 /*------------------------------------------------------------------------
    File        : ICollection
    Purpose     : A collection represents a group of objects, known as its 
                  elements.
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Dec 16 2007 (2010 stripped down version)
    Notes       :                                                           
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Lang.Collections.ICollection from propath.
using OpenEdge.DataAdmin.Lang.Collections.IIterator from propath.
 
interface OpenEdge.DataAdmin.Lang.Collections.ICollection:
    define public property Count as integer no-undo get.
    define public property IsEmpty as logical no-undo get.
  
 
    method public logical Add(o as Object).
    method public logical AddAll(c as ICollection).
    /*
    method public logical AddArray(c as Object extent).  
      */ 
    method public void Clear().
     
    method public logical Contains (o as Object).
      /*  method override public logical equals (o as Object). */
    method public IIterator Iterator().
    
       
    method public logical Remove (o as Object). 
      /*
      /* Removes from this list all the elements that are contained in the 
          specified collection (optional operation). */
      method public logical RemoveAll (c as ICollection). 
      /* Retains only the elements in this list that are contained in the 
          specified collection (optional operation). return true if the object changed */
      method public logical RetainAll (c as ICollection). 
      method public void ToTable (output table-handle tt). 
      method public Object extent ToArray (). 
      */
end interface.