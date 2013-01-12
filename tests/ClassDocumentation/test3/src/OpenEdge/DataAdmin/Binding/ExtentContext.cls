/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
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
using OpenEdge.DataAdmin.IExtent from propath. 
using OpenEdge.DataAdmin.Extent from propath. 
using OpenEdge.DataAdmin.ExtentList from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IAreaScope from propath. 
using OpenEdge.DataAdmin.Binding.ExtentContext from propath.
using OpenEdge.DataAdmin.Binding.Query.AreaExtentQuery from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Error.DataContextError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath.
using OpenEdge.DataAdmin.Error.ValidationError from propath.
using OpenEdge.DataAdmin.Error.CreateOnlyPropertyError from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

class OpenEdge.DataAdmin.Binding.ExtentContext inherits DataAdminContext implements IDataAdminContext: 
    
     
    {daschema/extent.i}
 
    define private dataset dsExtent serialize-name "root" for ttExtent. 
    define buffer bextent for ttExtent. 
    define temp-table copytable reference-only like ttExtent.  
      
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsExtent:handle.
        end get.
    
    define public override property TableHandle as handle no-undo 
        get():
            return temp-table ttExtent:handle.
        end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "AreaName,Number". 
        end.    
     
    define public override property Count as integer init ? no-undo  
        get(): 
            
            if Count = ? then
            do:
                Count = 0.
                for each bextent:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public ExtentContext():
        super ("Extent").
    end constructor.
        
	constructor public ExtentContext ( pscope as IAreaScope):
        super ("Extent",pscope).
    end constructor.
	
	method public override character GetJoinFields(parentid as char):
        if parentid = "areas" then 
             return "Name,AreaName".
        return "".     
    end.
	
	/** DataRefreshed from server cannot use copy-temp-table since the primary index
	    is on areanumber */
	method private void RefreshTable(input table copyTable):
	    define variable lTrack as logical no-undo.
        define buffer bExtent for ttExtent. 
        lTrack = temp-table ttExtent:tracking-changes.
        temp-table ttExtent:tracking-changes = FALSE.
        
        for each copytable on error undo, throw:  
            find bextent where bextent.Areaname = copytable.Areaname 
                           and bExtent.number  = copytable.Number no-error.
            if not avail bExtent then 
            do: 
                create bextent.   
            end.
            buffer-copy copytable to bextent.    
            
        end.
        finally:
            temp-table ttExtent:tracking-changes = lTrack.
        end finally.
    end method.
	 
    method private void CopyTable(input table copyTable):
        define variable dataerror as DataContextError no-undo.      
        define variable lTrack as logical no-undo.
        
        lTrack = temp-table ttExtent:tracking-changes.
        
        for each copytable on error undo, throw:  
             
            do on error undo, throw:
                find bextent where bextent.Areaname = copytable.Areaname 
                             and bExtent.number  = copytable.Number no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail bextent then
                do:
                    create bextent.
                    bextent.Areaname = copytable.Areaname .
                    bExtent.number  = copytable.Number .         
                end.    
     /* Length must be greater than or equal to 32. (6832)*/
     /* Fixed extent size 128 KB is less than the cluster size 256 KB. (11824)*/
     /* Only the last extent of a given area may be variable length. (6842)*/
                
                catch e as Progress.Lang.Error :
                    delete bextent.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("Extent",e).
                    else 
                        dataError:AddMessage(e).                     
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        temp-table ttExtent:tracking-changes = true.
        for each copytable:
            create ttExtent.    
            Count = Count + 1.
            buffer-copy copytable to ttExtent.    
            OnRowCreated().
        end.
        finally:
           temp-table ttExtent:tracking-changes = lTrack.
        end finally.
            
    end method.  
    
    method protected override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false.
    end method.    
 
    method private character GetCreateError(newextent as IExtent):
        return this-object:GetCreateError(cast(newextent,IDataAdminElement),string(newExtent:number)). 
    end method.
   
    method public override void CreateRow(entity as IDataAdminElement):
        /* if class cast error - the default syserror seems sufficent */
        CreateRow(cast(entity,IExtent)).    
    end method.
	
	/* override - unsupported in super */
	method protected override void InitRow():
        create ttExtent. 
    end method.
	
	method public override void InitRow(pname as char):
        undo, throw new UnsupportedOperationError("CreateRow with name in ExtentContext").
	end method.
    
    method public override void InitRow(pid as int):
        undo, throw new UnsupportedOperationError("CreateRow with int key in ExtentContext. The Extent:Number will be incremented when the extent is added to the Area." ).
    end method.
    
    method public void CreateRow(pNewExtent as IExtent):
        undo, throw new UnsupportedOperationError("CreateRow(IExtent) in ExtentContext." ).
    end method.
    
    method public void UpdateAreaName(pcOldname as char, pcNewname as char):
        define variable lTrack as logical no-undo.
        define buffer bextent for ttExtent.
        lTrack = temp-table ttExtent:tracking-changes.
        temp-table ttExtent:tracking-changes = false.
        for each ttExtent where ttExtent.AreaName = pcOldname:
            assign ttExtent.AreaName = pcNewname.
        end.    
        finally:
            temp-table ttExtent:tracking-changes = lTrack.
        end.
    end. 
        
    method public void CreateRow(pcAreaName as char,pNewExtent as IExtent,piNum as int):
        define variable validateError as DataContextError no-undo.
        define variable lTrack as logical no-undo.
        lTrack = temp-table ttExtent:tracking-changes.
        temp-table ttExtent:tracking-changes = true.
        /*        ValidateArea(area).*/
        
        do on error undo, throw: 
            Count = Count + 1.
            create ttExtent.
            assign 
                ttExtent.Number   = piNum  
                ttExtent.AreaName = pcAreaName
                ttExtent.Path     = pNewExtent:Path    
                ttExtent.isFixed  = pNewExtent:isFixed 
                ttExtent.Size     = pNewExtent:Size.   
