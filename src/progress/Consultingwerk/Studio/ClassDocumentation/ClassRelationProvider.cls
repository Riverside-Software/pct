/**********************************************************************
 * Copyright (C) 2006-2014 by Consultingwerk Ltd. ("CW") -            *
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
    File        : ClassRelationProvider
    Purpose     : Provides information about relations between classes
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Jul 02 21:32:00 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Framework.Collections.*     FROM PROPATH . 
USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.ClassDocumentation.ClassRelationProvider
    IMPLEMENTS IClassRelationProvider: 

    { Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
    { Consultingwerk/Util/TempTables/ttFileNames.i }

    DEFINE TEMP-TABLE ttClassRelation NO-UNDO 
        FIELD ChildClass        AS CHARACTER 
        FIELD Type              AS CHARACTER /* inherits / implements */ 
        FIELD ParentClass       AS CHARACTER 
        INDEX ParentClass ParentClass Type . 

    DEFINE TEMP-TABLE ttSortClasses NO-UNDO  
        FIELD ClassName AS CHARACTER 
        INDEX ClassName IS UNIQUE ClassName . 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ClassRelationProvider class
        Notes:   Initializes the temp-table with the class relation data from the 
                 class doc XML files
        @param poParameter The parameter object control the output
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC ClassRelationProvider (poParameter AS IDocumentWriterParameter):

        DEFINE VARIABLE oParser    AS ClassDocumentationParser NO-UNDO .
        DEFINE VARIABLE cClassName AS CHARACTER                NO-UNDO .

		SUPER ().

        Consultingwerk.Util.FileHelper:GetFileList (poParameter:SourceDir,
                                                    "*.xml":U,
                                                    OUTPUT TABLE ttFileNames BY-REFERENCE) .

        oParser = NEW ClassDocumentationParser () .
        
        FOR EACH ttFileNames ON ERROR UNDO, THROW:
            
            DATASET dsClassDocumentation:EMPTY-DATASET ().

            oParser:ParseClassDocumentation (ttFileNames.FileName,
                                             INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE) .

            FIND FIRST eUnit NO-LOCK .

            ASSIGN cClassName = eUnit.PackageName + (IF eUnit.PackageName > "":U THEN ".":U ELSE "":U) + eUnit.ClassName .
            
            IF eUnit.Inherits > "":U THEN DO:
                CREATE ttClassRelation.
                ASSIGN ttClassRelation.ChildClass = cClassName
                       ttClassRelation.Type       = "INHERITS":U .
                
                IF NUM-ENTRIES (eUnit.Inherits, ".":U) > 1 THEN 
                    ASSIGN ttClassRelation.ParentClass = eUnit.Inherits . 
                ELSE 
                    ASSIGN ttClassRelation.ParentClass = ClassDocumentationHelper:GetFullTypeName (eUnit.Inherits,
                                                                                                   TABLE eUsing BY-REFERENCE) . 
            END.

            FOR EACH eInterfaces ON ERROR UNDO, THROW:
                CREATE ttClassRelation.
                ASSIGN ttClassRelation.ChildClass = cClassName
                       ttClassRelation.Type       = "IMPLEMENTS":U .

                IF NUM-ENTRIES (eInterfaces.InterfaceName, ".":U) > 1 THEN 
                    ASSIGN ttClassRelation.ParentClass = eInterfaces.InterfaceName . 
                ELSE 
                    ASSIGN ttClassRelation.ParentClass = ClassDocumentationHelper:GetFullTypeName (eInterfaces.InterfaceName,
                                                                                                   TABLE eUsing BY-REFERENCE) . 
            END.
        END.
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the List of Child Classes of the given parent class
        Notes:   Returns direct and indirect child classes
        @param pcParentClass The name of the parent class
        @return The CharacterList of Child Classes
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC CharacterList GetChildClasses (pcParentClass AS CHARACTER):
		
		DEFINE VARIABLE oList AS CharacterList NO-UNDO . 
		
		oList = NEW CharacterList () . 
		
		THIS-OBJECT:GetChildClasses (pcParentClass, 
		                             oList) .
		
		RETURN oList . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Recursively looks for child classes and adds them to the list
        Notes:   
        @param pcParentClass The current parent class
        @param poList The CharacterList to add the child classes to
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID GetChildClasses (pcParentClass AS CHARACTER,
	                                       poList AS CharacterList):
		
		DEFINE BUFFER ttClassRelation FOR ttClassRelation. 
		
		FOR EACH ttClassRelation WHERE ttClassRelation.ParentClass = pcParentClass 
		                           AND ttClassRelation.Type        = "INHERITS":U ON ERROR UNDO, THROW:
		                               
		    poList:Add (ttClassRelation.ChildClass) .
		    
            THIS-OBJECT:GetChildClasses (ttClassRelation.ChildClass,
                                         poList) .		                               
        END.		                               

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the List of Classes implementing the given interface
        Notes:   Returns direct and indirect child classes
        @param pcInterfaceName The name of the interface 
        @return The CharacterList of Child Classes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CharacterList GetImplementingClasses (pcInterfaceName AS CHARACTER):
        
        DEFINE VARIABLE oList            AS CharacterList NO-UNDO . 
        DEFINE VARIABLE oChildClassList  AS CharacterList NO-UNDO . 
        DEFINE VARIABLE oChildInterfaces AS CharacterList NO-UNDO . 
        
        oList = NEW CharacterList () . 
        
        THIS-OBJECT:GetImplementingClasses (pcInterfaceName, 
                                            oList) .
        
        /* Child Interfaces */
        oChildInterfaces = THIS-OBJECT:GetChildClasses (pcInterfaceName) . 
        
        /* Now add all child classes of the given classes */
        {Consultingwerk/foreachPrimitiveList.i Character cInterface in oChildInterfaces}
            THIS-OBJECT:GetImplementingClasses (cInterface, oList) .
        END.        
        
        
        EMPTY TEMP-TABLE ttSortClasses .
        
        /* Now add all child classes of the given classes */
        {Consultingwerk/foreachPrimitiveList.i Character cClass in oList}
            
            IF NOT CAN-FIND (ttSortClasses WHERE ttSortClasses.ClassName = cClass) THEN DO: 
                CREATE ttSortClasses . 
                ASSIGN ttSortClasses.ClassName = cClass . 
            END. 
                        
            oChildClassList = THIS-OBJECT:GetChildClasses (cClass) .

            {Consultingwerk/foreachPrimitiveList.i Character cChildClass in oChildClassList}
            
                IF NOT CAN-FIND (ttSortClasses WHERE ttSortClasses.ClassName = cChildClass) THEN DO: 
                    CREATE ttSortClasses . 
                    ASSIGN ttSortClasses.ClassName = cChildClass . 
                END.
            END.    
        END.
        
        oList:Clear () . 

        FOR EACH ttSortClasses:
            oList:Add (ttSortClasses.ClassName) .
        END.
        
        RETURN oList . 

        FINALLY:
            EMPTY TEMP-TABLE ttSortClasses .		
        END FINALLY.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Recursively looks for classes implementing the Interface and adds 
                 them to the list
        Notes:   
        @param pcInterfaceName The name of the interface 
        @param poList The CharacterList to add the child classes to
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID GetImplementingClasses (pcInterfaceName AS CHARACTER,
                                                  poList AS CharacterList):
        
        DEFINE BUFFER ttClassRelation FOR ttClassRelation. 
        
        FOR EACH ttClassRelation WHERE ttClassRelation.ParentClass = pcInterfaceName 
                                   AND ttClassRelation.Type        = "IMPLEMENTS":U ON ERROR UNDO, THROW:
                                       
            poList:Add (ttClassRelation.ChildClass) .
            
            THIS-OBJECT:GetChildClasses (ttClassRelation.ChildClass,
                                         poList) .                                      
        END.                                       

    END METHOD .


END CLASS.
