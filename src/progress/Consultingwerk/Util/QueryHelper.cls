/**********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/   
/*------------------------------------------------------------------------
    File        : QueryHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Jul 04 21:15:06 CEST 2009
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*                       FROM PROPATH . 
USING Consultingwerk.Assertion.*             FROM PROPATH .
USING Consultingwerk.Exceptions.*            FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH . 
USING Consultingwerk.Util.*                  FROM PROPATH . 
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Util.QueryHelper:  

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE QueryHelper (  ):
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose:     Returns the complete query where clause for a specified buffer
                     INCLUDING leading and trailing blanks.
                     EXCLUDING commas and period.                            
        Notes:       This is supported as a 'utility function' that doesn't use any 
                     properties. 
                  -  RETURNs the expression immediately when found. 
                     RETURNs '' at bottom if nothing is found. 
        @param pcBuffer The buffer name to return the where clause from
        @param pcWhere The complete query:prepare-string
        @return The complete query where clause for the specified buffer
      ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER BufferWhereClause (pcBuffer AS CHAR,
                                                      pcWhere  AS CHAR):
                                     
        DEFINE VARIABLE iComma      AS INT        NO-UNDO. 
        DEFINE VARIABLE iCount      AS INT        NO-UNDO.
        DEFINE VARIABLE iStart      AS INT        NO-UNDO.
        DEFINE VARIABLE cString     AS CHAR       NO-UNDO.
        DEFINE VARIABLE cFoundWhere AS CHAR       NO-UNDO.
        DEFINE VARIABLE cNextWhere  AS CHAR       NO-UNDO.
        DEFINE VARIABLE cTargetType AS CHARACTER  NO-UNDO.
        DEFINE VARIABLE cBuffer     AS CHARACTER  NO-UNDO.
        DEFINE VARIABLE iUseIdxPos  AS INT        NO-UNDO.        
        DEFINE VARIABLE iByPos      AS INT        NO-UNDO.        
        DEFINE VARIABLE iIdxRePos   AS INT        NO-UNDO.  
        DEFINE VARIABLE iOptionPos  AS INTEGER    NO-UNDO.
       
        ASSIGN
            cString = RIGHT-TRIM(pcWhere," ":U)  
            iStart  = 1.
       
        /* Keep our promises and ensure that trailing blanks BEFORE the period are 
           returned, but remove the period and trailing blanks AFTER it. 
           If the length of right-trim with blank and blank + period is the same 
           then there is no period, so just use the passed pcWhere as is. 
           (Otherwise the remaining period is right-trimmed with comma further down)*/  
        IF LENGTH(cString) = LENGTH(RIGHT-TRIM(pcWhere,". ":U)) THEN
          cString = pcWhere.
       
        
        /* The ADM resolves qualification at this stage ensurimg that the caller
           can use different qualification than used in the query   
          cBuffer = resolveBuffer(pcBuffer}. 
        
          IF cBuffer <> '':U AND cBuffer <> ? THEN
            pcBuffer = cBuffer.
        */
          
        DO WHILE TRUE:
          iComma  = INDEX(cString,",":U). 
          
          /* If a comma was found we split the string into cFoundWhere and cNextwhere */  
          IF iComma <> 0 THEN 
            ASSIGN
              cFoundWhere = cFoundWhere + SUBSTR(cString,1,iComma)
              cNextWhere  = SUBSTR(cString,iComma + 1)     
              iCount      = iCount + iComma.       
          ELSE      
            /* cFoundWhere is blank if this is the first time or if we have moved on 
               to the next buffer's where clause
               If cFoundwhere is not blank the last comma that was used to split 
               the string into cFoundwhere and cNextwhere was not a join, so we set 
               them together again.  */     
            cFoundWhere = IF cFoundWhere = "":U 
                          THEN cString
                          ELSE cFoundWhere + cNextwhere.
                 
          /* We have a complete table whereclause if there are no more commas
             or the next whereclause starts with each,first or last */    
          IF iComma = 0 
          OR ListHelper:EntryIsInList (ENTRY(1,TRIM(cNextWhere)," ":U),
                                       "EACH,FIRST,LAST":U) THEN
          DO:
            /* Remove comma or period before inserting the new expression */
            ASSIGN
              cFoundWhere = RIGHT-TRIM(cFoundWhere,",.":U). 
            
            IF whereClauseBuffer(cFoundWhere) = pcBuffer THEN
            DO:
              ASSIGN
                iByPos        = INDEX(cFoundWhere," BY ":U)    
                iUseIdxPos    = INDEX(cFoundWhere," USE-INDEX ":U)    
                iIdxRePos     = INDEX(cFoundWhere + " ":U," INDEXED-REPOSITION ":U)
                iOptionPos    = MIN(IF iByPos > 0     THEN iByPos     ELSE LENGTH(cFoundWhere),
                                   IF iUseIdxPos > 0 THEN iUseIdxPos ELSE LENGTH(cFoundWhere),
                                   IF iIdxRePos > 0  THEN iIdxRePos  ELSE LENGTH(cFoundWhere)
                                  )
               .
      
              RETURN TRIM(SUBSTR(cFoundWhere,1,iOptionPos)).
            END.
            ELSE
              /* We're moving on to the next whereclause so reset cFoundwhere */ 
              ASSIGN      
                cFoundWhere = "":U                     
                iStart      = iCount + 1.      
           
             /* No table found and we are at the end so we need to get out of here */  
            IF iComma = 0 THEN 
              LEAVE.    
          END. /* if iComma = 0 or ListHelper:EntryIsInList (EACH,FIRST,LAST */
          cString = cNextWhere.  
        END. /* do while true. */
      
        RETURN '':U.
    
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the Index of the Queries Buffer the column belongs to                                                                        
        Notes:
        @param pcColumnName The name of the Column to return the Index for
        @param phQuery The handle of the query
        @return The index of the queries buffer the column belongs to                                                                        
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC INTEGER ColumnsBufferIndex (pcColumnName AS CHARACTER,
                                                     phQuery AS HANDLE):
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.

        IF NOT VALID-HANDLE (phQuery) THEN 
            UNDO, THROW NEW AppError ("A valid query is required to get columns buffer index."{&TRAN}, 0) .

        DO i = 1 TO phQuery:NUM-BUFFERS:
            ASSIGN hField = phQuery:GET-BUFFER-HANDLE (i):BUFFER-FIELD (pcColumnName) NO-ERROR .
            
            IF VALID-HANDLE (hField) THEN 
                RETURN i .                          
        END.

        RETURN ? .
    END METHOD.

     /*------------------------------------------------------------------------------
        Purpose: Creates, Prepares and Opens a new Query widget for the given 
                 buffer handle. The Query will be positioned at the first result row                                                                       
        Notes:   You need to manually delete the query widget. No garbage collection
                 is provided for query widgets.      
        @param phBuffer The buffer handle
        @return The handle of the prepared query                                                                                 
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC HANDLE CreatePreparedQuery (phBuffer AS HANDLE):
        
        IF NOT VALID-HANDLE(phBuffer) OR phBuffer:TYPE <> "BUFFER":U THEN 
            RETURN ERROR NEW AppError ("Invalid Buffer handle."{&TRAN}, 0) .
        
        RETURN CreatePreparedQuery (phBuffer, 
                                    SUBSTITUTE ("FOR EACH &1":U, phBuffer:NAME)).

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Creates, Prepares and Opens a new Query widget for the given 
                 buffer handle. The Query will be positioned at the first result row                                                                       
        Notes:   You need to manually delete the query widget. No garbage collection
                 is provided for query widgets.                                                                      
        @param phBuffer The buffer handle
        @param pcQueryString The prepare string for the query
        @return The handle of the prepared query                                                                                 
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC HANDLE CreatePreparedQuery (phBuffer AS HANDLE,
                                                     pcQueryString AS CHARACTER):
        
        DEFINE VARIABLE hQuery AS HANDLE NO-UNDO.
        
        CREATE QUERY hQuery . 
        hQuery:SET-BUFFERS (phBuffer) .
        hQuery:QUERY-PREPARE (pcQueryString) .
        hQuery:QUERY-OPEN () .
        hQuery:GET-FIRST () .
        
        RETURN hQuery.

    END METHOD.

     /*------------------------------------------------------------------------------
        Purpose: Returns a ROWID Array containing the rowids of the current
                 Query result row.                                                                        
        Notes:   Can be used with reposition to rowid
        @param phQuery The handle of the query
        @param prRowids OUTPUT The array of the rowid of each query buffer                                                                        
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC VOID GetCurrentRowids (phQuery AS HANDLE, 
                                                OUTPUT prRowids AS ROWID EXTENT):
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
                
        IF NOT VALID-HANDLE (phQuery) OR phQuery:TYPE <> "QUERY":U THEN 
            UNDO, THROW NEW AppError ("Invalid Query object."{&TRAN}, 0).                 
                                                           
        EXTENT (prRowids) = phQuery:NUM-BUFFERS .                 
                                          
        DO i = 1 TO phQuery:NUM-BUFFERS:
            IF phQuery:GET-BUFFER-HANDLE(i):AVAILABLE THEN  
                ASSIGN prRowids[i] = phQuery:GET-BUFFER-HANDLE(i):ROWID .
            ELSE 
                ASSIGN prRowids[i] = ? .  
        END.                                                  
                                                  
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the handle of a field from a queries buffer
        Notes:   Field names to be specified as Buffername.Fieldname
        @param phQuery The handle to the Query widget
        @param pcFieldName the name of the buffer field in the form Buffername.Fieldname
        @return The handle to the buffer field specified
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC HANDLE GetQueryFieldHandle (phQuery AS HANDLE,
                                                     pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.

        Consultingwerk.Assertion.HandleAssert:WidgetType (phQuery, WidgetTypeEnum:Query) .

        IF NUM-ENTRIES (pcFieldName, ".":U) <> 2 THEN 
            UNDO, THROW NEW InvalidParameterValueException ("pcFieldName":U, 
                                                            pcFieldName,
                                                            "Consultingwerk.Util.BufferHelper":U) .
        
        ASSIGN hBuffer = phQuery:GET-BUFFER-HANDLE (ENTRY (1, pcFieldName, ".":U)) . 

        Consultingwerk.Assertion.BufferAssert:HasField (hBuffer,    
                                                        ENTRY (2, pcFieldName, ".":U)) .

        RETURN hBuffer:BUFFER-FIELD (ENTRY (2, pcFieldName, ".":U)) .

    END METHOD .

    /*------------------------------------------------------------------------------
       Purpose:     Inserts an expression into ONE buffer's where-clause.
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
        @param pcWhere The complete where clause with or without the FOR keyword, but without any comma before or after
        @param pcExpression The new expression OR OF phrase (Existing OF phrase is replaced)
        @param pcAndOr Specifies what operator is used to add the new expression to existing ones, AND (default) or OR 
        @return The new query string
     -----------------------------------------------------------------------------*/  
    METHOD PUBLIC STATIC CHARACTER InsertExpression (pcWhere      AS CHAR,   
                                                     pcExpression AS CHAR,     
                                                     pcAndOr      AS CHAR):                         

        DEFINE VARIABLE cTable        AS CHAR NO-UNDO.  
        DEFINE VARIABLE cRelTable     AS CHAR NO-UNDO.  
        DEFINE VARIABLE cJoinTable    AS CHAR NO-UNDO.  
        DEFINE VARIABLE cWhereOrAnd   AS CHAR NO-UNDO.  
        DEFINE VARIABLE iTblPos       AS INT  NO-UNDO.
        DEFINE VARIABLE iWherePos     AS INT  NO-UNDO.
        DEFINE VARIABLE lWhere        AS LOG  NO-UNDO.
        DEFINE VARIABLE iOfPos        AS INT  NO-UNDO.
        DEFINE VARIABLE iRelTblPos    AS INT  NO-UNDO.  
        DEFINE VARIABLE iInsertPos    AS INT  NO-UNDO.    
          
        DEFINE VARIABLE iUseIdxPos    AS INT  NO-UNDO.        
        DEFINE VARIABLE iOuterPos     AS INT  NO-UNDO.        
        DEFINE VARIABLE iLockPos      AS INT  NO-UNDO.      
         
        DEFINE VARIABLE iByPos        AS INT  NO-UNDO.        
        DEFINE VARIABLE iIdxRePos     AS INT  NO-UNDO.        
        DEFINE VARIABLE cTrimExp      AS CHARACTER  NO-UNDO.
        DEFINE VARIABLE lAddPar       AS LOGICAL    NO-UNDO.
        DEFINE VARIABLE cOldWhere     AS CHARACTER  NO-UNDO.
        
        IF pcExpression BEGINS '(':U THEN
        DO:
            cTrimExp = TRIM(pcExpression, "()":U).
            IF  INDEX(cTrimExp, ")":U) = 0 
            AND INDEX(cTrimExp, "(":U) = 0 THEN
              pcExpression = cTrimExp.
        END.
            
        ASSIGN 
            /* Get rid of potential line break characters */   
            pcWhere       = REPLACE(pcWhere,CHR(10),' ':U)
            cTable      
              = whereClauseBuffer(pcWhere)
            iTblPos       = INDEX(pcWhere,cTable) + LENGTH(cTable,"CHARACTER":U)
            
            iWherePos     = INDEX(pcWhere," WHERE ":U) + 6    
            iByPos        = INDEX(pcWhere," BY ":U)    
            iUseIdxPos    = INDEX(pcWhere," USE-INDEX ":U)    
            iIdxRePos     = INDEX(pcWhere + " ":U," INDEXED-REPOSITION ":U)    
            iOuterPos     = INDEX(pcWhere + " ":U," OUTER-JOIN ":U)     
            iLockPos      = MAX(INDEX(pcWhere + " ":U," NO-LOCK ":U),
                                INDEX(pcWhere + " ":U," SHARE-LOCK ":U),
                                INDEX(pcWhere + 
                                " ":U," EXCLUSIVE-LOCK ":U),
                                INDEX(pcWhere + " ":U," SHARE ":U),
                                INDEX(pcWhere + " ":U," EXCLUSIVE ":U)
                                )    
            iInsertPos    = LENGTH(pcWhere) + 1 
                            /* We must insert before the leftmoust keyword,
                               unless the keyword is Before the WHERE keyword */ 
            iInsertPos    = MIN(
                              (IF iLockPos   > iWherePos THEN iLockPos   ELSE iInsertPos),
                              (IF iOuterPos  > iWherePos THEN iOuterPos  ELSE iInsertPos),
                              (IF iUseIdxPos > iWherePos THEN iUseIdxPos ELSE iInsertPos),
                              (IF iIdxRePos  > iWherePos THEN iIdxRePos  ELSE iInsertPos),
                              (IF iByPos     > iWherePos THEN iByPos     ELSE iInsertPos)
                               )                                                        
            lWhere        = INDEX(pcWhere," WHERE ":U) > 0 
            cWhereOrAnd   = (IF NOT lWhere          THEN " WHERE ":U 
                             ELSE IF pcAndOr = "":U OR pcAndOr = ? THEN " AND ":U 
                             ELSE " ":U + pcAndOr + " ":U) 
            iOfPos        = INDEX(pcWhere," OF ":U)
            cOldWhere     = IF lWhere 
                            THEN SUBSTR(pcWhere, iWherePos + 1, iInsertPos - iWherePos) 
                            ELSE '':U.
    
        IF LEFT-TRIM(cOldWhere) BEGINS '(':U THEN
          ASSIGN 
            cOldWhere = TRIM(cOldWhere, "()":U)
            lAddPar   = INDEX(cOldWhere, "(":U) > 0 OR INDEX(cOldWhere, ")":U) > 0.
        ELSE 
          lAddPar = cOldWhere > '':U.
    
        IF LEFT-TRIM(pcExpression) BEGINS "OF ":U THEN 
        DO:   
          /* If there is an OF in both the join and existing query we replace the 
             table unless they are the same */      
          IF iOfPos > 0 THEN 
          DO:
            ASSIGN
              /* Find the table in the old join */               
              cRelTable  = ENTRY(1,LEFT-TRIM(SUBSTRING(pcWhere,iOfPos + 4))," ":U)      
              /* Find the table in the new join */       
              cJoinTable = SUBSTRING(LEFT-TRIM(pcExpression),3).
            
            IF cJoinTable <> cRelTable THEN
              ASSIGN 
               iRelTblPos = INDEX(pcWhere + " ":U," ":U + cRelTable + " ":U) + 1                            
               pcWhere    = insertString(cJointable,pcWhere,iRelTblPos,LENGTH(cRelTable)).
            /*  SUBSTRING(pcWhere,iRelTblPos,LENGTH(cRelTable)) = cJointable. */
    
          END. /* if iOfPos > 0 */ 
          ELSE 
            pcWhere = insertString(pcExpression,pcWhere,iTblPos,0).
    
            /*
            SUBSTRING(pcWhere,iTblPos,0) = " ":U + pcExpression.        
              */
        END. /* if left-trim(pcExpression) BEGINS "OF ":U */
        ELSE 
          pcwhere = insertString((IF lAddPar THEN ')':U ELSE '':U)
                                 +  cWhereOrAnd 
                                 + (IF lWhere THEN "(":U ELSE '':U)
                                 + pcExpression 
                                 + (IF lWhere THEN ")":U ELSE '':U),
                                pcWhere, iInsertPos, 0).
                                                        /*
          SUBSTRING(pcWhere,iInsertPos,0) = (IF lAddPar THEN ')':U ELSE '':U)
                                             +  cWhereOrAnd 
                                             + (IF lWhere THEN "(":U ELSE '':U)
                                             + pcExpression 
                                             + (IF lWhere THEN ")":U ELSE '':U). 
             */
    
        IF lAddPar THEN pcWhere = REPLACE (pcWhere,' WHERE ':U,' WHERE (':U).
    
        RETURN RIGHT-TRIM (pcWhere).
  

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Inserts a String into and existing string                                                                        
        Notes:                                            
        @param pcString The string to insert into the target string 
        @param pcTargetString The string to insert into
        @param piPos The position to insert into
        @param piLength The length of the string to insert to      
        @return The resulting string                       
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE STATIC CHARACTER InsertString (pcString AS CHARACTER,
                                                  pcTargetString AS CHARACTER,
                                                  piPos AS INTEGER,
                                                  piLength AS INTEGER):
    
    RETURN   SUBSTRING (pcTargetString,1 , piPos - 1)
           + pcString
           + SUBSTRING (pcTargetString, piPos + piLength).

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Open a query that returns no records                                            
        Notes:   Query is open but returns no records                            
        @param phQuery The handle of the query                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID OpenNonMatchingQuery (phQuery AS HANDLE):
        
        DEFINE VARIABLE cPrepareString AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cQueryString   AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i              AS INTEGER   NO-UNDO .
        
        ASSIGN cPrepareString = phQuery:PREPARE-STRING 
               cQueryString   = "FOR ":U  .
        
        DO i = 1 TO phQuery:NUM-BUFFERS:
            ASSIGN cQueryString = cQueryString + 
                                  (IF i > 1 THEN ",":U ELSE "":U) + 
                                  " EACH ":U + phQuery:GET-BUFFER-HANDLE (i):NAME + " ":U +
                                  " WHERE ROWID(":U + phQuery:GET-BUFFER-HANDLE (i):NAME + ") = ? NO-LOCK ":U .
        END.     
        
        phQuery:QUERY-PREPARE (cQueryString) .
        phQuery:QUERY-OPEN () .
        
        IF cPrepareString <> ? THEN 
           phQuery:QUERY-PREPARE (cPrepareString) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the column name qualified with the first table name 
                 of the Queries buffers that contains the field name                                                                        
        Notes:   Returns ? if the field in not found in any of the queries buffers    
        @param pcColumnName The unqualified column name 
        @param phQuery The handle of the QUERY
        @return The qualified column name or ?                                                                             
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC CHARACTER QualifiedColumnName (pcColumnName AS CHARACTER,
                                                        phQuery AS HANDLE):
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.


        IF NOT VALID-HANDLE (phQuery) THEN 
            UNDO, THROW NEW AppError ("A valid query is required to qualify the column name."{&TRAN}, 0) .

        DO i = 1 TO phQuery:NUM-BUFFERS:
            ASSIGN hField = phQuery:GET-BUFFER-HANDLE (i):BUFFER-FIELD (pcColumnName) NO-ERROR .
            
            IF VALID-HANDLE (hField) THEN 
                RETURN hField:BUFFER-NAME + ".":U + hField:NAME .                          
        END.

        RETURN ? .
    END METHOD.

  /*------------------------------------------------------------------------------
      Purpose: Returns the buffername of a where clause expression. 
      Notes:   This function avoids problems with leading or double blanks in 
               where clauses.
      @param pcWhere Complete where clause for ONE table with or without the FOR keyword. The buffername must be the second token in the where clause as in "EACH order OF Customer" or if "FOR" is specified, the third token as in "FOR EACH order".
      @return The buffer name of the where clause
  ------------------------------------------------------------------------------*/
    METHOD PRIVATE STATIC CHARACTER WhereClauseBuffer (pcWhere AS CHAR):
        
        pcWhere = LEFT-TRIM(pcWhere).
    
        /* Remove double blanks */
        DO WHILE INDEX(pcWhere,"  ":U) > 0:
          pcWhere = REPLACE(pcWhere,"  ":U," ":U).
        END.
        /* Get rid of potential line break characters */   
        pcWhere = REPLACE(pcWhere, CHR(10), "":U). 
    
        RETURN (IF NUM-ENTRIES(pcWhere," ":U) > 1 
                THEN ENTRY(IF pcWhere BEGINS "FOR ":U THEN 3 ELSE 2,pcWhere," ":U)
                ELSE "":U).

    END METHOD.

END CLASS.
