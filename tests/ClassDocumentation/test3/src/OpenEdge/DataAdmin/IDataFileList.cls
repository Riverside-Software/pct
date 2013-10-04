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
using OpenEdge.DataAdmin.IDataFile  from propath.
using OpenEdge.DataAdmin.Lang.Collections.IList. 
 
interface OpenEdge.DataAdmin.IDataFileList inherits IDataAdminCollection, IList:  
   
    method public IDataFile Get(i as int).
   
    /* Returns the index in this list of the specified extent */
    method public integer IndexOf(pExtent as IDataFile). 
 
end interface.
