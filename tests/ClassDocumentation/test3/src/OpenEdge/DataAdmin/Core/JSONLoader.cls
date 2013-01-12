/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : JSONLoader
    Purpose     : 
    Syntax      : 
    Description :
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:18:09 EDT 2010
    Notes       : The loader updates existing collections and is different from a
                  reader that would create new (detached) object instances. 
                  The loader also creates objects, but it adds them to an existing 
                  (attached) collection.            
               -  Part of the reason for using this also for create is that 
                  we want to support parent-child import from JSON that has 
                  foreign key hidden. dataset:read-json cannot infer the relationship
                  into a new dataset in this case, so we need to call the collections 
                  which will load the json into an existing context.   
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.*  from propath. 
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Core.DataAdminWriter from propath. 

class OpenEdge.DataAdmin.Core.JSONLoader  inherits DataAdminWriter  :  
    define private variable mDs as handle no-undo.  
	constructor public JSONLoader (  ):
		super (). 
    end constructor.
    
    destructor public JSONLoader (  ):
        delete object mDs no-error.
    end destructor.
   
    method public void LoadFromFile(serializable as IDataAdminSerializable,pcFile as char,pcMode as char):
         LoadFromFile(serializable,pcfile,pcMode,"All").
    end method.
    
    method public void LoadFromFile(serializable as IDataAdminSerializable,pcFile as char,pcMode as char,pccollection as char):
        define variable h as handle no-undo.
        h = this-object:Load(serializable,pccollection /*pcMode*/ ).
        Trackchanges(h, yes).    
       
        h:read-json ("File",pcFile,pcMode).
        CheckRead(serializable, h).
        delete object mDs no-error.
        mDs = h.
    end method.
    
    method public void LoadFromLongchar(serializable as IDataAdminSerializable,pLong as longchar,pcMode as char):
         LoadFromLongChar(serializable,pLong,pcMode,"All").
    end method.
    
    method public longchar LoadFromLongchar(serializable as IDataAdminSerializable,pcl as longchar,pcmode as char,pccollection as char):
        define variable h as handle no-undo.
        define variable cl as longchar no-undo.
        h = this-object:Load(serializable,pcCollection).
        Trackchanges(h, yes).
        h:read-json ("Longchar",pcl,pcMode). 
        CheckRead(serializable, h).
    end method.
    
    method public void LoadFromMemptr(serializable as IDataAdminSerializable,m as memptr,pcMode as char):
        LoadFromMemptr(serializable,m,pcMode,"All").
    end method.
    
    method public void LoadFromMemptr(serializable as IDataAdminSerializable,m as memptr,pcMode as char,pccollection as char):
        define variable h as handle no-undo.       
        h = this-object:Load(serializable,pccollection).
        Trackchanges(h, yes).
        h:read-json ("memptr",m,pcMode). 
        CheckRead(serializable, h).
    end method.
    
    method public void LoadFromStream(serializable as IDataAdminSerializable,phStream as handle,pcMode as char):
        LoadFromStream(serializable,phStream,pcMode,"All").
    end method.
    
    method public void LoadFromStream(serializable as IDataAdminSerializable,phStream as handle,pcMode as char,pccollection as char):
        define variable h as handle no-undo.
       /* rename load to parse or ? */
        h = this-object:Load(serializable,pccollection).
        Trackchanges(h, yes).
        h:read-json("STREAM-HANDLE",phStream,pcMode).  
        CheckRead(serializable, h).
    end method.
    
    method private void CheckRead(serializable as IDataAdminSerializable,hds as  handle):
        if type-of(serializable,IDataAdminElement) then
        do:
              
        end.    
        TrackChanges(hds,no).
    end method.    
    
    method private void TrackChanges(hds as  handle, pl as logical):
        define variable i as integer no-undo.
        define variable hbuffer as handle no-undo.
        do i = 1 to hds:num-buffers:
             hbuffer = hds:get-buffer-handle (i).
             if valid-handle(hBuffer:before-buffer) then 
             do:
                hbuffer:table-handle:tracking-changes =  pl.   
       
             end.
        end.    
    end method.
    
    method private void showDS(hds as  handle):
        define variable i as integer no-undo.
        define variable hrel as handle no-undo.
        do i = 1 to hds:num-relations:
             hrel = hds:get-relation(i).
             
            if not session:batch-mode then
            do:
                message 
                hrel:parent-buffer:name hrel:parent-buffer:serialize-name skip
                hrel:child-buffer:name hrel:child-buffer:serialize-name
             
                view-as alert-box.
            end.                
             
        end.    
    end method.
      
end class.
