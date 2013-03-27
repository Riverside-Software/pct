/**********************************************************************
 * Copyright 2012 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        * 
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
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
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
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
        Purpose: Returns the error message of an OS-ERROR value                                                                        
        Notes:                                                          
        @param piOSError The OS-ERROR Error code              
        @return The OS-ERROR Text
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER OS-ERROR-TEXT (piOSError AS INTEGER):
        
        CASE piOSError:

            WHEN 0 THEN RETURN "No error" . 
            WHEN 1 THEN RETURN "Not owner" . 
            WHEN 2 THEN RETURN "No such file or directory" . 
            WHEN 3 THEN RETURN "Interrupted system call" . 
            WHEN 4 THEN RETURN "I/O error" . 
            WHEN 5 THEN RETURN "Bad file number" . 
            WHEN 6 THEN RETURN "No more processes" . 
            WHEN 7 THEN RETURN "Not enough core memory" . 
            WHEN 8 THEN RETURN "Permission denied" . 
            WHEN 9 THEN RETURN "Bad address" . 
            WHEN 10 THEN RETURN "File exists" . 
            WHEN 11 THEN RETURN "No such device" . 
            WHEN 12 THEN RETURN "Not a directory" . 
            WHEN 13 THEN RETURN "Is a directory" . 
            WHEN 14 THEN RETURN "File table overflow" . 
            WHEN 15 THEN RETURN "Too many open files" . 
            WHEN 16 THEN RETURN "File too large" . 
            WHEN 17 THEN RETURN "No space left on device" . 
            WHEN 18 THEN RETURN "Directory not empty" . 
            WHEN 999 THEN RETURN "Unmapped error (ABL default)" . 

            OTHERWISE RETURN "Unknown OS-ERROR" .
            
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

END CLASS.
