/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : IndexDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sep 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.DataSource.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.IndexDataSource inherits DataSource: 
    define protected variable AreaUrl as char no-undo init "/areas/".
    define protected variable mBuffer as handle no-undo.
    define protected variable mDBRecid as recid no-undo.
 	define private variable mMapping as char
	   init  	   
"Name,_Index-name,~
TableName,_File-Name,~
trowid,rowid(_Index),~
IsMultiTenant,_File-attributes[1],~
Description,_Index._Desc,~
IsActive,_Active,~
IsUnique,_Unique"
 no-undo.
    
    constructor public IndexDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL.
        AreaURL = pcURL + AreaURL.
    end constructor.
    
	constructor public IndexDataSource ( ):	    
		super ("_File,_Index","dictdb._File,dictdb._index", mMapping).	
		BaseQuery = "for each _file no-lock, each _index of _file no-lock".
    end constructor.
    
    constructor public IndexDataSource (hchanges as handle ):     
        super (hchanges,"_File,_Index","dictdb._File,dictdb._Index",
               "Name,ttIndexChange.Indexname,ttindex.TableName,ttIndexChange.Tablename,trowid,rowid(_Index),IsMultiTenant,_File-attributes[1]").
        find first dictdb._db where _db._db-local = true no-lock.
        mDBRecid = recid(dictdb._db).
        BaseQuery = "for each ttIndexChange, each _file where _file._file-name = ttIndexChange.Tablename and _file._db-recid = " + quoter(mDBRecid) + " and  _file._owner = 'PUB' and _file._hidden = 'false' no-lock,"
                  + " each _index of _file where _index._index-name = ttIndexChange.Indexname no-lock" .
    end constructor.
     
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterIndexRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
    end method.
    
    method public void AfterIndexRow(dataset-handle hds):
        define variable cArea as character no-undo.
        define variable cAreaRef as character no-undo.
        define variable iSource as integer no-undo.
        assign 
            cArea = ""
            cAreaRef = ""
            iSource = lookup("_index",Tables).
        
        find dictdb._index where recid(dictdb._index) = DataSourceHandle:get-source-buffer(iSource):recid no-lock.
        find dictdb._file of _index no-lock.
        
        if mBuffer::Description = ? then
            mBuffer::Description = "". 
        
        assign 
            mBuffer::IsWordIndex = if dictdb._index._Wordidx > 0 then true else false
            mBuffer::IsPrimary = dictdb._file._prime-index = recid(dictdb._index).
        
        if dictdb._file._file-attributes[1] = false 
        or dictdb._file._file-attributes[2] = true then
        do:    
            find dictdb._storage where dictdb._storage._db-recid = dictdb._file._db-recid
                                 and dictdb._storage._object-type = 2                                     
                                 and dictdb._storage._object-number = dictdb._index._idx-num 
                                 and dictdb._storage._Partitionid = 0
                                 no-lock no-error.
                                 
            if avail dictdb._storage then
            do:
                find dictdb._area where dictdb._Area._Area-number
                                      =  dictdb._storage._Area-number no-lock.   
                assign
                   cArea    = dictdb._area._area-name       
                   cAreaRef = AreaURL + WebUtil:UrlEncode(dictdb._Area._Area-name,"default"). 
            end. 
        end. 
        assign
            mBuffer::AreaName = cArea
            mBuffer::AreaURL  = cAreaRef.
    end method.
    
end class.