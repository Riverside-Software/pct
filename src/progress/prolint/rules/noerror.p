
/*      Title:  Find FIND Statements Without NO-ERROR                       */
/*    Purpose:  To find Find statements that don't have 'no-error'          */
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
                           "FIND":U).             /* list of statements to search, ?=all */

return.

                                                                                
procedure priv-InspectNode :   
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var lnoerror%       as logi initial false           no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sRecordName%    as char                         no-undo.
def var iSibling%       as inte                         no-undo.
def var sSiblingType%   as char                         no-undo.   
def var sNextSibType%   as char                         no-undo.
def var iNextSibling%   as inte                         no-undo.

    
    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign
        iChild%        = parserGetHandle()
        iSibling%      = parserGetHandle()
        iNextSibling%  = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%).
    
    if sChildType% = "" then 
    do:
        parserReleaseHandle(iChild%).
        parserReleaseHandle(iSibling%).
        parserReleaseHandle(iNextSibling%).
        return.
    end.  
                                                                   
    /* Check the Find statement for the findWhich qualifier that should follow   */
    /* or if a find statement has no findwhich then find the ambiguous statement */
    /* that follows directly after the Find statement.                           */
    if sNodeType% = "FIND":U then 
    do:
        sRecordName% = parserGetNodeText(iChild%). 
        CHILD-LOOP:
        do while sChildType% <> "" :
            
            case sChildType% :
                when "RECORD_NAME":U then
                do: 
                    sRecordName% = sRecordName% + ' ' + parserGetNodeText(iChild%). 
                    sSiblingType%  = parserNodeFirstChild(iChild%,iSibling%).
     
                    SIB-LOOP:
                    do while sSiblingType% <> "" :

                        case sSiblingType%:
                            when "NOERROR":U then
                            do:
                                lNoError% = yes. 
                                leave SIB-LOOP.
                            end.
                        end case.
                        
                        sSiblingType%  = parserNodeNextSibling(iSibling%,iSibling%).
                    
                     end. /* SIB-LOOP: */
    
                end. /* when "RECORD_NAME":U */

            end case.
            sChildType%    = parserNodeNextSibling(iChild%,iChild%).
        
        end. /* CHILD-LOOP:*/
    
    end. /* if sNodeType% = "FIND":U */
    
    if not lNoError% then
        run priv-WriteResult(
            input ipiTheNode%,
            input sNodeType%,
            input sRecordName%).
                     
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).
    parserReleaseHandle(iNextSibling%).
    
end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsRecordName%      as char         no-undo.
  

    run PublishResult            (compilationunit,
                                  parserGetNodeFilename(ipiTheNode%),
                                  parserGetNodeLine(ipiTheNode%), 
                                  substitute("find &1 statement defined without no-error":T, ipsRecordName%),
                                  rule_id).
end procedure.


