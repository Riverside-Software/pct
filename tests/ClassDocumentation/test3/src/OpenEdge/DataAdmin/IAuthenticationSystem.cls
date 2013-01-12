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
    Created     : 2011
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.

interface OpenEdge.DataAdmin.IAuthenticationSystem inherits IDataAdminElement:  
    /** Tne name and unique identifier */
    define public property Name            as character no-undo get. set.
    
    /** This is a free text description to describe the authentication system,
        its purpose, use, etc. primarily for tools and reporting purposes. */
    define public property Description     as char      no-undo get. set.
   
   /** This flag denotes if PAM plugin is enabled for the authentication system */    
    define public property IsEnabled       as logical   no-undo get. set.
 
   /** Callback procedure name for the authentication system */
    define public property Callback        as char      no-undo get. set.
            
    /** This is an additional field to record custom specific information about this 
        authentication system. */
    define public property Comments        as char      no-undo get. set.      
end interface.
