/************************************************************************
* Copyright (C) 2006-2012 by Progress Software Corporation.             * 
* All rights reserved.                                                  *
*                                                                       *
************************************************************************/
/*---------------------------------------------------------------------------- 
CLASS      QueryString                                                   HD
Purpose    Manage query string tranformation and manipulation.
           String based, need no handles or compilation.
           
           Manages a query string with field expressions and allows a caller 
           to add these expressions to the correct tables in an existing query.
           
           The main purpose is to support query transformation from a query 
           with field expressions against a domain table to a query expressed 
           against physical tables. 
           
           The mapping and transformation is optionally triggered by  
           passing an object that implements IQueryMap as the second parameter.     
                       
Parameters: pcQueryWhere complete query expression  
            pQueryMap optional IQueryMap (columnSource, defaultQuery) 
            
     Notes: This is a copied subset of ADM2's query manipulation with 
            additional parsing.
          - The BaseQuery are important for transformation, but can also 
            be used provide table options to the main query when used with no tranformation. 
            (and workaround the lack of full query parsing) 
          - The passed pcQueryWhere could fail with too complex queries ...  
            There is still an attempt to handle anything by just giving up and 
            treat complex expressions as a single expression while the 
            transformation  continues.. . If it fails with expressions on 
            functions with parenthesis try to add a parenthesis around 
            functions that also have parenthesis (no promise..) or fix the code.  
          - The passed query is expected to be a working (compilable) dynamic 
            temp-table query with no database options like locking. Outer 
            joins would not make sense in this context either.   
          - It is crucial that all values are quoted to be correctly parsed,
            (also needed to handle non american numeric and date formats,
             assuming same session format settings here as when applied)   
          - The transformation can split the expressions on different tables 
            if they are using an AND operator. An expression against multiple 
            tables with an OR operator between them will be added to the query 
            entry of the last of the tables.
          - Allthough some of the code is based on the ADM, it is still meant 
            as sample of query manipulation. 
        There are alternatives to full parsing.
            The query syntax is after all is a subset of the ABL programming 
            language. Maybe reconsider the design to see if some of the 
            complexity could be better encapsulated in the data access or data 
            source object. Even if this logic expects the query to be in 
            compilable form it is not really necessary at this stage, so tokens 
            and special patterns could be used to ease the 
            transformation/mapping.           
----------------------------------------------------------------------*/
 
routine-level on error undo, throw.

using OpenEdge.DataAdmin.Lang.IQueryMap.
using Progress.Lang.* from propath.
 
