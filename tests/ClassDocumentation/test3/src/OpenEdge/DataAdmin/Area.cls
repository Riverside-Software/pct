/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : Area
    Purpose     : yes
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Jun 13 00:13:36 EDT 2010
    Notes       : 
 ----------------------------------------------------------------------*/
routine-level on error undo, throw. 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.

using OpenEdge.DataAdmin.IDataAdminSerializable from propath.
using OpenEdge.DataAdmin.IDataAdminExporter from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.

using OpenEdge.DataAdmin.Area from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.IExtentList from propath.
using OpenEdge.DataAdmin.ExtentList from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IPartitionMap from propath.
using OpenEdge.DataAdmin.Core.JSONWriter from propath.
 
using OpenEdge.DataAdmin.Binding.AreaContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
 
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
/*using OpenEdge.DataAdmin.Error.CreateOnlyPropertyError from propath.*/
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath. 
/*using OpenEdge.DataAdmin.Error.DataError from propath.*/

class OpenEdge.DataAdmin.Area inherits Entity implements IArea: 
    
    define private variable mChild  as logical no-undo. 
    define private variable mExtentStarted as log no-undo. 
    define private variable xcReadOnlyWhy as character no-undo
      init "The Area cannot be edited after it has been created". 
    /** The internal unique area number */ 
    define public property Number as int no-undo     
        init ? 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Number.
            else
                return Number. 
        end.
        
    /** The block size of the area in KB */  
    define public property BlockSize as int no-undo     
        get():
            if valid-handle(mBuffer) then
                return mBuffer::BlockSize.
            else
                return BlockSize. 
        end.
       
     /** Records per block - 1,2,4,8,16,32,64,128 or 256  */  
    define public property RecordsPerBlock as int no-undo     
        init 64
        get():
            if valid-handle(mBuffer) then
                return mBuffer::RecordsPerBlock.
            else
                return RecordsPerBlock. 
        end.
        set(pRecordsPerBlock as int):
            if not Created then
            do:
                 undo, throw new ReadOnlyPropertyError("Area",Name,"RecordsPerBlock",xcReadOnlyWhy).
            end.     
            if valid-handle(mBuffer) then
            do:
                Context:SetProperty(mBuffer:rowid,"RecordsPerBlock",string(pRecordsPerBlock)).
            end.
            else
                RecordsPerBlock = pRecordsPerBlock.
        end. 
   
    
    /** The cluster size. Can be 1 (Type 1 area),8,64 or 512. */  
    define public property ClusterSize as int no-undo 
        init 64    
        get():
            if valid-handle(mBuffer) then
                return mBuffer::ClusterSize.
            else
                return ClusterSize. 
        end.
        set(pClusterSize as int):
            if not Created then
            do:
                undo, throw new ReadOnlyPropertyError("Area",Name,"ClusterSize",xcReadOnlyWhy).
            end.     
            if valid-handle(mBuffer) then
            do:
                Context:SetProperty(mBuffer:rowid,"ClusterSize",string(pClusterSize)).
            end.
            else
                ClusterSize = pClusterSize.
        end. 
    
    /** Returns true if the area is a type 2 area */   
    define public property IsType2 as logical no-undo     
        get():
            define variable isize as integer no-undo.
            isize = ClusterSize.
            return isize = 8 or isize = 64 or isize = 512.
        end.
    
    /** Area type - "Recovery","Transaction log","Event log","Data","Rollforward recovery". */    
    define public property Type as character no-undo     
        init "Data"
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Type.
            else
                return Type. 
        end.
        protected set(pType as character):
            if not Created then
            do:
                undo, throw new ReadOnlyPropertyError("Area",Name,"Type",xcReadOnlyWhy).
            end.
            undo, throw new ReadOnlyPropertyError("Area","","Type","~"Data~" is the only supported value").
             
/*            if valid-handle(mBuffer) then                                   */
/*            do:                                                             */
/*                mDefaultBuffer:find-by-rowid(mBuffer:rowid).                */
/*                mdefaultbuffer::Type = pType.                               */
/*            end.                                                            */
/*            Type = pType.                                                   */
        end. 
    
     /** A numbered list of the Area's extents */ 
    define public property Extents as IExtentList no-undo 
        get():
            if not valid-object(Extents) then
            do:             
                Extents = cast(GetChildCollection("extents"),IExtentList).    
                mExtentStarted = true.                              
            end.         
            return Extents.           
        end.
        private set.
    
    /** The total number of extents in the area. */    
    define public property NumExtents as int no-undo     
        get():
            /* Note - we are throwing unsupported operation for filter on extents 
                      because of this   */
            if mExtentStarted then 
                return Extents:Count. 
            
            if valid-handle(mBuffer) then
                return mbuffer::NumExtents.
            
            return NumExtents.
        end.
     
	constructor public Area (cntxt as IDataAdminContext):
        super (cntxt).     
    end constructor.
    
    constructor public Area (pname as char):
        super (pname).     
    end constructor.
    
    
    constructor public Area (cntxt as IDataAdminContext,preq as IRequestInfo):
        super (cntxt,preq).        
    end constructor.
        
    /**   local context needed - has child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return new AreaContext().
    end method.
     
    method public override void WriteTree(tree as IContextTree):
        WriteTree(tree,"extents").  
    end method.
  
    /** write specified collections (default all) */
    method public override void WriteTree(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo. 
        define variable cColl as character no-undo.
        tree:SetHandle(SerializeName,mDefaultBuffer).   
        do i = 1 to num-entries(pccollections):
           ccoll = entry(i,pccollections).
           case ccoll:
               when "extents" then 
               do:
                   tree:SetJoin(SerializeName,"extents","Number,AreaNumber").
                   Extents:WriteTree(tree,"").
               end.  
           end.    
        end.
       
    end method.
    
    method public override void  ExportTree(pcfile as char):
        define variable writer as IDataAdminExporter no-undo.
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,"All").
    end method.     
    
    method public override void ExportTree(pcfile as char,pcCollectionlist as char):
        define variable writer as IDataAdminExporter no-undo.
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,pcCollectionlist).
    end method.     
    
    method public override void Export():
        Export("area.json").
    end method.    

    method public override void Export(cFile as char):
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Export of new area").
        end.
 
/*        mDefaultBuffer:buffer-field("URL"):serialize-hidden = true.*/
        mDefaultBuffer:buffer-field("ExtentsURL"):serialize-hidden = true.
       
        mDefaultBuffer:write-json ("File",cFile,yes).     
    end method.
        
    method protected IDataAdminExporter GetExporter(pcFile as char):
        define variable i as integer no-undo.
        define variable fileext as character no-undo.
        fileExt = GetFileExtension(pcFile).
        case fileExt:
            when "st" then
                 undo, throw new UnsupportedOperationError("Export Area as structure file."). 
            when "json" then  
                return new JSONWriter().
            otherwise 
                undo, throw new IllegalArgumentError("Export to file with extension " + quoter(fileext)). 
        end.
    end method.
    
    method private char GetFileExtension(pcFile as char):
       define variable i as integer no-undo.
       i = num-entries(pcfile,".").
       if i > 1 then
           return entry(i,pcfile,".").
       else return "".    
    end method.   
    
end class.
