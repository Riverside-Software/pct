/* ==========================================================================================
    file    : prolint/core/tt_rules.i
    purpose : defines temp-table tt_rules, the list of Prolint rules
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

DEFINE TEMP-TABLE tt_rules NO-UNDO
   FIELD RuleID       AS CHARACTER  FORMAT "x(15)":U
   FIELD severity     AS INTEGER    FORMAT "9":U
   FIELD useproparse  AS LOGICAL    FORMAT "x/ ":U
   FIELD uselisting   AS LOGICAL    FORMAT "x/ ":U
   FIELD usexref      AS LOGICAL    FORMAT "x/ ":U
   FIELD useproclist  AS LOGICAL    FORMAT "x/ ":U
   FIELD ignoreUIB    AS LOGICAL    FORMAT "x/ ":U
   FIELD description  AS CHARACTER  FORMAT "x(60)":U 
   FIELD category     AS CHARACTER
   FIELD required     AS LOGICAL INITIAL TRUE FORMAT "yes/no":U
   FIELD customseverity  AS INTEGER  FORMAT "9":U
   FIELD customrule   AS LOGICAL INITIAL FALSE
   FIELD pragma       AS INTEGER
   FIELD hpRulePersist AS HANDLE
   FIELD sourcefile    AS CHARACTER
   INDEX idx_id   AS PRIMARY RuleID.

