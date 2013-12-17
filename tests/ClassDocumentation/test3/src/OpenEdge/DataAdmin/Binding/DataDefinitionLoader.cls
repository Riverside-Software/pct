/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DataDefinitionLoader
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Oct 03 00:59:29 EDT 2010
    Notes       :
       WARNING  : inherited by prodict/dump/_load_logger             
                  used by prodict load_df.p and sub load procedures
              -  The class currently implements empty stub for the stuff that is used when 
                 IsReader = true. DataDefinitionParser overrides these.     
                 
                 These methods should/could be moved out into the IDataDefintionParser interface. 
                 This would require a change to cast the class in prodict    
                 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Binding.IDataDefinitionLoader from propath. 
using OpenEdge.DataAdmin.Binding.DataDefinitionOptions from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError  from propath. 

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.DataDefinitionLoader  implements IDataDefinitionLoader: 
    define variable mUnsupported as character no-undo 
       init "&1 in DatadefinitionLaoder. Use DataDefinitionParser instead.".

    define public property IsReader as logical no-undo 
        init false 
        get. 
        protected set.
        
    define public property Error as AppError no-undo 
        get.
        private set. 
    
    define public property Warning as AppError no-undo 
        get.
        private set. 
    
    define public property AddingChildToNewTable as logical no-undo get. set. 
 
    
    define protected property ErrorLogMessage as character no-undo 
    get():
        return "".
        /*
        return "Please check " 
               + quoter(ErrorLog) 
               + " for load errors and/or warnings.".
        */
    end.
    set. 
    
    method private AppError  GetError():
        define variable cMsg as character no-undo.
        if not valid-object(Error) then
        do:  
            cMsg = "Error occurred during load of data definitions. "
                  + ErrorLogMessage.       
            this-object:Error = new AppError(cMsg).
            this-object:Error:AddMessage(cMsg,?).
        end.    
        return this-object:Error.    
    end.
    
    method private AppError  GetPhase2Error():
        define variable cMsg as character no-undo.
        if not valid-object(Error) then
        do:  
            cMsg = "Definitions for policies and attributes are loaded in a separate transaction.":t77
                 + " Errors caused that transaction to rollback. Other definitions were committed.":t78
                 + ErrorLogMessage.       
            this-object:Error = new AppError(cMsg).
            this-object:Error:AddMessage(cMsg,?).
        end.    
        return this-object:Error.    
    end.
    
    method private AppError  GetWarning():
        define variable cMsg as character no-undo.
        if not valid-object(this-object:Warning) then
        do:  
            cMsg = "Warnings from load of data definitions. "
                  + ErrorLogMessage.       
            this-object:Warning = new AppError(cMsg).
            this-object:Warning:AddMessage(cMsg,?).
        end.    
        return this-object:Warning.    
    end.
    
    method public void AddError( pcText as char ):
        define variable Err as AppError no-undo. 
        Err = GetError().
        Err:AddMessage(pctext,?).
    end method.
    
    method public void AddPhase2Error( pcText as char ):
        define variable Err as AppError no-undo. 
        Err = GetPhase2Error().
        Err:AddMessage(pctext,?).
    end method.
    
    method public void AddWarning( pcText as char ):
        define variable Err as AppError no-undo. 
        Err = GetWarning().
        Err:AddMessage(pctext,?).
    end method.
    
    method public void AddError( pError as Error):
        define variable i as integer no-undo.
        define variable iStart as integer no-undo.
        
        do i = 1 to pError:NumMessages:
              if i = 1 and type-of(pError,AppError) 
              and pError:GetMessage(i) = "" then                      
                 GetError():AddMessage(cast(pError,AppError):ReturnValue,?).
              else                                                            
                 GetError():AddMessage(pError:GetMessage(i),?).
        end.
    end method.
    
     method public AppError RemoveWarning ():
        define variable reterror as AppError no-undo.    
        reterror = this-object:Warning.
        this-object:Warning = ?.
        return reterror.
    end method. 
    
    method public AppError RemoveError ():
        define variable reterror as AppError no-undo.    
        reterror = this-object:Error.
        this-object:Error = ?.
        return reterror.
    end method.           
    
    method public char RemoveErrorMessages ():
        define variable Err as AppError no-undo.
        Err = RemoveError(). 
        return GetMessages(Err).
    end method.         
    
    method public char RemoveWarningMessages ():
        define variable Err as AppError no-undo.
        Err = RemoveWarning(). 
        
        return GetMessages(Err).
    end method.     
        
    method private char GetMessages (pError as AppError):
        define variable i as integer no-undo. 
        define variable cmsg as char no-undo. 
        
        if valid-object(pError) then
        do:
            do i = 1 to pError:NumMessages:
                 cmsg = cmsg 
                      + (if cmsg = "" then "" else chr(10)) 
                      + pError:GetMessage(i).
            end.
            
            return cmsg. 
        end.
    end method.         
    
    method public void AddTable(pcAction as char, h as handle,piArea as int):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"AddTable")).
    end method.
     
    method public void AddSequence(pcAction as char, h as handle):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"AddSequence")).
    end method.
    
    method public void AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int):
          undo, throw new UnsupportedOperationError(substitute(mUnsupported,"AddIndex")).
    end method.
     
    method public void AddField(pcAction as char, pcTable as char, h as handle, piArea as int):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"AddField")).
    end method.
    
    method public logical IsNewTable(pcTable as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"IsNewTable")).
    end method. 
    
    method public void RenameTable(pcname as char,pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"RenameTable")).
    end method.
    method public void RenameField(pcTable as char, pcname as char,pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"RenameField")).
    end method.
    method public void RenameIndex(pcTable as char, pcname as char,pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"RenameIndex")).
    end method.
    method public void RenameSequence(pcname as char,pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"RenameSequence")).
    end method. 
    
    method public char TableOldName(pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"TableOldName")).
    end method.
    method public char FieldOldName(pcTable as char, pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"FieldOldName")).
    end method.
    method public char IndexOldName(pcTable as char, pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"IndexOldName")).
    end method.
    method public char SequenceOldName(pcNewname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"SequenceOldName")).
    end method.
    method public char FieldNewName(pcTable as char, pcOldname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"FieldNewName")).
    end method.
    method public char IndexNewName(pcTable as char, pcOldname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"IndexNewName")).
    end method.
    method public char TableNewName(pcOldname as char):
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"TableNewName")).
    end method.    
    method public char SequenceNewName(pcOldname as char).
        undo, throw new UnsupportedOperationError(substitute(mUnsupported,"SequenceNewName")).
    end method.
    
         
end class.