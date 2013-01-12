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

class OpenEdge.DataAdmin.Lang.BeforeQuery implements IQueryMap: 

	define public property BaseQuery as character no-undo 
	get.
	set. 
    
    define public property Prefix as character no-undo 
    get.
    set. 
    
    define public property Suffix as character no-undo 
    init "Copy"
    get.
    set. 
    
    define variable mQuery  as character no-undo.
    define variable mFields as character no-undo.
    define variable mValues as character extent no-undo.
     
    constructor BeforeQuery(cWhere as char).
        mQuery = cWhere.
    end constructor.
    
    constructor BeforeQuery(pcwhere as char,pcfields as char,pcValues as char extent).
        mQuery = pcWhere.
        mfields = pcfields.
        mValues = pcValues.
    end constructor.
    
    constructor BeforeQuery(pcwhere as char,pcParent as char,pcJoin as char,pcValues as char extent).
        define variable i  as integer no-undo.
        mQuery = pcWhere.
        do i = 1 to num-entries(pcJoin) by 2:
            mfields = mfields 
                    + (if i = 1 then "" else ",")
                    + pcParent 
                    + "."
                    + entry(i,pcJoin).

        end.    
     
        mValues = pcValues.
    end constructor.
    
    method public character GetQueryString():
        define variable qstring as QueryString no-undo. 
        define variable cTable as character no-undo.
       
        qstring = new QueryString(mQuery,this-object).
        cTable = qstring:GetParsedQueryTables().
        return qstring:BuildQueryString(Prefix + cTable + Suffix).
    end method.
        
	method public character ColumnExpression( pcColumn as character,  pcOperator as character, pcValue as character ):
		 
		return ?.
	end method.

	method public character ColumnSortSource( pcColumn as character ):
		return pcColumn.
	end method.

	method public character ColumnSource( pcColumn as character ):
		define variable cTbl as character no-undo.
		define variable cCol as character no-undo.
		define variable i as integer no-undo.
		if mfields > "" then 
		do:
		     i = lookup(pcColumn,mfields).
		     if i > 0 then 
		          return quoter(mValues[i]).
		end.
		if num-entries(pccolumn,".") = 2 then
		do: 
		    cTbl = entry(1,pcColumn,".").
		    cCol = entry(2,pcColumn,".").
            return Prefix + cTbl + Suffix + "." + ccol. 
		end.
		return pcColumn.
	end method.

end class.