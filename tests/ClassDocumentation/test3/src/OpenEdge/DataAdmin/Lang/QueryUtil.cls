 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : convert a dataset query to before table query
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Sep 28 14:31:20 EDT 2011
    Notes       : based on naming convention 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Lang.QueryUtil implements IQueryMap: 

	define public property BaseQuery as character no-undo 
	get.
	set. 
    
    define variable mQuery  as character no-undo.
    define variable mFields as character no-undo.
    define variable mValues as character extent no-undo.
    define variable mTables as character no-undo. 
    define variable mReplaceTable as character no-undo. 
    
    constructor QueryUtil(pcTables as char).
        define variable i as integer no-undo.
        define variable cTable as character no-undo.
        do i = 1 to num-entries(pcTables):
           cTable = entry(i,pcTables).
           if i = 1 then
               assign 
                   BaseQuery = "preselect each " + cTable     
                   mReplaceTable = cTable.
           else 
               BaseQuery = BaseQuery + ", each " + cTable.           
        end.    
        mTables = pcTables.
    end constructor.
    
    method public character ReplaceQueryValues(pcQuery as char,pcFieldNames as char,pcValues as char extent):
        define variable qstring as QueryString no-undo. 
        mFields = pcFieldnames.
        mValues = pcValues. 
        qstring = new QueryString(pcQuery,this-object).
        return qstring:BuildQueryString(mTables).
    end method.
        
	method public character ColumnExpression( pcColumn as character,  pcOperator as character, pcValue as character ):
        define variable i as integer no-undo.
        define variable cTable as character no-undo.
        define variable ccolumn as character no-undo.
        if pcOperator = "=" or pcOperator = "eq" then
        do:
            assign
                cTable = entry(1,pccolumn,".")
                cColumn = entry(2,pccolumn,".").
            if cTable = mReplaceTable then 
            do: 
                i = lookup(cColumn,mfields).
                if i > 0 then 
                do:
                    return pcColumn + " " + pcOperator + " " + quoter(mValues[i]).
                end.
            end.
        end.  		 
		return ?.
	end method.

	method public character ColumnSortSource( pcColumn as character ):
		return pcColumn.
	end method.

	method public character ColumnSource( pcColumn as character ):
        return pcColumn.
	end method.

end class.