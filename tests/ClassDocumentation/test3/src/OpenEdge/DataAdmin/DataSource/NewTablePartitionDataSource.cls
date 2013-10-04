/**************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
   Purpose     : new table partitions before create
                 - for new tenant or group       
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using OpenEdge.DataAdmin.DataSource.NewPartitionDataSource from propath.
 
class OpenEdge.DataAdmin.DataSource.NewTablePartitionDataSource inherits NewPartitionDataSource: 
               
	constructor public NewTablePartitionDataSource ( ):	    
		super ("_File","dictdb._File",StorageFileMap).
		BaseQuery = "for each _file where " + FileExpression + " no-lock". 
    end constructor.
    
end class.