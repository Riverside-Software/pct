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
    File        : ClassHelper
    Purpose     : Class contains generic supporting routines to work 
                  with classes
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Jul 12 20:31:09 CEST 2010
    Notes       : This file is intended for GUI for .NET only
                  The result temp-table description is in Consultingwerk/Util/TempTables/ttClassNames.i
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.Assertion.* FROM PROPATH .
USING Consultingwerk.Util.*      FROM PROPATH .  
USING Progress.Lang.*            FROM PROPATH . 

CLASS Consultingwerk.Util.ClassHelper: 
    
    {Consultingwerk/Util/TempTables/ttClassNames.i &ACCESS="PRIVATE STATIC"}
    {Consultingwerk/Util/TempTables/ttClassNames.i &ACCESS="PRIVATE STATIC" &PREFIX="return_"}
    {Consultingwerk/Util/TempTables/ttClassNames.i &ACCESS="PRIVATE STATIC" &PREFIX="return2_"}
    {Consultingwerk/Util/TempTables/ttClassPath.i &ACCESS="PRIVATE STATIC"}
    {Consultingwerk/Util/TempTables/ttFileNames.i &ACCESS="PRIVATE STATIC"}

&IF DEFINED (DotNetAccessible) NE 0 &THEN
    DEFINE STATIC VARIABLE oProcess AS System.Diagnostics.Process NO-UNDO . 
