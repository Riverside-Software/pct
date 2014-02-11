/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DeallocateCommand
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 16:42:26 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.ProutilCommand from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.DeallocateRequest from propath.
        
routine-level on error undo, throw.

class OpenEdge.DataAdmin.ServerCommand.DeallocateCommand inherits ProutilCommand: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	constructor public DeallocateCommand ( databasename as char ):
		super (databasename).	
		PromptValue = "y".	
	end constructor.
    
    method protected override char GetRequestString(pRequest as IUtilityRequest).
        define variable dealloc as DeallocateRequest no-undo.
        dealloc = cast(pRequest,DeallocateRequest).
        return "deallocate " + dealloc:TableName + " " + dealloc:Type + " " + dealloc:Name.
    end method.
    
     
    
end class.