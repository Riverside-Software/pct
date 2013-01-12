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
using OpenEdge.DataAdmin.Util.ISequenceUtility .
using OpenEdge.DataAdmin.Util.IExportUtility .

interface OpenEdge.DataAdmin.Util.ISequenceExportUtility inherits ISequenceUtility,IExportUtility :  
     
end interface.