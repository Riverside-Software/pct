/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
 
using OpenEdge.DataAdmin.IDataAdminElement.

interface OpenEdge.DataAdmin.Internal.ICollation inherits IDataAdminElement:  
    /** The unique name identifier of the Collation  */
    define public property Name as char no-undo get. set.
    /*
    /** The sort sequence */ 
    define public property Sequence as int no-undo get. 
    
    /** The code page */  
    define public property CodePage as int no-undo get. set.
    
    define public property Translation??Version as int no-undo get. set.
    define public property Translation??SubType as int no-undo get. set.
    define public property Segment as int no-undo get. set.
    define public property Data as char no-undo get. 
    */
end interface.
