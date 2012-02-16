/*      Title:  Find all Matches                                            */
/*    Purpose:  To find all uses of the Matches operator                    */
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

run searchNode            (hTopnode,              /* "Program_root" node                 */
                           "priv-InspectNode":U,  /* name of callback procedure          */
                           "MATCHES":U).             /* list of statements to search, ?=all */

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
DEF VAR parentnode      AS INTEGER                      NO-UNDO.
DEF VAR parentnodetype  AS CHARACTER                    NO-UNDO.   
    
    /* MATCHES is not always bad, only when you are using it to search in a database, 
       in other words when MATCHES appears in a WHERE clause */     
    /* look at parent, grandparent, greatgrandparent etc... 
       if none of them is a "WHERE" keyword, then assign lWrite%=NO */
    
    parentnode = parserGetHandle().
    parentnodetype = parserNodeParent(ipiTheNode%,parentnode).
    IF parentnodetype="WHERE":U THEN 
       lWrite% = TRUE.
    DO WHILE parentnodetype>"" AND lWrite%=false: 
       parentnodetype = parserNodeParent(parentnode,parentnode).
       IF parentnodetype="WHERE":U THEN 
          lWrite% = TRUE.
    END.
    parserReleaseHandle(parentnode).
    
    if lWrite% then
        run priv-WriteResult(
            input ipiTheNode%, 
            input "MATCHES":U).
                     
    
end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.

    run PublishResult            (compilationunit,
                                  parserGetNodeFilename(ipiTheNode%),
                                  parserGetNodeLine(ipiTheNode%), 
                                  substitute("&1 statement used in this program":T, ipsNodeType%),
                                  rule_id).
end procedure.