/*  too soon          ValidateBuffer(buffer ttExtent:Handle).*/
            OnRowCreated().        
            catch e as Error:  
                delete ttExtent.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(pNewExtent),"Extent",e).  
            end catch.  
        
        end.
        finally:
            temp-table ttExtent:tracking-changes = lTrack.
        end.
    end method.
    
     /** override to validate path and size */
    method protected override void ValidateProperty(pcfield as char,poldvalue as char,pnewvalue as char).  
        if valid-object(Service) then 
            undo, throw new CreateOnlyPropertyError("Extent",string(ttExtent.number),pnewValue). 
        super:ValidateProperty(pcField,poldvalue,pnewvalue).
        case pcfield:
/*            when "Path" then                            */
/*                ValidatePath(ttExtent.Number,pnewvalue).*/
            when "Size" then 
                ValidateSize(ttExtent.Number,pnewvalue).                     
        end.     
    end method. 
    
    method public override void ValidateBuffer(phExtent as handle):      
        if phExtent::Isfixed  then
             ValidateSize(phExtent::Number,string(phExtent::Size)).

         /* done in DA  ValidatePath(phExtent::Number,phExtent::Path).*/
    end method.      

   /**      checked in data access, seems safer in case this is moved to a client
    
    method private void ValidatePath(piKey as int,pnewvalue as char).  
        if pnewvalue <> "" then
        do:
            file-info:file-name = pnewvalue.
            if substring(file-info:file-type,1,1) <> "D" then
                 undo, throw new InvalidPropertyValueError(Name,string(pikey),"Path",pnewvalue).
        end.
        if pNewValue = "" then
           undo, throw new ValidationError("Extent",string(pikey),"Path","cannot be blank. Specify a valid directory name or use period to specify the current directory").

    end method.
    */ 
    method private void ValidateSize(piKey as int,pnewvalue as char).  
        if pnewValue = ? then
            undo, throw new UnknownValueError("Size"). 
        
        if int(pnewvalue) lt 32 then 
            undo, throw new InvalidPropertyValueError(Name,string(pikey),"Size",pnewvalue). 
/*  @todo      Warning: Extent size should be a multiple of 16 database blocks*/
    end method.
    
    method public logical CanFindFirstOfArea (areaname as character):
        return can-find(first ttExtent where ttExtent.Areaname = areaname).            
    end.   
      
    method public logical CanFind (areaname as character, iext as int ):
        return can-find(ttExtent where ttExtent.Areaname = areaname
                                 and ttExtent.Number = iext).            
    end.    
    
    method public logical Find (areaname as character, iext as int ):
        find  ttExtent where ttExtent.Areaname = areaname
                       and   ttExtent.Number = iext no-error.
        return avail ttExtent.                          
    end.    
       
    method public override logical CanFind(id as integer):
        undo, throw new  UnsupportedOperationError("CanFind of extent with integer key").        
    end.    
     
    method public override logical CanFind(c as char):
        undo, throw new  UnsupportedOperationError("CanFind of extent with character key").        
    end.  
     
    method public override logical Find(id as integer):
        undo, throw new  UnsupportedOperationError("Find of extent with integer key").  
    end.    
    
    method public override logical Find(name as char):
        undo, throw new  UnsupportedOperationError("Find of extent with character key").        
    end. 
    
    method protected override char FindExpression(i as int):
        return "ttArea.Number = " + quoter(i).
    end method.
    
    method override protected FilteredContext CreateFilteredContext(pParent as IRow,pReq as IRequestInfo):     
        case pParent:SerializeName:  
            when "areas" then
            do:
                return new AreaExtentQuery(this-object,pParent,pReq).
            end.
        end.  
        super:CreateFilteredContext(pParent,pReq).
    end method. 
    
/*    method override protected FilteredContext CreateFilteredContext(pparent as char,pkey as char,pReq as IRequestInfo):*/
/*         case pparent:                                                                                                 */
/*/*             when "areas" then                                     */                                                */
/*/*             do:                                                   */                                                */
/*/*                 return new AreaExtentQuery(this-object,pkey,pReq).*/                                                */
/*/*             end.                                                  */                                                */
/*        otherwise                                                                                                      */
/*                 return super:CreateFilteredContext(pparent,pkey,pReq).                                                */
/*         end.                                                                                                          */
/*    end method.                                                                                                        */

    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new ExtentList(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Extent(cast(cntxt,ExtentContext)).
    end method.
    
    /** override to deal with unique key on number */
    method public override void DataRefreshed(pResponse as IFetchResponse):
        define variable TblResponse as OpenEdge.DataAdmin.Message.ITableResponse no-undo.
        define variable hNewBuffer as handle no-undo.
        define variable hTable as handle no-undo.
        TblResponse = pResponse:GetTableResponse(TableHandle:name).
        if valid-object(TblResponse) then
        do:
            hNewBuffer = pResponse:DataHandle:get-buffer-handle(TableHandle:name).
            hTable = hNewBuffer:table-handle.
            RefreshTable(input table-handle hTable by-reference).
/*            this-object:Total = TblResponse:Total.*/
        end.
        else 
            super:DataRefreshed(pResponse).
    end method.
    
        
end class.
