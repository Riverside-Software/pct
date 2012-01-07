
/*      Title:  prolint/rules/release.p                       */
/*    Purpose:  To find Release statements           */
/*   -----------------------------------------------------------------

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
                           "RELEASE":U).             /* list of statements to search, ?=all */


return.

                                                                                
procedure priv-InspectNode :   
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
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
    
    if sChildType% = "" OR sChildType% = "OBJECT" then 
    do:
        parserReleaseHandle(iChild%).
        parserReleaseHandle(iSibling%).
        parserReleaseHandle(iNextSibling%).
        return.
    end.  
                               
                          
                                
                                                                    
    if sNodeType% = "RELEASE":U then 
    do:
        sRecordName% = parserGetNodeText(iChild%). 
        CHILD-LOOP:
        do while sChildType% <> "" :
            case sChildType% :
                when "RECORD_NAME":U then
                do: 
                    sRecordName% = sRecordName% + ' ' + parserGetNodeText(iChild%). 
                    sSiblingType%  = parserNodeFirstChild(iChild%,iSibling%).
                    LEAVE CHILD-LOOP.
                     
                end. /* when "RECORD_NAME":U */

            end case.
            sChildType%    = parserNodeNextSibling(iChild%,iChild%).
        end. /* CHILD-LOOP:*/
 
        run priv-WriteResult(
            input ipiTheNode%,
            input sNodeType%,
            input sRecordName%).
    
    end. /* if sNodeType% = "RELEASE":U */
    
    
                     
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).
    parserReleaseHandle(iNextSibling%).
    
end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsRecordName%      as char         no-undo.
  
def var cdesc% as char no-undo.




    run PublishResult            (compilationunit,
                                  parserGetNodeFilename(ipiTheNode%),
                                  parserGetNodeLine(ipiTheNode%), 
                                  substitute(" RELEASE &1 statement found":T, ipsRecordName%),
                                  rule_id).
end procedure.


