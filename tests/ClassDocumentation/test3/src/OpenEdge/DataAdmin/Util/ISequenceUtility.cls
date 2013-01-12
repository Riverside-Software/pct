/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Wrapper for data admin .d export of sequence values
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.IDataUtility.
interface OpenEdge.DataAdmin.Util.ISequenceUtility inherits IDataUtility :  
    define public property FileName       as char no-undo get. set.
     /* all,multitenant,shared,one (?) or list*/
    define public property SequenceSelection     as char no-undo get. set.  

end interface.