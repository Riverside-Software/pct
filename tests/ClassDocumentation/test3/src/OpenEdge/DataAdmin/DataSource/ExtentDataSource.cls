/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : ExtentDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Oct 2010
    Notes       : This currently handles Area updates also. New areas are created when the extent
                  is created, so it happens at the same time, but some code, in particular 
                  refresh after save should use the AreaDataSource if we want to support 
                  PUT (extents) and POST new areas, since we need the URLs that we currently add
                  there on read. 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.ServerCommand.ProstrctAddOnlineCommand from propath.
using OpenEdge.DataAdmin.Message.ProstrctAddOnlineRequest from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.ExtentDataSource inherits DataSource: 
    define stream struct.
    define temp-table ttType2 no-undo
       field IsType2 as logical.
    
    define protected variable AreaTypeNames as char no-undo
        init "Recovery,Transaction log,Event log,Data,Rollforward recovery". 
    define protected variable AreaTypeNumbers as char no-undo
        init "3,4,5,6,7". 
    define protected variable AreaTypeShortNames as char no-undo
        init "b,t,e,d,a". 
    
    define protected property ProStructureCommand as ProstrctAddOnlineCommand  no-undo
        get():
            if not valid-object(ProStructureCommand) then        
                ProStructureCommand = new ProstrctAddOnlineCommand(ldbname("dictdb")).
            return ProStructureCommand.
        end.
        private set.
    
    define protected variable mBuffer as handle no-undo.
	define private variable mMapping as char
	   init  	
"AreaNumber,_Area-number,~
Number,_Extent-number,~
FileName,_Extent-path,~
Size,_Extent-size"
     no-undo.
    
    constructor public ExtentDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL. 
    end constructor.
    
	constructor public ExtentDataSource ( ):	    
		super ("_AreaExtent","dictdb._AreaExtent", mMapping). 
		BaseQuery = "for each _AreaExtent no-lock".
    end constructor.
    
    method public void Save(pArea as handle,pExtent as handle):
        define variable hQuery  as handle no-undo.
        define variable cfile   as character no-undo.
        define variable loknew  as logical no-undo.
        define variable lokext  as logical no-undo.
        define variable hBefore as handle no-undo.
        
        /* check for invalid state 
         - Area is checked in WriteNewAreas 
         - checks that can be done on Extent after buffer is done in WriteExtents */
        hBefore = pExtent:before-buffer.
        hBefore:find-first("where row-state(ttExtentCopy) = row-deleted") no-error. 
        if hBefore:avail then 
            undo, throw new UnsupportedOperationError("Delete of Extent.").
        
        run adecomm/_tmpfile.p ("", ".st", output cfile).

        output stream struct to value(cfile).  
        lokext = WriteExtents(parea,pExtent).
        if valid-handle(parea:before-buffer) then 
            loknew = WriteNewAreas(parea,pExtent).
        output stream struct close. 
        if loknew or lokext then
        do:
            ExecuteProstruct(cfile).
        end. 
        
        RefreshAreas(parea).
        
        
        finally:      
            os-delete value(cfile).
        end. 
    end method.    
    
    method private void ExecuteProstruct(pcfile as char):
        define variable msg as prostrctAddOnlineRequest no-undo.
        msg = new ProstrctAddOnlineRequest().
        msg:FileName = pcfile.
        ProStructureCommand:Execute(msg).
    end method.
    
    method private logical RefreshAreas(phArea as handle):
        define variable hQuery as handle no-undo.
        define variable lok as logical no-undo.
        define variable iType as integer no-undo.
        create query hquery.
        hQuery:set-buffers(phArea).
        hQuery:query-prepare("for each ttArea").
        hQuery:query-open().
        hQuery:get-first.
        do while phArea:avail:    
            find dictdb._area where dictdb._area._area-name = pharea::name no-lock.
            assign 
               phArea::NumExtents = dictdb._area._area-extents.
               phArea::Number = dictdb._area._area-number.
               
            hQuery:get-next.
        end.
    end method.
    
    method private logical WriteNewAreas(phArea as handle,phExtent as handle):
        define variable hQuery as handle no-undo.
        define variable hBefore as handle no-undo.
        define variable cfile as character no-undo.
        define variable lChildok as logical no-undo.
        define variable lok as logical no-undo.
        define variable iType as integer no-undo.
        create query hquery.
        hBefore = phArea:before-buffer.
        hQuery:set-buffers(hBefore).
        hQuery:query-prepare("for each ttAreaCopy").
        hQuery:query-open().
        hQuery:get-first.
        do while hBefore:avail:    
            if hBefore:row-state = row-deleted then 
                undo, throw new UnsupportedOperationError("Delete of Area.").
            if hBefore:row-state = row-modified then 
                undo, throw new UnsupportedOperationError("Update of an existing Area.").
            phArea:find-by-rowid (hBefore:after-rowid).
            if phArea:row-state = row-created then 
            do:
                if can-find(dictdb._area where dictdb._area._area-name = pharea::name) then
                    undo, throw new DataAccessError("Area " +  quoter(pharea::name) + " already exists." ).

