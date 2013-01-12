/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ExtentList
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
  
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataFileList from propath.
using OpenEdge.DataAdmin.IDataFile from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
  
class OpenEdge.DataAdmin.DataFileList inherits DataAdminCollection  implements IDataFileList  :  
    
              
/*	 constructor ExtentList():                                             */
/*        /* the super empty constructor will call CreateLocalContext() */*/
/*        super().                                                        */
/*    end constructor.                                                    */
    
    constructor DataFileList(cntxt as IDataAdminContext):
        super(cntxt).  
    end constructor. 
    
/*    constructor ExtentList(cntxt as FilteredContext):*/
/*        super(cntxt).                                */
/*                                                     */
/*    end constructor.                                 */
      
    method override protected IDataAdminContext CreateLocalContext(  ):
        return ?.
    end method.
/*    method public override logical Contains(obj as Object):*/
/*    end method.                                            */
         
    method protected override logical AddAll(pcol as IDataAdminCollection).
       undo, throw new UnsupportedOperationError("AddAll() to DataFileList is not supported.").
    end method.
    
    method public override logical Add(o as Object):
        undo, throw new UnsupportedOperationError("Add() to DataFileList is not supported.").
    end method.  
    
    method public IDataFile Get(i as int):
        return cast(Context:FindEntity(i),IDataFile).
    end method.    
    
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IDataFile)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(pfile as IDataFile):
        if pfile:ContextId <> ContextId then
           return false. 
        if not Context:CanFind(pfile:TableSequence) then
           return false.
        return pfile:Equals(this-object:Get(pfile:TableSequence)).   
    end method.  
    
    /* Returns the index in this list of the specified extent */
    method public integer IndexOf(o as Object):
        def var fil as IDataFile no-undo.
        fil = cast(o,IDataFile).
        return this-object:IndexOf(fil).
    end method.  
    
    /* The Number is also the list number */
    method public integer IndexOf(pfile as IDataFile). 
        if Contains(pfile) then
            return pfile:TableSequence.
        return 0.    
    end method.
    
    method override protected void PrepareExport(  ):

    end method.

    method override protected void PrepareExportTree() :

    end method.

    method override protected void PrepareExportList(  ):

    end method.
end class.
