/*************************************************************/
/* Copyright (c) 2010-2011 by Progress Software Corporation  */
/*                                                           */
/* All rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
   File        : AreaContext
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : hdaniels
   Created     : Aug 2010
   Notes       : 
 ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.Area from propath. 
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.AreaSet from propath.  
using OpenEdge.DataAdmin.IExtent from propath. 
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.ExtentContext from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IAreaScope from propath. 
using OpenEdge.DataAdmin.Message.FetchRequest from propath. 
using OpenEdge.DataAdmin.Message.IFetchRequest from propath. 
using OpenEdge.DataAdmin.Message.ISaveRequest from propath. 

using OpenEdge.DataAdmin.Error.DataError from propath.
using OpenEdge.DataAdmin.Error.DataContextError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath.
using OpenEdge.DataAdmin.Error.ValidationError from propath.

class OpenEdge.DataAdmin.Binding.AreaContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/area.i}
  
    define private dataset dsArea serialize-name "root" for ttArea .   
    
    define buffer barea for ttArea.
    define temp-table copytable reference-only like ttArea.  
   
    define protected variable ValidRecordsPerBlockValues as char no-undo
          init "1,2,4,8,16,32,64,128,256". 
    
    define protected variable ValidClusterSizeValues as char no-undo
          init "1,8,64,512". 
     
    define protected variable ValidTypeValues as char no-undo
        init "Recovery,Transaction log,Event log,Data,Rollforward recovery". 
 
           
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsArea:handle.
        end get.
    
    define public override property TableHandle as handle no-undo 
        get():
            return temp-table ttArea:handle.
        end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.    
    
    define public override property Count as integer init ? no-undo  
        get(): 
            
            if Count = ? then
            do:
                Count = 0.
                for each barea:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public AreaContext():
        define variable  extcntxt as Extentcontext no-undo. 
        super ("Area").       
        extcntxt = new ExtentContext().
        extcntxt:Lazy = false.
        AddChild(new ExtentContext()).
    end constructor.
    
    constructor public AreaContext(pscope as IAreaScope):
        define variable  extcntxt as Extentcontext no-undo. 
        super ("Area",pscope).       
        extcntxt = pscope:ExtentContext.
        extcntxt:Lazy = false.
        AddChild(extcntxt).
    end constructor.
    
    method public override character GetJoinFields(parentid as char):
        return "".
    end.
	
    method protected override void InitRow(pName as char):
        create ttArea. 
        assign ttArea.Name = pName .  
    end method.
    
    method public override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference,cntxt). 
        Loaded = false.
    end method.    
       
    method private void CopyTable(input table copytable,pCntxt as IDataAdminContext):
        define variable dataerror as DataContextError no-undo.   
        define variable extentcntxt as ExtentContext no-undo.  
        define variable cHeader    as character no-undo init "Create failed.".
        
        if valid-object(Service)then
        do:
            extentcntxt = cast(pcntxt:GetChild("extents"),ExtentContext).
        end.
        
        for each copytable on error undo, throw:  
/*            if valid-object(copytable.Entity) then         */
/*            do:                                            */
/*                ValidateArea(cast(copytable.Entity,IArea)).*/
/*            end.                                           */
            
            do on error undo, throw:
                find barea where barea.name = copytable.name no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail barea then
                do:
                    create barea.
                    bArea.name = copytable.name.               
                end.    
                  
/*                ValidateBuffer(buffer copytable:handle).*/
                
                catch e as Progress.Lang.Error :
                    if avail barea then delete barea.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError(cHeader).
                    dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError.
             
        temp-table ttArea:tracking-changes = true.
        for each copytable:
            create ttArea.    
            Count = Count + 1.
            buffer-copy copytable to ttArea.    
            OnRowCreated().
        end.
 
        temp-table ttArea:tracking-changes = false.
            
    end method.  
    
