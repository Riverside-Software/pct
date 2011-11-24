/*      Title:  prolint/rules/nobreakby.p                                */
/*    Purpose:  To find "Break By" options without first*,last* keywords */
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

FUNCTION CanFindBreak RETURNS LOGICAL (startnode AS integer) :
     DEFINE VARIABLE retval AS LOGICAL NO-UNDO.
     retval = parserQueryCreate(startnode, "qnobreakby":U, "BREAK":U) > 0.
     parserQueryClear ("qnobreakb":U).
     RETURN retval.
END FUNCTION.
 
IF NOT CanFindBreak(hTopnode) THEN RETURN.

run searchNode  (hTopnode,              /* "Program_root" node                 */
                 "priv-InspectNode":U,  /* name of callback procedure          */
                 "DO":U).               /* list of statements to search, ?=all */

run searchNode  (hTopnode,              /* "Program_root" node                 */
                 "priv-InspectNode":U,  /* name of callback procedure          */
                 "REPEAT":U).           /* list of statements to search, ?=all */


run searchNode  (hTopnode,              /* "Program_root" node                 */
                 "priv-InspectNode":U,  /* name of callback procedure          */
                 "FOR":U).              /* list of statements to search, ?=all */

run priv-WriteResult.

define temp-table ttErrorLine
    field iLineNumber% as INTEGER    FIELD sSourceFile% AS character
    field sErrorDesc%  as character.


procedure priv-InspectNode :   
/* Purpose : Call back procedure from searchNode, upon successful find of 
             REPEAT/FOR/DO. */
    define input  parameter ipiTheNode%         as integer            no-undo.
    define output parameter oplAbortSearch%     as logical initial no no-undo.
    define output parameter oplSearchChildren%  as logical            no-undo.

    define variable sReturnString%              as character no-undo.
    define variable lBreak%                     as logical   no-undo.

    IF NOT CanFindBreak(ipiTheNode%) THEN RETURN.
    run traverse(input ipiTheNode%,
                 input "BREAK",
                 input "",
                 output lBreak%, 
                 output sReturnString%).
    
end procedure.                            


procedure priv-WriteResult :
/* Purpose : send warning to the outputhandlers(s) */
  
    for each ttErrorLine:

        run PublishResult (input compilationunit,
                           input ttErrorLine.sSourceFile%,
                           input ttErrorLine.iLineNumber%, 
                           input ttErrorLine.sErrorDesc%,
                           input rule_id).
    end.

end procedure.

