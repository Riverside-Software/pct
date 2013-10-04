/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
   Purpose     : new field partitions before create
                 - for new tenant or group       
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using OpenEdge.DataAdmin.DataSource.NewPartitionDataSource from propath.
 
class OpenEdge.DataAdmin.DataSource.NewFieldPartitionDataSource inherits NewPartitionDataSource: 
     
    define protected property StorageFieldMap as char no-undo
        init "ttPartition.FieldName,_Field._Field-name"
        get. 
          
	constructor public NewFieldPartitionDataSource ( ):	    
		super ( "_File,_Field","dictdb._File,dictdb._Field",StorageFileMap + "," + StorageFieldMap).
		BaseQuery = "for each _file where " +  FileExpression + " no-lock,"
		          + " each _field of _file where _field._data-type = 'clob' or _field._data-type = 'blob' no-lock".
		           
    end constructor.
             
end class.