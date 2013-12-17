/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IDataDefinitionLoader
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Oct 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

interface OpenEdge.DataAdmin.Binding.IDataDefinitionLoader:
      
    define public property IsReader as logical no-undo get.
     
    define public property Error as AppError no-undo get.  
    
    define public property Warning as AppError no-undo get.  
    
    define public property AddingChildToNewTable as logical no-undo get. set. 
 
     
    method public void AddError( pcText as char ).
    
    method public void AddPhase2Error( pcText as char ).
    
    method public void AddWarning( pcText as char ).
    
    method public void AddError( pError as Error).
         
    method public AppError RemoveWarning (). 
    
    method public AppError RemoveError ().           
    
    method public char RemoveErrorMessages ().         
    
    method public char RemoveWarningMessages ().         

    method public void AddTable(pcAction as char, h as handle,piArea as int).
   
    method public void AddSequence(pcAction as char, h as handle).
    
    method public logical IsNewTable(pcTable as char).
     
    method public void AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int).
     
    method public void AddField(pcAction as char, pcTable as char, h as handle, piArea as int).
    
    method public void RenameTable(pcname as char,pcNewname as char).
    method public void RenameField(pcTable as char, pcname as char,pcNewname as char).
    method public void RenameIndex(pcTable as char, pcname as char,pcNewname as char).
    method public void RenameSequence(pcname as char,pcNewname as char).   
   
    method public char TableOldName(pcNewname as char).
    method public char SequenceOldName(pcNewname as char).
    method public char FieldOldName(pcTable as char, pcNewname as char).
    method public char IndexOldName(pcTable as char, pcNewname as char).
    method public char TableNewName(pcOldname as char).
    method public char SequenceNewName(pcOldname as char).
    method public char FieldNewName(pcTable as char, pcOldname as char).
    method public char IndexNewName(pcTable as char, pcOldname as char).
    
   
end interface.