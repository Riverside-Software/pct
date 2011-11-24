/*    Title   :  prolint/rules/nolonglines.p                                */
/*    Purpose :  To find Lines more than 80 characters.                     */
/*   ------------------------------------------------------------------------

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

define variable sLineString% as character   no-undo.
define variable iLinenumber% as integer     no-undo.

if search(parserGetNodeFilename(hTopNode)) <> ? then do:

  input from value(parserGetNodeFilename(hTopNode)).

  /* Import each line from the current file, and check its length */
  repeat:
      iLinenumber% = iLinenumber% + 1.

      import unformatted sLineString%.

      /* If length is more than 80 then raise error */
      if length(sLineString%) > 80 then
         run priv-WriteResult(input iLinenumber%,
                              input trim(sLineString%)).
       
  end.

  input close.

end.

procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */
   define input  parameter ipiLineNumber% as integer     no-undo.
   define input  parameter ipsLineString% as character   no-undo.

   run PublishResult (input compilationunit,
                      input parserGetNodeFilename(hTopNode),
                      input ipiLineNumber%,
                      input substring(ipsLineString%,1,24) + "... line has more than 80 characters.",
                      input rule_id).


end procedure.


