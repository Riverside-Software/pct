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
    File        : FileAssert
    Purpose     : Provides routines for validating file system files
    Syntax      : 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Jan 01 19:50:05 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Assertion.* FROM PROPATH .  
USING Progress.Lang.*            FROM PROPATH .

CLASS Consultingwerk.Assertion.FileAssert: 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the FileAssert class
        Notes:   Disallow instance creation   
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PRIVATE FileAssert ():
		SUPER ().
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Verifies that the file exists
        Notes:   
        Throws:  Consultingwerk.Assertion.AssertException            
        @param pcFileName The file name to verify
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID Exists (pcFileName AS CHARACTER):
		
        FILE-INFO:FILE-NAME = pcFileName . 
        IF FILE-INFO:FULL-PATHNAME = ? THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Invalid file name: &1":U, 
                                                         pcFileName),
                                             0) .
	END METHOD .

END CLASS.
