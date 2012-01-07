/* ------------------------------------------------------------------------
   file    :  prolint/rules/noundo.p
   by      :  Judy Hoffman Green
              adapted for prolint by Jurjen Dijkstra
   purpose :  Find "DEFINE VARIABLE" statements without "NO-UNDO". 
              and find "DEFINE TEMP-TABLE" statements without "NO-UNDO". 
**  CJP     27-Jul-01
**          Ignore buffer parameter definitions as they cannot have no-undo
**
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Judy Hoffman Green, Jurjen Dijkstra

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

RUN IgnoreDLLs.
                 
RUN searchNode            (hTopnode,         /* "Program_root" node                 */
                           "InspectNode":U,  /* name of callback procedure          */
                           "DEFINE":U).      /* list of statements to search, ?=all */


RETURN.

PROCEDURE IgnoreDLLs :       
  /* purpose : parameters in a DLL-procedure don't need to have NO-UNDO
               so prolint shouldn't raise a warning for params in PROCEDURE..EXTERNAL.
               Suppress warnings by setting the pragma attribute on these define  statements */
  DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
  DEFINE VARIABLE i1         AS INTEGER NO-UNDO.
  DEFINE VARIABLE result     AS INTEGER NO-UNDO.

  result = parserGetHandle().
  RUN ProcedureListGet IN hLintSuper (OUTPUT TABLE tt_procedure).
  FOR EACH tt_procedure WHERE tt_procedure.prototype = TRUE :
  
      numResults = parserQueryCreate(tt_procedure.startnode, "noundo":U, "DEFINE":U).
      DO i1 = 1 TO numResults:
         parserQueryGetResult("noundo":U, i1, result).
         parserAttrSet(result, pragma_number, 1).
      END.
      parserQueryClear ("noundo":U).
  
  END.
  parserReleaseHandle(result).

END PROCEDURE.
                           
PROCEDURE InspectNode :             
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE child       AS INTEGER NO-UNDO.
  DEFINE VARIABLE numChildren AS INTEGER NO-UNDO.
  DEFINE VARIABLE havevar     AS LOGICAL NO-UNDO.
  DEFINE VARIABLE havenoundo  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE varname     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE vartype     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.
                         
  ASSIGN
    SearchChildren = FALSE  /* a DEFINE statement can't contain more DEFINE statements */
    child          = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child)
    numChildren    = 0
    havevar        = FALSE
    havenoundo     = FALSE.
                        
  loop_testchildren:                      
  DO WHILE nodetype<>"" :
    ASSIGN numChildren = numChildren + 1.
    
    CASE nodetype :
      WHEN "VARIABLE":U  THEN ASSIGN havevar = TRUE
                                     vartype = 'variable':U.
      WHEN "PROPERTY":U  THEN ASSIGN havevar = TRUE
                                     vartype = 'property':U.
      WHEN "TEMPTABLE":U THEN ASSIGN havevar = TRUE
                                     vartype = 'temp-table':U.
      WHEN "PARAMETER":U THEN ASSIGN havevar = TRUE
                                     vartype = 'parameter':U.
      WHEN "ID":U        THEN IF varname="":U THEN 
                                 ASSIGN varname = parserGetNodeText(child).
      WHEN "NOUNDO":U    THEN ASSIGN havenoundo = TRUE.                                                      
                                                            
      /* exceptions: */                                                      
      /* did you know a temp-table can have an UNDO option? */
      WHEN "UNDO":U      THEN IF vartype='temp-table':U THEN 
                                 ASSIGN havenoundo = TRUE.
                                 
      WHEN "TABLE":U     THEN IF vartype='parameter':U THEN 
                            /* suppress warning on "DEFINE .. PARAMETER TABLE FOR ..." */
                               ASSIGN havevar = FALSE.
      /* cjp 27-jul-01 */
      WHEN "BUFFER":U    THEN IF vartype='parameter':U THEN 
                          /* suppress warning on "DEFINE .. parameter buffer FOR ..." */
                               ASSIGN havevar = FALSE.

      /* no-undo doesn't compile with parameter table-handle */ 
      WHEN "TABLEHANDLE":U THEN IF vartype='parameter':U THEN
                          /* suppress warning on "DEFINE .. parameter table-handle ..." */
                               ASSIGN havevar = FALSE.
    END CASE.                               
                                       
    /* numChildren >= 2 allows for up to 
       "DEFINE" <optional share phrase node> "VARIABLE", i.e. the VARIABLE token to be
       up to the third token of the statement. */        
    IF numChildren >= 2 AND (NOT havevar) THEN 
       LEAVE loop_testchildren.
       
    ASSIGN nodetype = parserNodeNextSibling(child,child).
  END.      

  /* If we got a VARIABLE or TEMPTABLE, and didn't get a NO-UNDO, then report it. */
  IF havevar AND (NOT havenoundo) THEN
    RUN PublishResult            (compilationunit,
                                  parserGetNodeFilename(theNode),
                                  parserGetNodeLine(theNode), 
                                  SUBSTITUTE("&1 '&2' defined without NO-UNDO":T, vartype, varname),
                                  rule_id).
    
  parserReleaseHandle(child).
    
END PROCEDURE.                            
