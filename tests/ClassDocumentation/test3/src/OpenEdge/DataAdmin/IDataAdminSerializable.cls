/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : serializable interface 
                  Defines a common property and methods for both 
                  entities and collections
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Aug 17 09:05:17 EDT 2010
    Notes       : subcinterfaces are IDataAdminEntity and IDataAdminCollection
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.IRequestInfo.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
interface OpenEdge.DataAdmin.IDataAdminSerializable:  
    /** External name of the entity (plural - first character lowercase)
        used in JSON and also as parameter in methods that defines a filter or list of collections */
    define public property SerializeName as char no-undo get.     
    
   define public property RequestInfo as IRequestInfo no-undo get.  
    
    /** Writetree is a visitor/serialize method that adds this object and the specified collections to the 
        passed ContextTree. The context tree wraps a dynamically created dataset  
        @param tree the IContextTree to add the object to
        @collections collections comma spearated list of child collections to add to the tree */           
    method public void WriteTree(tree as IContextTree,pcCollections as char).      
    
    /** Writetree is a visitor/serialize method that adds this object and its collections to the passed ContextTree
        The context tree is really a dynamically created dataset 
        @param tree the IContextTree to add the object to */           
    method public void WriteTree(tree as IContextTree).
    
    
    /*          
    method public void WriteList(tree as IContextTree).          
    method public void WriteObject(tree as IContextTree).          
    */   
    
end interface.