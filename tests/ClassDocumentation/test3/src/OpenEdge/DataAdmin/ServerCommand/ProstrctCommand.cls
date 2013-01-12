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
    Created     : Tue Jul 12 16:42:26 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.ProCommand from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
         
routine-level on error undo, throw.

class OpenEdge.DataAdmin.ServerCommand.ProstrctCommand abstract inherits ProCommand: 
	 /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	 ------------------------------------------------------------------------------*/
	 define protected override property CommandName  as char no-undo 
        get():
           return "prostrct". 
        end. 
        set.
	
	constructor public ProstrctCommand ( databasename as char ):
		super (databasename).
		/* prostrct does not seem to return any error status so we don't need the bat file*/
		UseBatFile = false.
	end constructor.
    
    
    
end class.