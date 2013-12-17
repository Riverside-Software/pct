 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SequenceDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sep 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.DataSource.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath. 
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.SequenceDataSource inherits DataSource: 
    define protected variable AreaUrl as char no-undo.
    define protected variable mBuffer as handle no-undo.
    define protected variable mTempSourceBuffer as handle no-undo.
    define private variable mSaving as logical no-undo.
    define protected variable SequenceURL as character no-undo init "/sequences/".  
    
    /* not really allowed - */
    define public property QueryString as character no-undo 
        get():
            return Queryhandle:prepare-string.   
        end.
             
     
	define private variable mMapping as char
	   init  	   
"Name,_Seq-Name,~
SchemaName,_Seq-Owner,~
IsMultitenant,_Seq-Attributes[1],~
InitialValue,_Seq-Init,~
IncrementValue,_Seq-Incr,~
MinimumValue,_Seq-Min,~
MaximumValue,_Seq-Max,~
isCyclic,_Cycle-Ok,~
tRowid,rowid(_Sequence)"        
no-undo.

    define private property SequenceExpression as char no-undo 
       get():
             return "_Sequence._db-recid = " + quoter(DatabaseInfo:DatabaseRecid) + " and  _Sequence._seq-owner = 'PUB'".
       end.
       set.  
 
    constructor public SequenceDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL.
       
    end constructor.
 
	constructor public SequenceDataSource ( ):	    
		super ("_Sequence","dictdb._Sequence", mMapping). 
        BaseQuery = "for each _Sequence where " + SequenceExpression + " no-lock".
	end constructor.
    
    constructor public SequenceDataSource (hchanges as handle ):     
        super ("ttSequenceChange,_Sequence","ttSequenceChange,dictdb._Sequence", mMapping).
        mTempSourceBuffer =  hchanges.  
   
        BaseQuery = "for each ttSequenceChange,"
                  +  " each _Sequence where " + SequenceExpression + " no-lock".
    end constructor.
    
    method public override logical Save(bufferHandle as handle):
  /*        CreateSaveSource("").*/
        mSaving = true. 
        SaveSequence(bufferHandle).
        mSaving = false.
    end method.     
    
    method private logical SaveSequence(phBuffer as handle):
        define variable hBeforeBuff as handle    no-undo.
        define variable lnew        as logical   no-undo. 
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable hDataset as handle no-undo.
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttSequenceCopy").    
        hquery:query-open().
        
        do while true:
            hquery:get-next.
            if not hBeforebuff:avail then 
                leave.
            
            if hBeforeBuff:row-state = row-deleted then 
            do:
                 find dictdb._Sequence where dictdb._Sequence._Seq-Owner = hBeforebuff::SchemaName
                                       and   dictdb._Sequence._Db-recid = DatabaseInfo:DatabaseRecid     
                                       and   dictdb._Sequence._Seq-name = hBeforebuff::Name exclusive no-wait.
                 delete dictdb._Sequence.  
            end.
            else do:    
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
             
                if hBeforeBuff:row-state = row-created then            
                do:
                  
                   create dictdb._sequence.
                   assign dictdb._Sequence._Seq-Owner = phBuffer::SchemaName
                          dictdb._Sequence._Db-recid = DatabaseInfo:DatabaseRecid                          dictdb._Sequence._Seq-name = phBuffer::Name 
                          dictdb._Sequence._Seq-Attributes[1]= phBuffer::IsMultitenant.
                    
                   if phBuffer::CurrentValue > 0 then 
                        undo, throw new DataAccessError("The CurrentValue can only be changed after the sequence has been created.").               
                  
                end. 
                else do:
                    find dictdb._Sequence where dictdb._Sequence._Seq-Owner = hBeforeBuff::SchemaName
                                            and   dictdb._Sequence._Db-recid = DatabaseInfo:DatabaseRecid     
                                            and dictdb._Sequence._Seq-name = hBeforeBuff::Name exclusive no-wait.
                    
                    if dictdb._Sequence._Seq-Attributes[1] <> phBuffer::IsMultitenant then 
                        undo, throw new DataAccessError("Cannot change multi-tenancy for a sequence.").                
                    /*
                      if hBuffer::isMultiTenant then
                        undo, throw new DataAccessError("Cannot change CurrentValue for a mulit-tenant sequence.").               
                    */
                   
                    if phBuffer::CurrentValue <> hBeforeBuff::CurrentValue  then 
                    do:
                        /* this is somewhat restrictive - wif it was allowed it would be applied to the 
                           effetie-tenant. The reason we don't is mainly that the Mt tool 
                           currently depends on the currentvalue being unknown (ou) 
                           want to be consistent */  
                           
                        if phBuffer::isMultiTenant and DatabaseInfo:IsUserSuperTenant then
                            undo, throw new DataAccessError("Cannot change CurrentValue for a multi-tenant sequence. It must be updated per tenant in the SequenceValues collection.").               
                        dynamic-current-value(dictdb._Sequence._Seq-name, "DICTDB")  = phBuffer::CurrentValue.
                    end.
                end.
                 
                if ((phBuffer::IncrementValue > 0) AND (phBuffer::InitialValue >= phBuffer::MaximumValue)) then
                     undo, throw new DataAccessError("The maximum value must be greater than the initial value when the increment value is positive."). 
                else 
                if ((phBuffer::IncrementValue < 0) AND (phBuffer::InitialValue <= phBuffer::MinimumValue)) then
                    undo, throw new DataAccessError("The minimum value must be less than the initial value when the increment value is negative.").
                
                
                if phBuffer::name <> dictdb._Sequence._Seq-name then
                    phBuffer::name = dictdb._Sequence._Seq-name.
                
                if phBuffer::InitialValue <> dictdb._Sequence._Seq-Init then
                    dictdb._Sequence._Seq-Init = phBuffer::InitialValue. 
                if phBuffer::IncrementValue <> dictdb._Sequence._Seq-Incr then
                    dictdb._Sequence._Seq-Incr = phBuffer::IncrementValue. 
                if phBuffer::MinimumValue <> dictdb._Sequence._Seq-Min then
                    dictdb._Sequence._Seq-Min  = phBuffer::MinimumValue.
                if phBuffer::MaximumValue <> dictdb._Sequence._Seq-Max then
                    dictdb._Sequence._Seq-Max  = phBuffer::MaximumValue.
                      
                if phBuffer::IsCyclic <> dictdb._Sequence._Cycle-Ok then
                    dictdb._Sequence._Cycle-Ok = phBuffer::IsCyclic.                    
                
                hdataset = phBuffer:dataset.
                
                mSaving = true.    
               
                AfterRow (dataset-handle hdataset by-reference).
                
                mSaving = false.
            end. /* else (not ddelete) */
        end.
        catch e1 as DataAccessError :
        	undo, throw e1.	
        end catch.
        catch e2 as Progress.Lang.Error :   
            undo, throw new DataAccessError(
                new DataMapper("Sequence,_Sequence",
                mMapping),
                e2). 
            
        end catch.          
    end method.
       
    method override protected void CreateQuery():
        define variable iBuffer as integer no-undo.
        define variable hBuffer as handle  no-undo.
        if valid-handle(mTempSourceBuffer) then
        do:
            create query QueryHandle.
            QueryHandle:add-buffer(mTempSourceBuffer).
            
            do iBuffer = 2 to num-entries(PhysicalTables):
                create buffer hBuffer 
                    for table entry(iBuffer,PhysicalTables) buffer-name entry(iBuffer,Tables).
                QueryHandle:add-buffer(hBuffer).
            end.
            delete object DataSourcehandle no-error.
            create data-source DataSourcehandle. 
            DataSourceHandle:query = QueryHandle.
        
        end.
        else
           super:CreateQuery().
        
    end method.     
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
    end method.
        
    method public override void AfterRow(dataset-handle hds):
        define variable hBuffer as handle no-undo. 
        hBuffer =  hds:get-buffer-handle("ttSequence").
       
        hBuffer::SequenceValuesUrl = url + "/schemas/PUB/sequences/" + WebUtil:UrlEncode(hbuffer::Name) + "/sequencevalues".
         
         /* return ? for super tenant to (values per tenant)  */
        if hBuffer::isMultiTenant and DatabaseInfo:IsUserSuperTenant then
            hBuffer::CurrentValue = ?.
        else if not msaving then  /* for regular tenant the current-value will find the applicable value */
            hBuffer::CurrentValue = dynamic-current-value(hbuffer::NAME, "DICTDB").
         
        hBuffer::url = url + "/schemas/PUB/sequences/" + WebUtil:UrlEncode(hbuffer::Name).
    
    end method.
    
end class.