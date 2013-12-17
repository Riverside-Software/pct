 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SchemaContext
    Purpose     : Schema contains all standard dictionary tables 
                  with the schema as the parent
                      
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : The Schema name is part of the unique key for tables 
                  and sequences in Data Dictionary.   
                - This context is not used/supported in the ABL API, 
                  since the only supported record is PUB and the 
                  DataAdminService GetTable(s) ando GetSequence(s) returns 
                  only data for PUB. This will not change. If other 
                  schemas than PUB is to be supported it will be done with 
                  separate requests i.e. GetSQLTable(s) or GetSysTable(s)
               -  The context is used for REST to allow a unique key to 
                  lookup table (or a table's index or field) and sequence.  
   ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope from propath.

using OpenEdge.DataAdmin.Error.* from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.

class OpenEdge.DataAdmin.Binding.SchemaContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/schema.i}    
/*    {daschema/table.i}   */
/*    {daschema/index.i}   */
/*    {daschema/field.i}   */
/*    {daschema/sequence.i}*/
    {daschema/change.i }
    
    define temp-table ttPartitionChange 
       field TableName as char  
       field FieldName as char  
       field IndexName as char  
       field Collation as char  
       index idx as primary unique TableName Fieldname Indexname Collation .  
    
    define private dataset dsSchema serialize-name "root" for ttSchema .
           
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then
                DatasetHandle = CreateDataset().
            return DatasetHandle.
        end get.
        private set. 
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttSchema:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bschema for ttSchema.
            if Count = ? then
            do:
                Count = 0.
                for each bschema:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
   
    
    define private variable mPartitionContext as PartitionContext no-undo.
    define private variable mSequenceContext as SequenceContext no-undo.
    
    constructor public SchemaContext ():
        super ("Schema").     
    end constructor.
    
    constructor public SchemaContext ( pScope as ISchemaScope):
        super ("Schema",pScope).
        AddChild(pScope:Tablecontext). 
        AddChild(pScope:SequenceContext). 
        mPartitionContext = pScope:PartitionContext.
        AddChild(mPartitionContext). 
        SkipList = "partitions". 
    end constructor.
    /*
    method public override IDataAdminContext GetChild(pname as char):
        if pname = "partitions" then 
            return mPartitionContext.
        else 
            return super:GetChild(pname).     
    end method.    
	*/
/*	method public void LoadInstances().                                           */
/*        undo, throw new UnsupportedOperationError("Load instances for Schema").*/
/*    end method.                                                                */
/*                                                                               */
/*    method protected void UnLoadInstances().                                   */
/*        undo, throw new UnsupportedOperationError("Load instances for Schema").*/
/*    end method.                                                                */
    
    method protected override handle CreateSaveDataset():
        define variable tree as IContextTree no-undo.
        define variable tblcntxt as IDataAdminContext no-undo.
        define variable cntxt as IDataAdminContext no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        
        AddTreeTo(tree).
        tree:SetJoin("schemas","partitions","Name,SchemaName").        
        mPartitionContext:AddTableTo(tree).
