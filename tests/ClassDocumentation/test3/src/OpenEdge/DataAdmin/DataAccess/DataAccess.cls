/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
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
    Created     : Wed Feb 10 03:01:11 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath. 
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Lang.WebUtil from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

/*using OpenEdge.DataAdmin.DataSource.IDataSource.*/
/*using OpenEdge.DataAdmin.DataSource.DataSource. */

 
class OpenEdge.DataAdmin.DataAccess.DataAccess abstract implements IDataAccess: 
    
    define protected property WebUtil as WebUtil no-undo 
        get():
            if not valid-object(WebUtil) then
                WebUtil = new WebUtil().
            return WebUtil.     
        end. 
        set.
    define variable hRel as handle no-undo extent.
    define protected property DatasetHandle as handle no-undo get. set.
    /* private  for now - subclasses have their own solutions  */
    define private property Url as char no-undo get. set. 
           
       /* private - sub classes should not have access to the TT. 
          There is protected methods for DataSource access
         (the use of TT is "preliminary" and there could easily be 100s of subclasses) */
    define private temp-table ttDataSource no-undo
        field Name   as character
        field Instance as Object          /* OpenEdge.DataSource.DataSource */
        index idx1 as primary unique Name
        .
       
    constructor public DataAccess (  ):
        super ().
    end constructor.
    
    method public void Create():
        StartDataSources().
    end method.  
      
    method protected void StartDataSources():
    end method.             
    
    /* TODO - make abstract */
    method public void FetchData(msg as IFetchRequest):  
        undo, throw new UnsupportedOperationError("FetchData( IFetchRequest ) is not supported").
    end method.  
     
    /** return true if the table is not in the search and not added 
                    or if it can be unquely identified and was added
               false - in search query and not avail   
               ?     - in search query and ambiguous or joined to 
                       others with OR */
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

    /* returns a join expression on current values of the table i
      example : "_StorageObject._PartitionId = " + quoter(_Tenant._Tenantid)
      blank is not found 
      ?     is ambiguous or complex expression with other tables (or non existing)
      
      Called from ParentJoinQuery, and must be overridden with unique find 
      for related tables if this functionality is needed.  
    */
    method protected character FindTableJoinValues(pTable as char,pFind as char):
        undo, throw new UnsupportedOperationError("FindTableJoinValues is not supported").
    end method.
    
    method protected void DeactivateChildRelations(phbuffer as handle):
        define variable i as integer no-undo.
        /* num-child-relations are active, so cannot loop and deactivate */
        extent(hrel) = ?.
        extent(hrel) = phbuffer:num-child-relations.
        do i = 1 to phbuffer:num-child-relations:
            hRel[i] = phbuffer:get-child-relation (i).
        end.
        do i = 1 to extent(hrel):
            hRel[i]:active = false.
        end.    
    end method.   
    
    method protected void ActivateChildRelations(phbuffer as handle):
        define variable i as integer no-undo.
        do i = 1 to extent(hrel):
            hRel[i]:active = true.
        end.    
    end method.   
    
