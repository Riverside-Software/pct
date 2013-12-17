/**************************************************************/
 /* Copyright (c) 2010-2012 by progress Software Corporation. */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TablePartitionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using OpenEdge.DataAdmin.DataSource.PartitionDataSource from propath.
 
class OpenEdge.DataAdmin.DataSource.TablePartitionDataSource inherits PartitionDataSource: 
    
    define property TableBaseQuery as char no-undo
        get():
           return "for each _file where " + DatabaseInfo:FileExpression + " no-lock,"
                  + " each _StorageObject where " + DatabaseInfo:StorageFileJoin + " no-lock".
        end.  
        
    constructor public TablePartitionDataSource (hchanges as handle ):     
        super (hchanges,"_File","dictdb._File", StorageFileMap).
        BaseQuery = "for each ttTablechange," 
                  + " each _file where _file._file-name = ttTableChange.Tablename and " + DatabaseInfo:FileExpression + " no-lock," 
                  + " each _StorageObject where " + DatabaseInfo:StorageFileJoin + " no-lock".
    end constructor.
 
    constructor public TablePartitionDataSource (hchanges as handle,pfilejoin as char ):     
        super (hchanges,"_File","dictdb._File", StorageFileMap).
        BaseQuery = "for each " +  hchanges:name + "," 
                  + " each _file where " + pFilejoin + " and " + DatabaseInfo:FileExpression + " no-lock,"
                  + " each _StorageObject where " + DatabaseInfo:StorageFileJoin  + " no-lock".
    end constructor.
        
	constructor public TablePartitionDataSource ( ):	    
		super ("_File","dictdb._File",StorageFileMap).
		BaseQuery = TableBaseQuery. 
    end constructor.
    
    constructor public TablePartitionDataSource (pcJoinTables as char, pcJoinPhysTables as char,pcJoinQueries as char ):        
        super ("_File,_StorageObject," + pcJoinTables,
               "dictdb._File,dictdb._StorageObject," + pcJoinPhysTables,
               StorageMap + "," + StorageFileMap + "," + GetMappingForJoin(pcJoinTables),
               TableBaseQuery + ", " + pcJoinQueries).
    end constructor.
    
     
end class.