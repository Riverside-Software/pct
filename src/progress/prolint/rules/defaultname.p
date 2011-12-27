/* ------------------------------------------------------------------------
   file    :  prolint/rules/defaultname.p
   by      :  Jurjen Dijkstra
   purpose :  widgets should not keep their default names, eg 
              fill-in-1, button-2, frame-c are just not descriptive enough.
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra

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

RUN searchNode            (hTopnode,                /* "Program_root" node                 */
                           "InspectNode":U,         /* name of callback procedure          */
                           "DEFINE":U).             /* list of statements to search, ?=all */


RETURN.

                           
PROCEDURE InspectNode :             
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE child       AS INTEGER NO-UNDO.
  DEFINE VARIABLE varname     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE vartype     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.      
  DEFINE VARIABLE iswidget    AS LOGICAL NO-UNDO.
  DEFINE VARIABLE defaultprefix AS CHARACTER NO-UNDO.
  DEFINE VARIABLE postfix     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE postfixnr   AS INTEGER NO-UNDO.
                         
  ASSIGN
    SearchChildren = FALSE 
    child          = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child)
    iswidget       = FALSE.
                        
  loop_testchildren:                      
  DO WHILE nodetype<>"" :
    
    CASE nodetype :   
      WHEN "BUTTON":U    THEN ASSIGN iswidget= TRUE
                                     vartype = "BUTTON":U.
      WHEN "FRAME":U     THEN ASSIGN iswidget= TRUE
                                     vartype = "FRAME":U.
      WHEN "VARIABLE":U  THEN ASSIGN iswidget= FALSE
                                     vartype = "VARIABLE":U.
      WHEN "VIEWAS":U    THEN ASSIGN iswidget = TRUE
                                     nodetype = parserNodeFirstChild(child,child)
                                     vartype  = parserGetNodeText(child).
      WHEN "ID":U        THEN IF varname="":U THEN 
                                 ASSIGN varname = parserGetNodeText(child).
    END CASE.                               
                                       
    ASSIGN nodetype = parserNodeNextSibling(child,child).
  END.      
     
  IF isWidget THEN DO:
  
     DefaultPrefix = vartype.
     CASE vartype :
       WHEN "SELECTION-LIST":U THEN DefaultPrefix = "SELECT":U.
       WHEN "TOGGLE-BOX":U     THEN DefaultPrefix = "TOGGLE":U.
     END CASE.                                       
     DefaultPrefix = DefaultPrefix + "-":U.   
     
     /* get the namepart after the default prefix: */
     IF varname MATCHES (DefaultPrefix + "*":U) THEN 
        postfix = SUBSTRING(varname, LENGTH(DefaultPrefix, "CHARACTER":U) + 1).
     ELSE 
        postfix = "a real name :-)":U.
     
     /* if the postfix is just a number, then we are not happy */
     ASSIGN postfixnr = ?.
     ASSIGN postfixnr = INTEGER(postfix) NO-ERROR.
     IF postfixnr<>? THEN 
        RUN PublishResult            (compilationunit,
                                      parserGetNodeFilename(theNode),
                                      parserGetNodeLine(theNode), 
                                      SUBSTITUTE("&1 is no meaningfull widget name":T, varname),
                                      rule_id).    
  END.
                  
  parserReleaseHandle(child).
    
END PROCEDURE.                            
