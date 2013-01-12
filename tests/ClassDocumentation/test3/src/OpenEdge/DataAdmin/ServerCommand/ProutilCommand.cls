/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Abstract class for proutil commands 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 16:25:38 EDT 2011
    Notes       : Subclasses should implement/override GetRequestString() 
                  for specific commands 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.ProCommand from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
      
class OpenEdge.DataAdmin.ServerCommand.ProutilCommand abstract inherits ProCommand: 
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    define protected override property CommandName  as char no-undo 
        get():
           return "proutil". 
        end. 
        set.
    
	constructor public ProutilCommand (pcdbname as char  ):
		super (pcdbname).	
	end constructor.

    method protected override char GetCommandParameters(pRequest as IUtilityRequest).
        return quoter(pdbname(DatabaseName)) 
               + " -C "
               + GetRequestString(pRequest).
    end.
   
    /* Implement subclass that overrides this with the details for a specific proutil command */
    method protected abstract char GetRequestString(pRequest as IUtilityRequest).
    
     
end class.