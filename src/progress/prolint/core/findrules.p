/* ==========================================================================================
    file    : prolint/core/findrules.p
    purpose : populate tt_rules, the list of all available rules
    -----------------------------------------------------------------------------------------
    
    Copyright (C) 2008 Jurjen Dijkstra

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
   ========================================================================================== */

/*
Search order:
Prolint will search rule *definitions* in the following order:
1. prolint/contribs/rules
2. extend and override the results from (1) by prolint/rules
3. extend and override the results from (2) by prolint/custom/rules

Execution order:
Prolint will search rule *code* in the following order:
1. prolint/custom/rules
2. when not found, search the rule in prolint/rules
3. when not found, search the rule in prolint/contribs/rules
*/


{prolint/core/tt_rules.i}
define input parameter profile as character no-undo.
define output parameter table for tt_rules.

define temp-table tt_severity
    field required as logical 
    field RuleId   as character 
    field severity as integer initial -1
   INDEX idx_id   AS PRIMARY RuleID.

define stream rulemanifest.
IF profile<>"/all/":U then
   run ImportProfile.
run ImportRules.

procedure ImportProfile :
   /* import the profile definitions, because it gives us a list of rules to skip. That saves time. */
   define variable ProfileDirectory  as character no-undo.
   define variable foundlocally      AS LOGICAL NO-UNDO INITIAL FALSE.
   define variable no-override       AS LOGICAL NO-UNDO INITIAL FALSE.
    
   run prolint/core/getprofiledir.p (input profile, output ProfileDirectory, output foundlocally, output no-override).
   
   FILE-INFO:FILE-NAME = ProfileDirectory + "/severity.d":U.
   IF FILE-INFO:FULL-PATHNAME = ? THEN
      ProfileDirectory = "prolint/settings":U.

   FILE-INFO:FILE-NAME = ProfileDirectory + "/severity.d":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).
      REPEAT:
         create tt_severity.
         import tt_severity.
      END.
      INPUT CLOSE.
   END.
   for each tt_severity where tt_severity.ruleid="" :
       delete tt_severity.
   end.
    
END PROCEDURE.


PROCEDURE ImportRules :
   DEFINE BUFFER buf_rules FOR tt_rules.
   DEFINE VARIABLE skippedrule AS CHARACTER NO-UNDO.
   DEFINE VARIABLE sourcelocation   AS CHARACTER NO-UNDO.

   /* import custom rules (e.g. those NOT shipped by Prolint) */
   FILE-INFO:FILE-NAME = "prolint/custom/rules/rules.d":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).
      REPEAT:
         CREATE tt_rules.
         IMPORT tt_rules EXCEPT tt_rules.customrule tt_rules.pragma tt_rules.hpRulePersist tt_rules.sourcefile.
         tt_rules.customrule = FALSE.
         IF CAN-FIND(buf_rules WHERE buf_rules.RuleID=tt_rules.RuleID AND ROWID(buf_rules) NE ROWID(tt_rules)) THEN 
            DELETE tt_rules.
      END.
      INPUT CLOSE.
   END.
   FOR EACH tt_rules WHERE tt_rules.RuleID = "" :
       DELETE tt_rules.
   END.
   
   /* import the default rules (e.g. those installed from Prolint website) */
   FILE-INFO:FILE-NAME = "prolint/rules/rules.d":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).    
      REPEAT:
         CREATE tt_rules.
         IMPORT tt_rules  EXCEPT tt_rules.customrule tt_rules.pragma tt_rules.hpRulePersist tt_rules.sourcefile.
         tt_rules.customrule = FALSE.
         IF CAN-FIND(buf_rules WHERE buf_rules.RuleID=tt_rules.RuleID AND ROWID(buf_rules) NE ROWID(tt_rules)) THEN 
            DELETE tt_rules.
      END.
      INPUT CLOSE.
   END.
   FOR EACH tt_rules WHERE tt_rules.RuleID = "" :
       DELETE tt_rules.
   END.

   /* import contributed rules */
   RUN ImportRulesFromDirectory ("prolint/contribs/rules":U).   
   FOR EACH tt_rules WHERE tt_rules.RuleID = "" :
       DELETE tt_rules.
   END.
                                             
   /* skip rules which are listed in prolint/custom/rules/skiprules.d */
   FILE-INFO:FILE-NAME = "prolint/custom/rules/skiprules.lst":U.
   IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
      INPUT FROM VALUE(file-info:FULL-PATHNAME).
      REPEAT:
         IMPORT UNFORMATTED skippedrule.
         skippedrule = TRIM(skippedrule).
         FOR EACH tt_rules WHERE tt_rules.RuleID=skippedrule :
            DELETE tt_rules.
         END.
      END.
      INPUT CLOSE.
   END.

   /* adjust severity based on the selected profile, or skip the rule entirely */
   FOR EACH tt_severity :
       FIND tt_rules WHERE tt_rules.RuleID = tt_severity.RuleId NO-ERROR.
       IF AVAILABLE tt_rules THEN DO:
           IF NOT tt_severity.required THEN
             DELETE tt_rules.
           ELSE 
             IF tt_severity.severity <> -1 THEN
                ASSIGN tt_rules.severity = tt_severity.severity.
       END.
   END.

   /* locate the source for each rule: decide if it is a custom rule */
   FOR EACH tt_rules :
       sourcelocation = "prolint/custom/rules/":U + tt_rules.RuleId + ".p":U.
       IF SEARCH("prolint/custom/rules/":U + tt_rules.RuleId + ".p":U) <> ?
          OR SEARCH("prolint/custom/rules/":U + tt_rules.RuleId + ".r":U) <> ? THEN
          ASSIGN tt_rules.customrule = TRUE
                 tt_rules.sourcefile = sourcelocation.
       ELSE DO:
          sourcelocation = "prolint/rules/":U + tt_rules.RuleId + ".p":U.
          IF SEARCH("prolint/rules/":U + tt_rules.RuleId + ".p":U) <> ?
             OR SEARCH("prolint/rules/":U + tt_rules.RuleId + ".r":U) <> ? THEN
             tt_rules.sourcefile = sourcelocation.
          ELSE DO:
             sourcelocation = "prolint/contribs/rules/":U + tt_rules.RuleId + ".p":U.
             IF SEARCH("prolint/contribs/rules/":U + tt_rules.RuleId + ".p":U) <> ? 
                OR SEARCH("prolint/contribs/rules/":U + tt_rules.RuleId + ".r":U) <> ? THEN
                tt_rules.sourcefile = sourcelocation.
          END.
       END. 
   END.

   /* custom rules that dont have a category, are category "custom" */
   FOR EACH tt_rules WHERE tt_rules.category = "" OR tt_rules.customrule=TRUE :
       tt_rules.category = "Custom":T.
   END.

   /* sanity check:
      rules that don't need proparse or xref or listing are nonsense  */
   FOR EACH tt_rules WHERE tt_rules.useproparse=NO AND tt_rules.uselisting=NO AND tt_rules.usexref=NO :
       DELETE tt_rules.
   END.

