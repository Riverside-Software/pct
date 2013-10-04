/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:26:27 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IExtent from propath.
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.Lang.Collections.IList. 
 
interface OpenEdge.DataAdmin.IExtentList inherits IDataAdminCollection, IList:  
   
    /** Add the extent to the list  */
    method public logical Add(pExtent as IExtent).
    
 /** Removes the extent from the collection. Returns true if the removal was successful.
     Can only be performed if the extent is not saved. */
    method public logical Remove(pExtent as IExtent).
    
    /** Get the extent with the specified number from the list  */
    method public IExtent Get(i as int).
   
    /* Returns the index in this list of the specified extent */
    method public integer IndexOf(pExtent as IExtent). 
 
end interface.
