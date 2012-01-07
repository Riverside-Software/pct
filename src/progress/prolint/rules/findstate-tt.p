/* -----------------------------------------------------------------------------
   file    :  prolint/rules/findstate-tt.p
   by      :  Breck Fairley, Jamie Ballarin
   purpose :  To find Find statements that don't have a qualifier
              This rule only looks at temp-tables; real tables are
              looked at by rule "findstate"
   ----------------------------------------------------------------------------
    Copyright (C) 2001,2002 Breck Fairley, Jamie Ballarin, Jurjen Dijkstra

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
   -------------------------------------------------------------------------- */


{prolint/core/ruleparams.i}  

run searchNode            (
    input hTopnode,              /* "Program_root" node                 */
    input "priv-InspectNode":U,  /* name of callback procedure          */
    input "FIND":U).             /* list of statements to search, ?=all */

return.


FUNCTION IfFindByRowid RETURNS LOGICAL ( INPUT theNode AS INTEGER, INPUT id AS CHARACTER ) :
    /* purpose : "FIND buffer WHERE ROWID(buffer)=rw" requires no FIRST|LAST|PREV|NEXT */

    DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodeRowid  AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodeParent AS INTEGER NO-UNDO.
    DEFINE VARIABLE i          AS INTEGER NO-UNDO.
    DEFINE VARIABLE foundMatch AS LOGICAL NO-UNDO INITIAL NO.

    numResults = parserQueryCreate(TheNode, "qryROWID":U, id).
    IF numResults > 0 THEN DO:
       ASSIGN
           nodeRowid  = parserGetHandle()
           nodeParent = parserGetHandle()
           i          = 1.
       DO WHILE i<=numResults AND NOT foundMatch :
          parserQueryGetResult("qryROWID":U, i, nodeRowid).
          IF "EQ":U = parserNodeParent(nodeRowid, nodeParent) THEN
             foundMatch = TRUE.
          i = i + 1.
       END.
       parserReleaseHandle(nodeRowid).
       parserReleaseHandle(nodeParent).
    END.
    parserQueryClear("qryROWID":U).

    RETURN foundMatch.

END FUNCTION.


procedure priv-InspectNode :   
/*    Purpose:  To Inspect Find statements to check for findwhich qualifier */

def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var lFindWhere%     as logi initial false           no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sRecordName%    as char                         no-undo.
def var iSibling%       as inte                         no-undo.
def var sSiblingType%   as char                         no-undo.   
def var iSiblingChild%  as inte                         no-undo.
def var sSibChildType%  as char                         no-undo.

    IF IfFindByRowid(ipiTheNode%, "ROWID":U) THEN
       RETURN.
    IF IfFindByRowid(ipiTheNode%, "RECID":U) THEN
       RETURN.

    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign
        iChild%        = parserGetHandle()
        iSibling%      = parserGetHandle()
        iSiblingChild% = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%)
        sSiblingType%  = parserNodeNextSibling(ipiTheNode%,iSibling%)
        sSibChildType% = parserNodeFirstChild(iSibling%,iSiblingChild%).

    if sChildType% = "" then
    do:
        parserReleaseHandle(iChild%).
        parserReleaseHandle(iSibling%).
        parserReleaseHandle(iSiblingChild%).
        return.
    end.  

    /* ignore real database tables, only look at temp-tables */
    IF sChildType% = "RECORD_NAME":U THEN
       IF parserAttrGet(iChild%,"storetype":U) = "st-dbtable":U THEN
       DO:
          parserReleaseHandle(iChild%).
          parserReleaseHandle(iSibling%).
          parserReleaseHandle(iSiblingChild%).
          return.
       END.
                                                                   
    /* Check the Find statement for the findWhich qualifier that should follow   */
    /* or if a find statement has no findwhich then find the ambiguous statement */
    /* that follows directly after the Find statement.                           */
    if sNodeType% = "FIND":U then 
    do:
        case sChildType%:
            when "FIRST":U then
                lFindWhere% = true.
            when "LAST":U then
                lFindWhere% = true.
            when "NEXT":U then
                lFindWhere% = true.
            when "PREV":U then
                lFindWhere% = true.
            when "CURRENT":U then
                lFindWhere% = true.
            otherwise
            do:
                if sSiblingType% = "IF":U then
                    if sSibChildType% <> "AMBIGUOUS":U then
                        assign
                            lFindWhere%  = false
                            sRecordName% = parserGetNodeText(iChild%).
                    else
                        lFindWhere% = true.
                else
                    assign
                        lFindWhere%  = false
                        sRecordName% = parserGetNodeText(iChild%).
            end.
        end case.
    end.
    
    if not lFindWhere% then
       run priv-WriteResult (
           input ipiTheNode%,
           input sNodeType%,
           input sRecordName% ).
                     
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).
    parserReleaseHandle(iSiblingChild%).
    
end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */

def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsRecordName%      as char         no-undo.
  

    run PublishResult            (
        input compilationunit,
        input parserGetNodeFilename(ipiTheNode%),
        input parserGetNodeLine(ipiTheNode%), 
        input substitute("&1 &2 statement defined without qualifer [ FIRST | LAST | NEXT | PREV | CURRENT ]":T, ipsNodeType%, ipsRecordName%),
        input rule_id ).
        
end procedure.


