/*      Title:  Find all get last and get prev query statements             */
/*    Purpose:  To find all get last and get prev query statements         */
/*  -----------------------------------------------------------------

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
def var sQueryId%       as char                         no-undo.

run searchNode            (hTopnode,              /* "Program_root" node                 */
                           "priv-InspectNode":U,  /* name of callback procedure          */
                           "DEFINE":U).             /* list of statements to search, ?=all */

return.

                                                                                
procedure priv-InspectNode :   
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var lQuery%         as logi                         no-undo.
def var lScroller%      as logi                         no-undo.

    
    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign
        iChild%        = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%).
    
    if sChildType% = "" then 
    do:
        parserReleaseHandle(iChild%).
        return.
    end.  
    
                                                                  
    if sNodeType% = "DEFINE":U  then
    do:
        CHILD-LOOP:
        do while sChildType% <> "" :

            case sChildType% :
                when "QUERY":U then
                    lQuery% = yes.    
                when "ID":U then
                    if lQuery% then
                        sQueryId% = parserGetNodeText(iChild%). 
                when "SCROLLING":U then
                    if lQuery% then
                        lScroller% = yes.
            end case.
        
            sChildType%    = parserNodeNextSibling(iChild%,iChild%).
        end.
        
    end.

    /* If this Query is defined without the SCROLLER option then  check for */
    /* uses of get last and get previous*/
    if lQuery% = yes and lScroller% = no then
        run searchNode            (hTopnode,              /* "Program_root" node                 */
                                   "priv-GetNode":U,  /* name of callback procedure          */
                                   "GET":U).             /* list of statements to search, ?=all */
                     
    parserReleaseHandle(iChild%).


end procedure.                            

procedure priv-GetNode :
def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var lWrite%         as logi initial false           no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sQueryName%    as char                         no-undo.
def var sSiblingType%   as char                         no-undo.   


    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign
        iChild%        = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%).

    if sChildType% = "" then 
    do:
        parserReleaseHandle(iChild%).
        return.
    end.  


    if sNodeType% = "GET":U  then
    do:
        CHILD-LOOP:
        do while sChildType% <> "" :

            case sChildType% :
                when "LAST":U then
                    assign
                        lWrite% = yes
                        sNodeType% = sNodeType% + ' ' + sChildType%.
                when "PREV":U then
                    assign
                        lWrite% = yes
                        sNodeType% = sNodeType% + ' ' + sChildType%.
                when "ID":U then
                do:
                    sQueryName% = parserGetNodeText(iChild%).
                   
                    if sQueryId% <> sQueryName% then
                        lWrite% = no.
                end.
            end case.

            sChildType%    = parserNodeNextSibling(iChild%,iChild%).
        end.

    end.


    if lWrite% then
        run priv-WriteResult(
            input ipiTheNode%, 
            input sNodeType%,
            input sQueryName%).

    parserReleaseHandle(iChild%).

end procedure. 

procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsQueryName%      as char         no-undo.

    run PublishResult            (
          compilationunit,
          parserGetNodeFilename(ipiTheNode%),
          parserGetNodeLine(ipiTheNode%), 
          substitute("&1 &2 QUERY statement used without the SCROLLING keyword in the DEFINE statement":T, ipsNodeType%,ipsQueryName%),
          rule_id).
end procedure.


