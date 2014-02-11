 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Abstract class that executes opsys commands silently 
                  and picks up errors.
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 16:25:38 EDT 2011
    Notes       : Subclasses 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.IServerCommand from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
      
class OpenEdge.DataAdmin.ServerCommand.ProCommand abstract implements IServerCommand: 
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	define protected property DatabaseName as char no-undo get. set.
	
	/* name of utility/command without path */ 
	define protected abstract property CommandName  as char no-undo get. set.
    /* prompt respons - typically "y" to continue */
    define protected property PromptValue as char no-undo get. set.
    define protected property UseBatFile as logical no-undo init true get. set.
    define protected property ProgressHeaderStart as char init "OpenEdge Release " no-undo get.
    define private variable mresponse as IUtilityResponse no-undo. 
    define protected property Slash as char no-undo 
       get():
           return if opsys = "win32" then "~\" else "/".
       end. 
       
    define protected property CommandFullName  as char no-undo 
        get():
            define variable cDlc as character no-undo.
            
            cDlc = GetDLC(). 
            
            if opsys = "Win32":U then 
              cDlc = replace(cDLC,"/",Slash).
            
            return quoter(cDLC + Slash + "bin" + Slash + CommandName).       
        end.
       
	constructor public ProCommand (pcdbname as char  ):
		super ().
		DatabaseName = pcdbname.
	end constructor.

    method public void Execute(prequest as IUtilityRequest):
        RunCommand(GetCommandParameters(pRequest)).  
        mResponse = cast(pRequest,IUtilityResponse).
    end method.
    
    method protected abstract char GetCommandParameters(pRequest as IUtilityRequest).
    
    method protected char GetDLC():
        define variable cDLC as character no-undo.
        if opsys = "Win32":U then /* Get DLC from Registry */
            get-key-value section "Startup":U key "DLC":U value cDLC.
        if (cDLC = "" or cDLC = ?) then 
        do:
            cDLC = os-getenv("DLC":U). /* Get DLC from environment */
        end.
        return cDlc.
    end method.
    
    method protected void RunCommand(pcCommand as char):
        define variable i          as integer no-undo.
        define variable fileext    as character no-undo.
        define variable cTmpFile   as character no-undo.
        define variable cLogFile   as character no-undo.
        define variable cCommand   as character no-undo.
        define variable cLine      as character no-undo.
        define variable cMessage   as character no-undo.
        
        cCommand = CommandFullName + " " + pcCommand.
        
        if PromptValue > "" then 
            cCommand = "echo " + PromptValue + " | " + cCommand.     
        
        run adecomm/_tmpfile.p ("", ".tmp",   OUTPUT cLogFile).
               
        /* if windows use the shortname to avoid problems with spaces in directoryname 
           when using os-command redirect > filename */
        if OPSYS = "WIN32" then
        do:
            
            output to value(cLogfile).          
            output close.
                 
            run adecomm/_getshortpathname.p(cLogFile,output cLogFile).
        
        end.    
        if UseBatFile then
        do:   
            if OPSYS = "WIN32" then
               assign fileext = ".bat".
            else
               assign fileext = ".sh".
             
            run adecomm/_tmpfile.p ("", fileext, OUTPUT cTmpFile).
     
            output to value(cTmpFile) no-echo.
            
            if OPSYS = "WIN32" THEN DO:           
               put unformatted "@ECHO OFF" skip.
               put unformatted cCommand skip.
               put unformatted "echo %errorlevel%".
            end.
            else do:
               put unformatted "#!/bin/sh " skip.
               put unformatted cCommand skip.
               put unformatted "echo $?".            
            
            end. 
                  
            output close. 
            
            if opsys = "WIN32" then         
                os-command silent value(cTmpfile + " > " + cLogfile).   
            else
                os-command silent value("/bin/sh " + cTmpfile + " > " + cLogfile).   
            
            os-delete value(cTmpFile).
        end.
        else   
            os-command silent value(cCommand + " > " + cLogfile).
       
        /* this could save us from output log, but cannot be done silenty on windows it seems (?)
           input-output through value(lTmpFile).*/
        input from value(cLogFile). 
        
        i = 0.
        repeat:
            import unformatted cLine.
            cMessage = cMessage + cLine + chr(10).
            i = i + 1.
        end.
        
        os-delete value(cLogFile). 
        /* deallocate does not have output ?
        if i = 0 then 
            undo, throw new AppError("OS command: " + CommandFullName + " failed to execute.").  
        */
        cMessage = trim(cMessage,chr(10)).
        CheckStatus(cMessage).
    end method.
    
    /** 
    Throws an error with error text from the passed command output if necessary 
    
    @param  pcMessage chr(10) separated list of output from command 
    
    Subclasses override this to handle utility specific messages 
    The default assumes the following  
    ---------------------------
    OpenEdge Release ...... as of Fri Jul 8 19:02:09 EDT 2011
    <utility text> (12345)
    Do you want to continue (y/n)? (13706)
    ------ 
    or (the openedge release is not always there even for the same utility)
    ---------------------------
    <utility text> (12345)
    Do you want to continue (y/n)? (13706)
    ------ 
    
    The last line is assumed if PromptValue is set     
    **/
        
    method protected void CheckStatus(pcMessage as char):
        define variable iStatus      as integer   no-undo.
        define variable CommandError as AppError no-undo.      
        define variable iEntries     as integer no-undo.
        define variable iLine        as integer no-undo.
        define variable iStart       as integer no-undo.
        define variable cMsg         as character no-undo.
        define variable lAnyMsgAdded    as logical no-undo.
        
        if entry(1,pcMessage,chr(10)) begins ProgressHeaderStart then
           iStart = 3.
        else 
           iStart = 2.        
        
        if PromptValue > "" then 
           iStart = iStart + 1.
         
        iEntries  = num-entries(pcMessage,chr(10)).       
        iStatus   = int(entry(iEntries,pcMessage,chr(10))) no-error.
     
        if istatus <> 0 then 
        do:
           CommandError = new AppError().         
           do iLine = iStart to iEntries - 1.
               cMsg = entry(iLine,pcMessage,chr(10)).
               if cMsg > "" then
               do:
                  CommandError:AddMessage(cMsg,?).
               end. 
           end.
           /* if we did not find any messagesthen just show the whole thing */
           if CommandError:NumMessages = 0 then
                CommandError:AddMessage(pcMessage,?).
                
           undo, throw CommandError.
         
        end. 
    end method.
    
    method protected int GetErrorNumber(pcMessage as char):        
        define variable i1 as integer no-undo.
        define variable i2 as integer no-undo.
        define variable iNum as integer no-undo.
        
        i1 = r-index(pcMessage,"(").
        i2 = r-index(pcMessage,")").
        
        if i2 > i1 and i1 > 0 and i2 = length(pcMessage) then
        do on error undo, throw: 
            iNum = int(substr(pcMessage,i1 + 1,i2 - (i1 + 1))).
            return iNum.
            catch e as Progress.Lang.Error :      
            end catch.
        end.     
        return 0.
              
    end method.
    
    /* does the text end with ?  or parenthesis but not number (y/n) */
    method protected logical IsPrompt(pcMessage as char):        
        define variable i1 as integer no-undo.
        define variable i2 as integer no-undo.
        define variable iNum as integer no-undo.
        
        i1 = r-index(pcMessage,"?").
        if i1 = length(pcMessage) then 
           return true.    
        
        i2 = r-index(pcMessage,")").
        if i2 > 0  and i2 = length(pcMessage) then
        do:  
            i1 = r-index(pcMessage,"(").
            if i1 > 0 then
            do on error undo, throw: 
                iNum = int(substr(pcMessage,i1 + 1,i2 - (i1 + 1))).
                return false.
                catch e as Progress.Lang.Error:
                    return true.
                end catch.
            end.
        end. 
        return false.
    end method.
    
    method public IUtilityResponse GetResponse():
        return mResponse.
    end method.
end class.