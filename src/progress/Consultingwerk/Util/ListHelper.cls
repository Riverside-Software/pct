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
    File        : ListHelper
    Purpose     : Provides support for Character delimited lists
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Jan 10 21:19:01 CET 2010
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.Util.*                  FROM PROPATH . 
USING Consultingwerk.Framework.Collections.* FROM PROPATH . 
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Util.ListHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ListHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Checks a string against a list of one or more string matching patterns 
        Notes:   ABL CAN-DO like function, restoring the pre OE11.0 behaviour. In OE11.0    
                 CAN-DO has changed it's behaviour due to the support for multi-tenancy  
                 Currently the support for negative matches (! character) is not implemented 
        @param pcMatchesList The list of matching patterns
        @param pcString The string to verify
        @return The function returns TRUE if the specified string matches an entry from the list 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL CanDo (pcMatchesList AS CHARACTER,
	                                    pcString AS CHARACTER):

        DEFINE VARIABLE i        AS INTEGER   NO-UNDO .
		DEFINE VARIABLE cPattern AS CHARACTER NO-UNDO .
		
		IF INDEX (pcMatchesList, "*":U) = 0 THEN 
		    RETURN ListHelper:EntryIsInList (pcString, pcMatchesList) .
		
        DO i = 1 TO NUM-ENTRIES (pcMatchesList):
            
            ASSIGN cPattern = ENTRY (i, pcMatchesList) .
            
            IF pcString MATCHES cPattern THEN 
                RETURN TRUE .  
        END.
        
        RETURN FALSE . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns if a String is contained in a comma delimited list
        Notes:   As the ABL CAN-DO function is reserved for checking an ID against a 
                 list of ID patterns and was never intended for string/list matching
                 this method shoudl be used in many functiony, where the CAN-DO function
                 was falsely used. In OE11.0 the CAN-DO function has changed it's behaviour
                 when using the @ character in one of the arguments
                 See: http://communities.progress.com/pcom/message/173455
        @param pcString The String to locate in the list
        @param pcList The comma delimited list
        @return Logical value indicating if the String is contained in the comma delimited list
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL EntryIsInList (pcString AS CHARACTER,
	                                            pcList AS CHARACTER):
		
		RETURN (LOOKUP (pcString, pcList) > 0 ).

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns if a String is contained in a delimited list
        Notes:   As the ABL CAN-DO function is reserved for checking an ID against a 
                 list of ID patterns and was never intended for string/list matching
                 this method shoudl be used in many functiony, where the CAN-DO function
                 was falsely used. In OE11.0 the CAN-DO function has changed it's behaviour
                 when using the @ character in one of the arguments
                 See: http://communities.progress.com/pcom/message/173455 
        @param pcString The String to locate in the list
        @param pcList The comma delimited list
        @param pcDelimiter The list delimited
        @return Logical value indicating if the String is contained in the delimited list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL EntryIsInList (pcString AS CHARACTER,
                                                pcList AS CHARACTER,
                                                pcDelimiter AS CHARACTER):
        
        RETURN (LOOKUP (pcString, pcList, pcDelimiter) > 0 ).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Expands a List pattern  
        Notes:   Every entry in the pattern list that contains a "*" wild-card character
                 will be expanded with all matching entries from the source list
        @param pcPatternList The list with the pattern
        @param pcSourceList The list with all possible entries
        @return The expanded pattern list 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ExpandListEntries (pcPatternList AS CHARACTER,
                                                      pcSourceList AS CHARACTER):

        RETURN ListHelper:ExpandListEntries (pcPatternList, 
                                             pcSourceList, 
                                             ",":U) .        

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Expands a List pattern  
        Notes:   Every entry in the pattern list that contains a "*" wild-card character
                 will be expanded with all matching entries from the source list
        @param pcPatternList The list with the pattern
        @param pcSourceList The list with all possible entries
        @param pcDelimiter The delimiter for both lists
        @return The expanded pattern list 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER ExpandListEntries (pcPatternList AS CHARACTER,
                                                      pcSourceList AS CHARACTER,
                                                      pcDelimiter AS CHARACTER):
		
        DEFINE VARIABLE cReturn      AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cEntry       AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cSourceEntry AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i            AS INTEGER   NO-UNDO .
        DEFINE VARIABLE j            AS INTEGER   NO-UNDO .
        
        DO i = 1 TO NUM-ENTRIES (pcPatternList, pcDelimiter) ON ERROR UNDO, THROW:

            ASSIGN cEntry = ENTRY (i, pcPatternList, pcDelimiter) .

            IF INDEX (cEntry, "*":U) > 0 THEN DO ON ERROR UNDO, THROW:
            
                DO j = 1 TO NUM-ENTRIES (pcSourceList, pcDelimiter) ON ERROR UNDO, THROW:
                
                    ASSIGN cSourceEntry = ENTRY (j, pcSourceList, pcDelimiter) .
                    
                    IF cSourceEntry MATCHES cEntry THEN         
                        ASSIGN cReturn = cReturn + (IF cReturn > "":U THEN pcDelimiter ELSE "":U) + cSourceEntry  .
                END.
            END.
            ELSE 
                IF LOOKUP (cEntry, pcSourceList) > 0 THEN 
                    ASSIGN cReturn = cReturn + (IF cReturn > "":U THEN pcDelimiter ELSE "":U) + cEntry .
        END.

        RETURN cReturn .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Inserts an Entry (or a list of Entries) into a List at position                                                                      
        Notes:  
        @param pcSourceList The source list 
        @param piPosition The position the pcNewEntry should be inserted at
        @param pcNewEntry The entry to insert at piPositon                                                                
        @param pcSeparator The list-separator to for other lists
        @return The new LONGCHAR List
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR InsertEntry (pcSourceList AS LONGCHAR,
                                               piPosition AS INTEGER,
                                               pcNewEntry AS CHARACTER,
                                               pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cBefore AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE cAfter  AS LONGCHAR NO-UNDO.

        IF piPosition > 1 THEN 
            ASSIGN cBefore = ListHelper:ListToEntry (pcSourceList, piPosition - 1, pcSeparator) .

        IF piPosition <= NUM-ENTRIES (pcSourceList, pcSeparator) THEN 
            ASSIGN cAfter = ListHelper:ListStartingEntry (pcSourceList, piPosition, pcSeparator) .

        RETURN cBefore + 
               (IF cBefore > "":U THEN pcSeparator ELSE "":U) +
               pcNewEntry +
               (IF cAfter > "":U THEN pcSeparator ELSE "":U) +
               cAfter.
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Inserts an Entry (or a list of Entries) into a List at position                                                                        
        Notes:  
        @param pcSourceList The source list    
        @param piPosition The position the pcNewEntry should be inserted at
        @param pcNewEntry The entry to insert at piPositon                                                                  
        @param pcSeparator The list-separator to for other lists
        @return The new CHARACTER List
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER InsertEntry (pcSourceList AS CHARACTER,
                                                piPosition AS INTEGER,
                                                pcNewEntry AS CHARACTER,
                                                pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cBefore AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAfter  AS CHARACTER NO-UNDO.

        IF piPosition > 1 THEN 
            ASSIGN cBefore = ListHelper:ListToEntry (pcSourceList, piPosition - 1, pcSeparator) .

        IF piPosition <= NUM-ENTRIES (pcSourceList, pcSeparator) THEN 
            ASSIGN cAfter = ListHelper:ListStartingEntry (pcSourceList, piPosition, pcSeparator) .

        RETURN SUBSTITUTE ("&1&2&3&4&5":U,
                           cBefore,
                           (IF cBefore > "":U THEN pcSeparator ELSE "":U),
                           pcNewEntry,
                           (IF cAfter > "":U THEN pcSeparator ELSE "":U),
                           cAfter) .
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Inserts an Entry (or a list of Entries) into a List at position                                                                      
        Notes:   Defaults to "," as the list delimiter
        @param pcSourceList The source list 
        @param piPosition The position the pcNewEntry should be inserted at
        @param pcNewEntry The entry to insert at piPositon                                                                
        @return The new LONGCHAR List
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR InsertEntry (pcSourceList AS LONGCHAR,
                                               piPosition AS INTEGER,
                                               pcNewEntry AS CHARACTER):
        
        RETURN ListHelper:InsertEntry (pcSourceList,
                                       piPosition,
                                       pcNewEntry,
                                       ",":U) .
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Inserts an Entry (or a list of Entries) into a List at position                                                                      
        Notes:   Defaults to "," as the list delimiter
        @param pcSourceList The source list 
        @param piPosition The position the pcNewEntry should be inserted at
        @param pcNewEntry The entry to insert at piPositon
        @return The new CHARACTER list                                                                
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER InsertEntry (pcSourceList AS CHARACTER,
                                                piPosition AS INTEGER,
                                                pcNewEntry AS CHARACTER):
        
        RETURN ListHelper:InsertEntry (pcSourceList,
                                       piPosition,
                                       pcNewEntry,
                                       ",":U) .
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a List of those Entries from the total list that are NOT 
                 contained in the matching list 
        Notes:   
        @param pcTotalList The total list of entries
        @param pcMatchingList The list of match with the total list
        @return The list of entries of the total list that are not contained in the matching list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ListEntriesNotContainedInList (pcTotalList AS CHARACTER,
                                                                  pcMatchingList AS CHARACTER):
        
        RETURN ListEntriesNotContainedInList (pcTotalList,
                                              pcMatchingList,
                                              ?) .
                                              
    END.                                                                      
                                                                      
    /*------------------------------------------------------------------------------
        Purpose: Returns a List of those Entries from the total list that are NOT 
                 contained in the matching list 
        Notes:   
        @param pcTotalList The total list of entries
        @param pcMatchingList The list of match with the total list
        @param pcDelimiter The delimiters used in both lists
        @return The list of entries of the total list that are not contained in the matching list
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER ListEntriesNotContainedInList (pcTotalList AS CHARACTER,
	                                                              pcMatchingList AS CHARACTER,
	                                                              pcDelimiter AS CHARACTER):
		
		DEFINE VARIABLE cResult AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cEntry  AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        
        IF pcDelimiter > "":U THEN . 
        ELSE pcDelimiter = ",":U . 
        

		DO i = 1 TO NUM-ENTRIES (pcTotalList, pcDelimiter) ON ERROR UNDO, THROW:
		    ASSIGN cEntry = ENTRY (i, pcTotalList, pcDelimiter) .
		    
		    IF LOOKUP (cEntry, pcMatchingList, pcDelimiter) > 0 THEN . 
            ELSE
		        cResult = SUBSTITUTE ("&1&2&3":U,
		                              cResult,
		                              pcDelimiter,
		                              cEntry) .    
		END.
		
		RETURN  TRIM (cResult, pcDelimiter) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list starting from the 
                 piStart Entry                                                                        
        Notes:                  
        @param pcList The source list
        @param piStart The starting index form the source list for entries getting into the target list
        @param pcSeparator The list-separator to for other lists
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR ListStartingEntry (pcList AS LONGCHAR,
                                                     piStart AS INTEGER,
                                                     pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cRet   AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE i      AS INTEGER  NO-UNDO.
        DEFINE VARIABLE iCount AS INTEGER  NO-UNDO.
        
        IF NUM-ENTRIES (pcList, pcSeparator) < piStart THEN RETURN "":U .
        
        ASSIGN iCount = NUM-ENTRIES (pcList, pcSeparator) .
        
        DO i = piStart TO iCount:
            
            IF i > piStart THEN ASSIGN cRet = cRet + pcSeparator .
            
            ASSIGN cRet = cRet + ENTRY (i, pcList, pcSeparator) .               
        END.
        
        RETURN cRet.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list starting from the 
                 piStart Entry                                                                        
        Notes:                  
        @param pcList The source list
        @param piStart The starting index form the source list for entries getting into the target list
        @param pcSeparator The list-separator to for other lists
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ListStartingEntry (pcList AS CHARACTER,
                                                      piStart AS INTEGER,
                                                      pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cRet   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iCount AS INTEGER   NO-UNDO.
        
        IF NUM-ENTRIES (pcList, pcSeparator) < piStart THEN RETURN "":U .
        
        ASSIGN iCount = NUM-ENTRIES (pcList, pcSeparator) .
        
        DO i = piStart TO iCount:
            
            IF i > piStart THEN ASSIGN cRet = cRet + pcSeparator .
            
            ASSIGN cRet = cRet + ENTRY (i, pcList, pcSeparator) .                
        END.
        
        RETURN cRet.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list starting from the 
                 piStart Entry                                                                        
        Notes:   Defaults to "," as the list delimiter                  
        @param pcList The source list
        @param piStart The starting index form the source list for entries getting into the target list
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR ListStartingEntry (pcList AS LONGCHAR,
                                                     piStart AS INTEGER):
        
        RETURN ListHelper:ListStartingEntry (pcList, piStart, ",":U) .                                                  
    END.  
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list starting from the 
                 piStart Entry                                                                        
        Notes:   Defaults to "," as the list delimiter                  
        @param pcList The source list
        @param piStart The starting index form the source list for entries getting into the target list
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ListStartingEntry (pcList AS CHARACTER,
                                                      piStart AS INTEGER):
        
        RETURN ListHelper:ListStartingEntry (pcList, piStart, ",":U) .                                                  
    END.                                                          

    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list up to the 
                 piTo Entry                                                                        
        Notes:                  
        @param pcList The source list
        @param piTo The last index form the source list for entries getting into the target list
        @param pcSeparator The list-separator to for other lists
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR ListToEntry (pcList AS LONGCHAR,
                                               piTo AS INTEGER,
                                               pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cRet   AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE i      AS INTEGER  NO-UNDO.
        DEFINE VARIABLE iCount AS INTEGER  NO-UNDO.
        
        ASSIGN iCount = MIN (NUM-ENTRIES (pcList, pcSeparator), piTo) .
        
        DO i = 1 TO iCount:
            
            IF i > 1 THEN ASSIGN cRet = cRet + pcSeparator .
            
            ASSIGN cRet = cRet + ENTRY (i, pcList, pcSeparator) .               
        END.
        
        RETURN cRet.
        
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list up to the 
                 piTo Entry                                                                        
        Notes:                  
        @param pcList The source list
        @param piTo The last index form the source list for entries getting into the target list
        @param pcSeparator The list-separator to for other lists
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ListToEntry (pcList AS CHARACTER,
                                                piTo AS INTEGER,
                                                pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cRet   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iCount AS INTEGER   NO-UNDO.
        
        ASSIGN iCount = MIN (NUM-ENTRIES (pcList, pcSeparator), piTo) .
        
        DO i = 1 TO iCount:
            
            IF i > 1 THEN ASSIGN cRet = cRet + pcSeparator .
            
            ASSIGN cRet = cRet + ENTRY (i, pcList, pcSeparator) .               
        END.
        
        RETURN cRet.
        
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list up to the 
                 piTo Entry                                                                        
        Notes:   Defaults to "," as the list delimiter                  
        @param pcList The source list
        @param piTo The last index form the source list for entries getting into the target list
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR ListToEntry (pcList AS LONGCHAR,
                                               piTo AS INTEGER):
        
        RETURN ListHelper:ListToEntry (pcList,
                                       piTo,
                                       " ":U) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a list with all entries of the source list up to the 
                 piTo Entry                                                                        
        Notes:   Defaults to "," as the list delimiter                  
        @param pcList The source list
        @param piTo The last index form the source list for entries getting into the target list
        @return The target list
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ListToEntry (pcList AS CHARACTER,
                                                piTo AS INTEGER):
        
        RETURN ListHelper:ListToEntry (pcList,
                                       piTo,
                                       " ":U) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Removes an Entry from the List                                                                       
        Notes:                                  
        @param pcList The source list
        @param piEntry the list index to be removed
        @param pcSeparator The optional separator for the list
        @return The list without the given entry                                      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR RemoveEntry  (pcList      AS LONGCHAR,
                                                piEntry     AS INTEGER,
                                                pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cReturn AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iCount  AS INTEGER  NO-UNDO.
        DEFINE VARIABLE i       AS INTEGER  NO-UNDO.

        ASSIGN iCount = NUM-ENTRIES (pcList, pcSeparator) .
        
        /* When the list is shorter then piEntry entries, return the list */
        IF iCount < piEntry THEN 
            RETURN pcList .

        DO i = 1 TO NUM-ENTRIES (pcList, pcSeparator):
            
            IF i = piEntry THEN NEXT . 
            
            ASSIGN cReturn = cReturn + 
                             (IF cReturn > "":U THEN pcSeparator ELSE "":U) +
                             ENTRY (i, pcList, pcSeparator) .
        END.

        RETURN cReturn .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Removes an Entry from the List                                                                        
        Notes:                                  
        @param pcList The source list
        @param piEntry the list index to be removed
        @param pcSeparator The optional separator for the list
        @return The list without the given entry                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER RemoveEntry  (pcList      AS CHARACTER,
                                                 piEntry     AS INTEGER,
                                                 pcSeparator AS CHARACTER):
        
        DEFINE VARIABLE cReturn AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iCount  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.

        ASSIGN iCount = NUM-ENTRIES (pcList, pcSeparator) .
        
        /* When the list is shorter then piEntry entries, return the list */
        IF iCount < piEntry THEN 
            RETURN pcList .

        DO i = 1 TO NUM-ENTRIES (pcList, pcSeparator):
            
            IF i = piEntry THEN NEXT . 
            
            ASSIGN cReturn = cReturn + 
                             (IF cReturn > "":U THEN pcSeparator ELSE "":U) +
                             ENTRY (i, pcList, pcSeparator) .
        END.

        RETURN cReturn .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Removes an Entry from the List                                                                       
        Notes:   Defaults to "," as the list delimiter                  
        @param pcList The source list
        @param piEntry the list index to be removed
        @return The list without the given entry                                      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR RemoveEntry  (pcList AS LONGCHAR,
                                                piEntry AS INTEGER):
        
        RETURN ListHelper:RemoveEntry (pcList, piEntry, ",":U) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Removes an Entry from the List                                                                       
        Notes:   Defaults to "," as the list delimiter                  
        @param pcList The source list
        @param piEntry the list index to be removed
        @return The list without the given entry                                      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER RemoveEntry  (pcList AS CHARACTER,
                                                 piEntry AS INTEGER):
        
        RETURN ListHelper:RemoveEntry (pcList, piEntry, ",":U) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: TRIM's every individual entry from a delimited list
        Notes:   
        @param pcList The List to TRIM all entries in
        @param pcDelimiter The List delimiter
        @return The list which all entries TRIM'ed 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER TrimEntries (pcList AS CHARACTER,
	                                            pcDelimiter AS CHARACTER):
		
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        
        DO i = 1 TO NUM-ENTRIES (pcList, pcDelimiter):
            ASSIGN ENTRY (i, pcList, pcDelimiter) = TRIM (ENTRY (i, pcList, pcDelimiter)) .
        END.

        RETURN pcList .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: TRIM's every individual entry from a delimited list
        Notes:   Uses the default delimiter of ,
        @param pcList The List to TRIM all entries in
        @return The list which all entries TRIM'ed 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER TrimEntries (pcList AS CHARACTER):
        
        RETURN ListHelper:TrimEntries (pcList, ",":U).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: TRIM's every individual entry from a delimited list
        Notes:   
        @param pcList The List to TRIM all entries in
        @param pcDelimiter The List delimiter
        @return The list which all entries TRIM'ed 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR TrimEntries (pcList AS LONGCHAR,
                                               pcDelimiter AS CHARACTER):
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        
        DO i = 1 TO NUM-ENTRIES (pcList, pcDelimiter):
            ASSIGN ENTRY (i, pcList, pcDelimiter) = TRIM (ENTRY (i, pcList, pcDelimiter)) .
        END.

        RETURN pcList .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: TRIM's every individual entry from a delimited list
        Notes:   Uses the default delimiter of ,
        @param pcList The List to TRIM all entries in
        @return The list which all entries TRIM'ed 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR TrimEntries (pcList AS LONGCHAR):
        
        RETURN ListHelper:TrimEntries (pcList, ",":U).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Verifies if a delimited list has only unique entries  
        Notes:   Defaults to the comma as the list delimiter
        @param pcList The delimited list
        @return Logical value indicating if the list has only unique entries
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL VerifyUniqueEntries (pcList AS CHARACTER):
        
        RETURN ListHelper:VerifyUniqueEntries (pcList, ",":U) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Verifies if a delimited list has only unique entries  
        Notes:   The empty list is considered to only has unique entries
        @param pcList The delimited list
        @param pcDelimiter The list delimiter
        @return Logical value indicating if the list has only unique entries
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL VerifyUniqueEntries (pcList AS CHARACTER,
	                                                  pcDelimiter AS CHARACTER):
		
        DEFINE VARIABLE iEntries AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iStart   AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iEntry   AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cEntry   AS CHARACTER NO-UNDO .
		
		/* Empty list has only unique entries */
		IF pcList = "":U THEN 
		    RETURN TRUE . 
		
		IF NUM-ENTRIES (pcList, pcDelimiter) = 1 THEN 
		    RETURN TRUE . 
		
		ASSIGN iEntries = NUM-ENTRIES (pcList, pcDelimiter) .
		
		DO iStart = 1 TO iEntries - 1:
            
            ASSIGN cEntry = ENTRY (iStart, pcList, pcDelimiter) .
		    
		    DO iEntry = iStart + 1 TO iEntries:
		        
		        IF cEntry = ENTRY (iEntry, pcList, pcDelimiter) THEN 
		            RETURN FALSE . 
		    END .
		END.    
		
		RETURN TRUE .

	END METHOD .
            
END CLASS.
