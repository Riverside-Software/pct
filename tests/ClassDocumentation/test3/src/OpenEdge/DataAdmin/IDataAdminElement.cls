/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IDataAdminElement
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.Core.IElement from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.

interface OpenEdge.DataAdmin.IDataAdminElement inherits IDataAdminSerializable, IElement:  
    
    /** returns the Service the object was retrieved from */
    define public property Service as IDataAdminService no-undo get. 
        
    /** defines the context (or scope?) for the instance.
        Used in Equals() to ensure entities with the same keys  
        - blank means the object has no context (yet)   
            new and not attached (in which case equals is only true if exact same 
            object instance)  
         */
         
    define public property ContextId as char  no-undo           get.
    
      /** Optional definition of unique find critieria for this object and/or queries for child 
        collections. */
    define public property RequestInfo as IRequestInfo no-undo get.  
  
    
    /** Tells whether the instance is in a collection or service. */
    define public property Attached as logical no-undo           get.
    
    /** Attaches the object to the context/model 
        @param context IDataAdminContext that holds the data     
        Call cntxt:CreateRow if IsAttached = false and contextid = "".
        Call cntxt:Copy(oldcontext) if IsAttached is false and context is valid
        
     */
    method public void Attach(cntxt as IDataAdminContext).
       
    /** Import entity data from the specified file (must exist) 
        @param file the file name to imprt from - currently supportes .json only */   
    method public void Import(cFile as char).      
    
    /** Import entity data including child collections from the specified file (the top level entity must exist) 
        @param file the file name to imprt from - currently supportes .json only */   
    method public void ImportTree(cFile as char).    
    
    method public void Export().      
    
    method public void Export(cFile as char).  
    method public void ExportTree(cFile as char).  
    method public void ExportTree(cFile as char,pcCollections as char).  
    
end interface.