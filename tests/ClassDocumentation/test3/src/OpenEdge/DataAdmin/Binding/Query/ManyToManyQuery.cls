 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Many to many where join is hidden
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Sep 04 00:17:40 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.ManyToManyQuery abstract inherits FilteredContext: 
  	
  	/** Parent context (Model) may change  - this is updated in NewContext */
  	define protected variable UpdateContext as IDataAdminContext no-undo.	
	
	define protected property ChildSerializeName as character no-undo
	   get.
	   private set.   
	
	/* multiple keys - unlikely for these ?  
	constructor public ManyToManyQuery (psourcecntxt as IDataAdminContext,pcparent as character,pcKeyvalues as character extent,pchild as char, pReq as IRequestInfo ):
		super (psourcecntxt,pcparent,pcKeyvalues,pReq).		
	end constructor.
    */
   
    constructor public ManyToManyQuery (psourcecntxt as IDataAdminContext,pcparent as character,pcKeyvalues as character ,pchildname as char, pReq as IRequestInfo ):         
        super (psourcecntxt,pcparent,pcKeyvalues,pReq). 
        ChildSerializeName = pchildname.
        UpdateContext = psourcecntxt:GetChild(pchildname).
        UpdateContext:RowCreated:Subscribe(Reopen).
        UpdateContext:RowDeleted:Subscribe(Reopen).
    end constructor.
    
    method protected override void NewContext(pCntxt as IDataAdminContext):
        if valid-object(UpdateContext) then
        do:
            UpdateContext:RowCreated:Unsubscribe(Reopen).
            UpdateContext:RowDeleted:Unsubscribe(Reopen).
        end.
        super:NewContext(pCntxt).
        UpdateContext = pCntxt:GetChild(ChildSerializeName).
        UpdateContext:RowCreated:Subscribe(Reopen).
        UpdateContext:RowDeleted:Subscribe(Reopen).
    end method.
    
    
    /** subclasses deals with the calls to the updatecontext for these for now 
       the updatecontext would typically have methods for both keys 
       some logic to deal with the field order would be needed to move this here
        */ 
    method public abstract override logical CanFind(pname as character). 
    method public abstract override logical Find(pname as character). 
    method public abstract override logical Delete(pname as character). 
    
    /** the collection should override Add to call this and avoid elem:Attach   */ 
    method public abstract override void CreateRow (elem as IDataAdminElement). 
     
end class.