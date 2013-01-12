/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/** ------------------------------------------------------------------------
    File        : ITableRequest
    Purpose     : Interface for table fetch request  
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Tue Feb 09 18:28:13 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
  
interface OpenEdge.DataAdmin.Rest.IPageRequest inherits IRequestInfo: 
    
    /** The default FillMode for this request. */
/*    define property FillMode as char no-undo get. set.*/
    
    /** Retrieve full page when page position is at beginning or end of result-set */
/*    define property FullPage as logical no-undo get. set.*/

  
  /*    define property RequestType as char no-undo get. set.*/

    /** context info/key for where to start appending page begin or end */
/*    define property PageContext as char    no-undo get. set.*/
    define property Start as integer no-undo get. set.
     
end interface.