procedure traverse:
/* Purpose : Recursive Procedure to traverse entire block of 
             REPEAT/DO/FOR to find break keyword without
             last/first functions.  */
    define input  parameter ipiTheNode%      as integer   no-undo.
    define input  parameter ipsMode%         as character no-undo.
    define input  parameter ipsSearchString% as character no-undo.
    define output parameter oplFound%        as logical   no-undo.
    define output parameter opsReturnString% as character no-undo.
    
    define variable iChild%                  as integer   no-undo.
    define variable sChildType%              as character no-undo.
    define variable lBreak%                  as logical   no-undo.
    define variable lBy%                     as logical   no-undo.
    define variable sBreakByString%          as character no-undo.
    define variable sReturnString%           as character no-undo.
    define variable iCount%                  as integer   no-undo.
    define variable iNumEntry1%              as integer   no-undo.
    define variable iNumEntry2%              as integer   no-undo.
    define variable sNodeText%               as character no-undo.

    assign iChild%        = parserGetHandle()
           sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%).

    TRAVERSE_TREE:
    do while sChildType% <> "":U :

        sNodeText% =  parserGetNodeText(iChild%).

        /* When Mode is "BREAK" If Encounter "BREAK":U keyword in the loop */
        /* then set the flag lBreak% to yes. This check is only necessary  */
        /* for the outermost BLOCK only */
        if ipsMode%    = "BREAK":U and
           sChildType% = "BREAK":U then
           lBreak% = yes. 

        /* After we encounter BREAK keyword search for BY keyword and */
        /* collect all field references with BY Keyword  */
        if sChildType% = "BY":U and lBreak% then do:
           run traverse (input iChild%,
                         input "BY",
                         input ipsSearchString%,
                         output lBy%,
                         output sReturnString%).

           sBreakByString% = trim(sReturnString%) + 
                            (if sBreakByString% = "" then "" else ",") + 
                            sBreakByString%.

        end. /* if sChildType% = "BY":U and lBreak% then do: */

        /* After we encounter BY keyword and traverse inside the Code_block. */
        /* of the block containing BREAK BY Keyword */
        else
        if sChildType% = "CODE_BLOCK":U and lBy% then do:

           do iCount% = 1 to num-entries(sBreakByString%):

              run traverse (input iChild%,
                            input "FINDFIRSTLAST":U,
                            input entry(iCount%,sBreakByString%),
                            output oplFound%,
                            output sReturnString%).

              if oplFound% then
                 leave.

           end. /* do iCount% = 1 to num-entries(sBreakByString%): */

           if not oplFound% and
              not can-find(first ttErrorLine 
                  where ttErrorLine.iLineNumber% = parserGetNodeLine(ipiTheNode%) 
                    AND ttErrorLine.sSourceFile% = parserGetNodeFilename(ipiTheNode%)) then do:

              create ttErrorLine.
              assign ttErrorLine.iLineNumber% = parserGetNodeLine(ipiTheNode%)
                     ttErrorLine.sSourceFile% = parserGetNodeFilename(ipiTheNode%)
                     ttErrorLine.sErrorDesc%  = 
                           substitute("&1 statement should use ~"BY~" option instead of ~"BREAK BY~" option.",
                                      substring(parserGetNodeText(ipiTheNode%) + 
                                                " ":U + opsReturnString%,1,24) + 
                                                "...":U).                        

           end. /* if not oplFound% then and */

        end. /* if sChildType% = "CODE_BLOCK":U and lBy% then do: */

        /* After we encounter BY keyword and search for FIRST,FIRST-OF, */
        /* LAST,LAST-OF keyword inside the Code_block. */
        else
        if ipsMode% = "FINDFIRSTLAST":U and
           (sChildType% begins "FIRST":U or
           sChildType% begins "LAST":U) then do:

           run traverse (input  iChild%,
                         input  "FIRSTLAST":U,
                         input  ipsSearchString%,
                         output oplFound%,
                         output sReturnString%).

           if oplFound% then
              leave TRAVERSE_TREE.
           
        end. /* if ipsMode% = "FINDFIRSTLAST":U and */

        /* After we found FIRST and LAST keyword search for the field */
        /* reference associated with them, and compare them with Break By */
        /* field references. If it does not match, or does not exists raise error */
        else
        if ipsMode% = "FIRSTLAST":U and
           (not oplFound%) and 
           sNodeText% <> "" and 
           lookup(sNodeText%, "),(") = 0 then do:

           /* Taking care of database and table qulaifiers with the field reference */
           assign iNumEntry1% = num-entries(ipsSearchString%,".")
                  iNumEntry2% = num-entries(sNodeText%,".").
              
           do iCount% = 0 to (minimum(iNumEntry1%,iNumEntry2%) - 1) :
              oplFound% = entry(iNumEntry1% - iCount%,ipsSearchString%,".") =
                          entry(iNumEntry2% - iCount%,sNodeText%,".").

              if not oplFound% then
                 leave.
           end.

           if oplFound% then
              leave TRAVERSE_TREE.

        end. /* if ipsMode% = "FIRSTLAST":U and */

        /* Else Condition is to traverse inside all other tree stuctures like RECORD_ITEM, */
        /* STREAM name etc. Do not traverse if Mode = "FINDFIRSTLAST" or "FIRSTLAST" and   */
        /* First/last keyword is found for the fields referenced in breaky by.             */
        else 
        if lookup(ipsMode%, "FINDFIRSTLAST,FIRSTLAST":U) = 0 or
           not oplFound% then
           run traverse (input  iChild%,
                         input  ipsMode%,
                         input  ipsSearchString%,
                         output oplFound%,
                         output sReturnString%).

        if ipsMode% = "BY":U or
           ipsMode% = "BREAK":U then
           opsReturnString% = trim(opsReturnString%) + " " + 
                              trim(sNodeText%) + " " + 
                              trim(sReturnString%).
        
        /* if we get Field Ref by Break By Return oplFound% as yes */
        if ipsMode% = "BY":U and 
           opsReturnString% <> "" then
           oplFound% = yes.

        /* Traverse to next sibling */
        sChildType% = parserNodeNextSibling(iChild%,iChild%).

    end. /* TRAVERSE_TREE: */

    parserReleaseHandle(iChild%).

end procedure.
