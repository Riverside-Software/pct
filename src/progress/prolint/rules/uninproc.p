/* ---------------------------------------------------------------------------------
   file    :  prolint/rules/uninproc.p
   by      :  Breck Fairley
   purpose :  Search for internal procedures that are never used.
              If a RUN VALUE ( proc ) call is made this is captured as well.   
   -----------------------------------------------------------------

    Copyright (C) 2002 Breck Fairley

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

def temp-table tt_DefinedProcedures no-undo like tt_procedure
    field LineNum       as inte
    field SourceFile    as char
    field IsUsed        as logi initial No
    field Processed     as logi initial No
    
    index ProcName
        IsUsed
        ProcName.
                                                                                
def temp-table tt_ProcedureTree no-undo
    field ParentProc    as char
    field ChildProc     as char.

def var child           as inte no-undo.
       
def buffer btt_DefinedProcedures for tt_DefinedProcedures.
    
    
MAIN-BLK:
do on error  undo MAIN-BLK, leave MAIN-BLK:

    child = parserGetHandle().
    
    /* get the list of all functions and procedures */                              
    run ProcedureListGet in hLintSuper (output table tt_procedure).
    
    
    for each tt_procedure 
        where tt_procedure.proctype = "PROCEDURE" :
        
        create tt_DefinedProcedures.
        buffer-copy tt_procedure to tt_DefinedProcedures.
        
    end.
    
    /* AIM: To build a complete list of accessed procedures. */
    
    /* Currently, do not include FUNCTIONs as they will require specific */
    /* processing.                                                       */
    
    for each tt_procedure
        where tt_procedure.proctype = "PROCEDURE" :

        /* Find where procedures are run. */ 
        run SearchNode            (
            input tt_procedure.startnode,
            input "BuildList":U,
            input "RUN":U ).
        
    end.
    
    /* Inspect the top "Program_root" scope for remaining objects.      */
    release tt_procedure. /* We must have not available */
    
    /* Find where procedures are run. */ 
    run SearchNode            (
        input hTopNode,
        input "BuildList":U,
        input "RUN":U ).   
    

    /* We now have our procedure call tree created and a list of all    */
    /* procedures and UNKNOWNs created. Currently, only the procedures  */
    /* called from the ROOT NODE are marked as Used.                    */
    /* What we need to do now is traverse the tree and set all Children */
    /* of used procedures to Used. Once this is done the original       */
    /* calling procedure will be set to Processed and this process will */
    /* repeat until no Unprocessed and Used procedures are left.        */

    /* Find the first Unprocessed Used Procedure */
    find first tt_DefinedProcedures
        where tt_DefinedProcedures.IsUsed
          and not tt_DefinedProcedures.Processed
        no-error.
    
    PROCESS-BLK:    
    repeat while available tt_DefinedProcedures :

        for each tt_DefinedProcedures
            where tt_DefinedProcedures.IsUsed
              and not tt_DefinedProcedures.Processed :
        
            for each tt_ProcedureTree
                where tt_ProcedureTree.ParentProc = tt_DefinedProcedures.ProcName :
                
                find first btt_DefinedProcedures
                    where btt_DefinedProcedures.ProcName = tt_ProcedureTree.ChildProc
                      and not btt_DefinedProcedures.IsUsed 
                      and not btt_DefinedProcedures.Processed 
                    no-error.
                    
                if available btt_DefinedProcedures then
                
                    btt_DefinedProcedures.IsUsed = Yes.
                
            end.
        
            tt_DefinedProcedures.Processed = Yes.
            
        end.
       
        find first tt_DefinedProcedures
            where tt_DefinedProcedures.IsUsed
              and not tt_DefinedProcedures.Processed
            no-error.

    end.
        
        
    /* If the program is using a RUN VALUE ( ) call then we can no longer */
    /* be certain that any procedure is definitely not used. Therefore,   */
    /* separate processing is required.                                   */
    
    if can-find ( first tt_DefinedProcedures
        where tt_DefinedProcedures.ProcName = "UNKNOWN" ) then
    do:
    
        /* Output the UNKNOWN run call locations */
        for each tt_DefinedProcedures
            where tt_DefinedProcedures.IsUsed
              and tt_DefinedProcedures.ProcName = "UNKNOWN" :

            run PublishResult            (
                input compilationunit,
                input tt_DefinedProcedures.SourceFile,
                input tt_DefinedProcedures.LineNum,
                input substitute("UNKNOWN Procedure executed at line &1.":U,string(tt_DefinedProcedures.LineNum)),
                input rule_id ).
        
        end.
        
        /* Output the internal procedures that may not be used */
        for each tt_DefinedProcedures
            where not tt_DefinedProcedures.IsUsed :
            
                run PublishResult            (
                    input compilationunit,
                    input parserGetNodeFilename(tt_DefinedProcedures.startNode),
                    input parserGetNodeLine(tt_DefinedProcedures.startNode),    
                    input substitute("Internal Procedure &1 may not be used.":U,tt_DefinedProcedures.ProcName),
                    input rule_id ).
                                           
        end.
    
    end.
    else
    
        /* Output the internal procedures that are not used */
        for each tt_DefinedProcedures
            where not tt_DefinedProcedures.IsUsed:
        
            run PublishResult            (
                input compilationunit,
                input parserGetNodeFilename(tt_DefinedProcedures.startNode),
                input parserGetNodeLine(tt_DefinedProcedures.startNode),
                input substitute("Internal Procedure &1 is not used.":U,tt_DefinedProcedures.ProcName),
                input rule_id ).
                                       
        end.
    
    return.

