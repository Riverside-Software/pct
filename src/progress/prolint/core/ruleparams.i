/* ------------------------------------------------------------------
   file    : prolint/ruleparams.i
   purpose : parameters and standard stuff for rules
   ------------------------------------------------------------------
   
    Copyright (C) 2001,2002 Jurjen Dijkstra

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   ------------------------------------------------------------------ */

{prolint/core/dlc-version.i}         
                        
{&_proparse_ prolint-nowarn(varusage)}                        
DEFINE INPUT PARAMETER xreffile        AS CHARACTER NO-UNDO.  /* name of file produced by "COMPILE compilationunit XREF xreffile" */
{&_proparse_ prolint-nowarn(varusage)}                        
DEFINE INPUT PARAMETER listingfile     AS CHARACTER NO-UNDO.  /* name of file produced by "COMPILE compilationunit LISTING listingfile" */
DEFINE INPUT PARAMETER hLintSuper      AS HANDLE    NO-UNDO.  /* procedure-handle of prolint/core/lintsuper.p */
DEFINE INPUT PARAMETER hparser         AS HANDLE    NO-UNDO.  /* procedure-handle of prolint/proparse-shim/api/proparse.p */
{&_proparse_ prolint-nowarn(varusage)}                        
DEFINE INPUT PARAMETER hTopnode        AS INTEGER   NO-UNDO.  /* node-handle of the "Program_root"-node */
DEFINE INPUT PARAMETER compilationunit AS CHARACTER NO-UNDO.  /* name of sourcefile under inspection */
DEFINE INPUT PARAMETER severity        AS INTEGER   NO-UNDO.  /* 0=informational, 9=critical */
DEFINE INPUT PARAMETER rule_id         AS CHARACTER NO-UNDO.  /* identifier of this currently running rule */
DEFINE INPUT PARAMETER pragma_number   AS INTEGER   NO-UNDO.  /* attribute set on nodes following _proparse prolint-nowarn(rule_id) */
DEFINE INPUT PARAMETER ignoreAB        AS LOGICAL   NO-UNDO.  /* suppress warnings in AB/UIB generated code? */
{&_proparse_ prolint-nowarn(varusage)}
DEFINE INPUT PARAMETER hpRulePersist   AS HANDLE    NO-UNDO.  /* handle to persistent "rules/persist/[rule_id].p" */
           
IF LOGICAL(DYNAMIC-FUNCTION("ProlintProperty", "filters.IgnoreAppbuilderstuff"))=FALSE THEN
   IgnoreAB = FALSE.

RUN SetRuleParameters IN hLintSuper(pragma_number, severity, ignoreAB).
THIS-PROCEDURE:ADD-SUPER-PROCEDURE(hLintSuper).

{prolint/proparse-shim/api/proparse.i hparser}                         

FUNCTION RelativeFilename RETURNS CHARACTER (pFileName AS CHARACTER) IN hLintSuper.
FUNCTION GetFieldnameFromFieldref RETURNS CHARACTER (INPUT nFieldRef AS INTEGER) IN hLintSuper.
FUNCTION IsInheritedAttribute RETURNS LOGICAL (INPUT classname AS CHARACTER, INPUT varname AS CHARACTER) IN hLintSuper.
                    
