/**********************************************************************
 * Copyright 2019 Consultingwerk Ltd.                                 *
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
    File        : AssembliesCatalog
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Nov 27 06:28:01 CET 2019
    Notes       :
  ----------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.PCT.AssembliesCatalog.AssembliesCatalog:

    /**
     * Purpose: Processes the base types
     * Notes:
     * @param poType The System.Type to process
     * @param poJson The JsonObject to add to
     */
    METHOD PROTECTED VOID AddBaseTypes (poType AS System.Type,
                                        poJson AS JsonObject):

        DEFINE VARIABLE oBase      AS System.Type NO-UNDO .
        DEFINE VARIABLE oBaseTypes AS JsonArray   NO-UNDO .

        oBase = poType:BaseType .

        DO WHILE VALID-OBJECT (oBase):
            IF NOT VALID-OBJECT (oBaseTypes) THEN
                oBaseTypes = NEW JsonArray () .

            oBaseTypes:Add (oBase:FullName) .

            oBase = oBase:BaseType .
        END.

        IF VALID-OBJECT (oBaseTypes) THEN
            poJson:Add ("baseTypes":U, oBaseTypes) .

    END METHOD.

    /**
     * Purpose: Processes the properties
     * Notes:
     * @param poType The System.Type to process
     * @param poJson The JsonObject to add to
     */
    METHOD PROTECTED VOID AddProperties (poType AS System.Type,
                                         poJson AS JsonObject):

        DEFINE VARIABLE oInstancePropertiesJson AS JsonArray                          NO-UNDO .
        DEFINE VARIABLE oStaticPropertiesJson   AS JsonArray                          NO-UNDO .
        DEFINE VARIABLE oProperties             AS "System.Reflection.PropertyInfo[]" NO-UNDO .

        oProperties = poType:GetProperties () .

        {Consultingwerk/foreach.i System.Reflection.PropertyInfo oProperty in oProperties '' propertyloop}

            IF CAST (oProperty:GetAccessors(TRUE):GetValue(0), System.Reflection.MethodInfo):IsStatic THEN DO:
                IF NOT VALID-OBJECT (oStaticPropertiesJson) THEN
                    oStaticPropertiesJson = NEW JsonArray () .

                oStaticPropertiesJson:Add (oProperty:Name) .
            END.
            ELSE DO:
                IF NOT VALID-OBJECT (oInstancePropertiesJson) THEN
                    oInstancePropertiesJson = NEW JsonArray () .

                oInstancePropertiesJson:Add (oProperty:Name) .
            END.
        END.

        IF VALID-OBJECT (oInstancePropertiesJson) THEN
            poJson:Add ("properties":U, oInstancePropertiesJson) .

        IF VALID-OBJECT (oStaticPropertiesJson) THEN
            poJson:Add ("staticProperties":U, oStaticPropertiesJson) .

    END METHOD.

    /**
     * Purpose: Processes the events
     * Notes:
     * @param poType The System.Type to process
     * @param poJson The JsonObject to add to
     */
    METHOD PROTECTED VOID AddEvents (poType AS System.Type,
                                     poJson AS JsonObject):

        DEFINE VARIABLE oEventsJson AS JsonArray                       NO-UNDO .

        oEventsJson = THIS-OBJECT:GetEvents (poType:GetEvents ()) .

        IF VALID-OBJECT (oEventsJson) THEN
            poJson:Add ("events":U, oEventsJson) .

    END METHOD.

    /**
     * Purpose: Processes the methods
     * Notes:
     * @param poType The System.Type to process
     * @param poJson The JsonObject to add to
     */
    METHOD PROTECTED VOID AddMethods (poType AS System.Type,
                                      poJson AS JsonObject):

        DEFINE VARIABLE oMethods      AS "System.Reflection.MethodInfo[]" NO-UNDO .
        DEFINE VARIABLE oMethodsJson  AS JsonArray                        NO-UNDO .

        oMethods = poType:GetMethods () .

        oMethodsJson = THIS-OBJECT:GetMethods (oMethods, FALSE) .

        IF VALID-OBJECT (oMethodsJson) THEN
            poJson:Add ("methods":U, oMethodsJson) .

        oMethodsJson = THIS-OBJECT:GetMethods (oMethods, TRUE) .

        IF VALID-OBJECT (oMethodsJson) THEN
            poJson:Add ("staticMethods":U, oMethodsJson) .

    END METHOD.

    /**
     * Purpose:
     * Notes:
     * @param poAssembly The reference to the .NET Assembly
     * @param poJsonObject The name of the JSON Array
     */
    METHOD PROTECTED VOID AddTypes (poAssembly AS System.Reflection.Assembly,
                                    poJsonObject AS JsonArray):

        DEFINE VARIABLE oTypeJson  AS JsonObject      NO-UNDO .
        DEFINE VARIABLE oBaseTypes AS JsonArray       NO-UNDO .
        DEFINE VARIABLE oTypes     AS "System.Type[]" NO-UNDO .

        oTypes = poAssembly:GetTypes() .

        {Consultingwerk/foreach.i System.Type oType in oTypes '' typeloop}
            /* IF poJsonObject:Has (oType:FullName) THEN
                NEXT typeloop . */

            oTypeJson = NEW JsonObject () .

            THIS-OBJECT:AddBaseTypes (oType, oTypeJson) .
            oTypeJson:Add ("name":U, oType:FullName).
            oTypeJson:Add ("isAbstract":U, oType:IsAbstract) .
            oTypeJson:Add ("isClass":U, oType:IsClass) .
            oTypeJson:Add ("isEnum":U, oType:IsEnum) .
            oTypeJson:Add ("isInterface":U, oType:IsInterface) .

            THIS-OBJECT:AddEvents (oType, oTypeJson) .
            THIS-OBJECT:AddMethods (oType, oTypeJson) .
            THIS-OBJECT:AddProperties (oType, oTypeJson) .

            poJsonObject:Add (oTypeJson) .
        END .

        CATCH rtle AS System.Reflection.ReflectionTypeLoadException:
            MESSAGE "Error processing" poAssembly:FullName SKIP
                    rtle:Message
                VIEW-AS ALERT-BOX.
        END CATCH.

    END METHOD.

    /**
     * Purpose: Adds the types from the given Assembly to the JsonObject
     * Notes:
     * @param pcAssemblyName The name of the assembly
     * @param poJsonObject The name of the JSON Array
     */
    METHOD PUBLIC VOID AddTypesFromAssembly (pcAssemblyName AS CHARACTER,
                                             poJsonObject AS JsonArray):

        DEFINE VARIABLE oAssembly AS System.Reflection.Assembly NO-UNDO .

        oAssembly = System.Reflection.Assembly:Load (pcAssemblyName) .

        IF NOT VALID-OBJECT (oAssembly) THEN
            RETURN .

        THIS-OBJECT:AddTypes (oAssembly, poJsonObject) .

    END METHOD.

    /**
     * Purpose: Returns the JsonArray of the given events
     * Notes:
     * @param poEvents The EventInfo[]
     * @return The JsonArray
     */
    METHOD PROTECTED JsonArray GetEvents (poEvents AS "System.Reflection.EventInfo[]"):

        DEFINE VARIABLE oEventsJson  AS JsonArray                        NO-UNDO .
        DEFINE VARIABLE cPrevName    AS CHARACTER                        NO-UNDO .

        {Consultingwerk/foreach.i System.Reflection.EventInfo oEvent in poEvents '' eventloop}
            IF NOT VALID-OBJECT (oEventsJson) THEN
                oEventsJson = NEW JsonArray () .

            IF cPrevName = oEvent:Name THEN
                NEXT eventloop .

            oEventsJson:Add (oEvent:Name) .

            ASSIGN cPrevName = oEvent:Name .
        END.

        RETURN oEventsJson .

    END METHOD.

    /**
     * Purpose: Returns the JsonArray of the given methods
     * Notes:
     * @param poMethods The MethodInfo[]
     * @param plStatic Logical flag indicating if we should be adding static methods or not
     * @return The JsonArray
     */
    METHOD PROTECTED JsonArray GetMethods (poMethods AS "System.Reflection.MethodInfo[]",
                                           plStatic AS LOGICAL):

        DEFINE VARIABLE oMethodsJson  AS JsonArray                        NO-UNDO .
        DEFINE VARIABLE cPrevName     AS CHARACTER                        NO-UNDO .

        {Consultingwerk/foreach.i System.Reflection.MethodInfo oMethod in poMethods '' methodloop}
            IF oMethod:IsStatic <> plStatic THEN
                NEXT methodLoop .

            IF oMethod:Name BEGINS "set_":U OR oMethod:Name BEGINS "get_":U THEN
                NEXT methodLoop .

            IF NOT VALID-OBJECT (oMethodsJson) THEN
                oMethodsJson = NEW JsonArray () .

            IF cPrevName = oMethod:Name THEN
                NEXT methodloop .

            oMethodsJson:Add (oMethod:Name) .

            ASSIGN cPrevName = oMethod:Name .
        END.

        RETURN oMethodsJson .

    END METHOD.

END CLASS.
