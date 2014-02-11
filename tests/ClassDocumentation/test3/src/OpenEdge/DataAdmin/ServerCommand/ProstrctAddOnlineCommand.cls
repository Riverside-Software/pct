/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : prostrct addonline 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 16:42:26 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.ProstrctCommand from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.ProstrctAddOnlineRequest from propath.
        
routine-level on error undo, throw.

class OpenEdge.DataAdmin.ServerCommand.ProstrctAddOnlineCommand inherits ProstrctCommand:
     
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	 ------------------------------------------------------------------------------*/
	constructor public ProstrctAddOnlineCommand ( databasename as char ):
		super (databasename).
	    /* prostrct may prompt to continue under certain conditions
           Answer "n" as we're not prepared to deal with this (see prostrct doc). (Checkstatus will throw error)*/     
        PromptValue = "n". 
	    
	end constructor.
    
    /* override the entire command since the default is db  -C  */ 
    method protected override char GetCommandParameters(pRequest as IUtilityRequest).     
        return "addonline"
               + " " + pdbname(DatabaseName) 
               + " " + cast(pRequest,ProstrctAddOnlineRequest):FileName.
               
    end.
    /*
    method protected override char GetRequestString(pRequest as IUtilityRequest).
    end method.
   */ 
    method protected override void CheckStatus(pcMessage as char):
        define variable CommandError as AppError no-undo.      
        define variable iEntries     as integer no-undo.
        define variable iLine        as integer no-undo.
        define variable cMsg         as character no-undo.
        define variable iError       as integer no-undo.
        
        /* check the last message */
        iEntries  = num-entries(pcMessage,chr(10)).       
        cMsg      = entry(iEntries,pcMessage,chr(10)).
        iError = GetErrorNumber(cMsg).
        if iError = 0 then 
        do:
            /* if last line is prompt throw error 
            (PromptValue = "n", so we have said no)  */
            if IsPrompt(cMsg) then
            do:
                CommandError = new AppError().    
                 
                do iLine = 1 to iEntries - 1:
                   cMsg = entry(iLine,pcMessage,chr(10)).
                   if cMsg > "" then 
                   do:
                       CommandError:AddMessage(cMsg,?).
                   end.
                end. 
                undo, throw CommandError.
            end.
            
        end.          
        else if iError > 0 then 
        do:
            /* keep the prostrct failed error */
            CommandError = new AppError(cMsg,?).         
            
             /* skip  last (prstrct failed - added as first above) */
            do iLine = 1 to iEntries - 1:
                cMsg = entry(iLine,pcMessage,chr(10)).
                if cMsg > "" and (iLine > 1 or (cMsg begins ProgressHeaderStart) = false) then 
                do:
                    iError = GetErrorNumber(cMsg).
                    /* skip  - Error occurred on line (6819) - prostrct syntax error (6840)*/
                    if  iError <> 6819 and iError <> 6840 then
                        CommandError:AddMessage(cMsg,?).
                end. 
            end.
 
            undo, throw CommandError.            
        end.
     end method.
    
end class.