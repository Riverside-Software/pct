/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** 
    Purpose     : Area interface 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Jun 09 23:22:52 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IExtentList.
using OpenEdge.DataAdmin.IPartitionMap.
using OpenEdge.DataAdmin.IDataAdminElement.

interface OpenEdge.DataAdmin.IArea inherits IDataAdminElement:  
    /** The unique name identifier of the area */
    define public property Name as char no-undo get. set.
    
    /** The internal unique area number */ 
    define public property Number as int no-undo get. 
    
    /** The block size of the area in KB */  
    define public property BlockSize as int no-undo get.  
    
    /** The cluster size. Can be 1 (Type 1 area),8,64 or 512. */  
    define public property ClusterSize as int no-undo get. set.
    
    /** Records per block - 1,2,4,8,16,32,64,128 or 256  */  
    define public property RecordsPerBlock as int no-undo get. set.
     
    /** Returns true if the area is a type 2 area */
    define public property IsType2 as logical no-undo get.
    
    /** Area type - "Recovery","Transaction log","Event log","Data","Rollforward recovery". 
        Currently read-only and defaults to "Data" for new Areas */
    define public property Type as char no-undo get.  
    
    /** The number of extents */
    define public property NumExtents as int no-undo get.  
    
    /** A numbered list of the Area's extents */ 
    define public property Extents as IExtentList no-undo get.
      
end interface.