class OpenEdge.DataAdmin.Lang.QueryString :
  define private variable mcTargetTable as character  no-undo extent 18.
  define private variable mcTargetQuery as character  no-undo extent 18.
  define private variable mcEvaluation  as character  no-undo extent 50 .
  define private variable mcExpression  as character  no-undo extent 100.
  define private variable mcExpTables   as character  no-undo extent 100.
  define private variable miNumTables   as integer    no-undo.
  define private variable miParCount    as integer    no-undo.
  define private variable miExpCount    as integer    no-undo.
  define private variable mQueryRef     as IQueryMap  no-undo. 
  
  define public property SortExpression as character  no-undo 
      get. 
      protected set. 
  
  define public property BaseQuery as character  no-undo 
      get:
          if valid-object(mQueryRef) then
              return mQueryRef:BaseQuery.
          return BaseQuery.
      end.    
      protected set. 
  
  /* should build query merge to BaseQuery (or default if no base)*/
  define public property MergeQuery as logical  no-undo 
      get:
          if valid-object(mQueryRef) then
              return true.
          return MergeQuery.
      end.       
      protected set. 
      
  define public property Tables         as character  no-undo get. set.
  define public property QueryOptions   as character  no-undo get. set.
  define public property Statement      as character  no-undo get. set.
  define public property UpperCaseKeyWords as logical no-undo get. set.
  
  define protected variable mcQueryWhere    as character  no-undo.
  define protected variable mcUnparsedQuery as character  no-undo.
  
  constructor public QueryString (pQueryMap as IQueryMap) :
       if not valid-object(pQueryMap) then                                     
           undo, throw new AppError("invalid IQueryMap passed to constructor",?). 
       mQueryRef = pQueryMap.
       MergeQuery = true. /* just for show... not used by getter... */
  end constructor.
  
  /* queryWhere is a simple query without any table options like no-lock */
  constructor public QueryString (pcQueryWhere as char) :
       mcUnparsedQuery = pcQueryWhere.  
       parseQuery(pcQueryWhere).
  end constructor.
  
  /* queryWhere is a simple query without any table options like no-lock 
     Basequery */
  constructor public QueryString (pcQueryWhere as char,
                                  pQueryMap as IQueryMap ) :
       this-object(pQueryMap).
       mcUnparsedQuery = pcQueryWhere.  
   
       parseQuery(pcQueryWhere).
  end constructor.
  
  /* QueryWhere - is a simple query without any table options like no-lock can have query options
                  like indexed-reposition
     Basequery  -  query to which the QueryWhere and filters should be merged 
                -  provide table options as well as a fixed expressions    
                - uses BuildDefaultQuery if base query is blank or ?  */  
  constructor public QueryString (pcQueryWhere as char,pcBaseWhere as char) :
       this-object(pcQueryWhere).
       BaseQuery = pcBaseWhere.
       MergeQuery = true. 
  end constructor.
  
  method protected void ClearQuery ():
    assign 
      QueryOptions  = ''
      Statement = " "
      mcQueryWhere = ''
      mcTargetTable = ''
      mcTargetQuery = ''
      mcEvaluation = '' 
      mcExpression = '' 
      mcExpTables  = '' 
      miParCount   = 0
      miExpCount  = 0
      miNumTables  = 0.  
  end method.

  /* insert the querystring into the query 
     - uses mQueryRef IQueryMap:BaseQuery if unprepared
     - buffers decide the order (can be different than BaseQuery )*/
  method public logical InsertToQuery(phQuery as handle):  
      return phQuery:query-prepare(buildQueryString(phQuery)).
  end.
  
  method public character  GetTableExpression(pcTable as char):
      return getTableEvaluation(1,1,pcTable).
  end method.
      
  method public void ClearFilter():
      ClearQuery().
      ParseQuery(mcUnparsedQuery). 
  end method.    
   
  method public void AddFilter(pColumnName as char,pColumnOperator as char,pColValue as char):
      /* we just add it to the 1st table - the table position is resolved in all methods
      that returns the query  */
      if pColValue = ? then 
          pColValue = "?".
      else
          pColValue = quoter(pColValue).          
      AddExpression(pColumnName + " " + pColumnOperator + " " + pColValue).
  end method.    
       
  method public void AddFilter(logicalAnd as log extent,columnNames as char extent,columnOperators as char extent,colValues as char extent).
      define variable i            as integer no-undo.
      define variable cExpression  as character no-undo.
      do i = 1 to extent(columnNames):
          cExpression = cExpression
                      + (if i = 1 then "" 
                         else " " + GetCased(if logicalAnd[i] then "AND" else "OR") + " ")
                      +  columnNames[i]  + " " + columnOperators[i] + " " 
                      +  if colValues[i] = ? then "?" else quoter(colValues[i]).
      end. 
       
      AddExpression(cExpression).
  end method.    
    
  
  method public character CheckIndex(phBuffer as handle):   
    
    define variable hTmpQuery     as handle     no-undo.
    define variable hTmpBuffer    as handle     no-undo.
    define variable cIndexed      as character  no-undo.
    define variable cWhere        as character  no-undo.

    cWhere = tableEvaluation(1,phBuffer:name).
    if cWhere > '' then
    do:
      create query hTmpQuery.
      create buffer hTmpBuffer for table phBuffer.
    
      hTmpQuery:add-buffer(hTmpBuffer).
      /* add dummy as the evaluation returns all expressions for last entry */
      cWhere = tableEvaluation(1,phBuffer:name + ',dummy').
   
      /* ok , no-lock does not change index usage .. but */
      cWhere = 'FOR EACH ' + phBuffer:name + ' WHERE ' + cWhere + ' NO-LOCK'.
      hTmpQuery:query-prepare(cWhere).
      cIndexed = hTmpQuery:index-information(1). 
      
      delete object hTmpBuffer.
      delete object hTmpQuery.
    end.

    return cIndexed.
  end method.
  
  method public character BuildQueryString(pcTables as char):   
      if MergeQuery  then                       
          return MergeQueryString(pcTables,?).
      else
          return BuildParsedQueryString(pcTables). 
  end method.
  
  method public character BuildQueryString(phQuery as handle):  
    define variable iTable          as integer    no-undo.
    define variable cQuery          as character  no-undo.
    define variable cTables         as character  no-undo.
    
    cQuery = phQuery:prepare-string.
 
    do iTable = 1 to phQuery:num-buffers:  
      assign
        cTables  = cTables 
                 + (if iTable = 1 then '' else ',')
                 + phQuery:get-buffer-handle(iTable):NAME.
    end.
    return MergeQueryString(cTables,cQuery). 
  end method.
  
  method private character MergeQueryString(pcTables as character,pcBaseQuery as character):  
      define variable iTable          as integer    no-undo.    
      define variable cBufferWhere    as character  no-undo.
      define variable cNewQuery       as character  no-undo.
      define variable cNewWhere       as character  no-undo.
      define variable lBuildDefault   as logical    no-undo.
      define variable iStart          as integer    no-undo.
      define variable iLength         as integer    no-undo.
      define variable cNewString      as character  no-undo. 
      define variable iWhereFound as integer no-undo.       
        
      if pcBaseQuery = ? or pcBaseQuery = "" then
      do:
         pcBaseQuery = BaseQuery. 
         if pcBaseQuery = ? or pcBaseQuery = "" then
             pcBaseQuery = BuildDefaultQueryString(pcTables).
      end. 
      do iTable = 1 to num-entries(pcTables):  
          assign 
            cNewWhere    = tableEvaluation(iTable,pcTables)
            cBufferWhere = BufferWhereClause(entry(iTable,pcTables),pcBaseQuery,output iWhereFound).
          if cBufferWhere = "" then 
              undo, throw new AppError("Cannot build expression for table "  
                                        + quoter(entry(iTable,pctables)) 
                                        + " not present in the BaseQuery "
                                        + quoter(pcBaseQuery)
                                        + " Use BuildParsedQueryString() to extract an expression from the parsed query.",?)  .
          /* workaround*/
          if cNewWhere > '' then
          do:
            assign              
              iStart  = index(substr(pcBaseQuery,iWhereFound),cBufferWhere) + iWhereFound - 1
              iLength = length(cBufferWhere).
              
              cNewString = insertExpression (cBufferWhere,
                                             cNewWhere,
                                             GetCased('AND')).
              pcBaseQuery = insertString(cNewString,pcBaseQuery,iStart,iLength).
              /*
	          SUBSTR(cQuery,iStart,iLength) = insertExpression
	                                          (cBufferWhere,
	                                           cNewWhere,
	                                           'AND').*/
        
          end.
      end.

      if SortExpression > '' then 
          return newQuerySort(pcBaseQuery,BuildSortExpression(pcTables)).
    
      return pcBaseQuery.
  end method.
  
   
  
  /* untested and doesn't do anything that you could not do with buildQueryString */
  method public character BuildFindString(pcTable as char):    
      return BuildFindString(pcTable,"").
  end method.

  method public character BuildFindString(phQuery as handle):       
      define variable cQuery          as character  no-undo.
      define variable cTable          as character  no-undo.

      if phQuery:num-buffers > 1 then
          return 'WHERE FALSE'.  /* just do something, blank can be seen as nothing*/
     
      assign 
          cQuery = phQuery:prepare-string
          cTable = phQuery:get-buffer-handle(1):NAME.
      /* uses BaseQuery if cQuery is unknown */
      return BuildFindString(cTable,cQuery).
  end method.


  /* untested and doesn't do anything that you could not do with buildQueryString */
  method private character BuildFindString(pcTable as char,pcQuery as char):    
      define variable cBufferWhere    as character  no-undo.
      define variable cNewQuery       as character  no-undo.
      define variable cNewWhere       as character  no-undo.
      define variable iFound as integer no-undo.      
      if pcQuery = "" or pcQuery = ? then
      do:
          if valid-object(mQueryRef) then
              pcQuery = mQueryRef:BaseQuery.
          else 
              pcQuery = BaseQuery.
      end.
      
      assign 
          cNewWhere    = tableEvaluation(1,pcTable)
          cBufferWhere = bufferWhereClause(pcTable,pcQuery,output ifound).
      if cBufferWhere = ""  and cNewWhere > "" then
          return "where " + cNewWhere. 
   
       /* get rid of for each and options  (this is just a quick solution ) */
      if cNewWhere > '' then
          assign /* Find the buffer's 'expression-entry' in the query */
            cBufferWhere = insertExpression(cBufferWhere,cNewWhere,'AND')
            cBufferWhere = SUBSTR(cBufferWhere,index(cBufferWhere,' EACH ') + 7)
            cBufferWhere = SUBSTR(cBufferWhere,length(pcTable) + 1)
            cBufferWhere = trim(replace(' ' + cBufferWhere + ' ',' NO-LOCK ',''))
            cBufferWhere = trim(replace(' ' + cBufferWhere + ' ',' INDEXED-REPOSITION ','')). 

     return cBufferWhere.  
  end method. 

  
  method public void AddExpression(pcExpression as char):
    define variable cQuery as character  no-undo.
    define variable cRest  as character  no-undo.
    define variable iPos as integer    no-undo.
    
    iPos = index(mcEvaluation[1],',').
    if iPos > 0 then
    do:
      assign
        cRest = SUBSTR(mcEvaluation[1],iPos)
        mcEvaluation[1] = entry(1,mcEvaluation[1]).
    end.
    /* -  add parenthesis to the new instead
    if mcEvaluation[1] > '' then
      assign
        miParCount = miParCount + 1
        mcEvaluation[miParCount] = mcEvaluation[1] 
        mcEvaluation[1] = 'P' + STRING(miParCount) + ' ' + GetCased('AND').
    */
    parseQuery("(" + pcExpression + ")"). 
    mcEvaluation[1] = mcEvaluation[1] + cRest.

  end method.
  
  method protected void ParseQuery ( pcQuery as char) :
   /*------------------------------------------------------------------------------
     Purpose: Parses the logical buffer's target query and stores it for 
              transformation to the datasource query.
       Notes: See main comments      
------------------------------------------------------------------------------*/ 
     define variable i as integer    no-undo.
     define variable cChar as character  no-undo.
     define variable lWord as logical    no-undo.
     define variable cNewString as character  no-undo.
     define variable lIdent as logical    no-undo.
     define variable lChar as logical    no-undo.
     define variable lToken as logical    no-undo.
     define variable cToken as character  no-undo.
     define variable cWord  as character  no-undo.
     define variable lDouble as logical    no-undo.
     define variable lSingle as logical    no-undo.
     define variable lIgnoreNext as logical    no-undo.
     define variable lNoFieldExp as logical    no-undo.

     define variable lNewValue     as logical    no-undo.
     define variable lNewToken     as logical    no-undo.
     define variable lNewIdent     as logical    no-undo.
     define variable lNewOperator  as logical    no-undo.
     define variable lNewAndOR     as logical    no-undo.
     define variable lNewLeft      as logical    no-undo.
     define variable lNewRight     as logical    no-undo.
     define variable lQueryOptions as logical    no-undo.
     
     define variable lTableNext as logical    no-undo.
    
     define variable cWordOperatorList as character  no-undo
       init "EQ,GE,LE,GT,LT,BEGINS,MATCHES,NE".
     define variable cOperatorList as character  no-undo
       init "=,>=,<=,>,<,<>".

     define variable lNewExpression as logical    no-undo.
     define variable iParOwner     as integer     no-undo extent 100.
     define variable iPar          as integer     no-undo.
 
     define variable iBadpar       as integer     no-undo.

 
     define variable lAddToken as logical    no-undo. 

     define variable cExpression as character  no-undo.
     define variable cFieldExp   as character  no-undo.
     define variable cColumnTable as character  no-undo.
    
     define variable cDiff       as character  no-undo.
     define variable cAccExpress as character  no-undo.
     define variable iLeftPar    as integer    no-undo.
     define variable cNewFieldExp as character no-undo.
     define variable cFieldValue as character no-undo.
     /* 48,57 */
     /* 65,90 */
     /* 97,122 */
     /* ('a'..'z'|'_'|'$') ('a'..'z'|'_'|'-'|'0'..'9'|'$'|'#'|'%'|'&')* */
    iPar   = 1.
    if miParCount = 0 then miParCount = 1.
 
    pcQuery = pcQuery + ' '. /* last char  */
    do i = 1 to length(pcQuery):   
      assign 
        cChar = SUBSTR(pcQuery,i,1).
      case cChar:
        when "~~" then
        do:
          if lSingle or lDouble then
            lIgnoreNext = not lIgnoreNext. /* would be true if ~~*/
        end. /* tilde */
        when "'" then
        do:
          if not lDouble then  
          do:
            if not lIgnoreNext then
            do:
              if lSingle then
                lNewValue = true.
              else do:
                if lToken then
                  lNewToken = true.
                lSingle = true.
              end.
            end.
            else 
              lIgnoreNext = false.
          end.
        end. /* single quote */
        when '"' then
        do:
          if not lSingle then
          do:
            if not lIgnoreNext then
            do:
              if lDouble then
                lNewValue = true.
              else do:
                if lToken then
                  lNewToken = true.
                lDouble = true.
              end.
            end.
            else 
              lIgnoreNext = false.
            if not lDouble then
              lNewValue = true. 
          end.
        end. /* double quote*/
        otherwise do:
          lIgnoreNext = false.
          if not lSingle and not lDouble then
          do:
            if cChar <> '' then 
            do:
              lChar = (asc(cChar) ge 97 and asc(cChar) le 122)
                       or
                      (asc(cChar) ge 65 and asc(cChar) le 90)
                       or
                      (asc(cChar) ge 48 and asc(cChar) le 57)
                       or 
                      (cChar = '_').
              /* period as part of word keeps column qualified */
              if not lChar and lIdent then
                lChar = lookup(cChar,'_,-,$,#,%,&,.,[,]') > 0.
              if lChar then 
              do:
                if lToken then
                  lNewToken = true.
                lIdent = true.
              end.
              else do : 
                if lIdent then
                  lNewIdent = true.
                else 
                  lNewToken = lookup(cChar,',|.|)|(|+','|') > 0.
                lToken = true. 
              end.
            end. /* not blank */
            else do:
              if lIdent then
                lNewIdent = true.
              else if lToken then
                lNewToken = true. 
            end. /* else (blank) */
          end. /* not quote*/
        end. /*otherwise*/
      end case.

       /* The case above will set lNewValue, lNewIdent or lNewToken whenever 
          a new token is found, this block will turn off flags and pass the 
          token on for further treatment below */
      
      if lNewValue then 
      do:
        assign
          cToken = cToken + cChar
          cChar  = ''
          lSingle = false
          lDouble = false
          lAddToken = true.
      end.
      else if lNewIdent then
      do:
        if lookup(cToken,'AND,OR') > 0 then
          lNewExpression = true.
        else
        if lookup(cToken,cWordOperatorList) > 0 then
          assign 
            lNewOperator = true
            lNewIdent = false.
        assign
          lAddToken = true
          lIdent    = false.
      end.
      else if lNewToken then
      do:
        if cToken = ')' then
        do:
          if iBadPar > 0 then 
            iBadPar = iBadPar - 1.
          else
            lNewExpression = true.
        end.
        else
        if lookup(cToken,cOperatorList) > 0 then
          assign
            lNewOperator = true
            lNewToken    = false.

        if cChar = '' or lIdent then
          lToken = false.
         
        lAddToken = cToken > ''.
      end.
      
      if not lQueryOptions  and i = LENGTH(pcQuery) then
      do:
        assign
          lAddToken = true
          lNewExpression = true.
      end.

      /***         **/
       
      if lAddToken then
      do:
       
        if lookup(cToken,"BY,INDEXED-REPOSITION,COLLATE,MAX-ROWS") > 0 then
        do:
            if cToken = "BY" then
            do:
                /* cuts off options */
                ParseSortExpression(cToken + substr(pcQuery,i)).
                cToken = SortExpression.
                i = i + length(SortExpression) - 2.
            end.
            if not lQueryOptions then
                assign
                    lNewExpression = true
                    lQueryOptions = true.
             
        end.
        else if lookup(cToken,'EACH,FIRST,LAST') > 0 then
        do:
          assign
            lNewExpression = true
            lTableNext = true.
          
          /* The query comma separator is hard to filter with this simple parsing, 
             as it is used in functions, but we know it's the last added 
             token here  */
          if miNumTables > 0 then
            assign
              mcTargetQuery[miNumTables] = right-trim(mcTargetQuery[miNumTables],' ,')
              cExpression                = right-trim(cExpression,','). 
          else 
              Statement = Statement + " " + cToken.
        end.
        else if lTableNext then
        do:
          miNumTables = miNumTables + 1.
          mcTargetTable[miNumTables] = cToken.
          lTableNext = false.
        end.
        else if lookup(cToken,'FOR,PRESELECT') > 0 then
        
            Statement = cToken.
            
        /* ignore keywords and the last blank (appended to end of query at top
           to have a breakpoint also for the last expression) */  
        else if not lQueryOptions and lookup(cToken,'WHERE, ') = 0 then
        do:
          if lookup(cToken,'AND,OR') = 0 then
          do:
             
            if lNewIdent then 
            do:
              /*   
              if num-entries(cToken,".") < 2   then
                assign
                  lNoFieldExp = true
                  lNewIdent = false
                  lNewToken = true.
              else 
              */
                /* get the column name from the map and store info about it */
                cToken = resolveColumn(cToken,miExpCount + 1 /* next expression */). 
            end.
            if lNewIdent 
            or lNewOperator 
            or lNewValue  
            or cToken = "?" then
            do:
              cNewFieldExp = ?.  
              if (lnewValue or ctoken = ?) 
              and valid-object(mQueryRef) then
              do:
                  cFieldValue = if cToken = "?" then "?" 
                                else substr(cToken,2,length(cToken) - 2).
                  cNewFieldExp = mQueryRef:ColumnExpression(entry(1,cFieldExp," "),
                                                                entry(2,cFieldExp," "),
                                                                cFieldValue).
 
              end.
 
              if cNewFieldExp <> ? then
              do:
                  cExpression = replace(cExpression,cFieldExp,cNewFieldExp).
                  cFieldExp = cNewFieldExp.
              end.
              else
                  assign
                      cFieldExp = left-trim(cFieldExp + ' ' + cToken)             
                      cExpression = left-trim(cExpression + ' ' + cToken).
            
            end. 
            else 
                assign
                    cExpression = left-trim(cExpression + ' ' + cToken).
          end.          
          if miNumTables = 0 then
            miNumTables = 1.
          mcTargetQuery[miNumTables] = if mcTargetQuery[miNumTables] = '' 
                                       then cToken
                                       else mcTargetQuery[miNumTables] + ' ' + cToken.

        end. /* else if not keyword*/
        
        /* newexpression is triggered by left parenthesis, and/or or 
           end of statement  */
        if lNewExpression then
        do:
          if cExpression > ''  then
          do:
            cDiff = if cFieldExp = ''   
                    then cExpression
                    else replace(cExpression,cFieldExp,'').
            /* If only diff is spaces and parenthesis then we store 
               the parenthesis as separate p-expressions */
            if cDiff <> '' and trim(cDiff,'( )') = '' then
            do:
              do iLeftPar = 1 to num-entries(cDiff,"(") - 1:
                assign 
                  miParCount  = miParCount + 1
                  mcEvaluation[iPar] = trim(mcEvaluation[iPar] 
                             + ' ' 
                             + 'P' + STRING(miParCount))
                  iParOwner[miParCount] = iPar
                  iPar = miParCount.
              end.
            end.
            else 
              assign  /* number of lefties to ignore */
              iBadPar = MAX(0,num-entries(cDiff,"(") - 2).
                          /* store expression  */
            if iBadpar = 0 then
            do:
              assign
                miExpCount = miExpCount + 1
                mcExpression[miExpCount] = if cAccExpress > '' or lNoFieldExp
                                           then cAccExpress + cExpression
                                           else trim(cFieldExp)
                mcEvaluation[iPar] = trim(mcEvaluation[iPar] 
                                   + ' ' 
                                   + 'E' + STRING(miExpCount))
                                   + (if lTableNext then ',' else '').
                           
              /* left parenthesis,  back up to parent parenthesis */
              if trim(cDiff) = ")" or cDiff = "(  )" then
                iPar = iParOwner[iPar].
              assign
                lNoFieldExp = false
                cFieldExp = ''
                cExpression = ''
                caccExpress = ''.
            end.
            else
              assign
                cAccExpress = cAccExpress + cExpression
                cExpression  = ''.
          
          end. /* cExpression > '' */
          else if lTableNext and minumtables > 0 then
             mcEvaluation[iPar] = mcEvaluation[iPar] + ','.

          if cAccExpress = '' and lookup(ctoken,'AND,OR') > 0 then
             mcEvaluation[iPar] = left-trim(mcEvaluation[iPar] + ' ' + cToken).

        end. /* newexpresssion */
        if lQueryOptions then
        do:
            if not cToken begins "BY " then 
                QueryOptions = (if QueryOptions <> " " then QueryOptions + " " else "") 
                             + cToken.
        end.    
        assign
          mcQueryWhere = mcQueryWhere + ' ' + cToken
          lNewToken      = false
          lNewExpression = false
          lNewIdent      = false
          lNewOperator   = false
          lNewValue      = false
          lAddToken      = false
          cToken         = ''.
      end.  /* lAddToken */
      
      if cChar > '' or lSingle or lDouble then
        cToken = cToken + cChar.
    end.
    /*
    showData().
      */
  end method.
  
  method public void Showdata():  

    message
    mcTargetTable[1] ':' mcTargetQuery[1] skip
    mcTargetTable[2] ':' mcTargetQuery[2] skip(1)
      tables skip(1)
    'parsed'   mcQueryWhere skip
    'SORT' SortExpression skip
    'OPTIONS' QueryOptions skip
    
    1    mcEvaluation[1] skip
    2    mcEvaluation[2] skip
    3    mcEvaluation[3] skip
    4    mcEvaluation[4] skip
    5    mcEvaluation[5] skip
    6    mcEvaluation[6] skip(1)
    
    1  mcExpression[1] mcExpTables[1] skip
    2  mcExpression[2] mcExpTables[2] skip
    3  mcExpression[3] mcExpTables[3] skip
    4  mcExpression[4] mcExpTables[4] skip
    5  mcExpression[5] mcExpTables[5] skip
    6  mcExpression[6] mcExpTables[6] skip
    7  mcExpression[7] mcExpTables[7] skip
    8  mcExpression[8] mcExpTables[8] skip
    9  mcExpression[9] mcExpTables[9] skip
    10 mcExpression[10] mcExpTables[10] skip
  view-as alert-box info buttons ok.


  end method.
  
  /* ParseSortExpression will transform and set SortExpression property,
     which has a protected set */
  method public void SetSort(cSort as character):
      ParseSortExpression(cSort).
  end method.
  
  /*  set querystring */
  method public void SetQueryString(cQuery as character):
      ClearQuery().
      ParseQuery(cQuery).
      mcUnparsedQuery = cQuery.
  end method.
  
  method private void ParseSortExpression ( pcSort as char) :

      define variable iSort as integer    no-undo.
      define variable cWord as character  no-undo.
      define variable cSort as character  no-undo.
      define variable lBy   as logical no-undo.
      SortExpression = "".   
      do iSort = 1 to num-entries(pcSort,' '):
          cWord = entry(iSort,pcSort,' ').
        
          if cWord <> '' then
          do:
              if cWord = "BY" then 
                  lBy = true.
              else if cWord <> "DESCENDING" then
              do:
                  if not lBy then 
                      leave.
                  
                  cWord = resolveColumn(cWord,0 /* not an expression */).
               
                  lBy = false. 
              end.
              SortExpression = left-trim(SortExpression + ' ' + cWord).
          end. /* not blank */
      end. /* isort loop */
      
 end method.
 
  /*
 METHOD PUBLIC CHARACTER checkqueryWhere (pcTable AS CHAR):
      DEFINE VARIABLE hTable AS HANDLE     NO-UNDO.
      CREATE BUFFER hTable FOR TABLE pcTable 

 END.
   */

 /** get the buffer where clause from the unparsed query ..*/
 method public character GetUnparsedWhereClause(pcBuffer as char): 
     define variable i as integer no-undo.
     return BufferWhereClause(pcBuffer,mcUnparsedQuery,output i).    
 end method.

 method private character BufferWhereClause 
                            (pcBuffer as char,
                             pcWhere  as char,
                             output piPos as int) :
  /*------------------------------------------------------------------------------
  Purpose:     Returns the complete query where clause for a specified buffer
               INCLUDING leading and trailing blanks.
               EXCLUDING commas and period.                            
  Parameters:  pcBuffer     - Buffer name. 
               pcWhere      - A complete query:prepare-string.
                            - ? use the current query                              
  Notes:       This is supported as a 'utility function' that doesn't use any 
               properties. 
            -  RETURNs the expression immediately when found. 
               RETURNs '' at bottom if nothing is found. 
  ------------------------------------------------------------------------------*/
    define variable iComma      as int        no-undo. 
    define variable iCount      as int        no-undo.
    define variable iStart      as int        no-undo.
    define variable cString     as char       no-undo.
    define variable cFoundWhere as char       no-undo.
    define variable cNextWhere  as char       no-undo.
    define variable cTargetType as character  no-undo.
    define variable cBuffer     as character  no-undo.
    define variable iUseIdxPos  as int        no-undo.        
    define variable iByPos      as int        no-undo.        
    define variable iIdxRePos   as int        no-undo.  
    define variable iOptionPos  as integer    no-undo.
   
    assign
      cString = right-trim(pcWhere," ":U)  
      iStart  = 1.
   
    /* Ensure that trailing blanks BEFORE the period are returned, but remove the 
       period and trailing blanks AFTER it. 
       If the length of right-trim with blank and blank + period is the same 
       then there is no period, so just use the passed pcWhere as is. 
       (Otherwise the remaining period is right-trimmed with comma further down)*/  
    if length(cString) = LENGTH(right-trim(pcWhere,". ":U)) then
      cString = pcWhere.
   
    
    /* The ADM resolves qualification at this stage ensurimg that the caller
       can use different qualification than used in the query   
      cBuffer = resolveBuffer(pcBuffer}. 
    
      IF cBuffer <> '':U AND cBuffer <> ? THEN
        pcBuffer = cBuffer.
    */
      
    do while true:
      iComma  = index(cString,",":U). 
      
      /* If a comma was found we split the string into cFoundWhere and cNextwhere */  
      if iComma <> 0 then 
        assign
          cFoundWhere = cFoundWhere + SUBSTR(cString,1,iComma)
          cNextWhere  = SUBSTR(cString,iComma + 1)     
          iCount      = iCount + iComma.       
      else      
        /* cFoundWhere is blank if this is the first time or if we have moved on 
           to the next buffer's where clause
           If cFoundwhere is not blank the last comma that was used to split 
           the string into cFoundwhere and cNextwhere was not a join, so we set 
           them together again.  */     
        cFoundWhere = if cFoundWhere = "":U 
                      then cString
                      else cFoundWhere + cNextwhere.
             
      /* We have a complete table whereclause if there are no more commas
         or the next whereclause starts with each,first or last */    
      if iComma = 0 
      or CAN-DO("EACH,FIRST,LAST":U,entry(1,trim(cNextWhere)," ":U)) then
      do:
        /* Remove comma or period before inserting the new expression */
        assign
          cFoundWhere = right-trim(cFoundWhere,",.":U). 
        
        if whereClauseBuffer(cFoundWhere) = pcBuffer then
        do:
          assign
            iByPos        = index(cFoundWhere," BY ":U)    
            iUseIdxPos    = index(cFoundWhere," USE-INDEX ":U)    
            iIdxRePos     = index(cFoundWhere + " ":U," INDEXED-REPOSITION ":U)
            iOptionPos    = MIN(if iByPos > 0     then iByPos     else length(cFoundWhere),
                               if iUseIdxPos > 0 then iUseIdxPos else length(cFoundWhere),
                               if iIdxRePos > 0  then iIdxRePos  else length(cFoundWhere)
                              )
           .
            pipos = istart.
          return trim(SUBSTR(cFoundWhere,1,iOptionPos)).
        
        end.
        else
          /* We're moving on to the next whereclause so reset cFoundwhere */ 
          assign      
            cFoundWhere = "":U                     
            iStart      = iCount + 1.      
       
         /* No table found and we are at the end so we need to get out of here */  
        if iComma = 0 then 
          leave.    
      end. /* if iComma = 0 or can-do(EACH,FIRST,LAST */
      cString = cNextWhere.  
    end. /* do while true. */
  
    return '':U.

  end method.

  
