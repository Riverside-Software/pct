/* -------------------------------------------------------------------------
   file    :  prolint/rules/abbrevkwd.p
   by      :  Jurjen Dijkstra
   purpose :  find abbreviated keywords
   note    :  this procedure can not easily be replaced by 3GL because it 
              uses the KEYWORD-ALL function
              Too bad, because it is an extremely slow procedure!!!!
    -----------------------------------------------------------------

    Copyright (C) 2001,2002,2003,2004 Jurjen Dijkstra, Sven Persijn

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
   ------------------------------------------------------------------------- */
  
{prolint/core/ruleparams.i}  

   DEFINE VARIABLE child         AS INTEGER NO-UNDO.
   DEFINE VARIABLE grandchild    AS INTEGER NO-UNDO.      
   
   /* for some reason, keyword-all("file-info") returns "FILE-INFORMATION"
                   and keyword-all("col")       returns "columns" instead "column".
      I think it's a bug in the keyword-all function. Let's fix it: */
   DEFINE VARIABLE lstAbbrev     AS CHARACTER NO-UNDO INITIAL "FILE-INFO,COL":U.
   DEFINE VARIABLE lstFull       AS CHARACTER NO-UNDO INITIAL "FILE-INFO,COLUMN":U.
   DEFINE VARIABLE ComhandlesAvail AS LOGICAL   NO-UNDO INITIAL FALSE.

   DEFINE TEMP-TABLE tt_comhandle NO-UNDO
       FIELD varname      AS CHARACTER
       INDEX idx AS PRIMARY UNIQUE varname.

   DEFINE TEMP-TABLE tt_accept NO-UNDO 
       FIELD statement    AS CHARACTER
       FIELD kword        AS CHARACTER
       FIELD abbreviation AS CHARACTER
       INDEX idx AS PRIMARY UNIQUE statement kword.

   DEFINE TEMP-TABLE tt_reject NO-UNDO 
       FIELD statement    AS CHARACTER
       FIELD kword        AS CHARACTER
       FIELD abbreviation AS CHARACTER
       INDEX idx AS PRIMARY UNIQUE statement abbreviation.        
   
   RUN DefineExceptions.    
                      
   ASSIGN 
      child          = parserGetHandle()
      grandchild     = parserGetHandle().

   /* create a list of com-handle variables */
   RUN searchNode             (hTopnode,             /* "Program_root" node                 */
                              "FindComhandles":U,   /* name of callback procedure          */
                              "COMHANDLE":U).       /* list of statements to search, ?=all */
      
   RUN QueryAllNodes.
                                              
   parserReleaseHandle(child).
   parserReleaseHandle(grandchild).

RETURN.              

PROCEDURE FindComhandles :
   /* purpose: locate COM-HANDLE variables, store their names */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE hNode      AS INTEGER   NO-UNDO.
  DEFINE VARIABLE objectname AS CHARACTER NO-UNDO.
  hNode = parserGetHandle().

  /* parent is "AS", grandparent is "DEFINE", prev.sibling of "AS" is "ID" */
  IF "DEFINE":U = parserNodeStateHead(theNode, hNode) THEN
    IF "AS":U = parserNodeParent(theNode, hNode) THEN
      IF "ID":U = parserNodePrevSibling(hNode, hNode) THEN DO:
         objectname = parserGetNodeText( hNode ).
         FIND tt_comhandle WHERE tt_comhandle.varname = objectname NO-ERROR.
         IF NOT AVAILABLE tt_comhandle THEN DO:
            ComhandlesAvail = TRUE.
            CREATE tt_comhandle.
            ASSIGN tt_comhandle.varname = objectname.
         END.
      END.

  parserReleaseHandle(hNode).

END PROCEDURE.

PROCEDURE QueryAllNodes :
   /* purpose: find all nodeheads and run InspectNode on them */

   DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
   DEFINE VARIABLE i          AS INTEGER NO-UNDO.
   DEFINE VARIABLE node       AS INTEGER NO-UNDO.
                                               
   node = parserGetHandle().                                            
   numResults = parserQueryCreate(hTopnode, "abbrevkwd":U, "").
   DO i=1 TO numResults :
      IF parserQueryGetResult("abbrevkwd":U, i, node) THEN
         IF parserNodeFirstChild(node, child)<>"" THEN
            IF 0=parserAttrGetI(node,pragma_number) THEN 
               RUN InspectNode (node).
   END.
   parserQueryClear("abbrevkwd":U).
   parserReleaseHandle(node).

