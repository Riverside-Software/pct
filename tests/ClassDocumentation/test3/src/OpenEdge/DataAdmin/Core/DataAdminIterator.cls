/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
/*------------------------------------------------------------------------
   File        : DataAdminIterator
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : hdaniels
   Created     : Fri Aug 27 20:20:38 EDT 2010
   Notes       : 
 ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.Binding.IIterable from propath.
using OpenEdge.DataAdmin.IPartitionCollection from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Lang.Collections.Iterator from propath.
using OpenEdge.DataAdmin.Lang.Collections.ICollection from propath.

class OpenEdge.DataAdmin.Core.DataAdminIterator inherits Iterator: 
	
    define protected property Iterable  as IIterable no-undo 
        get.
        set. 
    
    define private variable mUseQuery  as logical no-undo.
   
   /* we only support query and sort together */
   constructor public DataAdminIterator (pIterable as IIterable,  querystring as character ):
        super (pIterable:IteratorHandle,pIterable:Table, pIterable:EntityFieldName, "", querystring).
        Iterable = pIterable.
        if pIterable:IteratorHandle:type = "query" then
        do:
           mUseQuery = piterable:IteratorHandle:num-buffers > 1 or querystring = "".
        end.    
        catch e as Error :
            if not valid-handle(pIterable:IteratorHandle) then 
                undo, throw new UnknownValueError("DataAdminIterator constructor","handle").         
        end catch.    
    end constructor. 
 
    constructor public DataAdminIterator ( pIterable as IIterable):
        this-object (pIterable,"").
    end constructor.
        
    method public override Object Next(  ):
        define variable nextObj as Object no-undo.
        define variable ifld as integer no-undo.
                    
        QueryHandle:get-next().
        if BufferHandle:avail then 
        do:
            nextObj = ObjectFieldHandle:buffer-value().
            if not valid-object(nextObj) then
               nextObj = Iterable:FindEntity(if mUseQuery then QueryHandle else BufferHandle).          
            return nextObj.
        end.
        else 
            return ?.
    end method.
    
    method public override logical Remove(  ):
        if BufferHandle:avail then 
            return Iterable:Remove(if mUseQuery then QueryHandle else BufferHandle).
        return false.    
    end method.
         
end class.