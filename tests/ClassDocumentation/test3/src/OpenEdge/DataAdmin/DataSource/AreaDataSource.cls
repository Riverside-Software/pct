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
    Created     : Oct 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.AreaDataSource inherits DataSource: 
    
    define temp-table ttType2 no-undo
       field IsType2 as logical.
    
    define protected variable mBuffer as handle no-undo.
	
	define protected variable ValidRecordsPerBlockNumbers as char init "1,2,4,8,16,32,64,128,256" no-undo.
    define protected variable ValidRecordsPerBlockString  as char init "1, 2, 4, 8, 16, 32, 64, 128 and 256" no-undo.
    
	define protected variable AreaTypeNames as char extent 7 no-undo
	  init ["Undefined","Undefined","Recovery","Transaction log","Event log","Data","Rollforward recovery"]. 
 	
	/* Note - the mapping of RecordsPerBlock relies on recalcualtion in AfterAreaRow */ 
	define private variable mMapping as char
	
	   init  	   
"Number,_Area-number,~
Name,_Area-name,~
Clustersize,_Area-clustersize,~
RecordsPerBlock,_area-recbits,~
BlockSize,_area-blocksize,~
NumExtents,_area-extents"  
     no-undo.
    
   
	constructor public AreaDataSource ( ):	    
		super ("_Area","dictdb._Area", mMapping). 
		BaseQuery = "for each _Area no-lock".
    end constructor.
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterAreaRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
    end method.
    
    method protected override logical PrepareQueryString (poQueryString as QueryString):    
        define variable isOk as logical no-undo.
        define variable cQuery as character no-undo.
         
        cQuery = poQueryString:BuildQueryString(Tables).
   
        isOk = QueryHandle:query-prepare(cQuery). 
         
        return isOk.
    end method.
    
    method public void AfterAreaRow(dataset-handle hds):
        
        define variable hbuffer as handle    no-undo.
        define variable iSource as integer no-undo.
        define variable iType   as integer no-undo.
        assign
            hBuffer = hds:get-buffer-handle("ttArea")
            isource = lookup("_Area",Tables)
            iType   = DataSourceHandle:get-source-buffer(isource)::_Area-type
            hBuffer::url = url + "/areas/" + WebUtil:URLEncode(hBuffer::name)   
            hBuffer::PartitionsURL = hBuffer::url + "/partitions"
            hBuffer::ExtentsURL    = hBuffer::url + "/extents"   
            hBuffer::IsType2       = hBuffer::clustersize = 8 
                                     or
                                     hBuffer::clustersize = 64 
                                     or
                                     hBuffer::clustersize = 512 
                                     
            hbuffer::RecordsPerBlock = if hbuffer::RecordsPerBlock = 0 
                                       then 1
                                       else exp(2,hbuffer::RecordsPerBlock)
            hBuffer::type = AreaTypeNames[iType].                           
    end method.     
    
    method private char RecordsPerBlockExpression( pcOperator as char,pcValue as char):
        define variable iFrom as integer no-undo.
        define variable iTo as integer no-undo.
        define variable cVal as char no-undo.
        define variable cExpression as character no-undo.
        define variable i as integer no-undo.
        define variable cColumnExp as character no-undo.
        
        cColumnExp = "exp(2,_Area._Area-Recbits)".
        if lookup(pcOperator,"=,eq") > 0 then 
        do:                                                                                                       
            if lookup(pcValue,ValidRecordsPerBlockNumbers) = 0 then                                                                                   
                undo, throw new IllegalArgumentError(
                         "Invalid RecordPerBlock value " +  pcValue  + " found in query expression."
                       + " The valid values are " +  ValidRecordsPerBlockString + "."
                 ).
        end. 
        return cColumnExp + " " + pcOperator + " " + quoter(pcValue).    
     end method.   
    
    
    method private char Type2Expression(type2 as log):
          
         if type2 then
             return  "(_Area._Area-clustersize = '8'" 
                   + " or _Area._Area-clustersize = '64'" 
                   + " or _Area._Area-clustersize = '512')". 
         else  /* lt 2 ?*/
             return  "(_Area._Area-clustersize <> '8'" 
                   + " and _Area._Area-clustersize <> '64'" 
                   + " and _Area._Area-clustersize <> '512')". 
         
    end method.  
    
     /* convert istype2 value in query to the expression required in the db */
    method public override character ColumnSortSource(pcColumn as char):
        if pccolumn = "_Area.IsType2" then
        do:
            return Type2Expression(true).
        end.
        else if pccolumn = "_Area._Area-Type" then
        do: 
            return "(" 
                   +       "if _Area._Area-Type = 3 then " + quoter(AreaTypeNames[3])  
                   + " else if _Area._Area-Type = 4 then " + quoter(AreaTypeNames[4]) 
                   + " else if _Area._Area-Type = 5 then " + quoter(AreaTypeNames[5]) 
                   + " else if _Area._Area-Type = 6 then " + quoter(AreaTypeNames[6]) 
                   + " else if _Area._Area-Type = 7 then " + quoter(AreaTypeNames[7])
                   + " else " + quoter(AreaTypeNames[1])
                   + ")".            
        end.    
        return super:ColumnSortSource(pccolumn).
    end method.   
     
    /* convert  values in query to the expression required in the db */
    method public override character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        define variable iType as integer no-undo.
       
        if pccolumn = "_Area.IsType2" then
        do:
            return Type2Expression(logical(pcValue)).
        end.
        else if pccolumn = "_Area._Area-Recbits" then
        do:
            return RecordsPerBlockExpression(pcOperator,pcValue).       
        end.
        else if pccolumn = "_Area._Area-Type" then
        do: 
            if lookup(pcoperator,"=,eq,<>,ne") = 0 then
                undo, throw new IllegalArgumentError("The only valid operators for area type in a query expression are equals (eq,=) and not equals (ne,<>)" 
                  + validAreaTypesString()).
            
            do itype = 3 to extent(AreaTypeNames):
               if AreaTypeNames[itype] = pcValue then  
            
                   return pccolumn + " " + pcOperator + " " + quoter(iType). 
            
            end.
            
            undo, throw new IllegalArgumentError("Invalid value " + quoter(pcValue) + " in area type query expression. The valid values for area type in a query expression are " 
                  + validAreaTypesString()).
        end.    
        return ?.   
    end. 
    
    /*
    method private character validBlockSizeString():
        define variable i as integer no-undo.
        define variable cc as character no-undo.
        do i = 1 to extent(AreaTypeNames):
            if AreaTypeNames[i] <> "undefined" then
             cc = cc + quoter(AreaTypeNames[i]) 
                + if i = 6 then " or " else if i = 7 then " " else ", ".
        end.    
        return cc.
    end method.
    */
    
    method private character validAreaTypesString():
        define variable i as integer no-undo.
        define variable cc as character no-undo.
        do i = 1 to extent(AreaTypeNames):
            if AreaTypeNames[i] <> "undefined" then
             cc = cc + quoter(AreaTypeNames[i]) 
                + if i = 6 then " or " else if i = 7 then " " else ", ".
        end.    
        return cc.
    end method.
        
    /* rename table to match to right table when building  */
    method public override character ColumnSource (pcColumn as char):
        if pccolumn = "ttArea.IsType2" then
        do:
            return "_Area.IsType2".      
        end.
        else if pccolumn = "ttArea.Type" then
        do:
            return "_Area._Area-Type".      
        end.
        
        else return super:ColumnSource(pccolumn).
    end method.     
    
end class.