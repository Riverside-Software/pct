/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ISchema from propath.

interface OpenEdge.DataAdmin.ISchemaSet inherits IDataAdminCollection:  
    method public logical CanFind(schemaName as char).  
    method public logical Contains(schemaImpl as ISchema).  
    method public ISchema Find(schemaName as char).  
end interface.