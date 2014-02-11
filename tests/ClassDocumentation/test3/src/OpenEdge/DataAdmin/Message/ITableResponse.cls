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
    Created     : Thu Jul 21 02:10:02 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface OpenEdge.DataAdmin.Message.ITableResponse:  
   /* blank filter in base DataAdminContext context */
    
    define property Name as character  no-undo  
        get. 
    
    define property RequestType as character  no-undo  
        get. 
        
    define property NextPosition as character  no-undo  
        get. 
    
     /* blank filter in base DataAdminContext context */
    define property PrevPosition as character  no-undo  
        get. 
    
    define property Total as int  no-undo  
        get.
            
end interface.