 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
   File        : Iterator
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : hdaniels
   Created     : Dec 2007
   Notes       : 
 ----------------------------------------------------------------------*/

routine-level on error undo, throw.
 
using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.Lang.Collections.ICollection from propath.
using OpenEdge.DataAdmin.Lang.Collections.IIterator from propath.
using OpenEdge.DataAdmin.Lang.Collections.Iterator from propath.
    
class OpenEdge.DataAdmin.Lang.Collections.Iterator implements IIterator use-widget-pool:
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    define protected property QueryHandle       as handle               no-undo  get. set .     
    define protected property BufferHandle      as handle               no-undo  get. set .    
    define protected property ObjectFieldHandle as handle               no-undo  get. set  .    
    
    define private variable mCreate as logical               no-undo.    
     
    constructor public Iterator (TTOrQuery as handle,ofield as char):
        this-object(TTOrQuery,"",ofield,"","").            
    end constructor.
    
    constructor public Iterator (TTOrQuery as handle,ofield as char, sortfield as char):
        this-object(TTOrQuery,"",ofield,sortfield,"").            
    end constructor.
   
    constructor public Iterator (TTOrQuery as handle,ofield as char, sortfield as char, querystring as char):
        this-object(TTOrQuery,"",ofield,sortfield,querystring).            
    end constructor.
    
    constructor public Iterator (TTOrQuery as handle,pcTable as char, pcfield as char, pcsortfield as char, pcquerystring as char):
        super ().       
        if not valid-handle(TTOrQuery) then
           undo, throw new AppError("Unknown handle passed to iterator constructor").
        
        if pcQueryString begins "for " then
            entry(1,pcQueryString," ") = "preselect".
       
        if ttOrQuery:Type = "temp-table" then
        do:
            CreateQuery(TTOrQuery).
            /* sortfield is not in use, sort is expected to be part of expression if neccesary */
            if pcQuerystring begins "preselect " then
            do:
                QueryHandle:query-prepare (pcQuerystring).
            end.
            else
                PrepareQuery(pcquerystring,pcsortfield,pcsortfield = '').
        end.
        else if ttOrQuery:Type ="query" then 
        do:
            if pcsortfield > "" or pcqueryString > "" then
            do:
                QueryHandle = CloneQuery(TTOrQuery).
                /* sortfield is not in use, sort is expected to be part of expression if neccesary */
                if pcQuerystring begins "preselect " then
                    QueryHandle:query-prepare (pcQuerystring).
                else 
                    PrepareQuery(pcquerystring,pcsortfield,pcsortfield = '').
            end.    
            else 
                QueryHandle = TTOrQuery.
            
            if pcTable > "" then
                BufferHandle = QueryHandle:get-buffer-handle(pcTable).
            else
                BufferHandle = QueryHandle:get-buffer-handle(QueryHandle:num-buffers).
              
        end.    
        else 
            undo, throw new AppError(TTOrQuery:Type + " handle passed to iterator constructor").
            
        ObjectFieldHandle = BufferHandle:buffer-field(pcfield).
  
        if not QueryHandle:is-open then 
            QueryHandle:query-open().  
        else 
            QueryHandle:reposition-to-row (1).    
    end constructor.    
    
    method private handle CreateQuery(pTT as handle):
        create buffer BufferHandle for table pTT.
        create query QueryHandle.
        QueryHandle:add-buffer(BufferHandle).
        mCreate = true.
    end method.    
    
    method private handle CloneQuery(phSourceQuery as handle):
        define variable i as integer no-undo.
        define variable hQuery as handle no-undo. 
        define variable hBuf as handle no-undo. 
        create query hQuery.
        do i = 1 to phSourceQuery:num-buffers:
            hBuf = phSourceQuery:get-buffer-handle(i).
            create buffer hBuf for table hBuf.
            hQuery:add-buffer(hBuf).
        end.
        mCreate = true.
        return hQuery.
    end method.    
    
    method private void PrepareQuery (queryExp as char,sortExp as char,forwardOnly as logical):
        QueryHandle:query-prepare('preselect each ' + bufferHandle:name         
            + (if queryExp > '' 
            then ' where ' + queryExp 
            else '') 
            + if sortExp > '' 
            then ' by ' + sortExp
            else ''). 
        QueryHandle:forward-only = forwardOnly.
    end. 
    
    method public logical HasNext(  ):
        define variable offend as logical no-undo.
        
        if QueryHandle:query-off-end then 
        do:
            QueryHandle:reposition-forward(1).
            offend = QueryHandle:query-off-end.
            if not QueryHandle:forward-only then
                QueryHandle:reposition-backward(1).
            return not offend. 
        end. 
        else 
        if QueryHandle:num-results = 1 and QueryHandle:current-result-row = 1 then 
            return not BufferHandle:avail.
        else    
            return QueryHandle:current-result-row lt QueryHandle:num-results.   
    end method.

    method public Object Next(  ):
        define variable nextObj as Object no-undo.
        QueryHandle:get-next().
        if BufferHandle:avail then 
            return ObjectFieldHandle:buffer-value().
        else 
            return ?.
    end method.
  
    /* removes the current item from the underlying collection  */
    method public logical Remove(  ):    
        undo, throw new AppError("Remove not implemented",?).
/*        return false.*/
    end method.

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	destructor public Iterator ( ):
        if mCreate then 
        do:
            delete object QueryHandle no-error.
            delete object BufferHandle no-error.
        end.          
	end destructor.
    
    

end class.