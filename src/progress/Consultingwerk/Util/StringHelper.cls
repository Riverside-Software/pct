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
    File        : StringHelper
    Purpose     : Routines to support string (CHARACTER) operations
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Oct 24 12:34:34 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*            FROM PROPATH .
USING Consultingwerk.Assertion.*  FROM PROPATH .  
USING Consultingwerk.Exceptions.* FROM PROPATH .  
USING Consultingwerk.Util.*       FROM PROPATH .  
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Util.StringHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation
        Notes:   
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PRIVATE StringHelper ():
		SUPER ().
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns TRUE when the given source string ends in the ending string 
        Notes:   Equivalint to the ABL BEGINS operator / function
        @param pcSourceString The source string to check if it ends with the ending string
        @param pcEndingString The string to check if the source string ends with
        @return Logical value indicating if the given source string ends in the ending string
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL Ends (pcSourceString AS CHARACTER, 
	                                   pcEndingString AS CHARACTER):
		
		IF pcSourceString MATCHES SUBSTITUTE ("*&1":U, pcEndingString) THEN 
		    RETURN TRUE . 

		RETURN FALSE .

	END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Fixes the line ending characters of the given longchar 
        Notes:   Line Ending will be set to Consultingwerk.Environment:NewLine
        @param plcString The Longchar to fix the line ending at
        @return The Longchar value with the fixed line ending characters
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR FixLineEnding (plcString AS LONGCHAR):
		

        ASSIGN plcString = REPLACE (plcString, CHR(13), "":U)
               plcString = REPLACE (plcString, CHR(10), Environment:NewLine) .

		RETURN plcString.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the CHARACTER representation of a new UUID
        Notes:   
        @return The CHARACTER representation of the new UUID
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER GenerateUuid ():
		
        DEFINE VARIABLE rUuid       AS RAW       NO-UNDO .
        DEFINE VARIABLE cBase64Uuid AS CHARACTER NO-UNDO . 
        
        ASSIGN   
            rUuid       = GENERATE-UUID  
            cBase64Uuid = BASE64-ENCODE (rUuid).

        IF cBase64Uuid MATCHES "*==":U THEN 
            RETURN SUBSTRING (cBase64Uuid, 1, LENGTH (cBase64Uuid) - 2) .

        RETURN cBase64Uuid .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Indents a string by inserting a SPACE character at the beginning 
                 of every line
        Notes:   
        @param pcString The string to indent
        @param piIndent The number of characters to indent the string
        @return The indented string
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER Indent (pcString AS CHARACTER,  
	                                       piIndent AS INTEGER):
		
		DEFINE VARIABLE cResult AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iLines  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cLine   AS CHARACTER NO-UNDO .

        ASSIGN iLines = NUM-ENTRIES (pcString, CHR (10)) .

        DO i = 1 TO iLines:
            
            ASSIGN cLine = ENTRY (i, pcString, CHR (10)) 
                    
                   cResult = cResult + 
                             FILL (" ":U, piIndent) + 
                             cLine + 
                             (IF i < iLines THEN CHR (10) ELSE "":U) .
        END.

		RETURN cResult.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Inserts a string into another string at a give position
        Notes:   
        @param pcSourceString The source string, into which you want to insert another string
        @param piPosition The position at which you want to insert the target string
        @param pcTargetString The target string, which will be inserted into the source string
        @return The Source String with the Target string inserted
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Insert (pcSourceString AS CHARACTER, 
                                           piPosition AS INTEGER, 
                                           pcTargetString AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.

        IF piPosition > 1 THEN 
            cResult = SUBSTRING (pcSourceString, 1, piPosition - 1) .

        ASSIGN cResult = cResult + 
                         pcTargetString + 
                         SUBSTRING (pcSourceString, piPosition) .

        RETURN cResult . 

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Inserts a string into another string at a give position
        Notes:   
        @param pcSourceString The source string, into which you want to insert another string
        @param piPosition The position at which you want to insert the target string
        @param pcTargetString The target string, which will be inserted into the source string
        @return The Source String with the Target string inserted
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR Insert (pcSourceString AS LONGCHAR, 
        	                              piPosition AS INTEGER, 
        	                              pcTargetString AS CHARACTER):
		
		DEFINE VARIABLE cResult AS LONGCHAR NO-UNDO.

        IF piPosition > 1 THEN 
            cResult = SUBSTRING (pcSourceString, 1, piPosition - 1) .

        ASSIGN cResult = cResult + 
                         pcTargetString + 
                         SUBSTRING (pcSourceString, piPosition) .

        RETURN cResult . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns true when the given character is UPPERCASE 
        Notes:   
        @param pcCharacter The character to test
        @return True when the given character is UPPERCASE 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsLowercaseCharacter (pcCharacter AS CHARACTER):
        
        DEFINE VARIABLE cCharacter AS CHARACTER NO-UNDO.
        
        IF LENGTH (pcCharacter) > 0 THEN . 
        ELSE  
            UNDO, THROW NEW AppError (SUBSTITUTE ("Invalid Character &1."{&TRAN}, pcCharacter), 0) .
        
        ASSIGN cCharacter = SUBSTRING (pcCharacter, 1, 1) .
        
        RETURN ASC (cCharacter) = ASC (LC (cCharacter)) . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns true when the given character is UPPERCASE 
        Notes:   
        @param pcCharacter The character to test
        @return True when the given character is UPPERCASE 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL IsUppercaseCharacter (pcCharacter AS CHARACTER):
		
		DEFINE VARIABLE cCharacter AS CHARACTER NO-UNDO.
		
        IF LENGTH (pcCharacter) > 0 THEN . 
        ELSE  
    		UNDO, THROW NEW AppError (SUBSTITUTE ("Invalid Character &1."{&TRAN}, pcCharacter), 0) .
		
		ASSIGN cCharacter = SUBSTRING (pcCharacter, 1, 1) .
		
		RETURN ASC (cCharacter) = ASC (UPPER (cCharacter)) . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Prefixes every line in the given LONGCHAR with a given CHARACTR
        Notes:   Useful for formatted log-file output  
        @param plcLongchar The source LONGCHAR value
        @param pcPrefix The prefix to add to each line from the source LONGCHAR
        @return The new LONGCHAR value
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR PrefixLines (plcLongchar AS LONGCHAR,
	                                           pcPrefix AS CHARACTER):
		
        DEFINE VARIABLE cResult AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iLines  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cLine   AS CHARACTER NO-UNDO .

        IF IS-CODEPAGE-FIXED (plcLongchar) THEN 
            FIX-CODEPAGE (cResult) = GET-CODEPAGE (plcLongchar) . 

        ASSIGN plcLongchar = TRIM (TRIM(plcLongchar, CHR (13)), CHR(10)) . 

        ASSIGN iLines = NUM-ENTRIES (plcLongchar, CHR (10)) .

        DO i = 1 TO iLines:
            
            ASSIGN cLine = TRIM(ENTRY (i, plcLongchar, CHR (10)), CHR(13))  
                    
                   cResult = cResult + 
                             pcPrefix + 
                             cLine + 
                             Consultingwerk.Environment:NewLine .
        END.

        RETURN cResult .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes the given prefix at the beginning of the passed in String  
        Notes:   When the String does not begin with the prefix, the original string
                 is returned
        @param pcSourceString The source string to remove the prefix from
        @param pcPrefixString The prefix to remove from the source string
        @return The resulting strging without the prefix
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER RemovePrefix (pcSourceString AS CHARACTER,
	                                             pcPrefixString AS CHARACTER):
		
		IF pcSourceString BEGINS pcPrefixString THEN 
		    RETURN SUBSTRING (pcSourceString, LENGTH (pcPrefixString) + 1) .
		
		RETURN pcSourceString . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes the given suffix at the beginning of the passed in String  
        Notes:   When the String does not begin with the suffix, the original string
                 is returned
        @param pcSourceString The source string to remove the suffix from
        @param pcSuffixString The suffix to remove from the source string
        @return The resulting strging without the suffix
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER RemoveSuffix (pcSourceString AS CHARACTER,
                                                 pcSuffixString AS CHARACTER):
        
        IF StringHelper:Ends (pcSourceString, pcSuffixString) THEN 
            RETURN SUBSTRING (pcSourceString, 1, LENGTH (pcSourceString) - LENGTH (pcSuffixString)) .
        
        RETURN pcSourceString .
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes quotes from a Character String
        Notes:   
        @param pcString The source string to remove quotes
        @return The string without the quotes
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER Unquote (pcString AS CHARACTER):
		
		DEFINE VARIABLE iIndex     AS INTEGER   NO-UNDO .
		DEFINE VARIABLE cQuoteChar AS CHARACTER NO-UNDO .
		
		IF pcString = ? THEN 
		    RETURN ? .
		
		ASSIGN pcString = TRIM (pcString) .
		    
		IF LENGTH (pcString) < 2 THEN 
		    RETURN pcString .
		
		ASSIGN cQuoteChar = SUBSTRING (pcString, 1, 1) .
		
		IF cQuoteChar <> "'":U AND cQuoteChar <> "~"":U THEN 
		    RETURN pcString . 
		
		ASSIGN iIndex = R-INDEX (pcString, cQuoteChar) .
		
		IF iIndex > 1 THEN 
		    RETURN SUBSTRING (pcString, 2, iIndex - 2) .    
		    
        UNDO, THROW NEW AppError ("Unmatched QUOTE Character found in source string."{&TRAN}, 0) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes quotes from a Longchar String
        Notes:   
        @param pcString The source string to remove quotes
        @return The string without the quotes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR Unquote (pcString AS LONGCHAR):
        
        DEFINE VARIABLE iIndex     AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cQuoteChar AS CHARACTER NO-UNDO .
        
        IF pcString = ? THEN 
            RETURN ? .
        
        ASSIGN pcString = TRIM (pcString) .
            
        IF LENGTH (pcString) < 2 THEN 
            RETURN pcString .
        
        ASSIGN cQuoteChar = SUBSTRING (pcString, 1, 1) .
        
        IF cQuoteChar <> "'":U AND cQuoteChar <> "~"":U THEN 
            RETURN pcString . 
        
        ASSIGN iIndex = R-INDEX (pcString, cQuoteChar) .
        
        IF iIndex > 1 THEN 
            RETURN SUBSTRING (pcString, 2, iIndex - 2) .    
            
        UNDO, THROW NEW AppError ("Unmatched QUOTE Character found in source string."{&TRAN}, 0) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Encodes unsafe characters in a URL as per RFC 1738 section 2.2. 
                 http://ds.internic.net/rfc/rfc1738.txt 
        Notes:   See Progress K-Base 000042261, http://knowledgebase.progress.com/articles/Article/000042261
        @param pcValue Character string to encode
        @param pcEnctype Encoding option where "query", "cookie", "default" or any specified string of characters are valid
        @return Encoded string (unkown value is returned as blank) 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER UrlEncode (pcValue AS CHARACTER,
	                                          pcEnctype AS CHARACTER):
		
        DEFINE VARIABLE cHex        AS CHARACTER   NO-UNDO INITIAL "0123456789ABCDEF":U. 
        DEFINE VARIABLE cEncodeList AS CHARACTER   NO-UNDO INITIAL "query":U.
         
        DEFINE VARIABLE iCounter    AS INTEGER     NO-UNDO. 
        DEFINE VARIABLE cChar       AS INTEGER     NO-UNDO. 
         
        /* Unsafe characters that must be encoded in URL's.  See RFC 1738 Sect 2.2. */
        DEFINE VARIABLE cUnsafe   AS CHARACTER NO-UNDO 
               INITIAL " <>~"#%~{}|~\^~~[]`":U.
         
        /* Reserved characters that normally are not encoded in URL's */
        DEFINE VARIABLE cReserved AS CHARACTER NO-UNDO 
               INITIAL "~;/?:@=&":U.
         
        /* Don't bother with blank or unknown */ 
        IF LENGTH(pcValue) = 0 OR pcValue = ? THEN 
            RETURN "":U. 
         
        /* What kind of encoding should be used? */ 
        CASE pcEnctype: 
            WHEN "query":U THEN /* QUERY_STRING name=value parts */ 
                cEncodeList = cUnsafe + cReserved + "+":U. 
            WHEN "cookie":U THEN /* Persistent Cookies */ 
                cEncodeList = cUnsafe + " ,~;":U. 
            WHEN "default":U OR WHEN "":U THEN /* Standard URL encoding */ 
                cEncodeList = cUnsafe. 
            OTHERWISE 
                cEncodeList = cUnsafe + pcEnctype. /* user specified ... */ 
        END CASE. 
         
        /* Loop through entire input string */ 
        iCounter = 0. 
        DO WHILE TRUE: 
            ASSIGN iCounter = iCounter + 1 
                   /* ASCII value of character using single byte codepage */ 
                   cChar = ASC(SUBSTRING(pcValue, iCounter, 1, "RAW":U), 
                               "1252":U, 
                               "1252":U). 
            IF cChar LE 31  OR 
               cChar GE 127 OR 
               INDEX(cEncodeList, CHR(cChar)) GT 0 THEN DO: 
                   /* Replace character with %hh hexidecimal triplet */ 
                   SUBSTRING(pcValue, iCounter, 1, "RAW":U) = "%":U + 
                      SUBSTRING(cHex, INTEGER(TRUNCATE(cChar / 16, 0)) + 1, 1, "RAW":U) + /* high */ 
                      SUBSTRING(cHex, cChar MODULO 16 + 1, 1, "RAW":U). /* low digit */ 
          
                   iCounter = iCounter + 2. /* skip over hex triplet just inserted */ 
            END. 
            IF iCounter EQ LENGTH(pcValue,"RAW":U) THEN LEAVE. 
        END. 

        RETURN pcValue . 
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Turns a CamelCased string into a well formed sentence (Camel Cased) 
        Notes:   
        @param pcSource The source String
        @return The well formed string
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER WellFormFromCamelCase (pcSource AS CHARACTER):
		
		DEFINE VARIABLE cResult AS CHARACTER NO-UNDO .
		DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
		
		ASSIGN cResult = SUBSTRING (pcSource, 1, 1) .
		
		DO i = 2 TO LENGTH (pcSource):
		    
		     IF SUBSTRING (pcSource, i, 1) <> " ":U AND 
                SUBSTRING (pcSource, i - 1, 1) <> " ":U AND
		        IsUppercaseCharacter (SUBSTRING (pcSource, i, 1)) AND 
		        IsLowercaseCharacter (SUBSTRING (pcSource, i - 1, 1)) THEN 
		          
		         cResult = cResult + " ":U . 
		
		     ASSIGN cResult = cResult + SUBSTRING (pcSource, i, 1) .
        END .

		RETURN cResult .

	END METHOD .

END CLASS.
