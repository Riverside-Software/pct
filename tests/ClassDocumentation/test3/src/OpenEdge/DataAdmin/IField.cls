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
    Created     : Thu Jun 10 00:52:52 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.ITable from propath.
 
interface OpenEdge.DataAdmin.IField inherits ISchemaElement :  
    /** Parent table of the field */ 
    define public property Table as ITable    no-undo get.
      
    /** the data type of the field */
    define public property DataType as char no-undo get.
end interface.