/*    method protected void LoadInstances().            */
/*        if not Loaded then                            */
/*        for each ttArea:                              */
/*            if not valid-object(ttArea.Entity) then   */
/*                ttArea.Entity = new Area(this-object).*/
/*        end.                                          */
/*        Loaded = true.                                */
/*    end method.                                       */
/*	                                                      */
/*    method protected void UnLoadInstances().          */
/*        for each ttArea:                              */
/*            ttArea.Entity = ?.                        */
/*        end.                                          */
/*        Loaded = false.                               */
/*    end method.                                       */
    
    method private character GetCreateError(area as IArea):
        return this-object:GetCreateError(cast(area,IDataAdminElement),area:Name). 
    end method.
    
    /** fires after change - validation should have been done */
    method protected override void ValueChanged(pFieldName as char,pcOldValue as char,pNewValue as char).        
        define variable cntxt as IDataAdminContext no-undo. 
        super:ValueChanged(pFieldName,pcOldValue,pnewvalue).
        /* name change (new area) need to update extents (new) */
        if pFieldName = "Name" then
        do:    
            cntxt = GetChild("extents").
            cast(cntxt,ExtentContext):UpdateAreaName(pcOldValue,pNewValue).
        end.
    end method.
    
    method protected override void ValidateBuffer(phArea as handle):
        ValidateAreaName(phArea::Name).
        ValidateClusterSize(phArea::Name,string(phArea::ClusterSize)).
        ValidateRecordsPerBlock(phArea::Name,string(phArea::RecordsPerBlock)).     
        ValidateAreaType(phArea::Name,phArea::Type).      
        if pharea:row-state = row-created then 
        do:
            ValidateExtent(phArea::name).
        end.    
          
    end method.      
    
    method private void ValidateAreaName(pcKey as char).  
        if pcKey = ? or pcKey = "" then 
             undo, throw new DataError("Area must have a name to be created").  
    
    end method.
    
    method private void ValidateAreaType(pcKey as char,pnewvalue as char).  
        /*
        if pnewValue <> "Data" then
        do:
            if lookup(pnewvalue,ValidTypeValues) = 0 then
                undo, throw new ValidationError(Name,pcKey,"Type " + quoter(pnewvalue)," is invalid. The only valid type is ~"Data~"").
            else
                undo, throw new ValidationError(Name,pcKey,"Type " + quoter(pnewvalue)," is not supported. The only supported type is ~"Data~"").
        end.
        if lookup(pnewvalue,ValidTypeValues) = 0 then
            undo, throw new InvalidPropertyValueError(Name,pcKey,"Type",pnewvalue,ValidTypeValues).
         */    
    end method.
    
    method protected  void ValidateExtent(pcArea as char):
        define variable extentcntxt as ExtentContext no-undo.
        extentcntxt = cast(GetChild("extents"),ExtentContext).
        if valid-object(extentcntxt) and not extentcntxt:CanFindFirstOfArea(pcArea) then 
        do:
             undo, throw new DataError("Area " + pcArea +  " must have at least one Extent.",?).  
        end.
    end method.
    
    method private void ValidateRecordsPerBlock(pcKey as char,pnewvalue as char).  
        if lookup(pnewvalue,ValidRecordsPerBlockValues) = 0 then
            undo, throw new InvalidPropertyValueError(Name,pcKey,"RecordsPerBlock",pnewvalue,ValidRecordsPerBlockValues). 
    end method.
    
    method private void ValidateClusterSize(pcKey as char,pnewvalue as char).  
        if lookup(pnewvalue,ValidClusterSizeValues) = 0 then
            undo, throw new InvalidPropertyValueError(Name,pcKey,"ClusterSize",pnewvalue,ValidClusterSizeValues). 
    end method.
   
    /** override to validate clustersize and records pr block */
    method protected override void ValidateProperty(pcfield as char,poldvalue as char,pnewvalue as char).  
        /** allow name change if new (no service)  (shipped in v11.0)  */
        if valid-object(Service) or pcfield <> "name" then 
            super:ValidateProperty(pcfield,pOldValue,pnewvalue).
        case pcfield:
            when "ClusterSize" then 
                ValidateClusterSize(ttArea.Name,pnewvalue).
            when "RecordsPerBlock" then 
                ValidateRecordsPerBlock(ttArea.Name,pnewvalue).                       
        end.     
    end method. 

    method public override void CreateRow(entity as IDataAdminElement):
        /* if class cast error - the default syserror seems sufficient */
        CreateRow(cast(entity,IArea)).    
    end method.
      
    method public void CreateRow(area as IArea):
        define variable validateError as DataContextError no-undo.
        
        temp-table ttArea:tracking-changes = true.
        
         /* if service create check if there are extents 
           if no service (added to some collection) then we allow this to be added later. */
        if valid-object(Service) and area:Extents:Count = 0 then
        do:
            if not valid-object(validateError) then
                validateError = new DataContextError(GetCreateError(area)). 
            validateError:AddMessage("* The Area must have at least one Extent.",?).  
            undo, throw validateError.
        end.
	   
        do on error undo, throw: 
            Count = Count + 1.
            create ttArea.
            assign 
                ttArea.Number      = ?
                ttArea.Name        = area:Name 
                ttArea.Entity      = area 
                ttArea.Number      = area:Number  
                ttArea.Type        = area:Type 
                ttArea.BlockSize   = area:BlockSize 
 
                ttArea.isType2     = area:isType2 
                ttArea.ClusterSize = area:ClusterSize 
                ttArea.RecordsPerBlock = area:RecordsPerBlock.
