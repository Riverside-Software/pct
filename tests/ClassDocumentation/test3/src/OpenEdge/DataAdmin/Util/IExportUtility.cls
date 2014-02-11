/*************************************************************/
 /* Copyright (c) 2011,2012 by progress Software Corporation. */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : common properties for data admin dump of sequences and tables
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28  2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.IDataUtility.

interface OpenEdge.DataAdmin.Util.IExportUtility inherits IDataUtility:  
    /** Code page */
    define public property CodePage as character no-undo get. set.  
    
    /** set to true to overwrite any existing file. If false the file will be skipped with error */
    define public property OverwriteFiles            as logical no-undo get. set.
end interface.