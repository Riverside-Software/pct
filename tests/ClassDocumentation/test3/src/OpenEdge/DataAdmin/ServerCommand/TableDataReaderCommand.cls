 /*************************************************************/
  /* Copyright (c) 2012 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableDataReaderCommand.cls
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.TableDataCommand from propath.
using OpenEdge.DataAdmin.Binding.ITableDataMonitor from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.ServerCommand.TableDataReaderCommand inherits TableDataCommand: 
    
    define protected override property IsLoad as logical init true no-undo get.   
    
    constructor public TableDataReaderCommand (databasename as char):
        super (databasename).   
    end constructor. 
    
    /** call the execution method in the persistent procedure */ 
    method override protected void DoCommand(): 
        run doLoad in ProcedureHandle.
    end method.
     
    method override protected handle StartProcedure(): 
        define variable hProc as handle no-undo.
        /* initially set "All", this will be reset based on tableselection later */
        run prodict/load_d.p persistent set hProc
                 ("ALL", ttUtilityOptions.Directory).
        return hProc.         
    end method.    
    
    method override protected void HookProcedure(): 
        run SetAcceptableErrorPercentage in ProcedureHandle
                                       (ttUtilityOptions.AcceptableErrorPercentage).
    end method.    
    
end class.