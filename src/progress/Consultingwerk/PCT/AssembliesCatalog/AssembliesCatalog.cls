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
USING Progress.Util.*             FROM ASSEMBLY.

CLASS Consultingwerk.PCT.AssembliesCatalog.AssembliesCatalog:

    DEFINE VARIABLE oObsoleteType  AS System.Type NO-UNDO .
    DEFINE VARIABLE oStringType    AS System.Type NO-UNDO .
    DEFINE VARIABLE oBooleanType   AS System.Type NO-UNDO .
    DEFINE VARIABLE oByteType      AS System.Type NO-UNDO .
    DEFINE VARIABLE oSByteType     AS System.Type NO-UNDO .
    DEFINE VARIABLE oDateTimeType  AS System.Type NO-UNDO .
    DEFINE VARIABLE oDecimalType   AS System.Type NO-UNDO .
    DEFINE VARIABLE oInt16Type     AS System.Type NO-UNDO .
    DEFINE VARIABLE oUInt16Type    AS System.Type NO-UNDO .
    DEFINE VARIABLE oInt32Type     AS System.Type NO-UNDO .
    DEFINE VARIABLE oUInt32Type    AS System.Type NO-UNDO .
    DEFINE VARIABLE oInt64Type     AS System.Type NO-UNDO .
    DEFINE VARIABLE oUInt64Type    AS System.Type NO-UNDO .
    DEFINE VARIABLE oDoubleType    AS System.Type NO-UNDO .
    DEFINE VARIABLE oSingleType    AS System.Type NO-UNDO .
    DEFINE VARIABLE oCharType      AS System.Type NO-UNDO .
    DEFINE VARIABLE oByteArrayType AS System.Type NO-UNDO .

    /**
     * Purpose: Constructor for the AssembliesCatalog class
     * Notes:
     */
    CONSTRUCTOR PUBLIC AssembliesCatalog ():

        ASSIGN
            oObsoleteType  = TypeHelper:GetType("System.ObsoleteAttribute":U)
            oStringType    = TypeHelper:GetType ("System.String":U, TRUE)
            oBooleanType   = TypeHelper:GetType ("System.Boolean":U, TRUE)
            oByteType      = TypeHelper:GetType ("System.Byte":U, TRUE)
            oSByteType     = TypeHelper:GetType ("System.SByte":U, TRUE)
            oDateTimeType  = TypeHelper:GetType ("System.DateTime":U, TRUE)
            oDecimalType   = TypeHelper:GetType ("System.Decimal":U, TRUE)
            oInt16Type     = TypeHelper:GetType ("System.Int16":U, TRUE)
            oUInt16Type    = TypeHelper:GetType ("System.UInt16":U, TRUE)
            oInt32Type     = TypeHelper:GetType ("System.Int32":U, TRUE)
            oUInt32Type    = TypeHelper:GetType ("System.UInt32":U, TRUE)
            oInt64Type     = TypeHelper:GetType ("System.Int64":U, TRUE)
            oUInt64Type    = TypeHelper:GetType ("System.UInt64":U, TRUE)
            oDoubleType    = TypeHelper:GetType ("System.Double":U, TRUE)
            oSingleType    = TypeHelper:GetType ("System.Single":U, TRUE)
            oCharType      = TypeHelper:GetType ("System.Char":U, TRUE)
            oByteArrayType = TypeHelper:GetType ("System.Byte[]":U, TRUE) .

    END CONSTRUCTOR.

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
        DEFINE VARIABLE oFields                 AS "System.Reflection.FieldInfo[]" NO-UNDO .
        DEFINE VARIABLE oProperties             AS "System.Reflection.PropertyInfo[]" NO-UNDO .
        DEFINE VARIABLE oJsonObj                AS JsonObject NO-UNDO.
        DEFINE VARIABLE filter  AS System.Enum.

        filter = Progress.Util.EnumHelper:Add(System.Reflection.BindingFlags:Instance , System.Reflection.BindingFlags:Public).
        filter = Progress.Util.EnumHelper:Add(filter, System.Reflection.BindingFlags:DeclaredOnly).

        oProperties = poType:GetProperties(cast(filter, System.Reflection.BindingFlags)).
        oFields = poType:GetFields(cast(filter, System.Reflection.BindingFlags)).

        {Consultingwerk/foreach.i System.Reflection.PropertyInfo oProperty in oProperties '' propertyloop}
            
            IF CAST (oProperty:GetAccessors(TRUE):GetValue(0), System.Reflection.MethodInfo):IsStatic THEN DO:
                IF NOT VALID-OBJECT (oStaticPropertiesJson) THEN
                    oStaticPropertiesJson = NEW JsonArray () .
                oJsonObj = new JsonObject().
                oJsonObj:add("name", oProperty:Name).
                oJsonObj:add("dataType", this-object:TypeName(oProperty:PropertyType)).
                oStaticPropertiesJson:Add(oJsonObj) .
            END.
            ELSE DO:
                IF NOT VALID-OBJECT (oInstancePropertiesJson) THEN
                    oInstancePropertiesJson = NEW JsonArray () .
                oJsonObj = new JsonObject().
                oJsonObj:add("name", oProperty:Name).
                oJsonObj:add("dataType", this-object:TypeName(oProperty:PropertyType)).
                oInstancePropertiesJson:Add(oJsonObj) .
            END.
        END.

        {Consultingwerk/foreach.i System.Reflection.FieldInfo oField in oFields '' fieldloop}
                IF NOT VALID-OBJECT (oInstancePropertiesJson) THEN
                    oInstancePropertiesJson = NEW JsonArray () .
                oJsonObj = new JsonObject().
                oJsonObj:add("name", oField:Name).
                oJsonObj:add("dataType", this-object:TypeName(oField:FieldType)).
                oInstancePropertiesJson:Add (oJsonObj) .
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

        oMethodsJson = THIS-OBJECT:GetMethods (poType, oMethods, FALSE) .

        IF VALID-OBJECT (oMethodsJson) THEN
            poJson:Add ("methods":U, oMethodsJson) .

        oMethodsJson = THIS-OBJECT:GetMethods (poType, oMethods, TRUE) .

        IF VALID-OBJECT (oMethodsJson) THEN
            poJson:Add ("staticMethods":U, oMethodsJson) .

    END METHOD.

    /**
     * Purpose:
     * Notes:
     * @param poAssembly The reference to the .NET Assembly
     * @param poJsonObject The name of the JSON Array
     */
    METHOD PUBLIC VOID AddTypes (poAssembly AS System.Reflection.Assembly,
                                    poJsonObject AS JsonArray):

        DEFINE VARIABLE oTypeJson  AS JsonObject      NO-UNDO .
        DEFINE VARIABLE oBaseTypes AS JsonArray       NO-UNDO .
        DEFINE VARIABLE oTypes     AS "System.Type[]" NO-UNDO .

        oTypes = poAssembly:GetTypes() .

        {Consultingwerk/foreach.i System.Type oType in oTypes '' typeloop}
            /* IF poJsonObject:Has (oType:FullName) THEN
                NEXT typeloop . */
            IF oType:IsNotPublic THEN NEXT typeLoop.
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
     * @param poType The Type
     * @param poMethods The MethodInfo[]
     * @param plStatic Logical flag indicating if we should be adding static methods or not
     * @return The JsonArray
     */
    METHOD PROTECTED JsonArray GetMethods (poType AS System.Type,
                                           poMethods AS "System.Reflection.MethodInfo[]",
                                           plStatic AS LOGICAL):

        DEFINE VARIABLE oMethodsJson  AS JsonArray                           NO-UNDO .
        DEFINE VARIABLE oParameters   AS "System.Reflection.ParameterInfo[]" NO-UNDO .
        DEFINE VARIABLE oAttributes   AS "System.Object[]"                   NO-UNDO .
        DEFINE VARIABLE cParameters   AS CHARACTER                           NO-UNDO .
        DEFINE VARIABLE oMethodJson   AS JsonObject                          NO-UNDO .
        DEFINE VARIABLE oObsoleteJson AS JsonObject                          NO-UNDO .

        {Consultingwerk/foreach.i System.Reflection.MethodInfo oMethod in poMethods '' methodloop}
            IF oMethod:DeclaringType <> poType THEN
                NEXT methodLoop .

            IF oMethod:IsStatic <> plStatic THEN
                NEXT methodLoop .
            IF oMethod:isSpecialName then
                next methodLoop.

            IF NOT VALID-OBJECT (oMethodsJson) THEN
                oMethodsJson = NEW JsonArray () .

            ASSIGN cParameters = "":U
                   oParameters = oMethod:GetParameters () .

            {Consultingwerk/foreach.i System.Reflection.ParameterInfo oParameter IN oParameters}
                ASSIGN cParameters = cParameters +
                                     SUBSTITUTE (", &3 &1&2":U,
                                                 IF oParameter:IsOut THEN "output ":U ELSE "":U,
                                                 THIS-OBJECT:TypeName(oParameter:ParameterType), oParameter:Name) .
            END .

            ASSIGN cParameters = TRIM (TRIM (cParameters, ",":U)) .

            oAttributes = oMethod:GetCustomAttributes (oObsoleteType, TRUE) .

            oMethodJson = NEW JsonObject ().
            oMethodJson:Add ("name":U, SUBSTITUTE ("&1 (&2)", oMethod:NAME, cParameters)) .
            oMethodJson:Add ("returnType":U, SUBSTITUTE ("&1", THIS-OBJECT:TypeName(oMethod:ReturnType))) .
            IF oAttributes:Length > 0 THEN DO:
                oObsoleteJson = NEW JsonObject () .
                oMethodJson:Add ("obsolete":U, oObsoleteJson) .
                oObsoleteJson:Add ("message":U, CAST (oAttributes:GetValue(0), System.ObsoleteAttribute):Message) .
                oObsoleteJson:Add ("error":U, CAST (oAttributes:GetValue(0), System.ObsoleteAttribute):IsError) .
            END.
            oMethodsJson:Add (oMethodJson) .

        END.

        RETURN oMethodsJson .

    END METHOD.

    /**
     * Purpose: Converts a System.Type to the corresponding ABL DataType in a Character
     *          representation
     * Notes:   Assumes CHARACTER for System.String, not LONGCHAR or BLOB
     *          Returns BLOB for System.Byte[]
     * @param poType The System.Type to convert into an ABL DataType
     * @return The ABL DataType as a CHARACTER Value
     */
    METHOD PROTECTED CHARACTER TypeName (poType AS System.Type):

        IF poType:FullName = "System.Object":U THEN
            RETURN "System.Object":U .

        IF poType:IsAssignableFrom (oStringType) THEN
            RETURN "CHARACTER":U .

        IF poType:IsAssignableFrom (oBooleanType) THEN
            RETURN "LOGICAL":U .

        IF poType:IsAssignableFrom (oByteType) THEN
            RETURN "INTEGER":U .

        IF poType:IsAssignableFrom (oSByteType) THEN
            RETURN "INTEGER":U .

        IF poType:IsAssignableFrom (oDateTimeType) THEN
            RETURN "DATETIME":U .

        IF poType:IsAssignableFrom (oDecimalType) THEN
            RETURN "DECIMAL":U .

        IF poType:IsAssignableFrom (oInt16Type) THEN
            RETURN "INTEGER":U .

        IF poType:IsAssignableFrom (oUInt16Type) THEN
            RETURN "INTEGER":U .

        IF poType:IsAssignableFrom (oInt32Type) THEN
            RETURN "INTEGER":U .

        IF poType:IsAssignableFrom (oUInt32Type) THEN
            RETURN "INTEGER":U .

        IF poType:IsAssignableFrom (oInt64Type) THEN
            RETURN "INT64":U .

        IF poType:IsAssignableFrom (oUInt64Type) THEN
            RETURN "INT64":U .

        IF poType:IsAssignableFrom (oDoubleType) THEN
            RETURN "DECIMAL":U .

        IF poType:IsAssignableFrom (oSingleType) THEN
            RETURN "DECIMAL":U .

        IF poType:IsAssignableFrom (oCharType) THEN
            RETURN "CHARACTER":U .

        IF poType:IsAssignableFrom (oByteArrayType) THEN
            RETURN "MEMPTR":U .

        // Don't include generics information
        IF INDEX(poType:FullName, '`') > 0 THEN
            RETURN SUBSTRING(poType:FullName, 1, INDEX(poType:FullName, '`') - 1).

        RETURN poType:FullName .

    END METHOD .

END CLASS.
