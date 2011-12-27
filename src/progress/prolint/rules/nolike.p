
/*      Title:  nolike.p                                     */
/*    Purpose:  To find define statements with Like keyword  */
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

define variable iLikeNumber% as integer no-undo.

define temp-table ttCodeString
    field sCodeString%  as character
    field iCodeLine%    as integer 
    field iCodeColumn%  as integer
    index iCodeColumn% iCodeLine% iCodeColumn%.

run searchNode  (hTopnode,              /* "Program_root" node                 */
                 "priv-InspectNode":U,  /* name of callback procedure          */
                 "DEFINE":U).           /* list of statements to search, ?=all */

procedure priv-InspectNode :   

    define input  parameter ipiTheNode%         as integer            no-undo.
    define output parameter oplAbortSearch%     as logical initial no no-undo.
    define output parameter oplSearchChildren%  as logical            no-undo.

    define variable lLike%                      as logical initial no no-undo.
    define variable iChild%                     as integer            no-undo.
    define variable iSibling%                   as integer            no-undo.
    define variable sChildType%                 as character          no-undo.
    define variable sNodeType%                  as character          no-undo.
    define variable sDefineType%                as character          no-undo.
    define variable sSiblingType%               as character          no-undo.   
    
    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign iChild%        = parserGetHandle()
           iSibling%      = parserGetHandle()
           sNodeType%     = parserGetNodeType(ipiTheNode%)
           sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%).
    
    if sChildType% = "" then do:

       parserReleaseHandle(iChild%).
       parserReleaseHandle(iSibling%).
        
       return.

    end.  /* if sChildType% = "" then do: */

    create ttCodeString.
    assign ttCodeString.sCodeString% = parserGetNodeText(ipiTheNode%)
           ttCodeString.iCodeLine%   = parserGetNodeLine(ipiTheNode%).
           ttCodeString.iCodeColumn% = parserGetNodeColumn(ipiTheNode%).
                                                                    
    /* Check the define statement for the variable/temp-table/work-table/input */
    /* qualifier that should follow   */
    sDefineType% = parserGetNodeText(ipiTheNode%). 

    /* Taking care of define variable,temp-table,work-table and define input */
    /* While leaving Image,Menu,Rectangle,Sub-Menu and Button */
    if lookup(sChildType%,"VARIABLE,INPUT,TEMPTABLE,WORKTABLE":U) > 0 then 
       run searchString(input iChild%, input-output lLike%). 
    
    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).
    
end procedure.                            


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
    define input parameter ipiTheNode%         as integer   no-undo.
    
    define variable sErrString% as character no-undo.

    for each ttCodeString where ttCodeString.iCodeLine% = iLikeNumber%:

        sErrString% = sErrString% + 
                      if trim(ttCodeString.sCodeString%) = "" or
                         trim(ttCodeString.sCodeString%) = ",":U then "" else " ":U +
                      ttCodeString.sCodeString%.

    end.
  
    run PublishResult (compilationunit,
                       parserGetNodeFilename(ipiTheNode%),
                       parserGetNodeLine(ipiTheNode%), 
                       substitute("Variables and Temp-Table fields should not be defined 'LIKE' a database field in statement &1",sErrString%),
                       rule_id).

end procedure.

procedure searchString :   

   define input        parameter ipiTheNode% as integer   no-undo.
   define input-output parameter oplError%   as logical   no-undo.
   
   define variable iChild%                   as integer   no-undo.
   define variable sChildType%               as character no-undo.
   define variable sNodeType%                as character no-undo.
   define variable sErrorDesc%               as character no-undo.
   

   
   /* Assign handles and pointers to specific nodes in the Parse Tree */
   assign iChild%     = parserGetHandle()
          sNodeType%  = parserGetNodeType(ipiTheNode%).


   do while sNodeType% <> "" :

      create ttCodeString.
      assign ttCodeString.sCodeString% = parserGetNodeText(ipiTheNode%)
             ttCodeString.iCodeLine%   = parserGetNodeLine(ipiTheNode%).
             ttCodeString.iCodeColumn% = parserGetNodeColumn(ipiTheNode%).
         
      sChildType%  = parserNodeFirstChild(ipiTheNode%,iChild%).


      if sChildType% <> "" then
         run searchString(input iChild%, input-output oplError%).
     

      if sNodeType% = "LIKE":U  AND sChildType% <> "RECORD_NAME" then 
         assign iLikeNumber% = parserGetNodeLine(ipiTheNode%)
                oplError%    = yes.

      if lookup(sNodeType%,"PERIOD,LEXCOLON":U) > 0 then do:

         if oplError% then 
            run priv-WriteResult (ipiTheNode%).

         oplError% = no.

         empty temp-table ttCodeString.         

      end.             
         
      sNodeType% = parserNodeNextSibling(ipiTheNode%,ipiTheNode%).

   end. /* do while sNodeType% <> "" : */
    
end procedure.                            


