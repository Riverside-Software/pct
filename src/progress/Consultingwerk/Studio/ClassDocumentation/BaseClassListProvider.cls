/**********************************************************************
 * Copyright 2013 Consultingwerk Ltd.                                 *
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
    File        : BaseClassListProvider
    Purpose     : Helper class for returning the list of base classes
                  for a given ABL class
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Mar 24 21:21:49 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i} 

USING Consultingwerk.Framework.Collections.*     FROM PROPATH .
USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .  
USING Consultingwerk.Util.*                      FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.ClassDocumentation.BaseClassListProvider: 

    {Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i &ACCESS=STATIC}
    {Consultingwerk/Util/TempTables/ttClassNames.i &ACCESS=STATIC}
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BaseClassListProvider class
        Notes:   Disallow instance creation   
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PRIVATE BaseClassListProvider ():
		SUPER ().
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the CharacterList of ABL base classes for the given class
        Notes:   Determines the base classes based on the XML output of the PCT classdoc
                 tast   
        @param pcClassName The class name to return the list of ABL base classes for
        @param pcClassDocFolder The name of the folder (potentially relative) that contains the classdoc XML files
        @return The CharacterList of ABL base classes
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CharacterList GetBaseClassList (pcClassName AS CHARACTER,
	                                                     pcClassDocFolder AS CHARACTER):
		
        DEFINE VARIABLE oParser    AS ClassDocumentationParser NO-UNDO .
        DEFINE VARIABLE oList      AS CharacterList            NO-UNDO . 
		DEFINE VARIABLE cClassName AS CHARACTER                NO-UNDO .
		
		oList = NEW CharacterList () .
		
		oParser = NEW ClassDocumentationParser () .
		
		ASSIGN cClassName = pcClassName . 
		
		REPEAT:
    		FILE-INFO:FILE-NAME = SUBSTITUTE ("&1/&2.xml":U,
    		                                  pcClassDocFolder,
    		                                  cClassName) . 
    		
    		IF FILE-INFO:FULL-PATHNAME > "":U THEN DO: 
    		    DATASET dsClassDocumentation:EMPTY-DATASET () . 
    		    
    		    oParser:ParseClassDocumentation (FILE-INFO:FULL-PATHNAME,
    		                                     INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE) .
    		    
    		    FIND FIRST eUnit NO-ERROR .
    		    
    		    IF NOT AVAILABLE eUnit THEN RETURN oList . 
    		    
    		    IF eUnit.Inherits = "":U OR eUnit.Inherits = "Progress.Lang.Object":U THEN DO:
    		        oList:Add ("Progress.Lang.Object":U) .
    		        RETURN oList . 
    		    END. 
    		                       
                IF NUM-ENTRIES (eUnit.Inherits, ".":U) > 1 THEN DO:
                    oList:Add (eUnit.Inherits) .
                    
                    ASSIGN cClassName = eUnit.Inherits .
                    NEXT .
                END.  
                
                ASSIGN cClassName = ClassDocumentationHelper:GetFullTypeName (eUnit.Inherits,
                                                                              TABLE eUsing BY-REFERENCE) .
                                                                              
                IF cClassName > "":U THEN DO:
                    oList:Add (cClassName) .
                    
                    NEXT .
                END.                                                                              
            END.       
            
            LEAVE .        
        END.		                                     

        RETURN oList . 

        FINALLY:
            GarbageCollectorHelper:DeleteObject (oParser) .		
        END FINALLY.

	END METHOD .

	/*------------------------------------------------------------------------------
        Purpose: Loads all ABL classes
        Notes:   Workaround for sporadic AVM crash during Progress.Lang.Class:GetClass ()
        @param cPathName The pathname from where ABL classes should be preloaded    
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID PreloadClasses (cPathName AS CHARACTER):
	    
	    &IF DEFINED (DotNetAccessible) NE 0 &THEN
	    DEFINE VARIABLE oClass AS Progress.Lang.Class NO-UNDO.
	    
	    FILE-INFO:FILE-NAME = cPathName .
	    IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    		Consultingwerk.Util.ClassHelper:GetClassNames ("Progress.Lang.Object":U,
                                                           FILE-INFO:FULL-PATHNAME,
                                                           TRUE,
                                                           "":U,
                                                           OUTPUT TABLE ttClassNames) .

        FOR EACH ttClassNames:
            oClass = Progress.Lang.Class:GetClass (ttClassNames.ClassName).
        END.
        &ELSE
        UNDO, THROW NEW Consultingwerk.Exceptions.NotSupportedException ("PreloadClasses":U,
                                                                         "Consultingwerk.Studio.ClassDocumentation.BaseClassListProvider":U) .
        &ENDIF

	END METHOD.    

END CLASS.
