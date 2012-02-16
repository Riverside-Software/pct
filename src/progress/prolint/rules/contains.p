/*    Purpose:  To find all uses of the contains operator
   -----------------------------------------------------------------

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
def var scontainsId%       as char                         no-undo.

run searchNode            (hTopnode,              /* "Program_root" node                 */
                           "priv-InspectNode":U,  /* name of callback procedure          */
                           "CONTAINS":U).             /* list of statements to search, ?=all */

return.

                                                                                
procedure priv-InspectNode :   
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo.
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sSiblingType%   as char                         no-undo.
def var iSibling%       as inte                         no-undo.
def var lContains%      as logi                         no-undo.
def var lScroller%      as logi                         no-undo.
def var lWrite%         as logi                         no-undo.
def var sContains%    as char                         no-undo.

    
    /* Assign handles and pointers to specific nodes in the Parse Tree */
    assign
        iChild%        = parserGetHandle()
        iSibling%      = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%).
        
    
    if sNodeType% = "CONTAINS":U then
    do:

        sSiblingType%  = parserNodeFirstChild(ipiTheNode%,iSibling%).
        
        SIB-LOOP:
        do while sSiblingType% <> "" :
            
            if sSiblingType% = "QSTRING":U then
                sNodeType% = sNodeType% + ' ' + parserGetNodeText(iSibling%).
                
            if sSiblingType% = "Field_ref" then
            do:
                sChildType% = parserNodeFirstChild(iSibling%,iChild%).
                do while sChildType% <> "" :
                    
                    if sChildType% = "ID":U then
                        sContains%  = parserGetNodeText(iChild%).
            
                    sChildType% = parserNodeNextSibling(iChild%,iChild%).    
                end.

            end.
            sSiblingType%  = parserNodeNextSibling(iSibling%,iSibling%).

         end. /* SIB-LOOP: */
         
         lWrite% = yes.

    end.

    if lWrite% then
        run priv-WriteResult(
            input ipiTheNode%, 
            input sNodeType%,
            input sContains%).

                     
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).


end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsContains%      as char         no-undo.

    run PublishResult            (
          compilationunit,
          parserGetNodeFilename(ipiTheNode%),
          parserGetNodeLine(ipiTheNode%), 
          substitute("&1 operation used to search &2 (word index).":T, ipsNodeType%,ipsContains%),
          rule_id).
end procedure.


