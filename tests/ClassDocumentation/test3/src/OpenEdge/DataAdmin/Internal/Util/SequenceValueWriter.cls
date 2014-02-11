 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SequenceValueExport
    Purpose     : wrapper for dataadmin sequence value export
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.ISequenceExportUtility.
using OpenEdge.DataAdmin.Internal.Util.SequenceUtility.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.SequenceValueWriter inherits SequenceUtility 
                                                           implements ISequenceExportUtility: 
	/** IExportUtility  */
    define public property CodePage       as character no-undo get. set.  
    
    define public property OverwriteFiles as logical no-undo init yes 
        get. 
        set(plOver as log):
           if not plOver then 
              undo ,throw new ReadOnlyPropertyError("SequenceValueWriter","","OverwriteFiles","The utility currently always overwrites the file if it exists."). 
        end. 
 
	constructor public SequenceValueWriter(   ):
        super ("SequenceValueWriter").
        /** cannot currently set this to no. 
            Set to true here to avoid error when deserialize sets it from TT */
	    OverwriteFiles = yes.
	end constructor.
	
    method protected override void Serialize():
        /* assigns tt fields for super class */
        super:Serialize().
        assign 
            ttUtilityOptions.CodePage       = this-object:CodePage 
            ttUtilityOptions.OverwriteFiles = this-object:OverwriteFiles.
    end.     
    
    method protected override void Deserialize():
        /* assigns properties for super class */
        super:Deserialize().
        assign 
            this-object:CodePage       = ttUtilityOptions.CodePage 
         /* we should ideally give an error if someone tries to set this
            to no, but no is default in the TT */ 
            this-object:OverwriteFiles = true. 
    end.     
    
end class.