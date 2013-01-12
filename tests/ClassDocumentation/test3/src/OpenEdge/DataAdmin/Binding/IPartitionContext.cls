/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
/*------------------------------------------------------------------------
    Purpose     : Interface needed by all Partioncontext classes including query
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Nov 01 2010
    Notes       : There are realize methods in IPartitionCollection implementations that
                  use this interface to find the TT. (collection Find returns the class) 
                  The iterator:next relies on these to realize the class. 
                   (could be better ways to sync iterator?)   
                - Collections should ideally call the query context with simpler 
                  interfaces. (except area:partitions)                       
----------------------------------------------------------------------*/

using Progress.Lang.*.

interface OpenEdge.DataAdmin.Binding.IPartitionContext:  
   
    method public logical Allocate().
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
    
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
    method public logical FindGroup(pcgroup as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
        
end interface.