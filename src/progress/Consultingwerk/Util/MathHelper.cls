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
    File        : MathHelper
    Purpose     : Provides support for mathematical operations
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Dec 12 20:18:52 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Util.MathHelper: 
    
	/*------------------------------------------------------------------------------
		Purpose: Disallow instance creation 																	  
		Notes:  																	  
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC MathHelper ():
		SUPER ().
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Performs a bitwise AND operation
        Notes:                                   
        @param piValue1 The first operand
        @param piValue2 The second operand
        @return The resulting value                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INT64 And (piValue1 AS INT64, 
                                    piValue2 AS INT64): 

        DEFINE VARIABLE iReturn AS INT64   NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER NO-UNDO .
    
        DO i = 1 TO 64:
    
            PUT-BITS (iReturn, i, 1) = (IF  GET-BITS(piValue1, i, 1) = 1
                                        AND GET-BITS(piValue2, i, 1) = 1 THEN 1 ELSE 0).
    
        END. 
    
        RETURN iReturn.
    
    END METHOD. 

    /*------------------------------------------------------------------------------
        Purpose: Converts a hexdecimal string expression into the Integet value
        Notes:                                   
        @param pcHex The hexadecimal value 
        @return The resulting integer value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INT64 Hex2Int (pcHex AS CHARACTER):
    
        DEFINE VARIABLE iPos         AS INTEGER NO-UNDO .
        DEFINE VARIABLE iOffset      AS INTEGER NO-UNDO .
        DEFINE VARIABLE lNegative    AS LOGICAL NO-UNDO .
    
        DEFINE VARIABLE iReturn      AS INT64   NO-UNDO .
        DEFINE VARIABLE i            AS INTEGER NO-UNDO .
    
        IF pcHex = ? THEN RETURN ?.
    
        IF pcHex BEGINS "-":U THEN 
            ASSIGN 
                SUBSTRING  (pcHex, 1, 1)   = "":U
                lNegative                  = YES .
        
        IF pcHex BEGINS "0x":U THEN
            SUBSTRING (pcHex, 1, 2) = "":U.
    
        ASSIGN
            iPos    = LENGTH (pcHex)
            iOffset = 1.
    
        REPEAT WHILE iPos >= 1:
    
            i = INDEX ("0123456789ABCDEF":U, 
                       SUBSTRING (pcHex, iPos, 1)) - 1.
    
            IF i = -1 THEN 
                UNDO, THROW NEW InvalidParameterValueException ("pcHex":U, 
                                                                pcHex, 
                                                                "Consultingwerk.Util.MathHelper":U).
    
            PUT-BITS (iReturn, iOffset, 4) = i.
    
            ASSIGN 
                iPos    = iPos - 1
                iOffset = iOffset + 4.
    
        END . /* repeat */
    
        RETURN (IF lNegative THEN -1 * iReturn ELSE iReturn).
    
    END METHOD . 

    /*------------------------------------------------------------------------------
        Purpose: Converts a hexdecimal string expression into the Integet value
        Notes:                                   
        @param piInt The hexadecimal value 
        @return The resulting integer value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Int2Hex (piInt AS INT64):
    
        DEFINE VARIABLE iOffset      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE lNegative    AS LOG       NO-UNDO.
    
        DEFINE VARIABLE cReturn      AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
    
        IF piInt = ? THEN RETURN ?.
    
        IF piInt < 0 THEN
    
        ASSIGN
            piInt       = ABS (piInt)
            lNegative   = YES.
    
        iOffset = 61 .
    
        REPEAT WHILE iOffset >= 1:
    
            i = GET-BITS (piInt, iOffset, 4).
    
            IF NOT (i = 0 AND cReturn = "":U) THEN
    
                cReturn = cReturn + SUBSTR ("0123456789ABCDEF":U, i + 1, 1). 
    
            iOffset = iOffset - 4.
    
        END. 
    
        RETURN (IF lNegative THEN "-":U ELSE "":U) + 
               (IF cReturn = "":U THEN "0":U ELSE cReturn).
    
    END METHOD . 

    /*------------------------------------------------------------------------------
        Purpose: Performs a bitwise NOT operation
        Notes:                                   
        @param piValue The value to be processed 
        @return The resulting value                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INT64 Not (piValue AS INT64): 
    
        DEFINE VARIABLE iReturn AS INT64   NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER NO-UNDO .
    
        DO i = 1 TO 64:
    
            PUT-BITS (iReturn, i, 1) = (IF GET-BITS (piValue, i, 1) = 1 THEN 0 ELSE 1).
    
        END . 
    
        RETURN iReturn .
    
    END METHOD . 
        
    /*------------------------------------------------------------------------------
        Purpose: Performs a bitwise OR operation
        Notes:                                   
        @param piValue1 The first operand
        @param piValue2 The second operand
        @return The resulting value                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INT64 Or (piValue1 AS INT64, 
                                   piValue2 AS INT64): 

        DEFINE VARIABLE iReturn AS INT64   NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER NO-UNDO .
    
        DO i = 1 TO 64:
    
            PUT-BITS (iReturn, i, 1) = (IF GET-BITS (piValue1, i, 1) = 1
                                        OR GET-BITS (piValue2, i, 1) = 1 THEN 1 ELSE 0).
    
        END. 
    
        RETURN iReturn .
    
    END METHOD. 
    
	/*------------------------------------------------------------------------------
	   Purpose: Rounds up a number if it's not already an integer 
	   Notes:   Negative numbers will actually be rounded down, i.o.w. Roundup (-1.5) 
	            will return -2, so that the absolute value will be rounded up
	   @param pdeNumber The number to round up
	   @return The rounded value
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC INT64 Roundup (pdeNumber AS DECIMAL):
		
		DEFINE VARIABLE deHalf AS DECIMAL NO-UNDO.
		
		IF pdeNumber = ROUND (pdeNumber, 0) THEN 
		    RETURN INT64 (pdeNumber) . 
		
		IF pdeNumber > 0 THEN deHalf = .5 .
		ELSE 
		    deHalf = -.5 .
		
        RETURN INT64 (ROUND (pdeNumber + deHalf, 0)) .

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Performs a bitwise XOR operation
        Notes:                                   
        @param piValue1 The first operand
        @param piValue2 The second operand
        @return The resulting value                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INT64 Xor (piValue1 AS INT64, 
                                    piValue2 AS INT64): 
    
        DEFINE VARIABLE iReturn AS INT64   NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER NO-UNDO .
    
        DO i = 1 TO 64:
            
            PUT-BITS (iReturn, i, 1) = (IF GET-BITS (piValue1, i, 1) = 1
                                        OR GET-BITS (piValue2, i, 1) = 1 
    
                               AND NOT (GET-BITS (piValue1, i, 1) = 1
                                    AND GET-BITS (piValue2, i, 1) = 1)
    
                    THEN 1 ELSE 0).
    
        END . 
    
        RETURN iReturn .
    
    END METHOD . 

END CLASS.
