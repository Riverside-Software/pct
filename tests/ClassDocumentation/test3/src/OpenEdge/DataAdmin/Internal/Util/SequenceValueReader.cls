 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SequenceValueReader
    Purpose     : wrapper for dataadmin sequence value import
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28 
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Internal.Util.SequenceUtility.
using OpenEdge.DataAdmin.Internal.Util.ISequenceImportUtility.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.SequenceValueReader inherits SequenceUtility
                                                           implements ISequenceImportUtility: 
	 
	constructor public SequenceValueReader ():
        super ("SequenceValueReader").
	end constructor.
    
end class.