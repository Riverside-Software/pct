/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Query Partitions for a table 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.Query.SchemaPartitionQuery from propath.
 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.TablePartitionQuery inherits SchemaPartitionQuery: 
	define private variable mTable as character no-undo.
	constructor public TablePartitionQuery ( pdatacontext as PartitionContext, pcTable as character, preq as IRequestInfo):
	 	super (pdatacontext,"tables", pcTable, "","","",preq).
	 	mTable = pcTable. 
	end constructor.
    
     
    
    /** Allocate tenant partitions for the table 
        override to call context and allocate fields and indexes not aprt of the query
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public override logical AllocateTenants(pcAllocationState as char):        
        return cast(this-object:Parent,PartitionContext):AllocateTableTenants(mTable,pcAllocationState).
    end method.
    
    /** Allocate tenant partitions for the table 
        override to call context and allocate fields and indexes not aprt of the query
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public override logical AllocateGroups(pcAllocationState as char):        
         return cast(this-object:Parent,PartitionContext):AllocateTableGroups(mTable,pcAllocationState).
    end method.
    /*
    method public override logical Deallocate(): 
        define variable rid as rowid no-undo. 
        define variable lTrack as logical no-undo.
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true. 
        rid = BufferHandles[1]:rowid.
        QueryHandle:get-first ().
        do while BufferHandles[1]:avail: 
            if BufferHandles[1]::TenantName > "" 
            and BufferHandles[1]::AllocationState = "Allocated" then
            do:
                BufferHandles[1]::AllocationState = "None".
            end. 
            QueryHandle:get-next ().
        end.
        finally:
            TableHandle:tracking-changes = lTrack.          
            if rid <> ? then
                QueryHandle:reposition-to-rowid(rid). 
        end finally.      
    end method.
    */     
end class.