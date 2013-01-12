 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : LocaContextFactory
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Sep 13 23:54:43 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.Binding.NewPartitionContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using  OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.
using OpenEdge.DataAdmin.Binding.Factory.AbstractContextFactory.
 

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Factory.LocalContextFactory inherits AbstractContextFactory: 
    
    define protected property ServiceFactory as IServiceContextFactory no-undo get. set.
    
	define override public property IsLocal as logical no-undo 
	init TRUE
	get.
	  
	define public override property PartitionContext as PartitionContext no-undo 
        get(): 

             if not valid-object(PartitionContext) then
             do:
                 PartitionContext = new NewPartitionContext(this-object).
             end.
             return PartitionContext.
         end.
         set.
    
	constructor public LocalContextFactory ( pServiceFactory as IServiceContextFactory ):
		super (pServiceFactory:Service, pServiceFactory:ServiceAdapter).	
	    ServiceFactory = pServiceFactory.
	    Service:ServiceDeleted:Subscribe(this-object:Destroy). 
	end constructor.
    
    method protected void Destroy().
        delete object this-object.
    end method.
    
end class.