end. /* MAIN-BLK */
    
    
    
procedure BuildList :                          
/* purpose : recognize variable or parameter and add it to tt_object */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.
    
def var nodetype                as char no-undo.
def var procedureName           as char no-undo.


    /* set an attrib to remember we have been here before */                                   
    parserAttrSet(theNode, pragma_number, 1).
    
    nodetype = parserNodeFirstChild(theNode,child).        
        
    CHILD-LOOP:
    do while nodetype <> "" : 
        
        case ( nodetype ) :
        
            when "FILENAME":U then
            do:
                procedureName = trim(parserGetNodeText(child)).
                if not available tt_procedure then
                do:    
                    find first tt_DefinedProcedures
                        where tt_DefinedProcedures.ProcName = procedureName
                        no-error.
                        
                    /* If not available then this is not an internal */
                    /* procedure and we can discard.                 */
                    if available tt_DefinedProcedures then
                        assign
                            tt_DefinedProcedures.IsUsed     = Yes
                            tt_DefinedProcedures.Processed  = No.
                end.          
                create tt_ProcedureTree.
                assign
                    tt_ProcedureTree.ParentProc = 
                        if available tt_procedure then
                            tt_procedure.procname
                        else
                            "ROOTNODE" /* Give the ROOT NODE a label */
                    tt_ProcedureTree.ChildProc = procedureName.
                leave CHILD-LOOP.
            end.

            when "VALUE":U then
            do:
                create tt_DefinedProcedures.
                assign
                    tt_DefinedProcedures.SourceFile = parserGetNodeFilename(theNode)
                    tt_DefinedProcedures.LineNum    = parserGetNodeLine(theNode)
                    tt_DefinedProcedures.ProcName   = "UNKNOWN"
                    tt_DefinedProcedures.IsUsed     = Yes
                    tt_DefinedProcedures.Processed  = Yes.
                create tt_ProcedureTree.
                assign
                    tt_ProcedureTree.ParentProc = 
                        if available tt_procedure then
                            tt_procedure.procname
                        else
                            "ROOTNODE" /* Give the ROOT NODE a label */
                    tt_ProcedureTree.ChildProc = "UNKNOWN".
                leave CHILD-LOOP.
            end.
            
        end case.
        
        nodetype = parserNodeNextSibling(child,child).
        
    end. /* CHILD-LOOP */
    
end procedure.    
