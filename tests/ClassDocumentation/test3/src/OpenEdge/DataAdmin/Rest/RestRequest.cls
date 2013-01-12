/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : RestParser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jul 01 11:37:31 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Error.DataAdminError from propath.
using OpenEdge.DataAdmin.Error.NotFoundError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Lang.WebUtil from propath.
using OpenEdge.DataAdmin.Rest.IPageRequest from propath. 
using OpenEdge.DataAdmin.Rest.PageRequest from propath. 
using OpenEdge.DataAdmin.Rest.IRestRequest from propath.
using OpenEdge.DataAdmin.Rest.IRestRequestInfo from propath.

class OpenEdge.DataAdmin.Rest.RestRequest implements IRestRequest: 
    
    define protected property RequestInfo as IRestRequestInfo no-undo get. set.
    
    define public property StatusFileName as char no-undo 
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:StatusFileName.
            return StatusFileName.
        end.      
    
    define public property DownloadFileName as char no-undo 
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:DownloadFileName.
            return DownloadFileName.
        end.      
    
    define public property UploadFileName as char no-undo 
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:UploadFileName.
            return UploadFileName.
        end.      
        
    define public property CaptureFileName as char no-undo 
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:CaptureFileName.
            return CaptureFileName.
        end.      
   
     
    define public property ConnectionUrl as char no-undo  
        get. 
        private set.
   
    define public property StartEntry as int no-undo  
       init 5
       get(): 
           if valid-object(RequestInfo) then
               return RequestInfo:ConnectionsPos + 2.
           return StartEntry.    
       end.
       set.
    
    define public property ConnectionName as char no-undo  
        get():
            if ConnectionName = "" then
            do:
               if valid-object(RequestInfo) then
                   return RequestInfo:Connection. 
               if Num-dbs = 1 then 
                   return ldbname(1).
               return ?. 
            end.
            return ConnectionName.
        end. 
        set.
    
    define public property RequestUrl as char no-undo  
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:Url.
            return RequestUrl.
        end.
        private set.
        
    define public property Name as char no-undo  
        get. 
        private set.
    
    define protected property Error as DataAdminError no-undo  
        get. 
        private set.
    
    define protected property QueryString as char no-undo  
        get. 
        private set.
           
    define public property FileName as char no-undo  
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:FileName.
            return FileName.
        end.      
        private set.
    
    define public property OutFileName as char no-undo  
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:OutFileName.
            return OutFileName.
        end.  
        private set.
        
    define public property FileName2 as char no-undo  
        get():
            if valid-object(RequestInfo) then
            do:
                FileName2 = RequestInfo:UploadFileName.
                if FileName2 = "" then
                    FileName2 = RequestInfo:DownloadFileName.
            end.    
                
            return FileName2. 
        end.  
        private set.
    
    define public property ErrorFileName as char no-undo  
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:ErrorFileName.
                
            return OutFileName. 
        end. 
    
    define public property LogFileName as char no-undo  
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:LogFileName.
                
            return OutFileName. 
        end. 
        private set.
     
    define public property NumLevels as int no-undo  
        get. 
        private set.
    
    define public property Query as char no-undo  
        get. 
        private set.
     
    define public property CollectionName as char no-undo extent  
        get. 
        private set.
    
    define public property ChildCollectionName as char no-undo  
        get. 
        private set.
        
    define public property KeyValue as char no-undo extent 
        get. 
        private set.

    define public property StatusInterval as int no-undo 
        get():
            if valid-object(RequestInfo) then
                return RequestInfo:StatusInterval.
            return StatusInterval.
        end.     
    
    define private variable mProps  as char no-undo. 
    define private variable mValues as char no-undo. 
         
    define private property WebUtil as WebUtil no-undo 
        get():
            if not valid-object(WebUtil) then
                WebUtil = new WebUtil().
            return WebUtil.     
        end. 
        set.
    
    constructor RestRequest(info as IRestRequestInfo):
        RequestInfo = info.
        InitRequest(info:Method,info:Collection,info:Url). 
    end method.
      
    constructor RestRequest(cMode as char, cName as char, cUrl as char):
        ParseParams(cName,cUrl).
        InitRequest(cMode,cName,RequestUrl).  
    end method.

    constructor RestRequest(pMode as char, pName as char):
         if session:batch-mode then   
         do:
             /* TODO - comma is unsafe as delimiter - both url and filenames might have them */
             ParseParams(pname,session:parameter).            
             InitRequest(pMode,pName,RequestUrl).                 
         end. 
         else Error = new UnsupportedOperationError("RestRequest(char,char) is only supported in batch mode").
    end constructor.    
    
    method private void ParseParams(pName as char,pcRequest as char):
        define variable i as integer no-undo.
        i = num-entries(pcRequest). 
        if i > 2 then
        do:
            /* support comma separated collections 
              - bit of a hack 
                 - @TODO need to fix the way we send file names 
              - does not support 2 filenames 
            */
 
            if index(pcRequest,"?collections=") > 0
            or index(pcRequest,"&collections=") > 0 then
            do:
                if i = 3 then do:
                  FileName = entry(2,pcRequest).
                  OutFileName = entry(3,pcRequest).
                  entry(i,pcRequest) = "".
                  RequestUrl = entry(1,pcRequest).
                end.
                else do:    
                  FileName = entry(i,pcRequest).
                  entry(i,pcRequest) = "".
                  RequestUrl = right-trim(pcRequest,",").
                end.
            end.
            else do:
                RequestUrl = entry(1,pcRequest).  
                FileName = entry(2,pcRequest).
                OutFileName = entry(3,pcRequest).
                if i > 3 then
                    FileName2 = entry(4,pcRequest).
            end.
        end.
        else do: 
            RequestUrl = pcRequest.  
            FileName = pName + ".json".
            OutFileName = pName + "res.json".
        end.   
        
        LogFileName = FileName.
        entry(num-entries(LogFileName,"."),LogFileName,".") = "log".
    end method. 
       
    method private void InitRequest(cMode as char, cName as char, cUrl as char):
         Name = cname.        
         ParseRequest(cUrl).  
    end method.

    method public void Validate():

        if session:batch-mode and num-dbs <> 1 then
        do:
            undo, throw new UnsupportedOperationError("RestRequest(char,char)" + " expects one database to be connected"). 
        end. 
        else if valid-object(this-object:Error) then    
            undo, throw this-object:Error.
            
    end method.    
    
    method public character GetQueryValue(pcQuery as char):
        define variable i as integer no-undo.
        define variable cSearch as character no-undo.
        define variable cFound as character no-undo.
        
        cSearch =  "&" + pcQuery + "=".
        i = index("&" + QueryString,cSearch).
        if i > 0 then
        do:  
            cFound = substr(QueryString,i + length(cSearch) - 1).
            i = index(cFound,"&").
            if i > 0 then
                cFound = substr(cFound,1,i - 1).
            return cFound.
        end.
        return ?.
    end method.
    
    method private void ParseRequest(cUrl as char): 
        define variable i           as integer no-undo.        
        define variable iNumEntries as integer no-undo.        
        define variable cEntry      as character no-undo. 
        define variable iLevel as integer no-undo. 
        
        if num-entries(cUrl,"?") > 1 then
        do:
            QueryString = WebUtil:UrlDecode(entry(2,cUrl,"?")).
            this-object:Query = ParseQuery(QueryString).
            cUrl = entry(1,cUrl,"?"). 
        end.  
        
        iNumEntries = num-entries(cUrl,"/").
        NumLevels = (iNumEntries - (StartEntry - 1)) / 2.  
        if numlevels > 0 then
        do:
            extent(CollectionName) = NumLevels.
            extent(KeyValue) = NumLevels.
            KeyValue = ?. /* init as ? to support blank key */
        end.
        do i = StartEntry to iNumEntries:
            cEntry = entry(i,cUrl,"/").
            /* we remove the entries in order to keep the 4 first entries
               as the Url. The slashes are trimmed off below */
            entry(i,cUrl,"/") = "".
            if i = StartEntry and cEntry <> Name then 
            do:             
                /* Error is not thrown, since we want the error file name */
                /* Validate will throw it */ 
                Error = new NotFoundError("Invalid collection reference in url: " + cEntry).
                return.
            end.
            case i modulo 2:
               when 1 then do:
                   
                   iLevel = iLevel + 1.
                   CollectionName[iLevel] = cEntry.
               
               end.    
               when 0 then
                   KeyValue[iLevel] = WebUtil:UrlDecode(cEntry).                     
            end.     
        end.
     
        ConnectionUrl = right-trim(cUrl,"/").
    end method.
    
    method private char ParseQuery(pcQuery as char): 
        define variable cField    as character no-undo. 
        define variable cValue    as character no-undo. 
        define variable cOperator as character no-undo. 
        define variable iStar     as integer   no-undo.
        define variable iDot      as integer   no-undo.
        define variable i         as integer   no-undo.
        define variable cQuery    as character no-undo.
        define variable cQueryExp as character no-undo.
        define variable cNameExp  as character no-undo.
        define variable cSort     as character no-undo.
        define variable cDir      as character no-undo.
        define variable cReturn   as character no-undo.

        do i = 1 to num-entries(pcQuery,"&"):
            cQuery = entry(i,pcQuery,"&").              
            cField = entry(1,cQuery,"=").
            
            if cField = "query" then 
            do:
                cQueryExp = trim(substr(cQuery,7)).             
                /* strip quotes */
                if cQueryExp begins "'" or cQueryExp begins '"' then 
                    cQueryExp = substr(cQueryExp,2,length(cQueryExp) - 2).
                
            end.
            else
            if cField = "name" then
            do:
                assign    
                    cValue = entry(2,cQuery,"=")
                    iStar  = index(cValue,"*")
                    iDot   = index(cValue,".")
                    coperator = "begins".      
                
                if iStar > 0 then
                do:
                    if iStar = length(cValue) then
                        cValue = substr(cValue,1,iStar - 1).
                    else do:
                        cOperator = "matches".  
                        /* no support for . as match character 
                           (domains can have . in name) */   
                        if iDot > 0 then 
                           cValue = replace(cValue,".","~~.").
                    end.              
                end.            
                cNameExp = cField + " " + cOperator + " " 
                          + if cValue begins "'" or cValue begins '"' then cValue
                            else quoter(cValue).
            end.
            else if cField = "sort" then
                cSort = "by " + entry(2,cQuery,"=").
            else if cField = "dir" then
                cDir = entry(2,cQuery,"=").
        end.
        
        if cNameExp > "" and cQueryExp > "" then
            cReturn = "(" + cNameExp + ") and (" + cQueryExp + ")" .
        else if cQueryExp > "" then
            cReturn = cQueryExp.
        else if cNameExp > "" then
            cReturn = cNameExp.
        if cSort > "" then
        do: 
            cReturn = cReturn + " " + cSort +  if cDir = "desc" then " descending" else "".
            
        end.           
        return cReturn.                        
    end method.
    
    method public IPageRequest GetPageRequest():
        define variable cLimit      as character no-undo. 
        define variable cStart      as character no-undo. 
        define variable iStart      as integer no-undo. 
        define variable iLimit      as integer no-undo.  
        define variable pageRequest as IPageRequest no-undo.
        define variable cCollection as character no-undo.
        cLimit = GetQueryValue("limit").
        
        if cLimit <> ? then 
        do:
            
            iLimit = int(cLimit).  
            /* could probably use collection name numlevels in all cases */
            if NumLevels > 1 then 
            do:
                cCollection = CollectionName[NumLevels].     
                pageRequest = new PageRequest(cCollection).
            end.
            else
                pageRequest = new PageRequest().
            
            pageRequest:PageSize = iLimit.  
            cStart = GetQueryValue("start").
            if cStart <> ? then
            do: 
                iStart = int(cStart) + 1. 
                pageRequest:Start = iStart.
            end.
            if this-object:Query > "" then
                pageRequest:QueryString = this-object:Query.
            return pageRequest.
        end.   
        return ?.
    end method.

    /*
    method public void PostToService(service as DataAdminService):
    end method.

    method public void GetFromService():
    end method.
    
    method public void DeleteFromService():
    end method.
     */  
end class.
