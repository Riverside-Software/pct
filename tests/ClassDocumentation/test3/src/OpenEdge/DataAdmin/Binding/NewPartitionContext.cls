/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Partition context for new partitions not yet created
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Sep 01  2011
    Notes       : The records are generated from schema information 
                  in the data access layer.
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.NewPartitionContext inherits PartitionContext: 

	define protected property DefaultAllocation as char get. set.
	define protected property DefaultDataArea as char get. set.
    define protected property DefaultIndexArea as char get. set.
    define protected property DefaultLobArea as char get. set.
    define protected property TableName as char get. set.
    
    define private variable Type as character no-undo.
    define private variable Factory as IContextFactory no-undo.
     
    /** we're in a local scope, but need service
        passing no to super constructor ensures we get this */  
    constructor public NewPartitionContext (pscope as IContextFactory ):
        super (pscope,no /* not local  */ ).
        Factory = pscope.
    end constructor.
  
    method public override ISaveRequest GetSaveRequest():
        undo, throw new UnsupportedOperationError("Cannot save these partitions.").
    end method.  
    
    /* override to avoid fetching nothing */
    method public override void AddTreeTo(tree as IContextTree,parent as IDataAdminContext).
      
        define variable msg as IFetchRequest no-undo.
        tree:SetJoin(Parent:SerializeName,Serializename,GetJoinFields(Parent:SerializeName)).
        /*
        if Lazy and valid-object(Service) and tree:Parse = false  then
        do: 
            msg = GetRequest().
            FetchData(msg).
        end. 
        */   
 
        super:AddTreeTo(tree).
      
    end method.    
/*                                                                        */
/*    method public override void DataRefreshed (pResp as IFetchResponse):*/
/*        message "service" Service                                       */
/*        view-as alert-box.                                              */
/*        DataRefreshed:                                                  */
/*    end method.                                                         */
   
end class.