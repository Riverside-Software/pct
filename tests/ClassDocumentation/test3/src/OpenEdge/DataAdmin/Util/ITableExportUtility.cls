/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : ITableExportUtility
    Purpose     : Wrapper for data admin .d export of tenant table data  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.ITableDataUtility.
using OpenEdge.DataAdmin.Util.IExportUtility.
interface OpenEdge.DataAdmin.Util.ITableExportUtility inherits ITableDataUtility,IExportUtility :          
    /* all,tenant,shared or list*/ 
    define public property NoMap                  as logical   no-undo get. set.  
    define public property CharacterMap           as char      no-undo get. set.  
    /* Set to true to skip code page validation - currently skips the check of utf-8 
      The default behavior will give an error if the db has codepage utf-8 unless 
      both the CodePage and the session:charset is  "utf-8"
      If the client -cpinternal is not utf-8, it will not read any utf-8 specific 
      characters correctly (they will end up as ?) and we will write incorrect data 
      to the .d file. Keep in mind that there is a conversion happening from the db 
      to the client before we get to write to the output file.
       */ 
    define public property SkipCodePageValidation as logical   no-undo get. set.  
end interface.