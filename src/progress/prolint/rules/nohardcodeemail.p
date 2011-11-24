
/*      Title:  prolint\rules\nohardcodeemail.p                              */
/*    Purpose:  find hardcoded email address                                 */
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

define temp-table ttCodeString
    field sCodeString%  as character
    field iCodeColumn%  as integer
    index iCodeColumn% iCodeColumn%.

define variable lError% as logical   no-undo.

run searchString (input hTopnode,
                  output lError%).
                                                                                
procedure searchString :   
/* Run recursively searchString, to find hardcoded email address */
   define input  parameter ipiTheNode% as integer   no-undo.
   define output parameter oplError%   as logical   no-undo.

   define variable iChild%            as integer   no-undo.
   define variable sChildType%        as character no-undo.
   define variable sNodeType%         as character no-undo.
   define variable sErrorDesc%        as character no-undo.
   
   /* Assign handles and pointers to specific nodes in the Pares Tree */
   assign iChild%     = parserGetHandle()
          sNodeType%  = parserGetNodeType(ipiTheNode%).

   do while sNodeType% <> "" :

      create ttCodeString.
      assign ttCodeString.sCodeString% = parserGetNodeText(ipiTheNode%)
             ttCodeString.iCodeColumn% = parserGetNodeColumn(ipiTheNode%).

      sChildType%  = parserNodeFirstChild(ipiTheNode%,iChild%).

      if index(parserGetNodeText(ipiTheNode%),"@":U) > 0 then
         oplError% = yes.
      
      if sChildType% <> "" then
         run searchString(input iChild%, output oplError%).                               


      if lookup(sNodeType%,"PERIOD,LEXCOLON":U) > 0  then do:

         if oplError% then
            run priv-WriteResult (parserGetNodeLine(ipiTheNode%)).

         oplError% = no.

         empty temp-table ttCodeString.                  

      end.             
         
      sNodeType% = parserNodeNextSibling(ipiTheNode%,ipiTheNode%).

   end. /* do while sNodeType% <> "" : */
    
end procedure.                            

procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */

   define input parameter ipiErrorLine% as integer   no-undo.

   define variable sErrString%  as character   no-undo.

   for each ttCodeString:

       sErrString% = sErrString% + 
                     if trim(ttCodeString.sCodeString%) = "" or
                        trim(ttCodeString.sCodeString%) = ",":U then "" else " ":U +
                     ttCodeString.sCodeString%.

   end.
  
   run PublishResult (input compilationunit,
                      input parserGetNodeFilename(hTopnode),
                      input ipiErrorLine%, 
                      input substitute("&1, statement should not use any hard coded email.":T,sErrString%),
                      input rule_id).

end procedure.


