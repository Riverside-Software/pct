/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : area set  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:24:38 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IArea from propath.

interface OpenEdge.DataAdmin.IAreaSet  inherits IDataAdminCollection:   
    method public logical CanFind(areaname as char).  
    method public logical CanFind(areanum as int).
    method public logical Contains(area as IArea).
    method public IArea Find(areaname as char).  
    method public IArea Find(areanum as int):
 
    method public logical Add(area as IArea):  
end interface.
