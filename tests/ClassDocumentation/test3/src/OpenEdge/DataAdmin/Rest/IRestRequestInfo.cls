/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Connection and file info for rest request  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.JsonObject from propath.
using OpenEdge.DataAdmin.Rest.IRestRequestFileInfo from propath.

interface OpenEdge.DataAdmin.Rest.IRestRequestInfo inherits IRestRequestFileInfo: 
    /** request URL */
    define property Url        as char no-undo get. 
    
    /** URL method - POST, PUT, GET, DELETE */
    define property Method     as char no-undo get. 
    
    /** rest collection  - the first   */
    define public property Collection as char no-undo get.
   
    /** connection  -  db connection   */
    define public property Connection as char no-undo get. 
      
    /** run procedure    */
    define public property ProcedureName as char no-undo get.  
   
    /** the slash entry position of the the connections collection in the URL */
    define public property ConnectionsPos as int no-undo get. set.
    
    /** initialize from json file */
    method void InitFromJsonFile(pcChar as char)  .  
   
    /** initialize from json object */
    method void InitFromJson(pcPath as char,pJson as JsonObject)  .  
     
end interface.