/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IConnection
    Purpose     : Represents a connection 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Aug 05 23:24:09 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

interface OpenEdge.DataAdmin.Binding.IConnection:  
    define public property ServerName as char      no-undo get. set.  
    define public property Error     as Error           no-undo get. set.  
    define public property HostName as char        no-undo get. set.
    define public property FullName    as char    no-undo get.    
    define public property IsCreated as logical    no-undo get.  
    define public property IsConnected  as logical no-undo get.
    define public property IsSingleUser as logical no-undo get.  
    define public property IsMultiTenant as logical no-undo get.
    define public property Name as char            no-undo get. set.  
    define public property Path as char            no-undo get. set.  
    define public property HREF as char            no-undo get. set.  
    method logical Connect().
    method logical ConnectSingleUser().
    method logical ConnectMultiUser().
    method logical Disconnect().

end interface.