/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/

/* This is what the QueryString need to know about its owner  */
interface OpenEdge.DataAdmin.Lang.IQueryMap : 
    define public property BaseQuery as character no-undo get. set.   
    method public character ColumnSource(pcColumn as char).
    method public character ColumnSortSource(pcColumn as char).
    method public character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char). 
end interface.
 