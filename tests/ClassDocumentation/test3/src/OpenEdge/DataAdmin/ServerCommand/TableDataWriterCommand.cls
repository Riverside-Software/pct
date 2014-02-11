 /*************************************************************/
  /* Copyright (c) 2012 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableDataWriterCommand.cls
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.TableDataCommand from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.ServerCommand.TableDataWriterCommand inherits TableDataCommand: 
    
    define protected override property IsLoad as logical init false no-undo get.   
    define private property UTF-8            as char init "utf-8" no-undo get.   
    
    constructor public TableDataWriterCommand (databasename as char):
        super (databasename).   
    end constructor.
   
    /** call the execution method in the persistent procedure */ 
    method override protected void DoCommand(): 
        run doDump in ProcedureHandle.
    end method.
     
    method override protected handle StartProcedure(): 
        define variable hProc as handle no-undo.
        /* initially set "All", this will be reset based on tableselection later */
        run prodict/dump_d.p persistent set hProc
                 ("ALL", ttUtilityOptions.Directory, ttUtilityOptions.codePage).
        return hProc.         
    end method.    
    
    method override protected void HookProcedure(): 
        run setMap in ProcedureHandle(if ttUtilityOptions.NoMap 
                            then "NO-MAP" 
                            else if ttUtilityOptions.CharacterMap <> "" 
                                 then ("MAP" + " " + ttUtilityOptions.CharacterMap) 
                                 else "").
        
        if ttUtilityOptions.SkipCodePageValidation then
            run setSkipCodePageValidation in ProcedureHandle (ttUtilityOptions.SkipCodePageValidation).                        
    
    end method.
    
    method protected override void ValidateOptions():    
        define variable cMsg as character no-undo.
        if not ttUtilityOptions.SkipCodePageValidation then
        do:
            if DatabaseInfo:CodePage = UTF-8
            and (session:charset ne UTF-8 or TRIM(ttUtilityOptions.CodePage) ne UTF-8) then 
            do:
                cMsg = "The database codepage is 'UTF-8' but -cpinternal and/or the codepage" + "~n" +
                       "for output is not, which can cause some data not to be dumped properly" + "~n" +
                       "if it cannot be represented in that codepage." + "~n" +
                       "It's recommended that you dump the data from a session with the 'UTF-8'" + "~n" +
                       "codepage to avoid possible data corruption.".
                undo, throw new AppError(cMsg,?).
            end.
        end.
        super:ValidateOptions().
    end method.   
        
end class.