method private character NewQuerySort ( pcQuery       as char,
                                        pcSort        as char) :
/*------------------------------------------------------------------------------
  Purpose   :  Insert sort criteria (BY phrase) in a QueryString.
  Parameters:
    pcQuery    - Query to add sort to (current sort will be replaced)        
    pcSort     - new sort expression .
------------------------------------------------------------------------------*/
  define variable iByPos            as integer    no-undo.
  define variable iIdxPos           as integer    no-undo.
  define variable iLength           as integer    no-undo.
  
  if pcQuery = '':U then
     return '':U.

  assign   
    /* check for indexed-reposition  */
    iIdxPos = index(right-trim(pcQuery,". ") + " ":U," INDEXED-REPOSITION ":U)          
      
    /* If no INDEX-REPOSITION is found, set the iLength (where to end insert)
       to the end of where-clause. (right-trim periods and blanks to find 
       the true end of the expression) Otherwise iLength is the position of 
       INDEX-REPOSITION. */
    iLength = (if iIdxPos = 0 
               then length(right-trim(pcQuery,". ":U)) + 1     
               else iIdxPos)    
            
    /* Any By ? */ 
    iByPos  = index(pcQuery," BY ":U)                   
    /* Now find where we should start the insert; 
       We might have both a BY and an INDEXED-REPOSITION or only one of them 
       or none. So we make sure we use the MINIMUM of whichever of those 
       unless they are 0. */
    iByPos  = MIN(if iByPos  = 0 then iLength else iByPos,
                  if iIdxPos = 0 then iLength else iIdxPos) 
    .    
    /*
    SUBSTR(pcQuery,iByPos,iLength - iByPos) = IF pcSort <> '':U 
                                              THEN " ":U + pcSort
                                              ELSE "":U.  
    RETURN pcQuery. 
      */
    return  insertString(if pcSort <> '':U then " ":U + pcSort else "":U,
                             pcQuery,iByPos,iLength - iByPos).

 end method.
 
                                                           
 method private character InsertExpression 
                               (pcWhere       as char,   
                                pcExpression  as char,     
                                pcAndOr       as char):                         
