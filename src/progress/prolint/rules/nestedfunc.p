/* ---------------------------------------------------------------------------------
   file    :  prolint/rules/nestedfunc.p
   by      :  Jurjen Dijkstra
   purpose :  search for function definitions that are not direct 
              children of the program_root   
   -----------------------------------------------------------------

    Copyright (C) 2007 Jurjen Dijkstra

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
{prolint/core/ttprocedure.i}

    DEFINE VARIABLE parentnode AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
    
    parentnode = parserGetHandle().
    run ProcedureListGet in hLintSuper (output table tt_procedure).
    
    for each tt_procedure 
        where tt_procedure.proctype = "FUNCTION":U OR tt_procedure.proctype="PROCEDURE":U :
            
        nodetype = parserNodeParent(tt_procedure.startnode, parentnode).    
        IF nodetype = "Code_block":U THEN 
        run PublishResult            (
                input compilationunit,
                input parserGetNodeFilename(tt_procedure.startNode),
                input parserGetNodeLine(tt_procedure.startNode),
                input substitute("&1 &2 is defined inside a code block":T, tt_procedure.proctype, tt_procedure.ProcName),
                input rule_id ).
                
    end.
    
    parserReleaseHandle(parentnode).    
