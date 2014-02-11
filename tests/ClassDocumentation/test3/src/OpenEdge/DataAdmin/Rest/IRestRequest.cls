/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IRestRequest
    Purpose     : Connection and file info and rest info for rest request  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Mar 15 13:27:26 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Rest.IPageRequest from propath. 
using OpenEdge.DataAdmin.Rest.IRestRequestFileInfo from propath.

interface OpenEdge.DataAdmin.Rest.IRestRequest inherits IRestRequestFileInfo: 
    /** num rest levels  */
    define public property NumLevels as int no-undo get. 
    
    /** query of url  */
    define public property Query as char no-undo  get. 
 
    /** rest collections - NumLevels extents  */
    define public property CollectionName as char no-undo extent get. 
    
    /** rest key values - NumLevels extents  */
    define public property KeyValue as char no-undo extent get. 
    
    /** connection url - the part before the rest request */
    define public property ConnectionUrl as char no-undo get. 
   
    /** the slash entry position of the the first collection in the URL      */
    define public property StartEntry as int no-undo get. 
    
    /** connection name - logical name db  */
    define public property ConnectionName as char no-undo get. set.
 
    /** upload or download file    */     
    define public property FileName2 as char no-undo  get.
    
    /** validate data/properties */ 
    method public void Validate().
    
    define public property RequestUrl as char no-undo  get.
    
    /** returns an optional pagerequest (Based on url query properties)  */
    method public IPageRequest GetPageRequest().
    
    /** returns the value of a Url Query property */ 
    method public character GetQueryValue(pcQuery as char): 
    
end interface.