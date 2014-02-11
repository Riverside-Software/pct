/*************************************************************/
 /* Copyright (c) 2011,2012 by progress Software Corporation. */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Wrapper for data admin .d import of table data  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.ITableDataUtility.
using OpenEdge.DataAdmin.Util.IExportUtility.

interface OpenEdge.DataAdmin.Util.ITableImportUtility inherits ITableDataUtility  :          
    /** Acceptable error percentage per .d file
        0    - stop load of .d on first error 
        > 0 - continue load of .d until error percentage is reached 
        100 - continue load */
    define public property AcceptableErrorPercentage as int no-undo get. set.
    
    /** Set to true to skip missing .d files .  
        The default (false) behavior treats this as load error and adds an error to 
        the .e file.  **/
/*    define public property IgnoreMissingFiles        as log no-undo get. set.*/
    
    /** Set to true to ignore missing tenant and group table directories. 
       (Note that SkipGroups is used to ignore the entire root group directory)   
        The default (false) behavior treats missing directories as error and 
        does not load any data.  **/
    define public property IgnoreMissingDirectories  as log no-undo get. set.
    
end interface.