END PROCEDURE.
                     
                     
PROCEDURE DefineExceptions :

   /* fill a list with accepted abbreviations.
      for example, 'character' may be abbreviated to 'char' but only in a 'define' statement */

   RUN Accept ('define':U, 'define':U,    'def':U).
   RUN Accept ('define':U, 'variable':U,  'var':U).
   RUN Accept ('define':U, 'character':U, 'char':U).    
   RUN Accept ('define':U, 'integer':U,   'int':U).    
   RUN Accept ('FUNCTION':U, 'FORWARDS':U,   'FORWARD':U).
   RUN Accept ('define':U, 'column':U,   'col':U).  /* AB-generated DEFINE FRAME statements! */
   RUN Accept ('define':U, 'NO-LABELS':U, 'NO-LABEL':U).  /* fails in AB-generated blocks. Added by Sven Persijn */
                      
   /* fill a list with rejected abbreviations.
      for example, 'LOG' is an unabbreviated keyword, but in a 'DEFINE' statement you should use "LOGICAL" */
   
   RUN Reject ('DEFINE':U, 'LOGICAL':U,    'log':U).

END PROCEDURE.

                                              
PROCEDURE Accept :
  /* add accepted keyword (exception) to temp-table */
  DEFINE INPUT PARAMETER pStatement AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pKword     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pAbbrev    AS CHARACTER NO-UNDO.
  
  CREATE tt_accept.
  ASSIGN tt_accept.statement    = pStatement
         tt_accept.kword        = pKword
         tt_accept.abbreviation = pAbbrev.
         
END PROCEDURE.                                              


PROCEDURE Reject :
  /* add rejected keyword (exception) to temp-table */
  DEFINE INPUT PARAMETER pStatement AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pKword     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pAbbrev    AS CHARACTER NO-UNDO.
  
  CREATE tt_reject.
  ASSIGN tt_reject.statement    = pStatement
         tt_reject.kword        = pKword
         tt_reject.abbreviation = pAbbrev.
         
END PROCEDURE.                                              

        
FUNCTION accepted RETURNS LOGICAL (pStatement AS CHARACTER, pKword AS CHARACTER, pAbbrev AS CHARACTER):
   /* accept some abbreviated keywords, like "DEF" and "VAR" in "DEF VAR name AS CHAR" */
   RETURN CAN-FIND(tt_accept WHERE tt_accept.statement    = pStatement
                               AND tt_accept.kword        = pKword
                               AND tt_accept.abbreviation = pAbbrev).
END FUNCTION.


FUNCTION rejected RETURNS CHARACTER (pStatement AS CHARACTER, pAbbrev AS CHARACTER):
   /* reject some unabbreviated keywords, like LOG in "DEFINE VARIABLE ok AS LOG" */
   FIND tt_reject WHERE tt_reject.statement    = pStatement 
                    AND tt_reject.abbreviation = pAbbrev
                  NO-ERROR.
   IF AVAILABLE tt_reject THEN 
      RETURN tt_reject.kword.
   ELSE 
      RETURN ?.
END FUNCTION.

FUNCTION UnAbbreviate RETURNS CHARACTER (abbrev AS CHARACTER) :
   /* try to unabbreviate an abbreviated keyword */ 
   DEFINE VARIABLE i AS INTEGER NO-UNDO.

   IF LOOKUP (abbrev, lstFull)>0 THEN
      RETURN abbrev.

   i = LOOKUP (abbrev, lstAbbrev).
   IF i>0 THEN 
      RETURN ENTRY(i, lstFull).
   ELSE 
      RETURN KEYWORD-ALL(abbrev).
   
END FUNCTION.