/*                                               */
/*        tblcntxt = GetChild("tables").         */
/*                                               */
/*        tblcntxt:AddTreeTo(tree,"partitions"). */
/*                                               */
/*        cntxt = tblcntxt:GetChild("indexes").  */
/*        cntxt:AddTreeTo(tree,"partitions").    */
/*        cntxt = tblcntxt:GetChild("lobfields").*/
/*        cntxt:AddTreeTo(tree).                 */
/*        cntxt = GetChild("sequences").         */
/*        cntxt:AddTableTo(tree).                */
      
        return tree:GetReadHandle().
    end method.
    
    
	method public override character GetJoinFields(parentid as char):
	    case parentid:
            when "Schema" then 
                return "Name,SchemaName".        
        end.
        return "".
      
    end.
    
    /* public because it is  called from Schema  
      @todo make protected and overide copy() to call this) */ 
    method public override void CopyTable(cntxt as IDataAdminContext):
        if type-of(cntxt,SchemaChanges) then 
        do:
            CopyTable(cast(cntxt,SchemaChanges)).
        end. 
	end method.
	
	method protected void CopyTable(cntxt as SchemaChanges):
        define variable hdataset as handle no-undo.
        define variable i as integer no-undo.
        define variable hBuffer as handle no-undo.
        /* create ttschema - not currently  */
        hdataset = cntxt:GetChangeDataset().
        do i = 1 to hDataset:num-buffers:
           hBuffer = hdataset:get-buffer-handle (i).    
           case hBuffer:name:
               when "ttTableChange" then
               do:
                   temp-table ttTablechange:copy-temp-table(hBuffer:table-handle). 
               end.
               when "ttIndexChange" then
               do:
                   temp-table ttIndexChange:copy-temp-table(hBuffer:table-handle). 
               end.
               when "ttFieldChange" then
               do:
                   temp-table ttFieldChange:copy-temp-table(hBuffer:table-handle). 
               end.
               when "ttSequenceChange" then
               do:
                   temp-table ttSequenceChange:copy-temp-table(hBuffer:table-handle). 
               end.
               
           end case.                              
        end.
        /* instead of copying table fields indexes and sequences we do a new request that also will
           retrieve partitions */ 
           
        FetchData(GetChangeRequest()).   
    end method.
	 
	method public override void CreateRow(entity as IDataAdminElement):
	    undo, throw new UnsupportedOperationError("Create Schema row").
	end method. 
    
    method public override logical CanFind(name as character):
        return can-find(ttSchema where ttSchema.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttSchema where ttSchema.name = name no-error.
        return avail ttSchema.            
    end.    
    
    method public override  void DataRefreshed(pResponse as IFetchResponse):
        define variable cntxt as IDataAdminContext no-undo.
        define variable i as integer no-undo.
        define variable TblResponse as ITableResponse no-undo.
        TblResponse = pResponse:GetTableResponse(TableHandle:Name).
        if valid-object(TblResponse) then
            super:DataRefreshed(pResponse) .
        else do:    
            AfterTableRefreshed().
            cntxt = GetChild("tables").
            cntxt:DataRefreshed(pResponse).
            cntxt = GetChild("sequences").
            cntxt:DataRefreshed(pResponse).
       end.
    end method.
    
/*    method public override void MergeChanges(pResponse as ISaveRequest).*/
/*                                                                        */
/*    end method.                                                         */
    
/*    method public override void MergeChanges(pResponse as ISaveRequest).*/
/*                                                                        */
/*        if not valid-object(pResponse) then                             */
/*            undo, throw new UnknownValueError("MergeChange","response").*/
/*                                                                        */
/*        MergeChanges(SaveDataset,pResponse:DataHandle).                 */
/*    end method.                                                         */
    
    method public IPartitionCollection GetNewPartitions():
        return new PartitionCollection( GetNewPartitionContext() ).
    end method.
             
    method public PartitionQueryContext GetNewPartitionContext():
        define variable querycntxt as PartitionQueryContext no-undo.
        define variable hbuffer as handle extent 2 no-undo.
        define variable cQuery as character no-undo.
         
            for each ttTablechange where ttTablechange.IsMultiTenantChange:
                create ttPartitionchange.
                ttPartitionchange.Tablename = ttTablechange.Tablename.
            end.
            for each ttFieldchange where ttFieldchange.IsMultiTenantChange:
                create ttPartitionchange.
                ttPartitionchange.Tablename = ttFieldchange.Tablename.
                ttPartitionchange.Fieldname = ttFieldchange.Fieldname.
            end.
            for each ttIndexchange where ttIndexchange.IsMultiTenantChange:
                create ttPartitionchange.
                ttPartitionchange.Tablename = ttIndexchange.Tablename.
                ttPartitionchange.Indexname = ttIndexchange.Indexname.
                ttPartitionchange.Collation = "" /*ttIndexchange.Collation*/ .
            end.
            
            hBuffer[1] =   buffer ttPartitionChange:handle.  
            hBuffer[2] =   mPartitionContext:TableHandle.  
            cQuery = "preselect each ttPartitionChange, each ttPartition" +
                     " where ttPartition.TableName = ttPartitionChange.TableName" +
                     "   and ttPartition.Fieldname = ttPartitionChange.Fieldname" +
                     "   and ttPartition.Indexname = ttPartitionChange.Indexname" +
                     "   and ttPartition.Collation = ttPartitionChange.Collation".
 
            querycntxt = new PartitionQueryContext(mPartitionContext,cQuery,hBuffer).      
            return querycntxt.
            
    end method.
    
    method private IFetchRequest GetChangeRequest():
        define variable contexttree as IContextTree no-undo.
        define variable msg as FetchRequest no-undo.
        define variable cntxt as IDataAdminContext no-undo.
        define variable hTable as handle no-undo.
        define variable hIndex as handle no-undo.
        define variable hField as handle no-undo.
        
        define variable hPartitionTT as handle no-undo.
       
        
        contexttree = new ContextTree().
        contextTree:SetHandle("tableChanges",buffer ttTableChange:handle).
        contextTree:SetHandle("indexChanges",buffer ttIndexChange:handle).
        contextTree:SetHandle("fieldChanges",buffer ttFieldChange:handle).
        contextTree:SetHandle("sequenceChanges",buffer ttSequenceChange:handle).
        cntxt = GetChild("tables").
        cntxt:AddTreeTo(contextTree).
        cntxt = GetChild("sequences").
        cntxt:AddTreeTo(contextTree).
/*                                                                                       */
/*        contextTree:AHandle("tables",temp-table ttTable:default-buffer-handle).        */
/*                                                                                       */
/*        contextTree:SetJoin("tables","indexes","name,tablename").                      */
/*        contextTree:SetHandle("indexes",temp-table ttIndex:default-buffer-handle).     */
/*                                                                                       */
/*        contextTree:SetJoin("tables","fields","name,tablename").                       */
/*        contextTree:SetHandle("fields",temp-table ttfield:default-buffer-handle).      */
/*                                                                                       */
/*        contextTree:SetHandle("sequences",temp-table ttSequence:default-buffer-handle).*/
/*                                                                                       */
        hPartitionTT = mpartitionContext:Tablehandle.
       
        contextTree:SetHandle("partitions",hPartitionTT:default-buffer-handle).
        
/*                                                                                          */
/*        contextTree:SetJoin("indexes","partitions2","tablename,tablename,name,indexname").*/
/*        contextTree:SetHandle("partitions2",hPartitionTT:default-buffer-handle).          */

/*        contextTree:SetJoin("fields","partitions3","tablename,tablename,name,fieldname").*/
/*        contextTree:SetHandle("partitions3",hPartitionTT:default-buffer-handle).         */
      
        msg = new FetchRequest("File",ID,contexttree:GetReadHandle()).
        msg:UseReplaceOnClient = false.
        return msg. 
    end method.      
    
    method private void BindTableChanges (table ttTableChange bind):
    end.    
    method private void BindFieldChanges (table ttFieldChange bind):
    end.    
    method private void BindIndexChanges (table ttIndexChange bind):
    end.    
   
    method public void showtables():
        define variable cc as character no-undo.
/*        for each ttTable:                                                     */
/*            cc = cc + ttTable.name + chr(10).                                 */
/*                                                                              */
/*        end.                                                                  */
/*        for each ttField:                                                     */
/*            cc = cc + ttField.Tablename + "." + ttfield.name + chr(10).       */
/*        end.                                                                  */
/*        for each ttIndex:                                                     */
/*            cc = cc + "i " + ttindex.Tablename + "." + ttindex.name + chr(10).*/
/*        end.                                                                  */
/*        for each ttSequence:                                                  */
/*            cc = cc + ttSequence.name + chr(10).                              */
/*                                                                              */
/*        end.                                                                  */
        
        if not session:batch-mode then
        do:
            message cc view-as alert-box.
        end.
    end method. 
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in SchemaContext").
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Schema(cntxt).
    end method. 
 
       
end class.
