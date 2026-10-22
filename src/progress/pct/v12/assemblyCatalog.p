/**
 * Copyright 2005-2026 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

/* Generates a JSON catalog of all .Net types loaded in the current session, using PCTTools.dll */
/* Parameters: destFile (output file) and pctTools (path to PCTTools.dll) */
/* .Net types are only referenced dynamically, so that this procedure can be compiled without the CLR (i.e. on Linux) */

block-level on error undo, throw.

define variable cDestFile as character no-undo.
define variable cPctTools as character no-undo.
define variable oHandle   as Progress.Lang.Object no-undo.
define variable oCatalog  as Progress.Lang.Object no-undo.
define variable oWriter   as Progress.Lang.Object no-undo.

assign cDestFile = dynamic-function('getParameter' in source-procedure, 'destFile')
       cPctTools = dynamic-function('getParameter' in source-procedure, 'pctTools').

message substitute("Generating assembly catalog in &1", cDestFile).

/* Equivalent of Assembly:LoadFrom(cPctTools):CreateInstance("PCTTools.AssemblyCatalog"), */
/* as dynamic calls on System.Reflection.Assembly objects crash the CLR bridge */
assign oHandle  = dynamic-invoke("System.Activator", "CreateInstanceFrom", cPctTools, "PCTTools.AssemblyCatalog")
       oCatalog = dynamic-invoke(oHandle, "Unwrap").
/* PCTTools trace output is kept in memory, and displayed at the end */
oWriter = dynamic-new "System.IO.StringWriter" ().
dynamic-invoke(oCatalog, "SetWriter", oWriter).
dynamic-property(oCatalog, "UseOeTypes") = true.

dynamic-invoke(oCatalog, "GenerateDocumentationFromAppDomain").
dynamic-invoke(oCatalog, "ToJsonFile", cDestFile).
run displayLog.

message "Assembly catalog generated".

return '0'.

catch e as Progress.Lang.Error:
  run displayLog.
  message substitute("Unable to generate assembly catalog: &1", e:GetMessage(1)).
  return '1'.
end catch.

procedure displayLog private:
  define variable cLog as character no-undo.
  define variable i    as integer   no-undo.

  if not valid-object(oWriter) then return.
  assign cLog = replace(string(dynamic-invoke(oWriter, "ToString")), "~r", "").
  do i = 1 to num-entries(cLog, "~n"):
    if entry(i, cLog, "~n") <> "" then
      message entry(i, cLog, "~n").
  end.
end procedure.