/*                ttArea.NumExtents  = area:NumExtents.*/
            
/*            ValidateBuffer(buffer ttArea:handle).*/
            
            OnRowCreated().      
            catch e as Error:  
                delete ttArea.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(area),"Area",e).  
            end catch.  
        end.
        finally:
            temp-table ttArea:tracking-changes = false.        		
        end finally.
        
    end method.
    
    method public override logical CanFind(name as character):
        return can-find(ttArea where ttArea.name = name).            
    end.    
    
    method public override logical Find(name as character):
        find ttArea where ttArea.name = name no-error.
        return avail ttArea.            
    end.    
    
    method public override logical CanFind(id as integer):
        return can-find(ttArea where ttArea.Number = id).            
    end.    
     
    method public override logical Find(id as integer):
        find ttArea where ttArea.Number = id no-error.
        return avail ttArea.            
    end.    
    
    method protected override char FindExpression(i as int):
        return "ttArea.Number = " + quoter(i).
    end method.
    
    /** override for serverside join - data source (currently) requires join on number (error: areaname must be mapped to data source ) 
       */ 
    method public override IFetchRequest GetRequest():
        define variable hDs as handle no-undo.
        define variable tree as IContextTree no-undo.
        define variable extentcntxt as ExtentContext no-undo.
        tree = new ContextTree().  
        tree:Parse = true.       
       
        AddTableTo(tree).
        extentcntxt = cast(GetChild("extents"),ExtentContext).
        tree:SetJoin(SerializeName,"extents","Number,AreaNumber").
        extentcntxt:AddTableTo(tree).
       
        hDs = tree:GetReadHandle().
/*        h = CreateDataSet().*/
        
        return new FetchRequest(Name,Id,hDs).
        
    end method.
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new AreaSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Area(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(pReq as IRequestInfo):
        return new Area(this-object,pReq).
    end method.
    
    /** refresh partitions for create 
       NewPartitionContext retrieved these */
    method override public void MergeChanges( pResponse as ISaveRequest ):
        RefreshAreas(pResponse:DataHandle).
        super:MergeChanges(pResponse).
    end method.
    
    method private void RefreshAreas (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lTrack     as logical no-undo.
     
        hbuffer = pdsChanged:get-buffer-handle ("ttArea"). 
        create query hQuery.
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttArea where row-state(ttArea) = 0").
        hquery:query-open().
        hquery:get-first.
      
        do while hbuffer:avail:
            if hBuffer:row-state = 0 then
            do:
                /* @todo remove no-error and throw something  */  
                find ttArea where ttArea.name = hbuffer::name no-error.
                if avail ttArea then
                do: 
                    if ttArea.NumExtents <> hbuffer::NumExtents then
                    do:
                        lTrack = temp-table ttArea:tracking-changes.
                        temp-table ttArea:tracking-changes = false.
                        assign ttArea.NumExtents = hbuffer::NumExtents.
                        temp-table ttArea:tracking-changes = lTrack.
                    end. 
                end.
            end.
            hQuery:get-next.
        end.
    end method.
    
    method protected override logical ValidValue(pccolumn as character,piValue as int): 
        
        if pccolumn = "ttArea.RecordsPerBlock" then
            return lookup(string(piValue),ValidRecordsPerBlockValues) > 0.
        if pccolumn = "ttArea.ClusterSize" then
            return lookup(string(piValue),ValidClusterSizeValues) > 0.
        return super:ValidValue(pccolumn,piValue). 
    end method.
      
    method protected override char ValidValueList(pccolumn as character): 
        if pccolumn = "ttArea.RecordsPerBlock" then
            return ValidValueString(ValidRecordsPerBlockValues).
        if pccolumn = "ttArea.ClusterSize" then    
             return ValidValueString(ValidClusterSizeValues).
        return super:ValidValueList(pccolumn). 
    end method.
    
    method private char ValidValueString(pclist as char).  
        define variable i as integer no-undo.
        define variable cDelim as character no-undo.
        define variable cText as character no-undo.
        do i = 1 to num-entries(pclist):
            if i > 1 then 
            do:
                if i = num-entries(pclist) then 
                    cDelim = " and ".
                else 
                    cDelim = ", ".
                cText = cText + cDelim + quoter(entry(i,pclist)).             
            end.   
        end.
        return cText.     
    end method.
     
      /* convert expression for QueryString - unknown = keep as is */
    method public override character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
       
        if pccolumn = "ttArea.RecordsPerBlock" then
        do:
            return IntegerExpression(pcColumn,pcoperator,pcValue). 
        end.
        return super:ColumnExpression(pcColumn,pcoperator,pcValue).
    
    end. 
    
end class.
