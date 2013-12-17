/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
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
    Created     : Mon Aug 23 21:18:14 EDT 2010
    Notes       :  
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.*.
using OpenEdge.DataAdmin.DataAccess.IDataMapper.
 
class OpenEdge.DataAdmin.DataAccess.DataMapper implements IDataMapper:  
    
	define public property ReturnBlankWhenNotFound as logical no-undo 
    	init yes
    	get.
    	set. 

    define private variable mColumnMap as char no-undo.
    define private variable mTableMap as char no-undo.
    
    /* Convenience for mapped buffers - Note we're not storing the handles. */
  	constructor public DataMapper (hTarget as handle,hSource as handle):
		this-object(hTarget:Name + "," + hSource:Name,hTarget:data-source-complete-map).	
	    if hTarget:data-source-complete-map = ? then  
	        undo, throw new IllegalArgumentError("Target handle passed to DataMapper is not mapped to a source.").         
	    catch e as Error :
	       
        	undo, throw new IllegalArgumentError("Wrong or invalid handles pass to DataMapper constructor.").	
        end catch.
	end constructor.
    
    constructor public DataMapper (cTableMap as char,cColumnMap as char):
        super ().  
        if cTablemap > "" and cColumnMap <> ? then
           assign 
               mTableMap = cTableMap
               mColumnMap = cColumnMap.
        else  
             undo, throw new IllegalArgumentError("empty or unknown values passed to DataMapper constructor.").   
     
      
    end constructor.
    
    method public character GetSourceColumn(pcColumn as char):
        return GetSource(pcColumn,mColumnMap).
    end method.   
    
    method public character GetTargetColumn(pcColumn as char):
        return GetTarget(pcColumn,mColumnMap).    
    end method.
    
    method public character GetSourceTable(pcTable as char):
        return GetSource(pcTable,mTableMap).
    end method.   
    
    method public character GetTargetTable(pcTable as char):
        return GetTarget(pcTable,mTableMap).       
    end method.     
    
    method private character GetTarget(pcName as char,pcMap as char):
        define variable iLookup as integer no-undo.
        define variable cFound as character no-undo.
        iLookup = lookup(pcName,pcMap).
        if iLookup > 0 and ilookup modulo 2 = 0 then
        do:
            cFound =  entry(iLookup - 1,pcMap).
            return cFound.
        end.
        If ReturnBlankWhenNotFound then
            return "". 
        return pcName.   
    end.
    
    method public character GetSource(pcName as char,pcMap as char):
        define variable iLookup as integer no-undo.
        define variable cFound as character no-undo.
        iLookup = lookup(pcName,pcMap).
        if iLookup > 0 and ilookup modulo 2 <> 0 then
        do:
            cFound =  entry(iLookup + 1,pcMap).
            return cFound.
        end.
        If ReturnBlankWhenNotFound then
            return "". 
        return pcName.   
    end.
        
end class.