/*     V1           if phArea::Type <> "Data" then                                                                                                               */
/*                do:                                                                                                                                          */
/*                    if lookup(phArea::Type,AreaTypeNames) > 0 then                                                                                           */
/*                          undo, throw new DataAccessError("Area Type " +  quoter(phArea::Type) + " is not supported. The only supported type is ~"Data~"." ).*/
/*                    else                                                                                                                                     */
/*                       undo, throw new DataAccessError("Area Type " +  quoter(phArea::Type) + " is invalid. The only supported type is ~"Data~"." ).         */
/*                end.                                                                                                                                         */
                
/*    V2            if lookup(phArea::Type,AreaTypeNames) = 0 then                                                       */
/*                    undo, throw new DataAccessError("Type " +  quoter(phArea::Type) + " is not a valid Area Type." ).*/
            end.       
            phExtent:find-first ("where AreaName = " + quoter(phArea::name)) no-error.
            if not phExtent:avail then 
                undo, throw new DataAccessError("Area " + quoter(phArea::name) + " was not created."  
                                             +  " An Area must have at least one Extent.").
       
            lChildok = WriteChildExtents(phArea,phExtent) .        
            if lChildOk then
               lok = true.
            hQuery:get-next.
        end.
        
        return lok.
        finally:
            delete object hquery no-error.		
        end finally.
    end method.         
    
    method private logical WriteExtents(phArea as handle, phExtent as handle):
        define variable hQuery as handle no-undo.
        
        define variable cfile as character no-undo.
        define variable lok as logical no-undo.
        create query hquery.
        
        hQuery:set-buffers(phExtent).
        hQuery:query-prepare("for each ttExtent by ttExtent.Number").
        hQuery:query-open().
        hQuery:get-first.
        
        do while phExtent:avail:
            
            if phExtent:row-state = row-deleted then 
                undo, throw new UnsupportedOperationError("Delete of Extent.").
            
            if phExtent:row-state = row-modified then 
                undo, throw new UnsupportedOperationError("Update of an existing Extent.").
            
            /* check if new or old area - if changed (new or delete/modify unsupported) then we'll skip it here and 
               handle it in WriteNewAreas */
            phArea:find-unique("where name = " + quoter(phExtent::AreaName)) no-error.
            if pharea:avail = false or pharea:row-state = 0 then
            do: 
                 find dictdb._area where dictdb._area._area-name = phExtent::AreaName no-lock. 
                 if not avail dictdb._area then 
                 do:
                    undo, throw new DataAccessError("Cannot create Extent for non existing Area " + quoter(phExtent::AreaName)).
                 end.    
                 WriteExtent(dictdb._area._area-name,GetProstructFileType(dictdb._area._area-type),0,GetRecordsPerBlock(dictdb._area._area-recbits),dictdb._area._Area-clustersize,phExtent::Path,phExtent::Isfixed,phExtent::Size).
                 lok = true.
            end.
         
            hQuery:get-next().
        end.         
        
        return lok. 
    end method.        
        
    method private logical WriteChildExtents(phArea as handle, phExtent as handle):
        define variable hQuery as handle no-undo.
        
        define variable cfile as character no-undo.
        define variable lok as logical no-undo.
        
        create query hquery.
        
        hQuery:set-buffers(phExtent).
        hQuery:query-prepare("for each ttExtent where ttExtent.AreaName = " + quoter(phArea::Name) + " by ttExtent.Number").
        hQuery:query-open().
        hQuery:get-first.
        do while phExtent:avail:
            WriteExtent(phArea::name,GetProstructFileType(phArea::type),0,phArea::RecordsPerBlock,phArea::ClusterSize,phExtent::Path,phExtent::Isfixed,phExtent::Size).
            lok = true.
            hQuery:get-next().
        end.         
        
        return lok. 
    end method.    
    
    /* records per block from dictdb._area._area-recbits */
    method private int GetRecordsPerBlock(i as int):
        return if i = 0 then 1 else int(exp(2,i)).
    end method.
    
    method protected character GetDLC():
        define variable cDLC as character no-undo.
        if opsys = "Win32":U then /* Get DLC from Registry */
            get-key-value section "Startup":U key "DLC":U value cDLC.
        if (cDLC = "" or cDLC = ?) then 
        do:
            cDLC = os-getenv("DLC":U). /* Get DLC from environment */
        end.
        return cDLC.
    end method.
    
    method private void WriteExtent(cArea as char,cType as char,id as int,rpb as int,clust as int,cpath as char,fixed as log,sz as int  ):
        define variable cDbPath as character no-undo.
        define variable cspecify as character no-undo 
          init "Specify a valid directory name or use period to specify the current directory.".
        if cpath  = ? then
            undo, throw new DataAccessError("Extent for area " + cArea + " cannot be created with unknown path. " + cspecify). 
             
        if cpath  = "" then
        do:
            file-info:file-name = pdbname("dictdb") + ".db".
            cDbPath = GetPath(pdbname("dictdb")).
            file-info:file-name = cDbPath.
            if file-info:file-name = ? or substring(file-info:file-type,1,1) <> "D" then
                undo, throw new DataAccessError("Extent for area " + cArea + " cannot be created with default path because the database info is not known. " + cspecify).
            
            cPath = cDbPath.
        end.
        else if cpath > "" and cPath <> "." then
        do:
             file-info:file-name = cpath.
             if substring(file-info:file-type,1,1) <> "D" then
                 undo, throw new DataAccessError("Extent for area " + cArea + " cannot be created with path " + cPath + ". " + cSpecify).
        end.
        
        /* "TenantCommon":5,32;64 /11/db f 1024 */
        put stream struct unformatted    
