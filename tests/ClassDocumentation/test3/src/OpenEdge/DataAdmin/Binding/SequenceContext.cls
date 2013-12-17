 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SequenceContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.

using OpenEdge.DataAdmin.Sequence from propath.
using OpenEdge.DataAdmin.ISequence from propath.
using OpenEdge.DataAdmin.SequenceSet from propath. 
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath. 

using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 

using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.
using OpenEdge.DataAdmin.Error.DataContextError  from propath.

using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope from propath. 
using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope from propath. 
 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.SequenceContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/sequence.i}
     
    define private dataset dsSequence serialize-name "root" for ttSequence.
    define buffer bSequence for ttSequence.
    define temp-table copySequence reference-only like ttSequence .  
    define variable SchemaName as character no-undo init "PUB".
    define private variable mSaveDataset as handle no-undo.
      
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsSequence:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttSequence:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "SchemaName,Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bSequence for ttSequence.
            if Count = ? then
            do:
                Count = 0.
                for each bSequence:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public SequenceContext ():
        super ("Sequence").
    end constructor.
    
    constructor public SequenceContext (pScope as IContextScope):
        super ("Sequence",pScope).
        if pScope:IsLocal = false and type-of(pScope,IContextFactory) then
        do: 
           AddChild(cast(pScope,IContextFactory):SequenceValueContext). 
           SkipList = "sequenceValues".
        end.
    end constructor.
	
	 /**  Create row with key - used by CreateRootRow */
    method protected override void InitRow(pName as char):
        create ttSequence.
        assign
            ttSequence.name = pName
            ttSequence.SchemaName = this-object:SchemaName.
        
    end method.
	
	method protected override handle CreateSaveDataset():
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        AddTreeTo(tree).
        GetChild("sequenceValues"):AddTableTo(tree).
        return tree:GetReadHandle().
    end method.
	
	method public override void CopyTable(cntxt as IDataAdminContext).
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false.
    end method. 
     
    method private void CopyTable(input table copysequence):
        define variable dataerror as DataContextError no-undo.      
        define variable lTrack as logical no-undo.
        for each copysequence on error undo, throw:  
            if valid-object(Service) and valid-object(copysequence.Entity) then 
            do:
/*                ValidateArea(cast(copytable.Entity,IArea)).*/
            end.
            do on error undo, throw:
                find bsequence where  bsequence.SchemaName = this-object:SchemaName 
                               and    bsequence.name = copysequence.name 
                               no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail bsequence then
                do:
                    create bsequence.
                    assign 
                       bsequence.SchemaName = this-object:SchemaName
                       bsequence.name = copysequence.name.               
                end.    
                catch e as Progress.Lang.Error :
                    delete bsequence.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("Sequence",e).
                    else 
                        dataError:AddMessage(e).                    
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        lTrack = temp-table ttSequence:tracking-changes.
        temp-table ttSequence:tracking-changes = true.
        for each copysequence:
            create ttSequence.    
            Count = Count + 1.
            buffer-copy copysequence to ttSequence.    
            /* this is not really neccesary 
               initRow and createRow should be sufficent */
            ttSequence.SchemaName = this-object:SchemaName. 
            OnRowCreated().
        end.
 
        temp-table ttSequence:tracking-changes = lTrack.
            
    
    end method.    
     
    method public override void CreateRow(seq as IDataAdminElement):
        CreateRow(cast(seq,ISequence)).   
    end method.    
    
    method protected void CreateRow(seq as ISequence):
        
/*        define variable validateError as DataContextError no-undo.*/
       
        temp-table ttSequence:tracking-changes = true.
        
/*        ValidateSequence(seq).*/
        
        do on error undo, throw: 
            Count = Count + 1.
            create ttSequence.
            assign 
                ttSequence.SchemaName     = this-object:SchemaName
                ttSequence.Name           = seq:name
                ttSequence.IsMultitenant  = seq:IsMultitenant
                ttSequence.InitialValue   = seq:InitialValue
                ttSequence.CurrentValue   = seq:CurrentValue
                ttSequence.IncrementValue = seq:IncrementValue
                ttSequence.MinimumValue   = seq:MinimumValue
                ttSequence.MaximumValue   = seq:MaximumValue
                ttSequence.IsCyclic       = seq:IsCyclic.
                  
            OnRowCreated().      
            
            catch e as Error:  
                delete ttSequence.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(cast(seq,Sequence),seq:name),"Sequence",e).  
            end catch.  
        end.
        finally:
            temp-table ttSequence:tracking-changes = false.             
        end finally.
    end method.
    
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "schemas" then
                    return "Name,SchemaName".
        end.
    end.
    
	method public override logical CanFind(name as character):
        return can-find(ttSequence where ttSequence.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttSequence where ttSequence.name = name no-error.
        return avail ttSequence.            
    end.    
 
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new SequenceSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Sequence(cntxt).
    end method. 
    
    method protected override IDataAdminElement CreateEntity(preq as IRequestInfo):
        return new Sequence(this-object,pReq).
    end method. 
    
/*    method public override void DataRefreshed(pResponse as openedge.dataadmin.message.IFetchResponse):*/
/*        super:DataRefreshed(pResponse).                                                               */
/*        ShowPartitionData().                                                                          */
/*    end method.                                                                                       */
/*                                                                                                      */
/*    method protected void ShowPartitionData():                                                        */
/*        define variable cc as character no-undo.                                                      */
/*        define variable cx as character no-undo.                                                      */
/*        current-window:width = 200.                                                                   */
/*        cx = if valid-object(service) then Service:name else "<local>".                               */
/*        for each ttSequence with width 200:                                                           */
/*            cc = cc + " "                                                                             */
/*              +  ttSequence.Name + " "                                                                */
/*              + string(ttSequence.CurrentValue) + " "                                                 */
/*              +  string(ttSequence.MaximumValue) .                                                    */
/*        end.                                                                                          */
/*        message cc                                                                                    */
/*        view-as alert-box title cx.                                                                   */
/*    end method.                                                                                       */
end class.
