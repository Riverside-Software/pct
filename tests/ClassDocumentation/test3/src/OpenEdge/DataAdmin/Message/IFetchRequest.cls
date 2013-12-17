/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : IFetchRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Sep 05 17:32:04 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.IDataAdminMessage from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

interface OpenEdge.DataAdmin.Message.IFetchRequest  inherits IDataAdminMessage  :  
    
    
    define public property IsPageRequest as logical no-undo get. set.

    /* as of current this is used to avoid replace for some requests
       that passes a table to server / dataaccess to execute a query.         
    */
    define public property UseReplaceOnClient as logical no-undo get. set.
     
    method public char GetTableQuery (pcTable as char).
    
    method public logical HasTable (pcTable as char).
    
    method public void SetTableQuery (pcTable as char, pcQuery as char).
     
    method public ITableRequest GetTableRequest(pcTable as char).
    
    method public char GetTableRequestType (pcTable as char).
     /** Set total (response after fill)- currently both here and in IFetchResponse */   
    method public void SetTableTotal (pcTable as char, piTotal as int).     
    
    /** Set table pagerequest size */   
    method public void SetTablePageRequest (pcTable as char, pisize as int).     
    
    /** Set table pagerequest size and start */   
    method public void SetTablePageRequest (pcTable as char, pisize as int, pistart as int).   
    
    method public void SetTableRequestType (pcTable as char,pcType as char).
   
         
end interface.