/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Field permission defines who can access the field 
                  through character can-do expressions in the Can* properties
                  It has the same key (Name) as IField
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
 
interface OpenEdge.DataAdmin.IFieldPermission inherits IDataAdminElement:   
    define public property Name     as character no-undo get.  
    define public property CanRead  as character no-undo get. set.
    define public property CanWrite as character no-undo get. set.
end interface.