/*    /* TODO - make abstract */                                                  */
/*    method public ISaveRequest SaveData(phChanges as ISaveRequest):             */
/*        undo, throw new UnsupportedOperationError("SaveData with save request").*/
/*    end method.                                                                 */
/*                                                                                */
    method public ISaveRequest SaveData(pSaveReq as ISaveRequest): 
        DatasetHandle = pSaveReq:DataHandle. 
        SetUrl(pSaveReq:Url). 
        Url = pSaveReq:Url.
        do transaction on error undo, throw:
            SaveBuffers(DatasetHandle). 
        end.
        return pSaveReq.
        finally:
            DestroySources().
        end finally.
    end method.     
    
    method protected void SetUrl(pcUrl as char):
    end method.
    
    method protected void SaveBuffers(phDataset as handle):
        define variable i as integer no-undo.  
        define variable hBuffer as handle no-undo.
        do i = 1 to phDataset:num-top-buffers:
            hbuffer = phDataset:get-top-buffer(i).
            SaveBuffer(hBuffer,row-deleted).
            SaveBuffer(hBuffer,row-modified).
            SaveBuffer(hBuffer,row-created).
        end.    
    end method.
    
    method private void SaveChildBuffers(phBuffer as handle,piState as int):
        define variable i as integer no-undo.
        do i = 1 to phBuffer:num-child-relations:
            SaveBuffer(phBuffer:get-child-relation(i):child-buffer,piState).          
        end.    
    end method.
    
    method private void SaveBuffer(phBuffer as handle,pistate as int):
         define variable datasource as IDataSource no-undo.
         datasource = GetSaveSource(phBuffer:name).             
         case pistate:
             when row-created then 
             do:
                 datasource:Save(phBuffer,pistate).
                 SaveChildBuffers(phBuffer,piState).          
             end.
             when row-deleted or when row-modified then 
             do:  
                 SaveChildBuffers(phBuffer,piState).          
                 datasource:Save(phBuffer,pistate).
             end.
         end.    
    end method.
    
    method protected final IDataSource GetSaveSource(pcName as char):
        define variable dsrc as IDataSource no-undo.
        define variable h as handle no-undo.
        find ttDataSource where ttdatasource.name = pcname no-error.
        if not avail ttDataSource then
        do:
            dsrc = CreateSaveSource(pcName). 
            if not valid-object(dsrc) then
                undo, throw new UnsupportedOperationError("No data source returned from CreateSaveSource for " + substr(pcName,3)).
            dsrc:Url = Url.
            create ttDataSource.
            assign ttDatasource.name = pcname.
                   ttDatasource.instance = dsrc.
          
        end.
        return cast(ttDataSource.instance,IDataSource).
    end method.
    
    method protected IDataSource CreateSaveSource(pcName as char):
        
        undo, throw new UnsupportedOperationError("CreateSaveSource is not implemented in " + this-object:GetClass():TypeName).
       /** @todo ?       
        define variable src as IDataSource no-undo.
        define variable cName as character no-undo.
        cName = substr(pcName,3) + "DataSource".    
        cName = "OpenEdge.DataAdmin.DataSource." + cName.
        src = dynamic-new cName().
        return src.
        **/
    end method.
   
    method private IDataSource DestroySources():
        for each ttDataSource:
            delete object ttDatasource.instance no-error.
            delete ttDataSource.
        end.    
    end method.
    
    /* convert expression for QueryString - unknown = keep as is */
    /* (part of IQueryMap interface used by QueryString to map query */
    method public character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        return ?.     
    end.   
    
    /** convert sort expression column for QueryString   */
    /* (part of IQueryMap interface used by QueryString to map query)
       kept here because many subclasses still implement Iquerymap  */
    method public character ColumnSortSource(pcColumn as char):
        return pcColumn.     
    end.   
    
     
     /* return source columns for query mapping 
    (part of IQueryMap interface used by QueryString to map query */
    method public character ColumnSource (pcColumn as char):
        define variable iLookup     as integer    no-undo.
        define variable cTable      as character  no-undo.
        define variable hBuffer     as handle     no-undo.
        define variable hDataset    as handle     no-undo.
        define variable cColumn     as character  no-undo.
        define variable hParentRel  as handle     no-undo.
        /*  inner join reference to other buffers can be passed from client,
            so we use the buffer's dataset to get those datasources' 
            fieldmap. This assume that any buffer that has been attached to a 
            datasource is referencing the same physical storage, (keep in mind that all connected 
            progress databases are the same physical storage in this context), so all dataset mapping 
            is valid for this datasource. 
            Note that this secondary inner join is passed from the client as an option to reduce the 
            number of records to fill for THIS table. 
            The actual fill of the joined table is handled by another datasource.  */
    
        if num-entries(pcColumn,".") = 2  then
        do:                           
            cTable = entry(1,pcColumn,".").
            hbuffer = DatasetHandle:get-buffer-handle(cTable).
        end.
        else if num-entries(pcColumn,".") = 3  then                           
        do:
            cTable = entry(2,pcColumn,".").
            hbuffer = DatasetHandle:get-buffer-handle(cTable).
        end.
        else do:
            hbuffer = DatasetHandle:get-buffer-handle(1).
            cTable = hBuffer:name.
        end.    
         
        /* keep reference to parent relation as is  */
    /*    else do:                                                                     */
    /*      hParentRel = ParentRelation.                                               */
    /*      if valid-handle(hParentRel) and cTable = hParentRel:parent-buffer:NAME then*/
    /*        return pcColumn.                                                         */
    /*    end.                                                                         */
    
         if valid-handle(hBuffer) then
         do:
             iLookup = lookup(pcColumn,hBuffer:data-source-complete-map).
             if iLookup > 0 then
             do:
                 cColumn =  entry(iLookup + 1,hBuffer:data-source-complete-map).
    /*        if hBuffer <> mDataBuffer and lookup(entry(1,pcColumn,"."),Tables) = 0 then*/
    /*          return pcColumn.                                                         */
                 return cColumn.
             end.
             else
                 return pcColumn.
          end.
    end method.                   
     
    method protected void ThrowPrepareError(e as Error, pQuery as char, cname as char):
        if type-of(e,AppError) then
            undo, throw e.
        undo, throw new IllegalArgumentError(
                "Request for " + quoter(cname) + " have invalid field reference in query."
                + chr(10) + quoter(pQuery) + "." 
                + chr(10) + "This could be references to non existing fields or use of OR expression across mutually exclusive tables." 
                + chr(10) + e:GetMessage(1)
                ,e
                ). 
    end method.

    


end class.