&ENDIF

    /*------------------------------------------------------------------------------
        Purpose: Ability to force GetClassNames to include classes from the 
                 Consultingwerk.SmartComponents package  
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC STATIC PROPERTY ForceIncludeSmartComponents AS LOGICAL INITIAL FALSE NO-UNDO 
	GET.
	SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ClassHelper class
        Notes:   Private default constructor                   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ClassHelper():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Converts a class name into the source code file name (.cls)                                                                      
        Notes:                                                                        
        @param pcClassName The ClassName to convert into a source code file name
        @return The file name of the class source code
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ClassNameToFile (pcClassName AS CHARACTER):
        
        DEFINE VARIABLE cFileName AS CHARACTER NO-UNDO .
        DEFINE VARIABLE iDots     AS INTEGER   NO-UNDO .
        DEFINE VARIABLE i         AS INTEGER   NO-UNDO .

        Assert:NotNullOrEmpty (pcClassName) .

        ASSIGN iDots = NUM-ENTRIES (pcClassName, ".":U) - 1 .
        
        DO i = 1 TO iDots:
            SUBSTRING (pcClassName, INDEX (pcClassName, ".":U), 1) = "/":U . 
        END.
        
        RETURN pcClassName + ".cls":U .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the Progress.Lang.Class reference for a type referenced
                 by either the .cls or .r file name
        Notes:   
        @param pcFileName The file name
        @return The Progress.Lang.Class reference of the matching typ
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC Progress.Lang.Class FileNameToClass (pcFileName AS CHARACTER):
		
        DEFINE VARIABLE cShortFileName AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE oClass         AS Progress.Lang.Class NO-UNDO .
		DEFINE VARIABLE cExtension     AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cClassName     AS CHARACTER           NO-UNDO .
        
        FILE-INFO:FILE-NAME = pcFileName . 
        
        IF FILE-INFO:FULL-PATHNAME = ? THEN 
            RETURN ? . 

        ASSIGN cShortFileName = FileHelper:RelativeFileName (FILE-INFO:FULL-PATHNAME) .                        
            
        /* File Name should be .cls or .r */
        ASSIGN cExtension = ENTRY (NUM-ENTRIES (cShortFileName, ".":U), cShortFileName, ".":U) .                    

        IF cExtension = "R":U THEN DO:
            RCODE-INFORMATION:FILE-NAME = pcFileName . 
            
            IF NOT RCODE-INFORMATION:IS-CLASS THEN 
                RETURN ? . 
        END.             
        ELSE IF NOT cExtension = "CLS":U THEN 
            RETURN ? .             

        ASSIGN cClassName = SUBSTRING (cShortFileName, 1, R-INDEX (cShortFileName, ".":U) - 1) 
               cClassName = REPLACE (cClassName, "/":U, ".":U)
               cClassName = REPLACE (cClassName, "~\":U, ".":U).

        DO ON ERROR UNDO, THROW:
            
            oClass = Progress.Lang.Class:GetClass (cClassName) .
            
            CATCH err AS Progress.Lang.Error :
            	RETURN ? .	
            END CATCH.
        END.

        RETURN oClass .

	END METHOD .

&IF DEFINED (DotNetAccessible) NE 0 &THEN
    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the specified root directory
                 that match the specified base type, optionally including abstract 
                 classes                                                                      
        Notes:   The routine is designed to run on a windows client only, as it 
                 uses the .NET Framework, uses Progress.Lang.Object as the base 
                 type for the ClassLookup through GetClassNames (pcBaseType, OUTPUT TABLE ttClassNames)          
        @param ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNames (OUTPUT TABLE ttClassNames):
        
        GetClassNames ("Progress.Lang.Object":U, 
                       ".":U, 
                       FALSE,
                       "":U, 
                       OUTPUT TABLE ttClassNames BY-REFERENCE) .
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the specified root directory
                 that match the specified base type (class or interface)                                                
        Notes:   The routine is designed to run on a windows client only, as it 
                 uses the .NET Framework                                                                        
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNames (pcBaseType AS CHARACTER, 
                                             OUTPUT TABLE ttClassNames):
        
        GetClassNames (pcBaseType, 
                       ".":U, 
                       FALSE,
                       "":U, 
                       OUTPUT TABLE ttClassNames BY-REFERENCE) .
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the specified root directory
                 that match the specified base type (class or interface)                                         
        Notes:   The routine is designed to run on a windows client only, as it 
                 uses the .NET Framework                                                                        
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param pcPath The directory to look in (including sub folders)
        @param ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNames (pcBaseType AS CHARACTER,
                                             pcPath AS CHARACTER,
                                             OUTPUT TABLE ttClassNames):
        
        GetClassNames (pcBaseType, 
                       pcPath, 
                       FALSE,
                       "":U,
                       OUTPUT TABLE ttClassNames BY-REFERENCE) .
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the specified root directory
                 that match the specified base type (class or interface), optionally 
                 including abstract classes                                                                      
        Notes:   The routine is designed to run on a windows client only, as it 
                 uses the .NET Framework                              
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param pcPath The directory to look in (including sub folders)
        @param plIncludeAbstract Include abstract classes in the search
        @param pcPrefix The prefix (name space/package name) to add to the returned class names 
        @param ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNames (pcBaseType AS CHARACTER,
                                             pcPath AS CHARACTER,
                                             plIncludeAbstract AS LOGICAL,
                                             pcPrefix AS CHARACTER,
                                             OUTPUT TABLE ttClassNames):

        DEFINE VARIABLE oFiles     AS "System.String[]"   NO-UNDO .
        DEFINE VARIABLE cFile      AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE i          AS INT64               NO-UNDO .
        DEFINE VARIABLE oClass     AS Progress.Lang.Class NO-UNDO .
        DEFINE VARIABLE cClassName AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cRootDir   AS CHARACTER           NO-UNDO .

        EMPTY TEMP-TABLE ttClassNames .

        FILE-INFO:FILE-NAME = pcPath .
        
        ASSIGN cRootDir = FILE-INFO:FULL-PATHNAME . 
                
        oFiles = System.IO.Directory:GetFiles (cRootDir,
                                               "*.r":U, 
                                               System.IO.SearchOption:AllDirectories) .
        
        DO i = 0 TO oFiles:LongLength - 1:
            ASSIGN cFile = UNBOX(oFiles:GetValue (i)) .

            RCODE-INFORMATION:FILE-NAME = cFile . 
        
            IF RCODE-INFORMATION:IS-CLASS THEN DO:
                ASSIGN cClassName = SUBSTRING (cFile, LENGTH (cRootDir) + 2) 
                       cClassName = REPLACE (SUBSTRING (cClassName, 1, LENGTH (cClassName) - 2), "~\":U, ".":U)
                       NO-ERROR .
                       
                IF pcPrefix > "":U THEN 
                    ASSIGN cClassName = SUBSTITUTE ("&1.&2":U,
                                                    pcPrefix,
                                                    cClassName) . 

                /* Mike Fechner, Consultingwerk Ltd. 26.10.2011
                   Exclude SmartComponent Library from the class browser
                   We have observed crashes from the Progress.Lang.Class:GetClass 
                   call with some of the SmartComponents.Implementation classes. */                    
                IF ClassHelper:ForceIncludeSmartComponents = FALSE AND cClassName BEGINS "Consultingwerk.SmartComponents.":U THEN NEXT .                                     
                    
                ASSIGN oClass     = Progress.Lang.Class:GetClass (cClassName)
                       NO-ERROR .

                IF NOT VALID-OBJECT (oClass) THEN 
                    NEXT . 
                    
                IF (NOT plIncludeAbstract) AND (oClass:IsAbstract() OR oClass:IsInterface()) THEN
                    NEXT .       
                       
                IF oClass:IsA (pcBaseType) THEN DO: 
                    CREATE ttClassNames .
                    ASSIGN ttClassNames.ClassName = cClassName .
                END.
            END.
        END.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the directories specified in the 
                 .classpath file and that match the specified base type                                                       
        Notes:   The routine is designed to run on a windows client only, as it 
                 uses the .NET Framework                             
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param return_ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNamesInClassPath (pcBaseType AS CHARACTER,
                                                        OUTPUT TABLE return_ttClassNames):

        GetClassNamesInClassPath (pcBaseType, 
                                  FALSE, 
                                  OUTPUT TABLE return_ttClassNames BY-REFERENCE) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the directories specified in the 
                 .classpath file and that match the specified base type, optionally 
                 including or excluding abstract classes                                                                      
        Notes:   The routine is designed to run on a windows client only, as it 
                 uses the .NET Framework     
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param plIncludeAbstract Include abstract classes in the search
        @param return_ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNamesInClassPath (pcBaseType AS CHARACTER,
                                                        plIncludeAbstract AS LOGICAL,
                                                        OUTPUT TABLE return_ttClassNames):
        
        EMPTY TEMP-TABLE return_ttClassNames .
        
        FILE-INFO:FILE-NAME = ".classpath":U .

        IF FILE-INFO:FULL-PATHNAME > "":U THEN
            TEMP-TABLE ttClassPath:READ-XML ("FILE":U, FILE-INFO:FULL-PATHNAME, "EMPTY":U, ?, ?) NO-ERROR .
        
        IF NOT CAN-FIND (FIRST ttClassPath) THEN DO: 
            ClassHelper:GetClassNames (pcBaseType, ".":U, plIncludeAbstract, "":U, OUTPUT TABLE return_ttClassNames) .
            RETURN. 
        END.
        
        FOR EACH ttClassPath:
            FILE-INFO:FILE-NAME = ttClassPath.Directory .

            IF FILE-INFO:FULL-PATHNAME = ? THEN 
                RETURN . 
            
            ClassHelper:GetClassNames (pcBaseType, 
                                       FILE-INFO:FULL-PATHNAME, 
                                       plIncludeAbstract,
                                       ttClassPath.Prefix, 
                                       OUTPUT TABLE return2_ttClassNames) .
            
            FOR EACH return2_ttClassNames:
                IF CAN-FIND (FIRST return_ttClassNames WHERE return_ttClassNames.ClassName = return2_ttClassNames.ClassName) THEN 
                    NEXT .
                
                CREATE return_ttClassNames .
                BUFFER-COPY return2_ttClassNames TO return_ttClassNames . 
            END.
        END. 

    END METHOD.
&ENDIF 

    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the specified root directory
                 that match the specified base type (class or interface), optionally 
                 including abstract classes                                                                      
        Notes:   The routine is an alternative to GetClassNames and does not require 
                 access to the .NET Framework (suitable for 10.2B AppServer and 
                 UNIX)                              
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param pcPath The directory to look in (including sub folders)
        @param plIncludeAbstract Include abstract classes in the search
        @param pcPrefix The prefix (name space/package name) to add to the returned class names 
        @param ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNamesNoDotNet (pcBaseType AS CHARACTER,
                                                     pcPath AS CHARACTER,
                                                     plIncludeAbstract AS LOGICAL,
                                                     pcPrefix AS CHARACTER,
                                                     OUTPUT TABLE ttClassNames):

        DEFINE VARIABLE cFile      AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE oClass     AS Progress.Lang.Class NO-UNDO .
        DEFINE VARIABLE cClassName AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cRootDir   AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE mpData     AS MEMPTR              NO-UNDO .   
        DEFINE VARIABLE iLength    AS INTEGER             NO-UNDO .
        DEFINE VARIABLE i          AS INTEGER             NO-UNDO .

        EMPTY TEMP-TABLE ttClassNames .

        FILE-INFO:FILE-NAME = pcPath .
        
        ASSIGN cRootDir = FILE-INFO:FULL-PATHNAME . 
                
        Consultingwerk.Util.FileHelper:GetFileListNoDotNet (cRootDir, 
                                                            "*.r":U, 
                                                            OUTPUT TABLE ttFileNames) .                

        fileLoop: FOR EACH ttFileNames ON ERROR UNDO, THROW:
            
            ASSIGN cFile = ttFileNames.FileName .

            RCODE-INFORMATION:FILE-NAME = cFile . 
        
            IF RCODE-INFORMATION:IS-CLASS THEN DO:
                
                /* Mike Fechner, Consultingwerk Ltd. 04.09.2013
                   Is there a faster way to exclude .NET dependent 
                   r-code on UNIX? 
                   This is required as Progress.Lang.Class:GetClass (cClassName) 
                   kills the 10.2B AppServer agent (probably because .NET is not 
                   accessible) */
                DO ON ERROR UNDO, THROW:
                    COPY-LOB FROM FILE cFile TO mpData .
    
                    iLength = GET-SIZE (mpData) .
    
                    DO i = 1 TO iLength - 7:
                        IF GET-STRING (mpData, i, 7) = "System.":U THEN NEXT fileLoop .
                    END.
    
                    FINALLY:
                        SET-SIZE (mpData) = 0 .         
                    END FINALLY.
                END. /* Check .NET depentent code */
                
                ASSIGN cClassName = SUBSTRING (cFile, LENGTH (cRootDir) + 2) 
                       cClassName = REPLACE (SUBSTRING (cClassName, 1, LENGTH (cClassName) - 2), "~\":U, ".":U)
                       NO-ERROR .
                       
                IF pcPrefix > "":U THEN 
                    ASSIGN cClassName = SUBSTITUTE ("&1.&2":U,
                                                    pcPrefix,
                                                    cClassName) . 

                /* Mike Fechner, Consultingwerk Ltd. 26.10.2011
                   Exclude SmartComponent Library from the class browser
                   We have observed crashes from the Progress.Lang.Class:GetClass 
                   call with some of the SmartComponents.Implementation classes. */                    
                IF ClassHelper:ForceIncludeSmartComponents = FALSE AND cClassName BEGINS "Consultingwerk.SmartComponents.":U THEN NEXT .                                     
                    
                ASSIGN oClass     = Progress.Lang.Class:GetClass (cClassName)
                       NO-ERROR .

                IF NOT VALID-OBJECT (oClass) THEN 
                    NEXT . 
                    
                IF (NOT plIncludeAbstract) AND (oClass:IsAbstract() OR oClass:IsInterface()) THEN
                    NEXT .       
                       
                IF oClass:IsA (pcBaseType) THEN DO: 
                    CREATE ttClassNames .
                    ASSIGN ttClassNames.ClassName = cClassName .
                END.
            END.
        END.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns all class names found in the directories specified in the 
                 .classpath file and that match the specified base type, optionally 
                 including or excluding abstract classes                                                                      
        Notes:   The routine is an alternative to GetClassNamesInClassPath and does 
                 not require access to the .NET Framework (suitable for 10.2B AppServer 
                 and UNIX)
        @param pcBaseType The base type (class or interface) that the returned classes need to match
        @param plIncludeAbstract Include abstract classes in the search
        @param return_ttClassNames OUTPUT Temp-Table with the list of matching classnames                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetClassNamesInClassPathNoDotNet (pcBaseType AS CHARACTER,
                                                                plIncludeAbstract AS LOGICAL,
                                                                OUTPUT TABLE return_ttClassNames):
        
        EMPTY TEMP-TABLE return_ttClassNames .
        
        FILE-INFO:FILE-NAME = ".classpath":U .

        IF FILE-INFO:FULL-PATHNAME > "":U THEN
            TEMP-TABLE ttClassPath:READ-XML ("FILE":U, FILE-INFO:FULL-PATHNAME, "EMPTY":U, ?, ?) NO-ERROR .
        
        IF NOT CAN-FIND (FIRST ttClassPath) THEN DO: 
            ClassHelper:GetClassNamesNoDotNet (pcBaseType, ".":U, plIncludeAbstract, "":U, OUTPUT TABLE return_ttClassNames) .
            RETURN. 
        END.
        
        FOR EACH ttClassPath:
            FILE-INFO:FILE-NAME = ttClassPath.Directory .

            IF FILE-INFO:FULL-PATHNAME = ? THEN 
                RETURN . 
            
            ClassHelper:GetClassNamesNoDotNet (pcBaseType, 
                                               FILE-INFO:FULL-PATHNAME, 
                                               plIncludeAbstract,
                                               ttClassPath.Prefix, 
                                               OUTPUT TABLE return2_ttClassNames) .
            
            FOR EACH return2_ttClassNames:
                IF CAN-FIND (FIRST return_ttClassNames WHERE return_ttClassNames.ClassName = return2_ttClassNames.ClassName) THEN 
                    NEXT .
                
                CREATE return_ttClassNames .
                BUFFER-COPY return2_ttClassNames TO return_ttClassNames . 
            END.
        END. 

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the ShortClassName for the given Class object
        Notes:   The short name is the class name without the package
        @param poClass The class to return the short name for
        @return The short name of the class
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER ShortClassName (poClass AS Progress.Lang.Class):
		
		DEFINE VARIABLE cFullName AS CHARACTER NO-UNDO.
		
		Consultingwerk.Assertion.ObjectAssert:IsValid (poClass, "Class":U) .
		
		ASSIGN cFullName = poClass:TypeName .
		
		RETURN ENTRY (NUM-ENTRIES (cFullName, ".":U), cFullName, ".":U) . 

	END METHOD .

END CLASS.
