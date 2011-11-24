/* ----------------------------------------------------------------------------
   file    :  prolint/rules/ttnoindex.p
   by      :  Breck Fairley, Jamie Ballarin
   purpose :  To Find instances of temptables defined with no custom indexes
   ----------------------------------------------------------------------------
    Copyright (C) 2001,2002 Breck Fairley, Jamie Ballarin

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
   --------------------------------------------------------------------------- */

{prolint/core/ruleparams.i}  
{prolint/core/ttprocedure.i}

                 
run searchnode            (
    input hTopnode,         /* "Program_root" node                 */
    input "Inspectnode":U,  /* name of callback procedure          */
    input "DEFINE":U).      /* list of statements to search, ?=all */

return.


                           
procedure Inspectnode :             
/* purpose : callback from searchnode. Inspect the node found by searchnode */

def input  param iTheNode%              as inte                 no-undo.
def output param lAbortSearch%          as logi initial no      no-undo.
def output param lSearchChildren%       as logi                 no-undo.

def var iChild%             as inte             no-undo.
def var iNextChild%         as inte             no-undo.
def var iLikeChild%         as inte             no-undo.
def var lHaveIndex%         as logi             no-undo.
def var lHasLike%           as logi             no-undo.
def var sChildType%         as char             no-undo.
def var sNextChildType%     as char             no-undo.
def var sLikeChildType%     as char             no-undo.
def var sTempTableName%     as char             no-undo.
def var lIsTempTable%       as logi             no-undo.
def var sTableName%         as char             no-undo.


    assign
        lSearchChildren% = false  /* a def statement can't contain more def statements */
        iChild%          = parserGetHandle()
        iNextChild%      = parserGetHandle()
        iLikeChild%      = parserGetHandle()
        sChildType%      = parserNodeFirstChild(iTheNode%,iChild%)
        lHaveIndex%      = no
        lHasLike%        = no.
                        
    /* Loop the child nodes to find the TEMPTABLE and related nodes */
    CHILD-LOOP:
    do while sChildType% <> "" :
        
        case sChildType%:

            when "TEMPTABLE":U then
                 lIsTempTable% = Yes.

            when "ID":U then
                 sTempTableName% = parserGetNodeText(iChild%).      
                
            when "LIKE":U then
            do:
                sLikeChildType%  = parserNodeFirstChild(iChild%,iNextChild%).
                
                /* Checck the nodes of the LIKE statement for the USEINDEX key word */
                LIKE-LOOP:
                do while sLikeChildType% <> "" :
                    lHasLike%   = yes.
                    if sLikeChildType% = "USEINDEX":U then
                    do:    
                        lHaveIndex% = yes.
                        leave CHILD-LOOP.
                    end.
                    if sLikeChildType% = "RECORD_NAME":U then
                        sTableName% = parserGetNodeText(iNextChild%).

                    sLikeChildType%  = parserNodeNextSibling(iNextChild%,iNextChild%).

                end. /* LIKE-LOOP */

            end.

            when "INDEX":U then
            do:    
                lHaveIndex% = yes.
                leave CHILD-LOOP.
            end.

        end case.
        sChildType%  = parserNodeNextSibling(iChild%,iChild%).

    end. /* CHILD-LOOP: */

    /* Only report those warnings for temptables that are defined LIKE a table */
    if lIsTempTable% then
    do:
        if not lHasLike% then
            lHaveIndex% = yes.
    end.
    else
        lHaveIndex% = yes.
    
    /* if we got a TEMPTABLE that has a LIKE statement and */
    /* didn't get a use-index or index then report it      */
    if not lHaveIndex% then
        run PublishResult            (
            input compilationunit,
            input parserGetnodeFilename(iTheNode%),
            input parserGetnodeLine(iTheNode%), 
            input substitute("TempTable &1 defined like &2 has no index defined.":T, sTempTableName%,sTableName%),
            input rule_id ).
    
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iNextChild%).
    parserReleaseHandle(iLikeChild%).

END procedure.                            
