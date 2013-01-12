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
using OpenEdge.DataAdmin.IExtentList from propath.
using OpenEdge.DataAdmin.IExtent from propath.
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.Binding.AreaContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
  
class OpenEdge.DataAdmin.ExtentList inherits DataAdminCollection  implements IExtentList  :  
    
    define private variable mLoaded   as logical no-undo.
              
    define public property Area as IArea no-undo get.   set.
    define private variable mAreaContext as AreaContext no-undo.  	
/*	 constructor ExtentList():                                             */
/*        /* the super empty constructor will call CreateLocalContext() */*/
/*        super().                                                        */
/*    end constructor.                                                    */
    
    constructor ExtentList(cntxt as AreaContext):
        super(cntxt).  
        mAreaContext = cntxt.
    end constructor. 
    
    constructor ExtentList(cntxt as IDataAdminContext):
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
         
    method public IExtent Create(piSize as int):
  
    end method.   
    
    method protected override logical AddAll(pcol as IDataAdminCollection).
       undo, throw new UnsupportedOperationError("AddAll() to ExtentList is not supported.").
    end method.
    
    method public override logical Add(o as Object):
        def var ext as IExtent no-undo.
        ext = cast(o,IExtent).
        return this-object:Add(ext).
    end method.  
    
    method public logical Add(pExtent as IExtent):
        if Contains(pExtent) then
            return false.   
           
        pExtent:Attach(Context).
      
        return true.
    end method.  
   
    method public IExtent Get(i as int):
        return cast(Context:FindEntity(i),IExtent).
    end method.    
    
    method public override logical Remove(o as Object):
        define variable ext as IExtent no-undo.
        ext = cast(o,IExtent).
        return Remove(ext).
    end method.  
    
    method public logical Remove(pext as IExtent):
        AssertNotNull(pext,"Extent").
        
        if valid-object(pext:Service) then 
            undo, throw new UnsupportedOperationError("Extent cannot be removed after it has been created.").
        if Contains(pext) then 
            return Context:Delete(pext:Number).
        return false.
    end method.  
    
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IExtent)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(areaextent as IExtent):
        if areaextent:ContextId <> ContextId then
           return false. 
        if not Context:CanFind(areaextent:Number) then
           return false.
        return areaExtent:Equals(this-object:Get(areaextent:Number)).   
    end method.  
    
    /* Returns the index in this list of the specified extent */
    method public integer IndexOf(o as Object):
        def var ext as IExtent no-undo.
        ext = cast(o,IExtent).
        return this-object:IndexOf(ext).
    end method.  
    
    /* The Number is also the list number */
    method public integer IndexOf(pExtent as IExtent). 
        if Contains(pExtent) then
           return pExtent:Number.
        return 0.    
    end method.
    
    method override protected void PrepareExport(  ):

    end method.

    method override protected void PrepareExportTree() :

    end method.

    method override protected void PrepareExportList(  ):

    end method.
end class.
