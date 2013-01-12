 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : new index partitions before create
                 - for new tenant or group       
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using OpenEdge.DataAdmin.DataSource.NewPartitionDataSource from propath.
 
class OpenEdge.DataAdmin.DataSource.NewIndexPartitionDataSource inherits NewPartitionDataSource: 
     
    define protected property StorageIndexMap as char no-undo
        init "ttPartition.IndexName,_Index._Index-name"
        get. 
          
	constructor public NewIndexPartitionDataSource ():	    
		super ("_File,_Index","dictdb._File,dictdb._Index",StorageFileMap + "," + StorageIndexMap).
		BaseQuery = "for each _file where " + FileExpression + " no-lock,"
		          + " each _Index of _file no-lock". 
    end constructor.
    
     
           
end class.