END PROCEDURE.



PROCEDURE ImportRulesFromDirectory :
    define input parameter basepath as character no-undo.
    
    define variable basename as character no-undo.
    define variable line as character no-undo.
    define variable newruleid as character no-undo.
    
    FILE-INFO:FILE-NAME = basepath.
    IF FILE-INFO:FULL-PATHNAME<>? THEN DO:
       basepath = FILE-INFO:FULL-PATHNAME.
       INPUT FROM OS-DIR (basepath).
       REPEAT:
          IMPORT basename.
          IF basename matches "*~~.p":U then do:
              /* save some time: skip import when the profile-definition says that you can skip this rule */
              newruleid = lc(substring(basename, 1, length(basename) - 2)).
              find tt_severity where tt_severity.RuleId = newruleid no-error.
              if not (available tt_severity and tt_severity.required=no) then do: 
                  find tt_rules where tt_rules.RuleId = newruleid no-error.
                  if not available tt_rules then do: 
                      create tt_rules.
                      assign tt_rules.severity = 5
                             tt_rules.useproparse = no
                             tt_rules.uselisting = no
                             tt_rules.useproclist = no
                             tt_rules.usexref = no
                             tt_rules.ignoreUIB = no
                             tt_rules.customrule = no
                             tt_rules.description = "rule has no description":T
                             tt_rules.category = "nocategory":U
                             tt_rules.RuleID = newruleid
	/*                         tt_rules.sourcefile = basepath + "/":U + basename  */
                             .
                             
                      /* Read the manifest file that specifies the Prolint settings for this rule.
	                     The manifest is embedded in the first comment of the sourcefile of the rule */        
                      INPUT STREAM rulemanifest FROM VALUE(basepath + "/":U + basename).
                      block_readmanifest:
                      REPEAT:
                         IMPORT stream rulemanifest unformatted line.
                         IF line matches "*~~*/":U then 
                            LEAVE block_readmanifest.
                         if line matches "*description*:*":U THEN 
                            tt_Rules.description = trim(substring(line, index(line, ":":U) + 1)).
                         if line matches "*category*:*":U THEN 
                            tt_Rules.category = trim(entry(2, line, ":":U )).
                         if line matches "*severity*:*":U THEN 
                            tt_Rules.severity = integer(trim(entry(2, line, ":":U ))).
                         if line matches "*useproparse*:*":U THEN 
                            tt_Rules.useProparse = logical(trim(entry(2, line, ":":U ))).
                         if line matches "*useListing*:*":U THEN 
                            tt_Rules.uselisting = logical(trim(entry(2, line, ":":U ))).
                         if line matches "*useProclist*:*":U THEN 
                            tt_Rules.useProclist = logical(trim(entry(2, line, ":":U ))).
                         if line matches "*useXref*:*":U THEN 
                            tt_Rules.useXref = logical(trim(entry(2, line, ":":U ))).
                         if line matches "*ignoreUIB*:*":U THEN 
                            tt_Rules.ignoreUIB = logical(trim(entry(2, line, ":":U ))).
                      END.
                      INPUT STREAM rulemanifest CLOSE.
                      if available tt_severity and tt_severity.severity<>-1 then 
                         tt_rules.severity = tt_severity.severity.
                  end.
              end.
          END.
       END.
       INPUT CLOSE.
    END.
           
END PROCEDURE.

