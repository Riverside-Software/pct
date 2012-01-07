/*      Title:  prolint/rules/noglobaldefine.p                           */
/*    Purpose:  To alert on keyword &GLOBAL-DEFINE                       */
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

define variable sLineString%   as character no-undo.
define variable iLinenumber%   as integer   no-undo.
define variable iCommentLevel% as integer   no-undo.

if search(parserGetNodeFilename(hTopNode)) <> ? then do:

  input from value(parserGetNodeFilename(hTopNode)).

  repeat:

      iLinenumber% = iLinenumber% + 1.

      import unformatted sLineString%.     

      run removecomment(input-output sLineString%,
                        input-output iCommentLevel%).

      /* If Global Define statement exist raise warning */
      if index(sLineString%,"&GLOB":U) > 0 then
         run priv-WriteResult (input iLinenumber%,                                                                  
                               input substitute("&1 statement should not use &2":T, sLineString%,"&GLOBAL-DEFINE")).
       
  end.   /* repeat: */

  input close.

end.

procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
   define input  parameter ipiLineNumber% as integer     no-undo.
   define input  parameter ipsLineString% as character   no-undo.

   run PublishResult (input compilationunit,
                      input parserGetNodeFilename(hTopNode),
                      input ipiLineNumber%,
                      input ipsLineString%,
                      input rule_id).

end procedure.

procedure removecomment:
    define input-output parameter iopsString%       as character no-undo.
    define input-output parameter iopiCommentLevel% as integer no-undo.

    define variable sLineString%   as character no-undo.
    define variable sString%       as character no-undo.
    define variable iCount%        as integer   no-undo.
    define variable iCommentStart% as integer   no-undo.
    define variable iCommentEnd%   as integer   no-undo.

    sLineString% = iopsString%.

    if iopiCommentLevel% = 0 or 
       index(iopsString%, "*~/":U) <> 0 then do:

       do iCount% = 1 to iopiCommentLevel%:
          if index(iopsString%, "*~/":U) > 0 then
             iopsString% = substring(iopsString%, index(iopsString%, "*~/":U) + 2).
       end.

       assign iCommentStart% = r-index(iopsString%, "~/*":U)
              iCommentEnd%   = index(iopsString%, "*~/":U).

       repeat while iCommentStart% > 0 or iCommentEnd% > 0:
          if iCommentStart% <> 0 then do:

             if iCommentEnd% = 0 or iCommentEnd% < iCommentStart% then
                iopsString% = trim(substring(iopsString%,1,iCommentStart% - 1 )).
             else
                iopsString% = trim(substring(iopsString%, 1 , iCommentStart% - 1)) + " " +
                              trim(substring(iopsString%, iCommentend% + 2)).

          end.
          else
             iopsString% = trim(substring(iopsString%,iCommentEnd% + 2)). 

          assign iCommentStart% = r-index(iopsString%, "~/*":U)
                 iCommentEnd%   = index(iopsString%, "*~/":U).
       end.
    end.
    else
       iopsString% = "".
    
    do iCount% = 1 to length(sLineString%) - 1:

       sString% = substring(sLineString%,iCount%,2).

       if sString% = "~/*":U then
          iopiCommentLevel% = iopiCommentLevel% + 1.
       else
       if sString% = "*~/":U then
          iopiCommentLevel% = iopiCommentLevel% - 1.

    end.

end procedure.
