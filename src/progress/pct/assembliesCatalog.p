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

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.PCT.AssembliesCatalog.* FROM PROPATH.
USING Consultingwerk.Studio.AssemblyParser.* FROM PROPATH.
USING Progress.Json.ObjectModel.*            FROM PROPATH.

DEFINE VARIABLE oParser  AS AssemblyParser    NO-UNDO.
DEFINE VARIABLE oCatalog AS AssembliesCatalog NO-UNDO.
DEFINE VARIABLE oJson    AS JsonObject        NO-UNDO.

{ Consultingwerk/Studio/AssemblyParser/ttAssemblies.i }

/* ***************************  Main Block  *************************** */

MESSAGE "Generating assemblies catalog".
oParser = NEW AssemblyParser() .
oParser:GetTable (OUTPUT TABLE ttAssemblies) .

oJson = NEW JsonObject() .
oCatalog = NEW AssembliesCatalog() .

FOR EACH ttAssemblies:
  MESSAGE ttAssemblies.AssemblyEntry .
  oCatalog:AddTypesFromAssembly (ttAssemblies.AssemblyEntry, oJson) .
END.

oJson:WriteFile (SESSION:PARAMETER, TRUE) .
RETURN '0'.
