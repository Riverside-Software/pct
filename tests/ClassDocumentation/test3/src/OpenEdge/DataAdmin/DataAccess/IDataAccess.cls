/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : fetch and save data access interface 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
----------------------------------------------------------------------*/
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
interface OpenEdge.DataAdmin.DataAccess.IDataAccess:  
     method public void FetchData(msg as IFetchRequest).    
     method public ISaveRequest SaveData(msg as ISaveRequest).
end interface.