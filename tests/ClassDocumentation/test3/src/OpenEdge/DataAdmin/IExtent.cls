/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IExtent
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:30:19 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IArea  from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
  
interface OpenEdge.DataAdmin.IExtent inherits IDataAdminElement:   
     
    /** The area of the extent */
    define public property Area as IArea no-undo get. 
    
    /** The file name of the extent */
    define public property FileName as char no-undo get.   
    
    /** The path of the extent - can be set instead of the file  */
    define public property Path     as char no-undo get. set.
    
    /** The number of the extent within the area */
    define public property Number  as int no-undo get. 
    
    /** Is the extent fixed. */
    define public property IsFixed as log no-undo get. set.
    
    /** The Size of the extent in KB */
    define public property Size as int no-undo get. set.
    
end interface.  
