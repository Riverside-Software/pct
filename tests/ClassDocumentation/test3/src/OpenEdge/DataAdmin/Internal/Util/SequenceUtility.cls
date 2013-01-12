/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Internal.Util.DataUtility.
using OpenEdge.DataAdmin.Util.ISequenceUtility.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.SequenceUtility  abstract inherits DataUtility 
                                                                 implements ISequenceUtility : 
 
    define public property FileName       as char no-undo get. set.
     
     /* all,multitenant,shared,one (?) or list*/
    define public property SequenceSelection   as char  init "all"  no-undo get. set.     
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public SequenceUtility (  pname as char ):
        super (pname).
		FileName = "_seqvals.d". 
	end constructor.
    
     method protected override void Serialize():
        /* assigns tt fields for super class */
        super:Serialize().
        assign 
            ttUtilityOptions.FileName = FileName   
            ttUtilityOptions.SequenceSelection = SequenceSelection.
             
    end.     
    
    method protected override void Deserialize():
        /* assigns properties  for super class */
        super:Deserialize().
        assign 
            FileName    = ttUtilityOptions.FileName
            SequenceSelection = ttUtilityOptions.SequenceSelection. 
    end.     
    
        
end class.