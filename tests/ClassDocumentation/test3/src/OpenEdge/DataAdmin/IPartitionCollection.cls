/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IPartitionCollection
    Purpose     : General interface for the various partitionmaps
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : Ideally tenant an group partioncollections/maps should not need to 
                  implement these, since they have the key, but the 
                  iterator:next (currently?) relies on these to realize the class.
                - Map implementations (should) validate that the passed key
                  matches the internal parent.      
  ----------------------------------------------------------------------*/

 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
 
using OpenEdge.DataAdmin.IPartition from propath. 
 
interface OpenEdge.DataAdmin.IPartitionCollection inherits IDataAdminCollection  :  
   
    method public logical Contains(partition as IPartition).  
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
    
    method public IPartition FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
    method public IPartition FindGroup(pcgroup as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
     
end interface.
