/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/

/*------------------------------------------------------------------------------
  Purpose: Base query 
  Notes:   Does not set Tables 
           Known subclass trees
           DataSource - does not call constructor
            DBQuery -> DataSource -> many 
           Binding.Query
            AbstraQueryContext -> FilteredContext -> many
                               -> CreateContext
                               -> more
------------------------------------------------------------------------------*/
routine-level on error undo, throw.   
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
 
class OpenEdge.DataAdmin.Binding.Query.DataAdminQuery abstract  :
   
  define public abstract property Tables   as character no-undo get.   
  
  define public    property Table          as char      no-undo get. set.
  define public    property BaseQuery      as character no-undo get. set.
  define public    property KeyFields      as character no-undo get. set.    
  define public    property UseRowid       as logical   no-undo get. set.
  define public    property PhysicalTables as character no-undo  get. set.
  define protected property QueryHandle    as handle    no-undo  get. set.
  define private   property BufferHandles  as handle  extent  no-undo  get. set.
  
  define protected property QueryMode      as char no-undo 
      init "PRESELECT"
      get. 
      set.
  
  define protected property QueryLock      as char no-undo 
      get. 
      set.
  
  constructor public DataAdminQuery(): 
       super().  
  end constructor.
  /*
  constructor public DataAdminQuery(hBuffer as handle): 
       this-object(hBuffer:name,SingleExtent(hBuffer)).
  end constructor.
  */
 
  constructor public DataAdminQuery(pcTable as char): 
       define variable i as integer no-undo.
       super().
       this-object:Table = pcTable.    
  end constructor.
 
  method protected abstract handle extent GetBufferHandles():
   
  method protected handle extent SingleExtent(ph as handle):
       define variable h as handle extent 1 no-undo.
       h[1] = ph.
       return h.
  end. 
  
  method protected void CreateQuery():
      define variable iBuffer    as integer no-undo.
      define variable hBuffer    as handle  no-undo.
      define variable i as integer no-undo.
      define variable cPhysTable as character no-undo.
      
      BufferHandles = GetBufferHandles().
      
      DeleteQuery().
      create query QueryHandle.
      do iBuffer = 1 to extent(BufferHandles):
          create buffer hBuffer for table BufferHandles[iBuffer].
          QueryHandle:add-buffer(hBuffer).
      end.
  end method.
  
  method protected void DeleteQuery():
      /* delete the handles  */
    define variable iBuffer as integer    no-undo.
    define variable h       as handle     no-undo extent 18.
    define variable iNum    as integer    no-undo.
 
    if valid-handle(QueryHandle) then
    do:
      iNum = QueryHandle:num-buffers.
      /* we loose num-buffers on first delete */
 
      do iBuffer = 1 to iNum:
        h[iBuffer] = QueryHandle:get-buffer-handle(iBuffer).
      end.
      
      do iBuffer = 1 to iNum: 
        delete object h[iBuffer]  no-error.
      end.
      delete object QueryHandle no-error.
    end.
      
  end method.
  
  destructor public DataAdminQuery () :
      DeleteQuery().
  end destructor.

  method public logical Prepare ():
      return QueryHandle:query-prepare(currentQuery()).     
  end.
  
  method protected logical ResetQuery ():
      return QueryHandle:query-prepare(defaultQuery()).     
  end.
  
  method protected character CurrentQuery ():
  /*------------------------------------------------------------------------------
    Purpose:     Return the current query for query manipulation and prepare.
                 returns the default if not yet prepared.
  ------------------------------------------------------------------------------*/
      define variable cQueryString as character  no-undo.
    
      if QueryHandle:prepare-string > '' then
          return QueryHandle:prepare-string.

      return DefaultQuery().

  end method. 
  
  method public character extent GetCurrentRowKey():
      define variable i          as integer   no-undo.
      define variable bufferHdl  as handle    no-undo.
      define variable fieldName  as character no-undo.
      define variable bufferName as character no-undo.
      define variable tableNum   as integer   no-undo.
      define variable keyWhere   as character extent no-undo.
      define variable fieldWhere as character no-undo.
      
      extent(keyWhere) = num-entries(Tables).
      do i = 1 to num-entries(KeyFields):
          fieldName = entry(i,KeyFields).
          if num-entries(fieldName,".") > 2 then
              undo, throw new AppError("Too many qualifiers in KeyFields").
          if num-entries(fieldName,".") = 2 then
              assign 
                  bufferName = entry(1,fieldName,".")
                  fieldName  = entry(2,fieldName,".").
          else 
              bufferName = entry(1,Tables).
          
          assign
              tableNum   = lookup(bufferName,Tables)        
              bufferHdl  = QueryHandle:get-buffer-handle(bufferName).
 
          if (bufferHdl:avail) then   
              keyWhere[tableNum] = (if keyWhere[tableNum] > "" 
                                     then keyWhere[tableNum] + " and " 
                                     else "where ")
                                  +  bufferName + "." + fieldName 
                                  + " = " 
                                  + quoter(bufferHdl:buffer-field(fieldName):buffer-value).
          else 
              keyWhere[tableNum] = ?.                       
      end.    
      return keyWhere.
  end method.    
  
  method public character DefaultQuery ():
  /*------------------------------------------------------------------------------
    Purpose:     Return the BaseQuery or build a default query. 
  ------------------------------------------------------------------------------*/
    define variable iBuffer     as integer    no-undo.
    define variable cPrepare    as character  no-undo.
    define variable cBuffer     as character  no-undo.
    define variable cParent     as character  no-undo.
    define variable cMode       as character  no-undo.
    define variable cKeyTable   as character  no-undo.

    if BaseQuery <> '' then
      return BaseQuery.
    
    /* assume the first table in the definition is the main table that 
       the others join to and that need to have 'EACH' if joined from
       one of the other tables */
    cKeyTable = entry(1,Tables).
    
    /* If there's more than one buffer than add them, just assuming that
       an OF relationship to the first table in tables will properly relate them. */
    cPrepare = " " + QueryMode + " EACH " + QueryHandle:get-buffer-handle(1):NAME 
             + (if QueryLock > "" then " " + QueryLock else "").
    do iBuffer = 2 to QueryHandle:num-buffers:

      assign 
          cBuffer  = QueryHandle:get-buffer-handle(iBuffer):NAME
          cParent  = if cKeyTable = cBuffer then 
                         QueryHandle:get-buffer-handle(1):NAME
                     else  
                         QueryHandle:get-buffer-handle(cKeyTable):NAME
          cMode    = if cKeyTable = cBuffer then 'EACH' else 'FIRST'
          cPrepare = cPrepare 
                 + ", " + cMode + " " + cBuffer + " OF " +  cParent 
                 + (if QueryLock > "" then " " + QueryLock else "").

    end.   /* DO iBuffer = 2 */
    cPrepare = cPrepare + ' INDEXED-REPOSITION'.  
    return cPrepare.
  end.

  method public character ColumnValue (pcColumn as char):
    define variable cBuffer as character  no-undo.
    define variable cColumn as character  no-undo.
    define variable cValue  as character  no-undo.
    define variable hBuffer as handle     no-undo.

    assign
      cBuffer = entry(1,pcColumn,'.')
      cColumn = entry(2,pcColumn,'.')  
      hBuffer = QueryHandle:get-buffer-handle(cBuffer).
    if hBuffer:AVAIL then
    do:
      /* extent support could be added by <field>[i] as param, 
        but this used for keys though */
      cValue = hBuffer:buffer-field(cColumn):BUFFER-VALUE(0). 
      /* this string is for transport of values, so return unknown as string
       (assuming '?' never is a value in a progress DB...)*/        
      return if cValue <> ? then cValue else '?'.
    end.
    return ?. /* not avail*/ 
  end method.

  /* order neutral position that is safe if tables changes order 
     passed back to setPosition  
     note that one need all rowids when the unique table is not 
     the first  */
  method public character extent GetPosition ():
     define variable iBuffer as integer    no-undo.
     define variable cBuffer as character  no-undo.
     define variable cPosition as character extent no-undo.
     
     extent(cPosition) = num-entries(Tables).
     
     do iBuffer = 1 to num-entries(Tables):
       assign
         cBuffer = entry(iBuffer,Tables)    
         cPosition[iBuffer] = string(QueryHandle:get-buffer-handle(cBuffer):rowid).
     end.
     
 
     return cPosition.
  end method.
 
  /* set position as returned from GetPosition */
  method public logical SetPosition (prPosition as rowid extent  ):
      define variable lOk as logical no-undo.
      define variable iNumExtents as integer no-undo.
      iNumExtents = extent(prPosition).
      case iNumExtents:
      /* workaround for 2 issues: extent 1 old - many extents new */
      when 1 then
          lOk = QueryHandle:reposition-to-rowid(prPosition[1]) no-error.
      when 2 then
           lOk = QueryHandle:reposition-to-rowid(prPosition[1],prPosition[2]) no-error.
      when 3 then
           lOk = QueryHandle:reposition-to-rowid(prPosition[1],prPosition[2],prPosition[3]) no-error.
      when 4 then
           lOk = QueryHandle:reposition-to-rowid(prPosition[1],prPosition[2],prPosition[3],prPosition[4]) no-error.
      when 5 then
           lOk = QueryHandle:reposition-to-rowid(prPosition[1],prPosition[2],prPosition[3],prPosition[4],prPosition[5]) no-error.
      when 6 then
           lOk = QueryHandle:reposition-to-rowid(prPosition[1],prPosition[2],prPosition[3],prPosition[4],prPosition[5],prPosition[6]) no-error.
      otherwise 
          undo, throw new UnsupportedOperationError("More than 6 buffers in SetPosition.").    
