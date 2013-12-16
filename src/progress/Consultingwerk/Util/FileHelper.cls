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
    File        : FileHelper
    Purpose     : File System Helper methods 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Jun 26 11:07:56 CEST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Assertion.*  FROM PROPATH . 
USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Consultingwerk.Util.*       FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Util.FileHelper: 

    {Consultingwerk/Util/TempTables/ttFileNames.i &ACCESS=STATIC}

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE FileHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Copies files from one path to a target directory                                                                        
        Notes:                      
        @param pcSourcePath The source file path 
        @param pcFileMask A comma-delimited list of file patterns to copy (e.g. *.xml,*.resx)
        @param pcTargetPath The directory to copy into
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID CopyFiles (pcSourcePath AS CHARACTER,
                                         pcFileMask AS CHARACTER,
                                         pcTargetPath AS CHARACTER):
        
        DEFINE VARIABLE cMask     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFile     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFileName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cRelative AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTarget   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i         AS INTEGER   NO-UNDO.

        FILE-INFO:FILE-NAME = pcSourcePath . 
        IF FILE-INFO:FULL-PATHNAME > "":U THEN 
            ASSIGN pcSourcePath = FILE-INFO:FULL-PATHNAME . 
        ELSE 
            UNDO, THROW NEW InvalidParameterValueException ("pcSourcePath":U,
                                                            pcSourcePath,
                                                            "Consultingwerk.Util.FileHelper":U) .

        FILE-INFO:FILE-NAME = pcTargetPath . 
        IF FILE-INFO:FULL-PATHNAME > "":U THEN 
            ASSIGN pcTargetPath = FILE-INFO:FULL-PATHNAME . 
        ELSE 
            UNDO, THROW NEW InvalidParameterValueException ("pcTargetPath":U,
                                                            pcTargetPath,
                                                            "Consultingwerk.Util.FileHelper":U) .

        DO i = 1 TO NUM-ENTRIES (pcFileMask) ON ERROR UNDO, THROW:
            ASSIGN cMask = ENTRY (i, pcFileMask) . 
            
            IF cMask > "":U THEN . 
            ELSE NEXT . 

            EMPTY TEMP-TABLE ttFileNames .
    
            /* Get a list of files to compile */
            Consultingwerk.Util.FileHelper:GetFileList (pcSourcePath, 
                                                        cMask,
                                                        OUTPUT TABLE ttFileNames BY-REFERENCE) .
        
            FOR EACH ttFileNames ON ERROR UNDO, THROW:

                ASSIGN cFile     = REPLACE (ttFileNames.FileName, "~\":U, "/":U)
                       cRelative = SUBSTRING (SUBSTRING (cFile, 1, R-INDEX (cFile, "/":U) - 1),
                                              LENGTH (pcSourcePath) +  2)
                       cFileName = SUBSTRING (cFile, R-INDEX (cFile, "/":U) + 1).

                IF cRelative > "":U THEN 
                    cTarget = pcTargetPath + "/":U + cRelative . 
                ELSE 
                    cTarget = pcTargetPath . 

                ASSIGN cTarget = REPLACE (cTarget, "~\":U, "/":U).

                FILE-INFO:FILE-NAME = cTarget . 
                IF FILE-INFO:FULL-PATHNAME > "":U THEN . 
                ELSE 
                    Consultingwerk.Util.FileHelper:CreateDirectory (cTarget) .
                
                &IF DEFINED (DotNetAccessible) NE 0 &THEN
                System.IO.File:Copy (cFile, REPLACE (cTarget, "/":U, "~\":U) + "~\":U + cFileName, TRUE) .
                System.IO.File:SetAttributes (REPLACE (cTarget, "/":U, "~\":U) + "~\":U + cFileName, 
                                              System.IO.FileAttributes:Normal) .
                
                &ELSE
                OS-COPY VALUE (cFile) VALUE (cTarget) .
                IF OS-ERROR > 0 THEN 
                    UNDO, THROW NEW OsErrorException (OS-ERROR) .                 
                &ENDIF
            END.
        END.


    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Creates all directories and subdirectories in the specified path.                                                                        
        Notes:     
        @param pcPath The path to create
        @return 0 when success otherwise 999 on windows (Exception) or the OS-ERROR on UNIX                                                                         
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER CreateDirectory (pcPath AS CHARACTER):

        DEFINE VARIABLE iPos AS INTEGER NO-UNDO INIT 2.
        
        &IF DEFINED (DotNetAccessible) NE 0 &THEN
        System.IO.Directory:CreateDirectory (REPLACE (pcPath, "/":U, "~\":U)) .
    
        RETURN 0 . 
        
        CATCH err AS System.Exception:
            RETURN 999 .
        END CATCH.
        &ELSE
        ASSIGN pcPath = REPLACE (pcPath, "~\":U, "/":U) .
        
        iPos = INDEX (pcPath, "/":U, iPos) .

        DO WHILE iPos > 0:
            OS-CREATE-DIR VALUE (SUBSTRING (pcPath, 1, iPos - 1)) .
            
            iPos = INDEX (pcPath, "/":U, iPos + 1) .  
        END.
        &ENDIF

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the directory portion of a file name, absolutely of relatively 
        Notes:   
        @param pcFileName The base file name 
        @return The directory portion of the file name 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER DirectoryName (pcFileName AS CHARACTER):
		
        DEFINE VARIABLE iIndex AS INTEGER NO-UNDO.
        
        IF OPSYS = "MS-DOS":U OR OPSYS = "WIN32":U THEN 
            ASSIGN pcFileName = REPLACE (pcFileName, "~\":U, "/":U) .

        iIndex = R-INDEX (pcFileName, "/":U) .

        IF iIndex > 1 THEN 
            RETURN SUBSTRING (pcFileName, 1, iIndex - 1) .
            
        RETURN pcFileName .             

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns True when the file can be found in the PROPATH                                                                        
        Notes:                              
        @param pcFileName The file name to search
        @return Logical value indicating if the file can be found                                         
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL Exists (pcFileName AS CHARACTER):
        
        FILE-INFO:FILE-NAME = pcFileName . 
        
        IF FILE-INFO:FULL-PATHNAME <> ? THEN 
            RETURN TRUE .  
        ELSE 
            RETURN FALSE .
        
    END METHOD.
    
	/*------------------------------------------------------------------------------
		Purpose: Returns the absolute file name for the given file   																	  
		Notes:  							
		@param pcFileName The file name to search
		@return The absolute path to the file or ? when the file is not found										  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER FindFile (pcFileName AS CHARACTER):
		
		FILE-INFO:FILE-NAME = pcFileName . 
		
		RETURN FILE-INFO:FULL-PATHNAME .
		
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the List of files on disk for the specified criteria                                                                        
        Notes:                                            
        @param pcDirectory The directory to search files in (including subdirectories)
        @param pcFileMask A comma-delimited list of file name patterns to return (e.g. *.cls,*.w,*.p)
        @param ttFileNames OUTPUT TABLE containing the matching file names (Consultingwerk/Util/TempTables/ttFileNames.i)                           
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetFileList (pcDirectory AS CHARACTER,
                                           pcFileMask AS CHARACTER,
                                           OUTPUT TABLE ttFileNames):

        DEFINE VARIABLE cMask AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i     AS INTEGER   NO-UNDO.

        EMPTY TEMP-TABLE ttFileNames .

&IF DEFINED (DotNetAccessible) NE 0 &THEN
        DEFINE VARIABLE oFiles AS "System.String[]" NO-UNDO .  
&ENDIF
        
        DO i = 1 TO NUM-ENTRIES (pcFileMask):
            ASSIGN cMask = ENTRY (i, pcFileMask) . 
            
            IF cMask > "":U THEN . 
            ELSE NEXT . 

&IF DEFINED (DotNetAccessible) NE 0 &THEN
            oFiles = System.IO.Directory:GetFiles (pcDirectory,
                                                   cMask,
                                                   System.IO.SearchOption:AllDirectories) .

            {Consultingwerk/foreach.i System.Object oFile in oFiles}
                CREATE ttFileNames.
                ASSIGN ttFileNames.FileName = UNBOX (oFile) .
            END.
&ELSE
            RUN Consultingwerk/Util/Support/getfilenames.p
                    (pcDirectory, 
                     cMask,
                     INPUT-OUTPUT TABLE ttFileNames BY-REFERENCE) .


&ENDIF
        END.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the List of files on disk for the specified criteria                                                                        
        Notes:   The routine is an alternative to GetFileList and does not require 
                 access to the .NET Framework (suitable for 10.2B AppServer and 
                 UNIX)                                         
        @param pcDirectory The directory to search files in (including subdirectories)
        @param pcFileMask A comma-delimited list of file name patterns to return (e.g. *.cls,*.w,*.p)
        @param ttFileNames OUTPUT TABLE containing the matching file names (Consultingwerk/Util/TempTables/ttFileNames.i)                           
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetFileListNoDotNet (pcDirectory AS CHARACTER,
                                                   pcFileMask AS CHARACTER,
                                                   OUTPUT TABLE ttFileNames):

        DEFINE VARIABLE cMask AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i     AS INTEGER   NO-UNDO.

        EMPTY TEMP-TABLE ttFileNames .

        DO i = 1 TO NUM-ENTRIES (pcFileMask):
            ASSIGN cMask = ENTRY (i, pcFileMask) . 
            
            IF cMask > "":U THEN . 
            ELSE NEXT . 

            RUN Consultingwerk/Util/Support/getfilenames.p
                    (pcDirectory, 
                     cMask,
                     INPUT-OUTPUT TABLE ttFileNames BY-REFERENCE) .
        END.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a temporary filename either using a .NET API or based on 
                 a GUID and the AVM SESSION:TEMP-DIRECTORY                                                                         
        Notes:   The .NET GUI will create an empty temp-file to "block" the file
        @return The name for a temporary file                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetTempFileName ():
        
&IF DEFINED (DotNetAccessible) NE 0 &THEN
        RETURN System.IO.Path:GetTempFileName () .       
&ELSE
        RETURN SESSION:TEMP-DIRECTORY + GUID + ".tmp":U . 
&ENDIF

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the error message of an OS-ERROR value                                                                        
        Notes:                                                          
        @param piOSError The OS-ERROR Error code              
        @return The OS-ERROR Text
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER OS-ERROR-TEXT (piOSError AS INTEGER):
        
        CASE piOSError:

            WHEN 0 THEN RETURN "No error"{&TRAN} . 
            WHEN 1 THEN RETURN "Not owner"{&TRAN} . 
            WHEN 2 THEN RETURN "No such file or directory"{&TRAN} . 
            WHEN 3 THEN RETURN "Interrupted system call"{&TRAN} . 
            WHEN 4 THEN RETURN "I/O error"{&TRAN} . 
            WHEN 5 THEN RETURN "Bad file number"{&TRAN} . 
            WHEN 6 THEN RETURN "No more processes"{&TRAN} . 
            WHEN 7 THEN RETURN "Not enough core memory"{&TRAN} . 
            WHEN 8 THEN RETURN "Permission denied"{&TRAN} . 
            WHEN 9 THEN RETURN "Bad address"{&TRAN} . 
            WHEN 10 THEN RETURN "File exists"{&TRAN} . 
            WHEN 11 THEN RETURN "No such device"{&TRAN} . 
            WHEN 12 THEN RETURN "Not a directory"{&TRAN} . 
            WHEN 13 THEN RETURN "Is a directory"{&TRAN} . 
            WHEN 14 THEN RETURN "File table overflow"{&TRAN} . 
            WHEN 15 THEN RETURN "Too many open files"{&TRAN} . 
            WHEN 16 THEN RETURN "File too large"{&TRAN} . 
            WHEN 17 THEN RETURN "No space left on device"{&TRAN} . 
            WHEN 18 THEN RETURN "Directory not empty"{&TRAN} . 
            WHEN 999 THEN RETURN "Unmapped error (ABL default)"{&TRAN} . 

            OTHERWISE RETURN "Unknown OS-ERROR"{&TRAN} .
            
        END CASE .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Return relative path if file is in propath
        Notes:   Based on adecomm/_relfile.p
        @param pcFileName The (absolute) name of a file 
        @return The relative file name based on the current propath
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER RelativeFileName (pcFileName AS CHARACTER):

        DEFINE VARIABLE cReturn AS CHARACTER NO-UNDO.        

        RUN adecomm/_relfile.p (pcFileName,     
                                FALSE,
                                "":U,
                                OUTPUT cReturn) .

        RETURN cReturn . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns just the file name portion of a relative or absolute file
                 name
        Notes:   
        @param pcPath The base path
        @return The file name portion of the path
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER ShortFileName (pcPath AS CHARACTER):
		
		DEFINE VARIABLE iIndex AS INTEGER NO-UNDO.
		
        IF OPSYS = "MS-DOS":U OR OPSYS = "WIN32":U THEN 
            ASSIGN pcPath = REPLACE (pcPath, "~\":U, "/":U) .

        iIndex = R-INDEX (pcPath, "/":U) .

        IF iIndex > 0 THEN 
            RETURN SUBSTRING (pcPath, iIndex + 1) .
            
        RETURN pcPath .             

	END METHOD .

END CLASS.
