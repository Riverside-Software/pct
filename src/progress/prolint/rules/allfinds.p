/*      Title:  Find all FIND and CAN-FIND Statements                       */
/*    Purpose:  To find all Find statements and display them seperately     */
/*              for each qualifier type                                     */
/*   -----------------------------------------------------------------

    Copyright (C) 2002 Murray Hermann

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
   ------------------------------------------------------------------------ */

{prolint/core/ruleparams.i}

run searchNode            (hTopnode,              /* "Program_root" node                 */
                           "priv-InspectNode":U,  /* name of callback procedure          */
                           "FIND,CANFIND":U).             /* list of statements to search, ?=all */

return.

                                                                                
procedure priv-InspectNode :   
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var lWrite%         as logi initial false           no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sRecordName%    as char                         no-undo.
def var iSibling%       as inte                         no-undo.
def var sSiblingType%   as char                         no-undo.   
def var sStoreType%     as char                         no-undo.   

    
    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign
        iChild%        = parserGetHandle()
        iSibling%      = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%)
        sSiblingType%  = parserNodeNextSibling(ipiTheNode%,iSibling%).
    
    if sChildType% = "" then 
    do:
        parserReleaseHandle(iChild%).
        parserReleaseHandle(iSibling%).
        return.
    end.  
                                                                  
    /* Search for Find statements and can-find statements and seperate by the */
    /* findWhich qualifier that should follow.                                  */
    case sNodeType%: 
        when "CANFIND":U or when "FIND":U then
        do:
            if sNodeType% = "CANFIND":U then
                lWrite% = yes.

            CHILD-LOOP:
            do while sChildType% <> "" :
                case sChildType%:
                    when "FIRST":U then
                    do:
                        sNodeType% = sNodeType% + ' ' + sChildType%.
                        lWrite% = yes.
                    end.
                    when "LAST":U then
                    do:
                        sNodeType% = sNodeType% + ' ' + sChildType%.
                        lWrite% = yes.                    
                    end.
                    when "PREV":U then
                    do:
                        sNodeType% = sNodeType% + ' ' + sChildType%.
                        lWrite% = yes.
                    end.
                    when "NEXT":U then
                    do:
                        sNodeType% = sNodeType% + ' ' + sChildType%.
                        lWrite% = yes.
                    end.
                    when "RECORD_NAME":u THEN DO:
                        sRecordName% = parserGetNodeText(iChild%).
                        sStoretype% = parserAttrGet(iChild%,"storetype":U).
                    END.
                        
                end case.
                
                sChildType%    = parserNodeNextSibling(iChild%,iChild%).
            end.
            
            /* we are doing this for dataserver compatibility, so we are not interested in temp-tables and work-tables */
            IF sStoretype% <> "st-dbtable":U THEN lWrite% = FALSE.
        end.

    end case.

    if lWrite% then
        run priv-WriteResult(
            input ipiTheNode%, 
            input sNodeType%,
            input sRecordName%,
            input "statement included.").
                     
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).
    
end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsRecordName%      as char         no-undo.
def input param ipsString%          as char         no-undo.
  

    run PublishResult            (compilationunit,
                                  parserGetNodeFilename(ipiTheNode%),
                                  parserGetNodeLine(ipiTheNode%), 
                                  substitute("&1 &2 &3":T, ipsNodeType%, ipsRecordName%,ipsString%),
                                  rule_id).
end procedure.