/*           cType + " "*/
           "d "
           quoter(cArea) 
           + (if id > 0 then (":" + string(id)) else "") 
           + "," 
           + string(rpb) 
           + ";"
           + string(clust)
           " " 
           (if cpath > "" and cPath <> "." then "!" + quoter(cpath) else ".")
          
           (if fixed then " f " + string(sz) else "")
             skip.   
    end method.
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterExtentRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
    end method.
    
    method public void AfterExtentRow(dataset-handle hds):
        define variable hbuffer as handle    no-undo.
        define variable hbufferArea as handle    no-undo.
        define variable iunix as integer no-undo.
        define variable idos as integer no-undo.
        define variable iPathPos as integer no-undo.
        define variable cfile as character no-undo.
        
        assign
            hbufferArea = hds:get-buffer-handle("ttArea")
            hBuffer = hds:get-buffer-handle("ttExtent")
            hBuffer::IsFixed  = hbuffer::Size <> 0
            hBuffer::AreaName  =  hbufferArea::Name
            cfile = hBuffer::FileName
            iunix = r-index(cfile,"/")
            idos = r-index(cfile,"~\")
            iPathPos = max(iunix,idos).
       
        if iPathPos > 0 then
             hBuffer::Path = substr(cfile,1,iPathPos - 1).
         
    end method.     
    
    method private char GetProstructFileType(iType as int):
        define variable i as integer no-undo.
        i = lookup(string(iType),AreaTypeNumbers).
        if i > 0 then
           return entry(i,AreaTypeShortNames).
        else
            undo, throw new IllegalArgumentError("Invalid type number " + quoter(iType) + " used in prostruct generation.").
        end method.
    
    method private char GetProstructFileType(cType as char):
        define variable i as integer no-undo.
        i = lookup(cType,AreaTypeNames).
        if i > 0 then
           return entry(i,AreaTypeShortNames).
        else
            undo, throw new IllegalArgumentError("Invalid type " + quoter(cType) + " used in prostruct generation.").
    end method.    
    
    method private char GetPath(cFile as char):
        define variable iunix as integer no-undo.
        define variable idos as integer no-undo.
        define variable iPos as integer no-undo.
        iunix = r-index(cfile,"/").
        idos = r-index(cfile,"~\").
        ipos = max(iunix,idos).
        if ipos > 0 then
           return substr(cfile,1,ipos).
        return cfile.   
    end method.    
    
end class.