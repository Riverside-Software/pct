/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : abstract query for partitions of a schema element 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 2011
    Notes       : Known subclasses TablePartitionQuery, IndexPartitionQuery 
                  and FieldPartitionQuery 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath.
 
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.PartitionQuery from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.SchemaPartitionQuery abstract inherits PartitionQuery implements IPartitionContext: 
	/*------------------------------------------------------------------------------
			Purpose: Used for a collection of partitions of a schema element
			 		 mapped by tenant or group															  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	/** Parent context (Model) may change so don't store this */
	define private property PartitionContext as PartitionContext no-undo
	    get():
	        return cast(Parent,PartitionContext).   
	    end.
	    
    define protected variable TableName as character no-undo.
	define protected variable FieldName as character no-undo.
    define protected variable IndexName as character no-undo.
    define protected variable Collation as character no-undo.
    
    constructor protected SchemaPartitionQuery (pdatacontext as PartitionContext,pcparent as char,pcTable as char,pcfield as char, pcIndex as char,pccollation as char,preq as IRequestInfo):
 	    super (pdatacontext,pcParent,GetValues(pcTable,pcfield,pcIndex,pccollation),pReq).    
 	    assign
 	        TableName = pcTable
 	        FieldName = pcfield
 	        IndexName = pcIndex
 	        Collation = pccollation.
	end constructor.
    
    method private char extent 4 GetValues(pcTable as char,pcfield as char, pcIndex as char,pccollation as char):
        define variable cValues  as character extent 4 no-undo.
        
        assign
            cValues[1] = pctable
            cValues[2] = pcfield
            cValues[3] = pcIndex
            cValues[4] = pccollation.
        return cValues.
    end.
     
    method public override logical CanFind(pname as character):
        undo, throw new UnsupportedOperationError("SchemaPartitionQuery CanFind with single key").
    end.    
     
    method public override logical Find(pname as character):
        undo, throw new UnsupportedOperationError("SchemaPartitionQuery Find with single key").
    end.    
    
/*    method public override IFetchRequest GetQueryRequest():*/
/*        define variable tree   as IContextTree no-undo.    */
/*        define variable hds    as handle no-undo.          */
/*                                                           */
/*        tree = new ContextTree().                          */
/*        AddTableTo(tree).                                  */
/*        hds = tree:GetReadHandle().                        */
/*        return new FetchRequest(Name,Id,hds).              */
/*                                                           */
/*    end method.                                            */
/*                                                           */
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            /*
            hbuffer:buffer-field ("SchemaName"):serialize-hidden = true.
            hbuffer:buffer-field ("SequenceName"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
             */
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
    method public logical CanFindTenant(pcTenant as char):      
        return PartitionContext:CanFindTenant(pcTenant,TableName,FieldName,Indexname,Collation).
    end method.
    
    method public logical CanFindGroup(pcGroup as char):      
        return PartitionContext:CanFindGroup(pcGroup,TableName,FieldName,Indexname,Collation).
    end method.
    
     method public logical FindTenant(pcTenant as char):
         return PartitionContext:FindTenant(pcTenant,TableName,FieldName,Indexname,Collation).
     end method.
    
    method public logical FindGroup(pcGroup as char):
        return PartitionContext:FindGroup(pcGroup,TableName,FieldName,Indexname,Collation).
    end method.
       
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):      
        if pcTable = TableName and pcField = FieldName and pcIndex = Indexname and pcCollation = Collation then  
            return CanFindTenant(pcTenant).
        else
            return false.
    end method.
    
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        if pcTable = TableName and pcField = FieldName and pcIndex = Indexname and pcCollation = Collation then  
            return CanFindGroup(pcGroup).
        else
            return false.
    end method.
    
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        if pcTable = TableName and pcField = FieldName and pcIndex = Indexname and pcCollation = Collation then  
            return FindTenant(pcTenant).
        else
            return false.
    end method.
    
    method public logical FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        if pcTable = TableName and pcField = FieldName and pcIndex = Indexname and pcCollation = Collation then  
            return FindGroup(pcGroup).
        else
            return false.
    end method.
      
    /****
    method public logical Deallocate(): 
        undo, throw new UnsupportedOperationError("Allocate() in SchemaPartitionContext. Use TablePartitionContext").    
    end method.     
    ****/
    method public logical Allocate():        
        return AllocateTenants("Delayed"). 
    end method.     
    
    /** Allocate group partitions for the parent schema elelement    
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public logical AllocateGroups(pcAllocationState as char):        
        define variable rid as rowid no-undo. 
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        define variable hBuf as handle no-undo.
        PartitionContext:ValidateAllocationRequest(pcAllocationState).
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true. 
        hBuf = QueryHandle:get-buffer-handle(this-object:Table).
        
        rid = hBuf:rowid.
        QueryHandle:get-first ().
        do while hBuf:avail: 
            if hBuf::tenantgroupName > "" 
            and (hBuf::AllocationState = pcAllocationState
                 or (hBuf::AllocationState <> "Allocated" 
                     and 
                     pcAllocationState = "All")) then
            do:
                lok = true.
                hBuf::AllocationState = "Allocated".
            end. 
            QueryHandle:get-next ().
        end.
        return lok.
        finally:
            TableHandle:tracking-changes = lTrack.          
            if rid <> ? then
                QueryHandle:reposition-to-rowid(rid). 
        end finally.       
    end method.     

   /** Allocate tenant partitions for the parent schema elelement    
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public logical AllocateTenants(pcAllocationState as char):        
        define variable rid as rowid no-undo. 
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        define variable hBuf as handle no-undo.
       
        PartitionContext:ValidateAllocationRequest(pcAllocationState).
        
        lTrack = TableHandle:tracking-changes.
         
        TableHandle:tracking-changes = true. 
        hBuf = QueryHandle:get-buffer-handle (this-object:Table).
        rid = hBuf:rowid.
        QueryHandle:get-first ().
        
        do while hBuf:avail: 
            if hBuf::TenantName > "" 
            and (hBuf::AllocationState = pcAllocationState
                 or (hBuf::AllocationState <> "Allocated" 
                     and 
                     pcAllocationState = "All")) then
            do:
                lok = true.
                hBuf::AllocationState = "Allocated".
            end. 
            QueryHandle:get-next ().
       
        end.
      
        return lok.
        finally:
            TableHandle:tracking-changes = lTrack.          
            if rid <> ? then
                QueryHandle:reposition-to-rowid(rid). 
        end finally.       
    end method.     
         
    /*    
    method public override character ColumnSource(pcColumn as char):
        define variable cField  as character no-undo.
        define variable cBuffer as character no-undo.
        
        define variable cMsg as character no-undo. 
        /*
        if num-entries(pcColumn,".") > 1 then
        do:
            cBuffer = entry(1,pcColumn,".").
            cField  = entry(2,pcColumn,".").
            if cBuffer = "tenant" then
            do:
                return Tenantcontext:ColumnSource(cField).
            end.    
        end.
        */
        return super:ColumnSource(pcColumn).
    end method.
    */
    
    
end class.