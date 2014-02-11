 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Sep 04 02:01:56 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.TableDataSource inherits DataSource: 
    define protected variable AreaUrl as char no-undo init "/areas/".
    define protected variable mBuffer as handle no-undo.
    
    define protected variable mDBRecid as recid no-undo.	
    define private variable mMapping as char
	   init  	   
"SchemaName,_Owner,~
Name,_File-name,~
trowid,rowid(_File),~
Description,_desc,~
Hidden,_hidden,~
IsMultiTenant,_File-attributes[1],~
KeepDefaultArea,_File-attributes[2]"
/*Description,_Desc,~  */
/*DumpName,_Dump-name,~*/
/*DisplayName,_File-label"*/
 no-undo.
/*
ValidationExpression,_Valexp,~
ValidationMessage,_Valmsg"  no-undo.
*/

     /* valmsg-SA  stringatributes*/
     /* _for - 11 fields   */
     /* _Has-C- F- U- PCnstrs  */
   /*
/* filelabelSA  stringatributes*/
     _hidden
     _frozen
     _db-lang
     _version
     _Tbl-status
     _Tbl-Type
     _crc
     _last-change
     _last-modified
     _mod-sequence
     _field-map
     field fileMisc1 ext 8 
     field fileMisc2 ext 8 
     field fileRes1 ext 8 
     field fileRes2 ext 8 
      _User-Misc
      _Rssid
         */ 
 /*  _cache */  
 /*  _file-number */    
 /*  _dft-pk */
 /* _numkey */    
 /* _numkfld */    
 /* _numkcomp */ 
 /* _Template*/
 /* _numfld */
		
	constructor public TableDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL.
        AreaURL = pcURL + AreaURL.
    end constructor.
    
    constructor public TableDataSource (hchanges as handle ):     
        super (hchanges,"_File","dictdb._File", mMapping).
        BaseQuery = "for each ttTablechange, each _file where _file._file-name = ttTableChange.Tablename and " + DatabaseInfo:FileExpression + " no-lock".
    end constructor.
    
    constructor protected TableDataSource ( alltables as log):     
        super ("_File","dictdb._File", mMapping).   
/*      BaseQuery = "for each _file  no-lock".*/
        BaseQuery = "for each _file" 
                   + (if alltables then "" 
                      else " where " + DatabaseInfo:FileExpression) + " no-lock".
        
    end constructor.
    
	constructor public TableDataSource ( ):	    
		this-object (no).	
    end constructor.
     
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterTableRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
    end method.
    
    method public void AfterTableRow(dataset-handle hds):
        define variable cArea as character no-undo.
        define variable cAreaRef as character no-undo.
        define variable iTbl as integer no-undo.
        assign 
            cArea = ""
            cAreaRef = ""
            iTbl = lookup("_File",Tables).
       
        find dictdb._file where recid(dictdb._file) = DataSourceHandle:get-source-buffer(itbl):recid no-lock.
       
        find dictdb._storage where dictdb._storage._db-recid = dictdb._file._db-recid
                             and dictdb._storage._object-type = 1                                     
                             and dictdb._storage._object-number = dictdb._file._file-number 
                             and dictdb._storage._Partitionid = 0
                             no-lock no-error.
                             
        if avail dictdb._storage and dictdb._storage._Area-number > 0 then
        do:
            find dictdb._area where dictdb._Area._Area-number
                                  =  dictdb._storage._Area-number no-lock.   
            assign
               cArea    = dictdb._area._area-name       
               cAreaRef = AreaURL + WebUtil:UrlEncode(dictdb._Area._Area-name,"default"). 

        end. 
        assign
            mBuffer::AreaName = cArea
            mBuffer::AreaURL  = cAreaRef.
            mBuffer::PartitionsUrl = url + "/schemas/PUB/tables/" + WebUtil:UrlEncode(mBuffer::name) +  "/partitions".
    end method.
    
    method private void DeleteTable(rid as rowid):
        /* this is not used in 11.0.0. We might need this in future.
           NOT TESTED */
           
        define buffer b_IndexField for dictdb._Index-field.   
        define buffer b_FileTrig   for dictdb._File-trig.   
        define buffer b_FieldTrig  for dictdb._Field-trig.
           
        find dictdb._File where rowid(dictdb._File) = rid exclusive-lock no-wait.
        
        for each dictdb._Index of dictdb._File no-lock:
            find b_IndexField of dictdb._Index exclusive-lock no-wait.
            delete b_IndexField.
 
            delete dictdb._Index.
        end.
        
        find b_FileTrig of dictdb._File exclusive-lock no-wait.
        delete b_FileTrig.
        
        for each dictdb._Field of dictdb._File no-lock:
            find b_FieldTrig of dictdb._Field exclusive-lock no-wait.
            delete b_FieldTrig.
            
            delete dictdb._Field.
        end.
        delete dictdb._File.
    end method.   

    method public override logical Save(phbuffer as handle):
        define variable hDataset as handle no-undo. 
        define variable hBeforeBuff as handle    no-undo.
        
        define variable hquery      as handle    no-undo.
       
        
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttTableCopy").    
        hquery:query-open().       
        do transaction on error undo, throw:
            do while true:
                hquery:get-next.             
                if not hBeforebuff:avail then 
                    leave.
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                /* avoid merge changes if not success set to false at end */ 
                phBuffer:error = true.
           
                if hBeforeBuff:row-state = row-created then 
                    undo, throw new UnsupportedOperationError("Create of Table.").
                else 
                    find dictdb._File where dictdb._File._File-name = phBuffer::Name exclusive no-wait.
                
                if phBuffer::KeepDefaultArea = no then
                     undo, throw new DataAccessError("Cannot set KeepDefaultArea to false.").    
                                                
                if dictdb._File._File-attributes[1] = true and phBuffer::IsMultitenant = false then
                     undo, throw new DataAccessError("Cannot set IsMultiTenant to false.").                               
                
                if dictdb._File._File-attributes[1] <> phBuffer::IsMultitenant then
                    dictdb._File._File-attributes[1] = phBuffer::IsMultitenant.
                
                if dictdb._File._File-attributes[2] <> phBuffer::KeepDefaultArea then
                    dictdb._File._File-attributes[2] = phBuffer::KeepDefaultArea.                       
       
       /*         hdataset = phBuffer:dataset.
                AfterTableRow(dataset-handle hdataset  by-reference).     */
                         
                phBuffer:error = false.
                phBuffer:rejected = false.
            end.
            catch e1 as DataAccessError:
            	undo, throw e1.	
            end catch.
            catch e2 as Progress.Lang.Error :
                undo, throw new DataAccessError(new DataMapper("TtTable,_file",mMapping ),e2).
            		
            end catch.
             
        end. /* transaction */
             
    end method.      

end class.