PROCEDURE InspectNode :
  /* purpose : callback from QueryAllNodes. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  
  DEFINE VARIABLE nodetype      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE prevnodetype  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE statementnode AS INTEGER   NO-UNDO.

  ASSIGN
     statementnode = parserGetHandle().

  /* it would boost performance if we could find criteria to 
     skip this theNode. I have tried skipping when theNode is inside a
     UIB/AB-generated codeblock, but that didn't make it any faster because:
       a. the ratio nodehead:node is only 1:2 or 1:3
       b. most nodehaeds are synthetic nodes, so determining their linenumber
          is somewhat slow
     the performance-gain from skipping nodes just about equals the overhead */

  if parserAttrGet(theNode, "statehead":U)<>"" then
     ParserCopyHandle(theNode, statementnode).
  else
     prevnodetype = parserNodeStateHead(theNode,statementnode).

  nodetype = parserNodeFirstChild (theNode,child).
  RUN TestNode(statementnode, theNode, parserGetNodeType(theNode)).

  DO WHILE nodetype <>"" :                                  
    IF parserNodeFirstChild(child,grandchild)="" THEN
       /* nodetype="ID" needs only be tested if it follows "OBJCOLON" */
       IF (nodetype<>"ID":U OR prevnodetype="OBJCOLON":U) THEN
          RUN TestNode(statementnode, child, nodetype).
    ASSIGN prevnodetype = nodetype
           nodetype     = parserNodeNextSibling(child,child).
  END.                 

  parserReleaseHandle(statementnode).
           
END PROCEDURE.                            

    
PROCEDURE TestNode :
  /* purpose : callback from InspectNode */
   DEFINE INPUT PARAMETER ParentNode AS INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER ChildNode  AS INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER NodeType   AS CHARACTER NO-UNDO.
   
   DEFINE VARIABLE NodeString    AS CHARACTER NO-UNDO.
   DEFINE VARIABLE unAbbreviated AS CHARACTER NO-UNDO.
   DEFINE VARIABLE statement     AS CHARACTER NO-UNDO.
   DEFINE VARIABLE firstchar     AS CHARACTER NO-UNDO.
   DEFINE VARIABLE prevnode      AS INTEGER   NO-UNDO.

   /* save a little time: rule out some often-used nodetypes */
   IF LOOKUP(NodeType,",QSTRING,NUMBER,PERIOD,COMMA,LEXCOLON,OBJCOLON,LEFTPAREN,RIGHTPAREN":U) GT 0 THEN
      RETURN.                  
   IF INDEX(NodeType,"_":U) GT 0 THEN 
      RETURN.

   ASSIGN                                     
      statement     = parserGetNodeType(ParentNode)
      NodeString    = parserGetNodeText(ChildNode). 

   IF (NodeString EQ "") OR (NodeType EQ NodeString) THEN 
      RETURN.                    

   /* exception: FORM is abbreviation of FORMAT, except in a FORM statement */
   IF NodeString="FORM":U THEN
      IF parserAttrGet(ChildNode, "statehead":U)<>"" THEN
         RETURN.

   /* all keywords begin with a char in A-Z range */                                          
   firstchar = UPPER(SUBSTRING(Nodestring,1,1)).
   IF firstchar LT "A":U OR firstchar GT "Z":U THEN 
      RETURN. /* save a little bit of time */

   /* start the actual test */
   unAbbreviated = Rejected(statement,NodeString).
   IF unAbbreviated = ? THEN 
      unAbbreviated = UnAbbreviate(NodeString).

   /* no need to warn about com-handle properties and methods */
   IF unAbbreviated<>NodeString AND ComhandlesAvail THEN DO:
      /* is the previous node an OBJCOLON? */
      prevnode = parserGetHandle().
      IF "OBJCOLON":U = parserNodePrevSibling(ChildNode, prevnode) THEN
         DO WHILE LOOKUP(parserNodePrevSibling(prevnode, prevnode), "Field_ref,":U)=0 :
         END.
         IF parserGetNodeType(prevnode) = "Field_ref":U THEN
            IF CAN-FIND( tt_comhandle WHERE tt_comhandle.varname =GetFieldnameFromFieldref ( prevnode )) THEN
               unAbbreviated=?.
      parserReleaseHandle(prevnode).
   END.

   IF (NOT (unAbbreviated=? OR unAbbreviated=NodeString))
       AND (NOT accepted(statement,unAbbreviated,NodeString)) THEN
         RUN PublishResult            (compilationunit,
                                       parserGetNodeFilename(ChildNode),
                                       parserGetNodeLine(ChildNode), 
                                       SUBSTITUTE("Abbreviated &1 for &2":T, NodeString, unAbbreviated),
                                       rule_id).

END PROCEDURE.    