/*          lOk = QueryHandle:reposition-to-rowid(prPosition).*/
      end case.
      if lOk then 
          QueryHandle:get-next.
      return lOk.  
  end method. 
  
   /* We may clone this query in order to get row keys from a result without
       causing the 'real' query to reposition. This may be used when performing
       multi-select operations in the UI, where we don't want to move off the
       current record. Note that these actions may be expensive, because of the
       cost of creating, opening, etc the query. */
  method protected handle CloneQuery(input phSource as handle):
      define variable hQueryClone as handle no-undo.        
      define variable iLoop as integer no-undo.
      define variable iMax as integer no-undo.
    
      create query hQueryClone.
      iMax = phSource:num-buffers.
    
      do iLoop  = 1 to iMax:
          hQueryClone:add-buffer(phSource:get-buffer-handle(iLoop)).
      end.
      hQueryClone:query-prepare(phSource:prepare-string).

      return hQueryClone.
  end method. 
  
   method protected void RemoveQueryBuffers(phQuery as handle):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = phQuery:num-buffers. 
        
        /* Clean up after ourselves. Note that this only removes the
           named buffer used for the query, and not the underlying buffer
           itself. */
        do iLoop = 1 to iMax:
            delete object phQuery:get-buffer-handle(iLoop).
        end.
    end method.
        
  method public logical SetPosition (pKeyWhere as char):
      define variable tableNum   as integer no-undo.
      define variable tokenNum   as integer no-undo.
      define variable fieldName  as character no-undo.
      define variable fieldValue as character no-undo.
      define variable bufferName as character no-undo.
      define variable keyWhere   as character extent no-undo.
      
      extent(keyWhere) = num-entries(Tables).
      /* remove double blanks */
      do while index(pKeyWhere,"  ") > 0:
          pKeyWhere = replace(pKeyWhere,"  "," ").
      end.     
      
      /* allow string passed without "where" and trim blanks front/end */ 
      pKeyWhere = (if entry(1,pKeyWhere," ") <> "where" then "where " else "")
                + trim(pKeyWhere," ").
          
      do tokenNum = 1 to num-entries(pKeyWhere," ") by 3:
          if tokenNum > 1 and entry(tokenNum,pKeyWhere," ") <> "and" then
              undo, throw new AppError("Illegal format of key where: "  + pKeyWhere).
      
          assign
              fieldName  = entry(tokenNum + 1,pKeyWhere," ")
              fieldValue = entry(tokenNum + 2,pKeyWhere," ").
          
          if num-entries(fieldName,".") = 1 then
          do:
              if num-entries(Tables) = 1 then 
                  bufferName = Tables.
              else
                  undo, throw new AppError("Illegal unqualified field reference: "  + fieldName).
          end.
          else if num-entries(fieldName,".") = 2 then
              assign 
                  bufferName = entry(1,fieldName,".")
                  fieldName  = entry(2,fieldName,".").
          else do:
              undo, throw new AppError("Too many qualifiers in field reference: "  + fieldName).
          end.
 
          assign 
              tableNum = lookup(bufferName,Tables) 
              keyWhere[tableNum] = (if keyWhere[tableNum] > "" 
                                    then keyWhere[tableNum] + " and " 
                                    else "where ")
                                  +  bufferName + "." + fieldName 
                                  + " = " 
                                  + if not fieldValue begins "'" and not fieldValue begins '"' 
                                    then quoter(fieldValue)
                                    else fieldValue.         
             
      end.    
      SetPosition(KeyWhere).
  end method.
  
  /* set position as returned from GetPosition */
  method public logical SetPosition (pcPosition as char extent):
      define variable hBuffer    as handle  no-undo.
      define variable iBuffer    as integer no-undo.
      define variable iTable     as integer no-undo.
      define variable rPosition  as rowid   extent no-undo.
      define variable lOk        as logical no-undo.
      
      extent(rPosition) = QueryHandle:num-buffers.
      do iBuffer = 1 to QueryHandle:num-buffers:
          iTable = lookup(QueryHandle:get-buffer-handle(iBuffer):NAME,Tables).
          if UseRowid then 
              rPosition[iBuffer] = to-rowid(pcPosition[iTable]).
          else do:   
              hBuffer = QueryHandle:get-buffer-handle(iTable). 
              hBuffer:find-unique("where " + pcPosition[iTable]) no-error.
              rPosition[iBuffer] = hBuffer:rowid.
          end.
      end.
      
      return SetPosition(rPosition).
  end method.
 
end.

