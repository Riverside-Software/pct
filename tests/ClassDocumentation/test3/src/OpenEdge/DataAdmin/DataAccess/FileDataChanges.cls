 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 
 /*------------------------------------------------------------------------
    File        : FileDataChanges
    Purpose     : .df changes
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
 
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.FetchDefinitions from propath.
using OpenEdge.DataAdmin.Message.LoadDefinitions from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.DataAccess.FileDataChanges inherits DataAccess implements IDataAccess: 
    define data-source dsFile for dictdb._File.
    define data-source dsField for dictdb._Field.
    define data-source dsIndex for dictdb._index.    
    
    define private variable mURL as character no-undo.
    define private variable AreaURL as character no-undo.
    
    method protected override void SetUrl(pcUrl as char):
        mURL = pcURL.
        AreaURL = pcURL + "/areas/".
    end method.
    
    
    
    method public override void FetchData(msg as IFetchRequest):
        define variable c  as FetchDefinitions no-undo.
        FetchData(cast(msg,FetchDefinitions)).
    end method.
    
    method public void FetchData(msg as FetchDefinitions):
        SetUrl(msg:URL). 
        DatasetHandle = msg:DataHandle.
        FillData(msg).
    end method.
    
    method public override ISaveRequest SaveData(msg as ISaveRequest): 
         return SaveData(cast(msg,LoadDefinitions)).    
    end method.     
         
    method public ISaveRequest SaveData(msg as LoadDefinitions):
     
        run prodict/dump/_load_df.p(msg).   
 
        if valid-object(msg:Logger:Error) then
           undo, throw msg:Logger:Error.
        return msg.  
    end method.     
    
        
    
	method protected void FillData(msg as FetchDefinitions):
	    define variable hSchema as handle no-undo.
/*	    define variable cWarnings as character no-undo.*/
	  
	    hSchema = DatasetHandle:get-buffer-handle ("ttSchema").
	    hSchema:buffer-create(). 
        hSchema::name = "PUB".
        run prodict/dump/_load_df.p(msg).
        if valid-object(msg:Logger:Error) then     
            undo, throw msg:Logger:Error.            
           
	end method.
   
end class.
