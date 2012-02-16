/* -----------------------------------------------------------------------------
   file    :  prolint/rules/namecheck.p
   by      :  Carl Verbiest
   purpose :  Default logic for naming convention checks,
              copy this file to prolint/custom/rules and adapt to your convention
   -----------------------------------------------------------------------------

    Copyright (C) 2005 Carl Verbiest

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
   --------------------------------------------------------------------------------- */

{prolint/core/ruleparams.i}  
{prolint/rules/nameconv.i}

PROCEDURE ObjectNameCheck:
    DEFINE PARAMETER BUFFER btt_Object FOR tt_Object.

    DEFINE VARIABLE lPrefix AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lcaseName AS CHARACTER NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE lProcName AS CHARACTER  NO-UNDO.
    
    ASSIGN
        lProcName = btt_Object.ObjScope 
        lCaseName = btt_Object.ObjName.
    CASE btt_Object.ParamType:
        WHEN "INPUT":U THEN lPrefix = "i".
        WHEN "OUTPUT":U THEN lPrefix = "o".
        WHEN "INPUTOUTPUT":U THEN lPrefix = "io".
        OTHERWISE DO:
            IF lProcName = "MAIN":U THEN
                lPrefix = "g".
            ELSE lPrefix = "l".
        END.
    END CASE.

    if keyword-all(btt_Object.ObjName) ne ? then
        RUN PublishResult            (
            input compilationunit,
            input btt_Object.sourcefile,
            input btt_Object.linenumber, 
            input substitute('&3 in &6 is a Progress keyword':T,
                btt_Object.ParamType,
                btt_Object.ObjType,
                btt_Object.ObjName, 
                btt_Object.ObjDataType, 
                btt_Object.ObjScope, 
                btt_Object.ProcName, 
                lPrefix),
            input rule_id ).
    IF NOT lcaseName BEGINS lPrefix THEN
        RUN PublishResult            (
            input compilationunit,
            input btt_Object.sourcefile,
            input btt_Object.linenumber, 
            input substitute('&1 &2 &3 &4 scope &5 &6 should start with "&7"':T,
                btt_Object.ParamType,
                btt_Object.ObjType,
                btt_Object.ObjName, 
                btt_Object.ObjDataType, 
                btt_Object.ObjScope, 
                btt_Object.ProcName, 
                lPrefix),
            input rule_id ).

END PROCEDURE.
