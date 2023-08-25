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

block-level on error undo, throw.

using Progress.Json.ObjectModel.JsonArray from propath.

define variable oCatalog    as Consultingwerk.PCT.AssembliesCatalog.AssembliesCatalog no-undo.
define variable oJson       as JsonArray                      no-undo.
define variable oAssembly   as System.Reflection.Assembly     no-undo.
define variable oAssemblies as "System.Reflection.Assembly[]" no-undo.
define variable oEnum       as System.Collections.IEnumerator no-undo.

/* ***************************  Main Block  *************************** */

message "Generating assemblies catalog".

assign oJson = new JsonArray().
assign oCatalog = new Consultingwerk.PCT.AssembliesCatalog.AssembliesCatalog().
assign oAssemblies = System.AppDomain:CurrentDomain:GetAssemblies().
assign oEnum = cast(oAssemblies , System.Collections.IEnumerable):GetEnumerator().
oEnum:reset().
do while oEnum:MoveNext() on error undo, throw:
  assign oAssembly = cast(oEnum:Current, System.Reflection.Assembly).
  message substitute("  -> Generating &1 catalog", oAssembly:FullName).
  oCatalog:AddTypes (oAssembly, oJson) .
end.
message "Catalog generated".

oJson:WriteFile (session:parameter, true).

return '0'.