/*------------------------------------------------------------------------------
 Purpose:     Inserts an expression into ONE buffer's where-clause.
 Parameters:  
      pcWhere      - Complete where clause with or without the FOR keyword,
                     but without any comma before or after.
      pcExpression - New expression OR OF phrase (Existing OF phrase is replaced)
      pcAndOr      - Specifies what operator is used to add the new expression 
                     to existing ones.
                     - AND (default) 
                     - OR         
 Notes:     - The new expression is embedded in parenthesis and a parentheses
              is also placed around the existing one, which is different.  
              than the original ADM's version which is just appended
              This would be problematic in adm, as it would be to many 
              parenthesises. 
             (could be improved to check for any OR and avoid parenthesis if not 
              found ) 
            - Lock keywords must be unabbreviated or without -lock (i.e. SHARE
              or EXCLUSIVE.)   
            - Any keyword in comments may cause problems.
 -----------------------------------------------------------------------------*/  
  define variable cTable        as char no-undo.  
  define variable cRelTable     as char no-undo.  
  define variable cJoinTable    as char no-undo.  
  define variable cWhereOrAnd   as char no-undo.  
  define variable iTblPos       as int  no-undo.
  define variable iWherePos     as int  no-undo.
  define variable lWhere        as log  no-undo.
  define variable iOfPos        as int  no-undo.
  define variable iRelTblPos    as int  no-undo.  
  define variable iInsertPos    as int  no-undo.    
  
  define variable iUseIdxPos    as int  no-undo.        
  define variable iOuterPos     as int  no-undo.        
  define variable iLockPos      as int  no-undo.      
  
  define variable iByPos        as int  no-undo.        
  define variable iIdxRePos     as int  no-undo.        
  define variable cTrimExp      as character  no-undo.
  define variable lAddPar       as logical    no-undo.
  define variable cOldWhere     as character  no-undo.
  define variable cMaskedWhere  as character  no-undo.
  if pcExpression begins '(' then
  do:
    cTrimExp = trim(pcExpression,"()").
    if  index(cTrimExp,")") = 0 
    and index(cTrimExp,"(") = 0 then
      pcExpression = cTrimExp.
  end.
    
  assign 
    /* Get rid of potential line break characters */   
    pcWhere       = replace(pcWhere,chr(10),' ':U)
    cMaskedWhere  = MaskQuotes(pcWhere,?)
    cTable        = whereClauseBuffer(cMaskedWhere)
    iTblPos       = index(cMaskedWhere,cTable) + LENGTH(cTable,"CHARACTER":U)
    
    iWherePos     = index(cMaskedWhere," WHERE ":U) + 6    
    iByPos        = index(cMaskedWhere," BY ":U)    
    iUseIdxPos    = index(cMaskedWhere," USE-INDEX ":U)    
    iIdxRePos     = index(cMaskedWhere + " ":U," INDEXED-REPOSITION ":U)    
    iOuterPos     = index(cMaskedWhere + " ":U," OUTER-JOIN ":U)     
    iLockPos      = MAX(index(cMaskedWhere + " ":U," NO-LOCK ":U),
                        index(cMaskedWhere + " ":U," SHARE-LOCK ":U),
                        index(cMaskedWhere + " ":U," EXCLUSIVE-LOCK ":U),
                        index(cMaskedWhere + " ":U," SHARE ":U),
                        index(cMaskedWhere + " ":U," EXCLUSIVE ":U)
                        )    
    iInsertPos    = length(cMaskedWhere) + 1 
                    /* We must insert before the leftmoust keyword,
                       unless the keyword is Before the WHERE keyword */ 
    iInsertPos    = MIN(
                      (if iLockPos   > iWherePos then iLockPos   else iInsertPos),
                      (if iOuterPos  > iWherePos then iOuterPos  else iInsertPos),
                      (if iUseIdxPos > iWherePos then iUseIdxPos else iInsertPos),
                      (if iIdxRePos  > iWherePos then iIdxRePos  else iInsertPos),
                      (if iByPos     > iWherePos then iByPos     else iInsertPos)
                       )                                                        
    lWhere        = index(cMaskedWhere," WHERE ":U) > 0 
    cWhereOrAnd   = (if not lWhere          then GetCased(" WHERE ")
                     else if pcAndOr = "":U or pcAndOr = ? then GetCased(" AND ")
                     else " ":U + GetCased(pcAndOr) + " ":U) 
    iOfPos        = index(cMaskedWhere," OF ":U)
    cOldWhere     = if lWhere 
                    then SUBSTR(pcWhere,iWherePos + 1,iInsertPos - iWherePos) 
                    else ''.
 
    if left-trim(cOldWhere) begins '(' then
      assign 
        cOldWhere = trim(cOldWhere,"()")
        lAddPar   = index(cOldWhere,"(") > 0 or index(cOldWhere,")") > 0.
    else 
      lAddPar = cOldWhere > ''.

    if left-trim(pcExpression) begins "OF ":U then 
    do:   
      /* If there is an OF in both the join and existing query we replace the 
         table unless they are the same */      
      if iOfPos > 0 then 
      do:
        assign
          /* Find the table in the old join */               
          cRelTable  = entry(1,left-trim(substring(cMaskedWhere,iOfPos + 4))," ":U)      
          /* Find the table in the new join */       
          cJoinTable = substring(left-trim(pcExpression),3).
        
        if cJoinTable <> cRelTable then
          assign 
           iRelTblPos = index(cMaskedWhere + " ":U," ":U + cRelTable + " ":U) + 1                            
           pcWhere    = insertString(cJointable,pcWhere,iRelTblPos,length(cRelTable)).
        /*  SUBSTRING(pcWhere,iRelTblPos,LENGTH(cRelTable)) = cJointable. */

      end. /* if iOfPos > 0 */ 
      else 
        pcWhere = insertString(pcExpression,pcWhere,iTblPos,0).

        /*
        SUBSTRING(pcWhere,iTblPos,0) = " ":U + pcExpression.        
          */
    end. /* if left-trim(pcExpression) BEGINS "OF ":U */
    else do:
      pcWhere = insertString((if lAddPar then ')' else '')
                             +  cWhereOrAnd 
                             + (if lWhere then "(" else '')
                             + pcExpression 
                             + (if lWhere then ")" else ''),
                            pcWhere,iInsertPos,0).
                                                    /*
      SUBSTRING(pcWhere,iInsertPos,0) = (IF lAddPar THEN ')' ELSE '')
                                         +  cWhereOrAnd 
                                         + (IF lWhere THEN "(" ELSE '')
                                         + pcExpression 
                                         + (IF lWhere THEN ")" ELSE ''). 
         */
   
      if lAddPar then  
          substr(pcWhere,index(pcWhere,' WHERE ') + 7,0) = "(".
    end.
     
    return right-trim(pcWhere).
  
  end method.
  
  method private character WhereClauseBuffer (pcWhere as char):
  /*------------------------------------------------------------------------------
    Purpose:     Returns the buffername of a where clause expression. 
                 This function avoids problems with leading or double blanks in 
                 where clauses.
    Parameters:
      pcWhere - Complete where clause for ONE table with or without the FOR 
                keyword. The buffername must be the second token in the
                where clause as in "EACH order OF Customer" or if "FOR" is
                specified, the third token as in "FOR EACH order".

    Notes:      Used internally in query.p.
  ------------------------------------------------------------------------------*/
    pcWhere = left-trim(pcWhere).

    /* Remove double blanks */
    do while index(pcWhere,"  ":U) > 0:
      pcWhere = replace(pcWhere,"  ":U," ":U).
    end.
    /* Get rid of potential line break characters */   
    pcWhere = replace(pcWhere,chr(10),'':U). 

    return (if num-entries(pcWhere," ":U) > 1 
            then entry(if pcWhere begins "FOR ":U or pcWhere begins "PRESELECT ":U then 3 else 2,pcWhere," ":U)
            else "":U).

  end.
  
  method private character GetCased(word as char):
      if UpperCaseKeyWords then 
          return caps(word).
      else 
          return lc(word). 
  end.    
  
  method public character BuildQueryString ():
      if MergeQuery then
          undo, throw new AppError("BuildQueryString with no parameters cannot be used when queryString is set up to merge with BaseQuery",?).
      return BuildParsedQueryString(GetParsedQueryTables()).
  end method.
   
  method public character BuildParsedQueryString(pcTables as char):
    
    define variable iTable as integer    no-undo.
    define variable cWhere  as character  no-undo.
    define variable cTable  as character  no-undo.
    define variable cEval   as character  no-undo.
    define variable cSort    as character no-undo.
    
    do iTable =  1 to num-entries(pcTables):
      assign
        cTable = entry(iTable,pcTables)
        cWhere = (if iTable = 1 then GetCased(if Statement = "" then GetCased("FOR EACH") else Statement) + " " 
                  else               cWhere + ', ' + GetCased('EACH') + ' ')
               + cTable
        cEval  = getTableEvaluation(1,iTable,pcTables).
        if cEval > ''  then
          cWhere = cWhere + ' ' + GetCased('WHERE') + ' ' + getTableEvaluation(1,iTable,pcTables).
    end.
         
    if SortExpression > "" then
    do:
        cSort = BuildSortExpression(pcTables).
        if cSort >  "" then 
           cWhere = cWhere + " " + cSort.
    end.    
    if QueryOptions > "" then
        cWhere = cWhere + " " + QueryOptions.   
        
    return cWhere.
  end.
  
   /* return sort only for specified tables */
  method public character BuildSortExpression(pcTables as char) :
      define variable iSort       as integer    no-undo.
      define variable cWord       as character  no-undo.
      define variable cSort       as character  no-undo.
      define variable cTable      as character  no-undo.
      define variable cExpression as character  no-undo.
      define variable lOk         as logical    no-undo.
      
      do iSort = 1 to num-entries(SortExpression,' '):
          cWord = entry(iSort,SortExpression,' ').       
          
          if cWord <> '' then
          do:
              if cWord = "BY" then
              do: 
                  if lOk then 
                      cSort = cSort + ' ' + cExpression.
                  assign
                      lOk         = false
                      cExpression = "".
              end.
              else if cWord <> "DESCENDING" then
              do:
                  if num-entries(cWord,".") = 2 then
                      cTable = entry(1,cWord,".").
                  lok = lookup(cTable,pcTables) > 0.
                  if lok and valid-object(mQueryRef) then 
                  do:
                      cWord = mQueryRef:ColumnSortSource(cWord).
                  end.        
              end.
              cExpression = left-trim(cExpression + ' ' + cWord).
          end. /* not blank */            
      end. /* isort loop */
      if lok then 
         cSort = cSort + ' ' + cExpression.
     
      return left-trim(cSort).
  end method.
   
  method private character TableEvaluation (piTableEntry as int,
                                            pcTables as char):
      return GetTableEvaluation(1,piTableEntry,pcTables).
  end method.
  
  method private character GetTableEvaluation (piEval as int,
                                               piTableEntry as int,
                                               pcTables as char):
     
     define variable iEval        as integer    no-undo.
     define variable cRef         as character  no-undo.
     define variable iRef         as integer    no-undo.
     define variable cEvaluation  as character  no-undo .
     define variable cExpression  as character  no-undo.
     define variable cOperator    as character  no-undo.
     define variable lAnyOr       as logical    no-undo.
     define variable cEvalTables  as character  no-undo.
     define variable cCheckExp    as character  no-undo.
     define variable lAddPar      as logical    no-undo.

     if piTableEntry > 0 then
     do:
       /* if any OR only add the whole evaluation */ 
       lAnyOr = index(mcEvaluation[piEval],' OR ') > 0. 
       if lAnyOr then
       do:
         cEvalTables = getEvaluationTables(piEval,'').
         if not canAddRefTables(cEvalTables,piTableEntry,pcTables) then
           return ''.
         piTableEntry = 0.
       end.
     end.

     do iEval = 1 to num-entries(mcEvaluation[piEval],' '):
       cRef = entry(iEval,mcEvaluation[piEval],' ').
       if lookup(cRef,'AND,OR') > 0 then
       do:
         cOperator =  cRef.
       end.
       else
       do:
         iRef = INT(SUBSTR(cRef,2)).
         if cRef begins 'E' then
         do:
           if piTableEntry = 0  
           or canAddRefTables(mcExpTables[iRef],piTableEntry,pcTables) then
           do:
             cExpression = mcExpression[iRef]. 
           end.
         end.
         else if iRef > 0 then 
         do:
           cExpression = getTableEvaluation(iRef,piTableEntry,pctables).
           if cExpression > '' then 
           do:
             if cExpression begins '(' then
               assign
                 cCheckExp = trim(cExpression,"()")
                 lAddPar   = index(cCheckExp,"(") > 0 or index(cCheckExp,")") > 0.
             else 
               lAddPar = true.

             cExpression = (if lAddPar then "(" else '')
                         + cExpression 
                         + (if lAddPar then ")" else '').
           end.
         end.

         if cExpression > '' then
         do:
           if cEvaluation = '' then
             cEvaluation = cExpression. 
           else if cOperator > '' then
             cEvaluation = cEvaluation + ' ' + cOperator + ' ' + cExpression.
           else /* added for second table */
             cEvaluation = cEvaluation + GetCased(' AND ') + cExpression.
         end.
       
         assign
           cOperator  = ''
           cExpression = ''.
       end.
     end.
     return cEvaluation.
  end method.

  method private character GetEvaluationTables (piEval as int,pcTables as char ):
     
    define variable iEval        as integer    no-undo.
    define variable cRef         as character  no-undo.
    define variable iRef         as integer    no-undo.
    define variable cEvaluation  as character  no-undo .
    define variable cExpression  as character  no-undo.
    define variable cOperator    as character  no-undo.
    define variable lAnyOr       as logical    no-undo.
    define variable cEvalTables  as character  no-undo.
    define variable cCheckExp    as character  no-undo.
    define variable lAddPar      as logical    no-undo.
    define variable iTable       as integer    no-undo.
    define variable cTable       as character  no-undo.

    do iEval = 1 to num-entries(mcEvaluation[piEval],' '):
       cRef = entry(iEval,mcEvaluation[piEval],' ').
       if lookup(cRef,'AND,OR') = 0 then
       do:
         iRef = INT(SUBSTR(cRef,2)).
        
         if cRef begins 'E' then
         do iTable = 1 to num-entries(mcExpTables[iRef]) :
           cTable = entry(iTable,mcExpTables[iRef]).
           if lookup(cTable,pcTables) = 0 then
             pcTables = pcTables 
                      + (if pcTables = '' then '' else ',') 
                      + cTable.  
         end.
         else if iRef > 0 then
          pcTables = getEvaluationTables(iRef,pctables).
       end.
    end.
    return pcTables.
  end method.

  method private logical CanAddRefTables (pcRefTables as char,
                                          piTableLevel as int,
                                          pcTables as char):
    /* can pcRefTables be added to piTableLevel entry in a pcTables ordered query */
    define variable iNumRefTables as integer    no-undo.
    define variable iTable        as integer    no-undo.
    define variable cTable        as character  no-undo.
    define variable cCurrentTable as character  no-undo.
    define variable iTablePos     as integer    no-undo.
    define variable iCurrent      as integer    no-undo.
    
    cCurrentTable = entry(piTableLevel,pcTables).
    
    iNumRefTables = num-entries(pcRefTables).  
    
    /* expression with no ref goes to first */ 
    if iNumRefTables = 0 then
        return piTableLevel = 1 .
    
    if iNumRefTables = 1 then
        return cCurrentTable = pcRefTables.
    
    /* if current is in ref include if the others are higher or external  */
    if lookup(cCurrentTable,pcRefTables) > 0 then
    do:
        do iTable = 1 to num-entries(pcRefTables) :
            cTable = entry(iTable,pcRefTables).
            if cTable <> cCurrentTable then
            do:
                iTablePos = lookup(cTable,pcTables).
                if iTablePos > piTableLevel then
                do:
                    return false.
                end.    
            end.
        end.
        return true.
    end.
    return false.

  end method.

  method private character GetEvaluation (piEval as int):
     define variable iEval as integer    no-undo.
     define variable cRef  as character  no-undo.
     define variable iRef  as integer    no-undo.
     define variable cEvaluation as character  no-undo.
     define variable cExpression as character  no-undo.

     do iEval = 1 to num-entries(mcEvaluation[piEval],' '):
       cRef = entry(iEval,mcEvaluation[piEval],' ').

       if lookup(cRef,'AND,OR') > 0 then
         cEvaluation = cEvaluation + ' ' + cRef.
       else
       do:
         iRef = INT(SUBSTR(cRef,2)).
         if cRef begins 'E' then
           cEvaluation = left-trim(cEvaluation + ' ' + mcExpression[iRef]).
         else 
           cEvaluation = left-trim(cEvaluation + " (" + getEvaluation(iRef) + ")").
       end.
     end.

     return cEvaluation.
  end method.
            
  method private character ResolveColumn (pcColumn as char, piExp as int):
    /* called from parsequery and parseSortExpression */
    define variable cColumnTable as character  no-undo.
    define variable cColumn      as character  no-undo.
 
    /* get the column name from the map */
    if valid-object(mQueryRef) then
    do:
      cColumn = mQueryRef:columnSource(pcColumn). 
      if cColumn > '' then
        pcColumn = cColumn.
    end.
    
    if pcColumn > '' then
    do:
        
      cColumnTable = entry(1,pcColumn,".").
      /* keep track of table references in the expression */
      if piExp > 0 and lookup(cColumnTable,mcExpTables[piExp]) = 0 then
 
         mcExpTables[piExp] = mcExpTables[piExp]
                            + (if mcExpTables[piExp] = '' then '' else ',')
                            + cColumnTable.
  
          /* Trim is a bit dangerous with recycled variables if set to ' '.
          LEFT-TRIM(mcExpTables[piExp] + "," + cColumnTable,", ") <--USE-.
           */
      /* keep track of table references in the object */
      if lookup(cColumnTable,Tables) = 0 then
        Tables = left-trim(Tables + "," + cColumnTable,",").
    end.
    /* as for now we just return in any case leaving error messages to 
       query prepare if mapping was unsuccessful  */
    return pcColumn.
  end.
  
  /* workaround for temporary core bug */
  method protected character InsertString
     (pcString as char,
      pcTargetString as char,
      piPos as int,
      piLength as int):
    
    return SUBSTR(pcTargetString,1,piPos - 1)
           + pcString
           + SUBSTR(pcTargetString,piPos + piLength).
  end.

  method public character GetParsedQueryTables ():
     define variable i as integer    no-undo.
     define variable c as character  no-undo.
     do i = 1 to miNumTables:
       c = c + ',' + mcTargetTable[i].
     end.
     return trim(c,","). 
  end.
  
  /*------------------------------------------------------------------------------
    Purpose: Return a default query from data (no table options)
    ------------------------------------------------------------------------------*/
  method protected character BuildDefaultQueryString (pcTables as char):
        define variable iBuffer     as integer    no-undo.
        define variable cPrepare    as character  no-undo.
        define variable cBuffer     as character  no-undo.
        define variable cParent     as character  no-undo.
        define variable cMode       as character  no-undo.
        define variable cKeyTable   as character  no-undo.
            
        /* assume the first table in the definition is the main table that 
           the others join to and that need to have 'EACH' if joined from
           one of the other tables */
        cKeyTable = entry(1,pcTables).
         
        cPrepare = GetCased("FOR EACH ") + cKeyTable + GetCased(" NO-LOCK")  .
        /* If there's more than one buffer than add them, just assuming that
           an OF relationship to the first table in tables will properly relate them. */
        do iBuffer = 2 to num-entries(pcTables):
    
          assign 
              cBuffer  = entry(iBuffer,pcTables)
              cParent  = cKeyTable
              cMode    = GetCased("EACH")
              cPrepare = cPrepare 
                     + ", " + cMode + " " + cBuffer + GetCased(" NO-LOCK")  + GetCased(" OF ") +  cParent .
    
        end.   /* DO iBuffer = 2 */
        cPrepare = cPrepare + GetCased(' INDEXED-REPOSITION').
   
        return cPrepare.
  end method.
 
   /*------------------------------------------------------------------------------
    Purpose: Utility function that masks all quoted strings in the passed string              
    Parameters: pcString = string that might have embedded quoted strings. 
                     must be syntactically correct - paired single or double.  
                pcReplaceChar = single char to insert in quoted positions. 
    Notes: Used in various query manipulation before looking for keywords 
           (Basically a workaround for lack of full parsing  )   
   ------------------------------------------------------------------------------*/
  method public char MaskQuotes (pcString as char, pcReplaceChar as char) :
    
      define variable iChr          as integer   no-undo.
      define variable iState        as integer   no-undo.
      define variable cQuote        as character no-undo.         
      define variable cChr          as character no-undo.   
      
      if pcReplaceChar = ? or pcReplaceChar = "":U then
        pcReplaceChar = '0':U.
      
      if index(pcString,"'":U) > 0 or index(pcString,'"':U) > 0 then 
      do:
        do iChr = 1 to length(pcString):
          cChr = substring(pcString,iChr,1).
          case iState:
            when 0 then 
            do:
              if cChr = '"':U or cChr = "'":U then  
                assign      
                  iState = 1
                  cQuote = cChr.
            end.  
            when 1 then /* start quote is found */
            do:
              if cChr = '~~':U then iState = 2. /* ignore next */
              if cChr = cQuote then iState = 3. /* possible end */
            end.  
            when 2 then /* prev char was tilde */ 
              iState = 1.
            when 3 then /* possible end quote was found */ 
            do:
              /* if another quote then we're still in quoted string */
              if cChr = cQuote then 
                iState = 1.
              else 
                iState = 0.    
            end.
          end case.        
          if iState > 0 then 
            substring(pcString,iChr,1) = pcReplaceChar.
        end.    
      end.
      return pcString.   

  end method.
end.

