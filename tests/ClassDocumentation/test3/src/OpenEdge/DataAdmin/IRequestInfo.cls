/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
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
    Created     : Tue Jul 19 22:51:42 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

interface OpenEdge.DataAdmin.IRequestInfo:  
    /** protected set - not changeable - provide with constructor  */  
    define public property Name   as char no-undo get.
    
    /** A query on properties of the collection entities  */
    define public property QueryString as char no-undo get. set.
    
    define public property KeyFields as char no-undo get. 
    
    define public property SearchString as char no-undo get. set.
     
    /** The number of records to return per page or batch */
    define property PageSize as integer no-undo get. set.
                     
    /** returns an array of all children */
    method public IRequestInfo extent GetChildren().
    
    /** add collection request
        @param child IRequestInfo with name set to match a collection */
    method public logical Add(child as IRequestInfo). 
     /*
    /** add collection request
        @param namechild character name to match a collection 
        @param child IRequestInfo */
    method public logical Add(name as char,child as IRequestInfo).
    */
    
    /** add collection request
        @param child IRequestInfo with name set to match a collection */
    method public logical Remove(child as IRequestInfo).
    
    /** get a child collection request by name 
        @param child IRequestInfo with name set to match a collection */
    method public IRequestInfo Get(name as char). 
    
    /** get the key value for top level request */ 
    method public character extent GetKeyValues(). 
    
end interface.