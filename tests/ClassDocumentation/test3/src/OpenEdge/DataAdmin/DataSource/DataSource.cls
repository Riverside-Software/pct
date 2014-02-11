/**  DataSource manages the source query for a target and deals with various 
     query tranformation in support of this. It implements IQueryMap 
     to utilize QueryString for the transformation                       HD **/


routine-level on error undo, throw.     
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DBQuery from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.DatabaseInfo from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Lang.WebUtil from propath.

class OpenEdge.DataAdmin.DataSource.DataSource inherits DBQuery implements IDataSource, IQueryMap:
    
    define private variable mBuffer as handle no-undo.
         
    define protected property DatabaseInfo as DatabaseInfo no-undo 
        get():
            if not valid-object(DatabaseInfo) then
                DatabaseInfo = new DatabaseInfo().
            return DatabaseInfo.     
        end. 
        set.
    
    define protected property WebUtil as WebUtil no-undo 
        get():
            if not valid-object(WebUtil) then
                WebUtil = new WebUtil().
            return WebUtil.     
        end. 
        set.
    
    define protected property ParentRelation as handle no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer:parent-relation.
            else 
                return ?.    
        end.    
    
    define public property NumRecords     as integer   no-undo 
        init ?
        get. set.
         
    define public property BatchSize as integer   no-undo 
        get.     
        set(newSize as integer):
            if valid-handle(mBuffer) then
                mBuffer:batch-size = newSize.
            BatchSize = newSize.   
        end.
    
    define public property FillMode     as character no-undo 
        get.    
        set(newMode as character):
            if valid-handle(mBuffer) then
                mBuffer:fill-mode = newMode.
            FillMode = newMode.   
        end.
    
    define protected property DataBuffer      as handle    no-undo
       get():
           return mBuffer.
       end.    
       set(hbuff as handle):
            /* allow Batchsize and fillmode to be set before attach
              (disallow/override setting to buffer directly before attach)*/
           mBuffer = hbuff.   
           mBuffer:fill-mode = FillMode.
           mBuffer:batch-size = BatchSize.
           
       end.    
                
    define public property Url          as character   no-undo 
        get. 
        set(pcUrl as char):
           Url = pcUrl.
           AfterSetUrl().
        end.
    
    define public property FillError    as Error no-undo get. set.
  
    define protected property DataSourceHandle  as handle    no-undo get. set.
    define protected property SaveSourceHandle  as handle    no-undo get. set.
    
    define protected property FieldMapping as character no-undo 
        get. 
        /* restrict set as it has to be set before attachDataSource*/
        protected set.
   
    define private   variable mcClientPosition  as character no-undo.
   
    define private   variable mcClientRequest   as character no-undo.
  
    define private   variable mlIgnoreLastBatch as logical    no-undo.

    constructor public DataSource (pcTables    as char,
                                   pcMapping   as char) :

        this-object(pcTables,pcTables,pcMapping).
        FieldMapping = pcMapping.
    end constructor.
  
    constructor public DataSource (pcTables  as char,
                                   pcPhysicalTables as char,
                                   pcMapping     as char) :
        super(pcTables,pcPhysicalTables,""). 
        this-object:Table = entry(1,pcTables).  
        FieldMapping = pcMapping.
    end constructor.
    
    constructor public DataSource (hTempSource as handle,
                                   pcTables  as char,
                                   pcPhysicalTables as char,
                                   pcMapping     as char) :
        super(hTempSource,pcTables,pcPhysicalTables,""). 
        this-object:Table = entry(1,pcTables).  
        FieldMapping = pcMapping.
    end constructor.
    
    constructor public DataSource (pcTables  as char,
                                   pcPhysicalTables as char,
                                   hTempSource as handle,
                                   pcMapping     as char) :
        super(pcTables,pcPhysicalTables,"",hTempSource). 
        this-object:Table = entry(1,pcTables).  
        FieldMapping = pcMapping.
    end constructor.
      
    method public logical Save(bufferHandle as handle).
        undo, throw new UnsupportedOperationError("Save of " + GetClass():TypeName).
    end method.     
    
    method public logical Save(bufferHandle as handle,piState as integer).
        undo, throw new UnsupportedOperationError("Save a specified state for " + GetClass():TypeName).
    end method.       
     
    method public logical Refresh(bufferHandle as handle).
        undo, throw new UnsupportedOperationError("Refresh for " + GetClass():TypeName).
    end method.       
     
    /* override to set url dependent props/vars*/
    method protected void AfterSetUrl():
    end method.  
  
    method protected void DetachDatasource(phBuffer as handle):
    end method.  
  
    method public logical Attach(bufferHandle as handle).
        define variable lok as logical no-undo.
        CreateMapSource().
        FillMode = "no-fill".
        DataBuffer = bufferHandle.
        
        return bufferHandle:attach-data-source (DataSourceHandle,FieldMapping).
    end method.
    
    method public void AfterRow(dataset-handle hds):
    end method.
    
    
    method public logical Fill().
         define variable hDs as handle.
         define variable i as integer no-undo.
                     
         QueryHandle:query-open().   
         QueryHandle:get-first(). 
         hds = DataBuffer:dataset.
      
         do while QueryHandle:get-buffer-handle(1):avail:
             DataBuffer:buffer-create().
             do i = 1 to  QueryHandle:num-buffers:
                 if QueryHandle:get-buffer-handle(i):avail then
                     DataBuffer:buffer-copy(QueryHandle:get-buffer-handle(i)).
             end.
             QueryHandle:get-next(). 
             AfterRow(dataset-handle hds by-reference).
         end.
          
    end method.
    
    method protected handle CreateMapSource():
        define variable ibuffer     as integer no-undo.
        define variable hbuffer     as handle no-undo.
        
        create data-source DataSourceHandle.
        do iBuffer = 1 to num-entries(PhysicalTables):
            create buffer hBuffer 
                for table entry(iBuffer,PhysicalTables) buffer-name entry(iBuffer,Tables).
            DataSourceHandle:add-source-buffer(hBuffer,?).
        end.
        DataSourceHandle = DataSourceHandle.
    end method.
    
    method public logical Prepare(phBuffer as handle):
        Prepare(phBuffer,"","").
    end method. 
    
    method public logical Prepare(phBuffer as handle,req as ITableRequest):
        define variable cQuery as character no-undo.
        define variable iStart as integer no-undo.
        define variable iPageSize as integer no-undo.
        define variable lok as logical no-undo.
        cQuery = req:QueryString.
        iStart = req:Start. 
        iPageSize = req:PageSize. 
        lok = Prepare(phBuffer,cQuery,"").
        
        if iPageSize > 0 then
        do: 
            BatchSize = iPageSize.
            cQuery = QueryHandle:prepare-string.
            entry(1,cQuery," ") = "preselect".
            
            QueryHandle:query-prepare(cQuery).         
            QueryHandle:query-open().    
            NumRecords = QueryHandle:num-results.
            if iStart > 1 then
                PositionToRow(istart).
        end.  
        return lok.          
    end method. 
    
    method public logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable oQueryString as class QueryString.
        define variable lOk          as logical    no-undo.
        define variable hParentRel   as handle     no-undo.
              
        DataBuffer = phBuffer.
     
        CreateQuery().    
 
        /* fieldmapping is set from constructor */
        
        DataBuffer:attach-data-source(DataSourceHandle:handle,FieldMapping).
   
        hParentRel = ParentRelation.
        
        if pcTargetQuery > "" or pcJoin > '' or valid-handle(hParentRel) then
        do:
            oQueryString = new QueryString(pcTargetQuery,this-object).
            if pcJoin > '' then 
                oQueryString:addExpression(pcJoin).
            
            /* Data-Sources are defined with queries in the constructor in the event that
               there is a join involved. Add and transform the fill-where-string for the dependent 
               tables so that Progress can identify the related when filling the temp-tables.
              (columnValue ensures parent reference is NOT transformed) */
            else if valid-handle(hParentRel) and hParentRel:active and not hParentRel:reposition then
                oQueryString:addExpression(DataSourceHandle:fill-where-string).
            
            lOk = PrepareQueryString(oQueryString).
        end.
        else
            lok = Prepare().
       
        return lOk.
        catch e1 as IllegalArgumentError :
        	undo, throw e1.	
        end catch.
        catch e2 as Progress.Lang.Error :
            undo, throw new IllegalArgumentError(e2:GetMessage(1)).
        end catch.
        finally:
            if valid-object(oQueryString) then
                 delete object oQueryString.
        end.
    end method. 
    
    method protected handle CreateSaveSource(cKey as char):
        define variable ibuffer     as integer no-undo.
        define variable hbuffer     as handle no-undo.
        
        create data-source SaveSourceHandle.
        do iBuffer = 1 to num-entries(PhysicalTables):
            create buffer hBuffer 
                for table entry(iBuffer,PhysicalTables) buffer-name entry(iBuffer,Tables).
            SaveSourceHandle:add-source-buffer(hBuffer,cKey).
        end.
        DataSourceHandle = SaveSourceHandle.
    end method.
     
    method override protected void CreateQuery():
        super:CreateQuery().
        
        delete object DataSourcehandle no-error.
        create data-source DataSourcehandle. 
        DataSourceHandle:query = QueryHandle.
        
    end method.     
    
    /* prepare with QueryString (subclass override this for query optimization) */
    method protected logical PrepareQueryString (poQueryString as QueryString):    
        define variable isOk as logical no-undo.
        if valid-object(poQueryString) then
        do:
            if not valid-handle(QueryHandle) then
                CreateQuery().
            
            isOk = poQueryString:InsertToQuery(QueryHandle).
        end.    
        else 
            isOk = Prepare().
        
        return isOk.
    end method.
  
    method public override logical Prepare():    
         return QueryHandle:query-prepare(DefaultQuery()).
    end method.
    
    /*  */
    
    method protected character FindUniqueOrNoneQuery(pcTable as char,pcQuery as character):
        define variable queryString as QueryString no-undo.
        define variable lok as logical      no-undo. 
        define variable cFind as character no-undo.
        queryString = new QueryString(pcQuery,"for each " + pctable + " no-lock").
        cFind = queryString:BuildFindString(pcTable).
        return FindTableJoinValues(pcTable,cFind).
        catch e as error:
        
           case e:GetMessageNum(1):
                /* not found (valid query) */ 
                when 138 then
                    return "".
                /* ambiguous */
                when 3166 then
                    return ?.
                 /* fields in query not for tenant . 
                    this could still be a valid query, but an OR expression
                    to other tables returned from BuildFindString  */
                when 7328 then
                    return ?.
            
            end case.

            undo, throw new IllegalArgumentError("Bad partition query "
                     + quoter(cFind) + ".",e).
            
        end.
        finally:
            delete object queryString.
        end.
    end method.    
    
    /*
      Called from FindUniqueOrNoneQuery and must be overridden with unique find 
      for related tables if this functionality is needed.  
      returns a query expression of the table if it was found and 
      throw standard progress error from the find  */  
    method protected character FindTableJoinValues(pTable as char,pFind as char):
        undo, throw new UnsupportedOperationError("FindTableJoinValues is not supported").
    end method.
    
    /* converts a parent find on external parent key to query expression on internal key 
       true means value is added or not needed 
       false means not found 
       ? means ambiguous
    */
    method protected logical AddUniqueOrNone(pcTable as char,pQueryStr as QueryString):
        define variable cParentquery as character   no-undo .
        
        cParentQuery = pQueryStr:BuildParsedQueryString(pcTable).
        
        if index(cParentQuery," where ") <> 0 then
        do:
            cParentQuery = FindUniqueOrNoneQuery(pcTable,cParentQuery).
            if cParentQuery = ? then
               return ?.
            if cParentQuery = "" then
               return false.
            pQueryStr:AddExpression(cParentQuery).       
        end.
        return true.
    end method.
    
    method private logical PositionToRow(piRow as integer):
        define variable lok as logical no-undo.
        define variable i as integer no-undo.
        lok = QueryHandle:reposition-to-row (piRow) no-error.
        if lok and QueryHandle:get-next then
        do: 
           do i = 1 to QueryHandle:num-buffers: 
              DataSourceHandle:restart-rowid(i) = QueryHandle:get-buffer-handle(i):rowid.
           end.
           return true. 
        end.
        return false.
    end method.
   
    /* set start rowid to where position */
    method public logical PositionToWhere (pcWhere as char, plFill as logical):
    
    /**8
        define variable oQueryString as Querystring no-undo.
        define variable cCurrentQuery   as character  no-undo.
        define variable cPosition    as character  no-undo.
        
        /* querystring does not handle  a clean where string (yet?), 
           so add a for each (buffer name is irrelevant for transform source) */ 
        if not (pcWhere begins 'FOR ') then
          oQueryString = new QueryString
             ('FOR EACH dummy ' + pcwhere,this-object).
        cCurrentQuery = GetCurrentQueryString().
        /* prepare and open with find criteria */
        oQueryString:insertToQuery(QueryHandle).  
        delete object oQueryString.
        QueryHandle:QUERY-OPEN.
        QueryHandle:GET-FIRST.
        /* IMPORTANT to set query back,  a sorted query could remain with 
           criteria and relieve the datasource of the restart-rowid, but  
           we also need this for fill and prev position */ 
        QueryHandle:QUERY-PREPARE(cCurrentQuery).
        cPosition = getCurrentRowKey().
        if cPosition > '' then
        do:
            mcClientPosition = ClientRowKey(cPosition).
            SetStartFromQuery(QueryHandle).
            QueryHandle:query-open().
            RepositionQuery(cPosition).
            /* Check and set prev position */
            QueryHandle:GET-PREV.
            PrevPosition = GetCurrentRowKey(). /* blank if not avail*/
            if plFill then
            do:
                QueryHandle:GET-NEXT.
                if not QueryHandle:REPOSITION-FORWARDS(BatchSize) then
                  PositionToLastBatch().
            end.
            return true.
        end. /* position[1] > '' */
        return false.
        finally:
             QueryHandle:query-close ().		
        end finally.
      **/
  end method.
  
  /* set start rowid to get one batch including last*/
  method public logical PositionToLastBatch():
      /*
      define variable isOpen as logical    no-undo.
    
      isOpen = QueryHandle:is-open.
      if not isOpen then 
          QueryHandle:query-open().
      QueryHandle:get-last().
      mcClientPosition = GetCurrentRowKey().
      QueryHandle:reposition-backward(BatchSize).
      QueryHandle:get-next().
      SetStartFromQuery(QueryHandle).
      QueryHandle:get-prev().   /* more records on top?  */
      PrevPosition = GetCurrentRowKey().
      if not isOpen then 
          QueryHandle:query-close().
      BatchSize = 0. /* we want the rest of the data */
      */
      return true. /* should return false if not found (fill would be empty though) */
  end method.

  /* are there more records ahead?   */
  method private character GetNextPosition ():
    /*
    define variable cBuffer    as character no-undo.
    define variable iBuffer    as integer   no-undo.
    define variable cPosition  as character extent no-undo.
    define variable rPosition  as rowid     extent no-undo.
    define variable cRowKey    as character no-undo.
    /* ignore if batch was set to append to this record (setPrevPosition) */
    extent(rPosition) = QueryHandle:num-buffers.
    if mlIgnoreLastBatch = no and DataBuffer:last-batch = no then
    do:
        do iBuffer = 1 to num-entries(Tables):
            assign
                cBuffer = entry(iBuffer,Tables)
                rPosition[iBuffer] = DataSourceHandle:next-rowid(cBuffer).
        end.
        QueryHandle:query-open().             
        DoPositionQuery(rPosition).
        cRowKey = GetCurrentRowKey().
        QueryHandle:query-close().
    end.
    return cRowKey.
    */
  end method.
  
  method protected logical CheckQuery(pQueryStr as QueryString,pcTable as char):
      define variable cParentQuery as char no-undo.     
      cParentQuery = pQueryStr:BuildParsedQueryString(pcTable).
      return index(cParentQuery," where ") <> 0.
  end. 
   
  method private character SourceFields(tablename as char, clientFields as char):
      define variable i       as integer no-undo.
      define variable srcKeys as character no-undo.  
      do i = 1 to num-entries(clientFields):
          srcKeys = (if i = 1 then "" else srcKeys + ",") 
                  + ColumnSource(tableName + "." + entry(i,clientFields)).
      end.
      return srcKeys.
  end method.
  
  /* convert expression for QueryString - unknown = keep as is */
    /* (part of IQueryMap interface used by QueryString to map query */
  method public character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
      return ?.     
  end method.   
  
   /** convert sort expression column for QueryString 
      (second parse - column already transformed by ColumnSource(pccolumn)  
      (part of IQueryMap interface used by QueryString to map query) */
  method public character ColumnSortSource(pcColumn as char):
      return pcColumn.     
  end method.   
      
   /* return source columns for query mapping 
    (part of IQueryMap interface used by QueryString to map query */
  method public character ColumnSource (pcColumn as char):
    define variable iLookup    as integer    no-undo.
    define variable cTable     as character  no-undo.
    define variable hBuffer    as handle     no-undo.
    define variable hDataset   as handle     no-undo.
    define variable cColumn    as character  no-undo.
    define variable hParentRel as handle     no-undo.
    /*  inner join reference to other buffers can be passed from client,
        so we use the buffer's dataset to get those datasources' 
        fieldmap. This assume that any buffer that has been attached to a 
        datasource is referencing the same physical storage, (keep in mind that all connected 
        progress databases are the same physical storage in this context), so all dataset mapping 
        is valid for this datasource. 
        Note that this secondary inner join is passed from the client as an option to reduce the 
        number of records to fill for THIS table. 
        The actual fill of the joined table is handled by another datasource.  */
                                
    cTable = entry(1,pcColumn,".").
    if DataBuffer:name = cTable then
      hBuffer = DataBuffer.
    /* keep reference to parent relation as is  */
    else do:
      hParentRel = ParentRelation.
      if valid-handle(hParentRel) and cTable = hParentRel:parent-buffer:NAME then
        return pcColumn.
    end.
    
    assign
      hDataset = DataBuffer:dataset
      hBuffer  = hDataSet:get-buffer-handle(cTable) NO-ERROR.
    
    if valid-handle(hBuffer) then
    do:
      iLookup = lookup(pcColumn,hBuffer:data-source-complete-map).
      
      if iLookup > 0 then
      do:
      
         cColumn =  entry(iLookup + 1,hBuffer:data-source-complete-map).
       
         if hBuffer <> DataBuffer and lookup(entry(1,cColumn,"."),Tables) = 0 then
             return pcColumn.
         return cColumn.
      
      end.
      else
        return pcColumn.
    end.
    catch e as Progress.Lang.Error :         
        /* 12781 = data-source-complete-map reference in not attached buffer */       
        if e:GetMessageNum(1) = 12781 then
        do:
            undo, throw new IllegalArgumentError(
                           "Reference to " + substr(pccolumn,3) 
                           + " could not be resolved in the "
                           + substr(DataBuffer:name,3) + " query because the " 
                           + substr(hBuffer:name,3)
                           + " has not been attached to a data source." 
                           + " This could mean that the data source does not support the OR operator between "
                           + substr(hBuffer:name,3) + " properties and " + substr(DataBuffer:name,3) 
                           + " properties in a query expression." ). 
        end.
        else
               undo, throw new IllegalArgumentError("Error when resolving " + substr(pccolumn,3) + " in " 
                                                   + substr(DataBuffer:name,3) + " query: " +
                                                   e:GetMessage(1)). 
      
     end catch.  
  end method.                   
  
  
  
  /* not in use - could allow an external procedure like the DAO to register call back events */
  method public void SetCallBack(pcEvent   as char,
                                 pcMethod  as char,
                                 phTarget  as handle):
    /*  if 
    DataBuffer:SET-CALLBACK(pcEvent, pcMethod, phTarget).
       else
    DataBuffer:SET-CALLBACK(pcEvent, pcMethod, this-object).
      */
  end method.
   
  /** Purpose: compare two CLOB buffer-fields  
      Notes: The core does not currently support compare of CLOBs */
  
  method protected logical CompareClobValues ( phColumn1  as handle,pcOperator as char,phcolumn2  as handle,pcStrength as char) :
      define variable cLong1    as longchar   no-undo.
      define variable cLong2    as longchar   no-undo.
      define variable lUnknown1 as logical    no-undo.
      define variable lUnknown2 as logical    no-undo.
      define variable lEqual    as logical    no-undo.
      define variable lCompare  as logical    no-undo.
    
      assign
        lEqual    = can-do('=,EQ':U,pcOperator)
        lUnknown1 = (phColumn1:buffer-value = ?)
        lUnknown2 = (phColumn2:buffer-value = ?).
    
      if lUnknown1 and lUnknown2 then
        lCompare = lEqual.
      else if lUnknown1 or lUnknown2 then
        lCompare = not lEqual.
      else if length(phColumn1:buffer-value) <> LENGTH(phColumn2:buffer-value) then
        lCompare = not lEqual.
    
      else do:
        copy-lob from phColumn1:buffer-value to cLong1.
        copy-lob from phColumn2:buffer-value to cLong2.
        lCompare = compare(cLong1,pcOperator,cLong2,pcStrength).
      end.
    
      return lCompare.

   end method.
 
   /**  compares two buffers and returns a comma separated list of fields that are different
        This is mainly needed to check for changes in character fields, since A = a. 
        Many international characters that really are different will also be seen as equal by the 
        ABL . 
        
        @param bufferHandle of first buffer
        @param bufferHandle of the other buffer
        @param Excludefielsd comma separated list of fields to ignore
        @param options One of RAW,CASE-SENSITIVE or CASE-INSENSITIVE 
        
        */
             
   method protected char CompareBuffers(phbuffer1 as handle, phBuffer2 as handle,pcExclude as char,pcOption as char):
       define variable iVar           as integer    no-undo.
       define variable cChangedFlds   as character  no-undo.
       define variable lChanged       as logical    no-undo.
       define variable cName          as character  no-undo.
       define variable cDataType      as character  no-undo.
         
       /** if not lookup > 0 covers unknown */   
       if not lookup(pcOption, "RAW,CASE-SENSITIVE,CASE-INSENSITIVE":U) > 0 then
           undo, throw new IllegalArgumentError("Invalid option " + quoter(pcoption) + " passed to CompareBuffers."
                                             + " Valid values are ~"RAW~", ~"CASE-SENSITIVE~" or ~"CASE-INSENSITIVE~"").
            
       do iVar = 1 to phBuffer1:num-fields: 
           cName = phBuffer1:buffer-field(iVar):NAME.
    
           if lookup(cName, pcExclude) > 0 then 
               next.
           cDataType = phBuffer1:buffer-field(iVar):DATA-TYPE.
           if cDataType = 'CHARACTER':U then
               lChanged = compare(phBuffer1:buffer-field(iVar):BUFFER-VALUE, 
                                '<>':U, 
                                phBuffer2:buffer-field(cName):BUFFER-VALUE,
                                pcOption).
           else if cDataType = 'CLOB' then
               lChanged = CompareClobValues(phBuffer1:buffer-field(iVar), 
                                          '<>':U, 
                                          phBuffer2:buffer-field(cName),
                                          pcOption).
           else 
                lChanged = phBuffer1:buffer-field(iVar):BUFFER-VALUE 
                        <> phBuffer2:buffer-field(cName):BUFFER-VALUE.
         
            if lChanged then
                cChangedFlds = cChangedFlds 
                             + (if cChangedFlds > "" then "," else "") 
                             + cName.
       end.
       return cChangedFlds.
  end method.
  
  destructor public DataSource (  ): 
        /* delete the handles  */
        define variable iBuffer as integer    no-undo.
        define variable h       as handle     no-undo extent 18.
        define variable iNum    as integer    no-undo.
      
      if valid-handle(SaveSourceHandle) then
      do:
          iNum = SaveSourceHandle:num-source-buffers.
          do iBuffer = 1 to iNum:
              h[iBuffer] = SaveSourceHandle:get-source-buffer(iBuffer).
          end.
          
          do iBuffer = 1 to iNum: 
              delete object h[iBuffer]  no-error.
          end.
          delete object SaveSourceHandle no-error.
      end.
      if valid-handle(DataSourceHandle) then
      do:
          iNum = DataSourceHandle:num-source-buffers.
          do iBuffer = 1 to iNum:
              h[iBuffer] = DataSourceHandle:get-source-buffer(iBuffer).
          end.
          
          do iBuffer = 1 to iNum: 
              delete object h[iBuffer]  no-error.
          end.
          delete object DataSourceHandle no-error.
      end.
      
      
  end destructor.

end.

