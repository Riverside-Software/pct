/* ------------------------------------------------------------------------
   file    :  prolint/rules/ifindent.p
   by      :  Judy Hoffman Green, Joanju Limited, www.joanju.com
   purpose :  check IF statements for indenting that could indicate bugs. 
   ------------------------------------------------------------------------ 

    Copyright (C) 2002 Judy Hoffman Green

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

    -----------------------------------------------------------------
   
Warning Numbers Reference: 
 101: important: indicates possible code bug. 
 102: important: indicates possible code bug.
 201: informational. 
 202: informational. 
 203: informational. Comes up once per IF. 


Future Enhancements: 
-  set attributes on nodes that are ok, then look at this in NEXTBLOCK once you
   have the node you're going to check. (and set attr if a node's indent is ok).  
   Sometimes we end up analyzing the same node more than once (particularly in 
   the NEXTBLOCK), and this could save a bit of running time. 
   Probably only want to do this for the IF nodes themselves, and their "next statements". 
   Don't do this for the subNodes of the IF, as you don't actually know their indents
   are correct, just that they are okay when compared to the current IF node. 

***********/


{prolint/core/ruleparams.i}  

DEFINE VARIABLE IgnoreAppbuilderstuff AS LOGICAL NO-UNDO.
IgnoreAppbuilderstuff = LOGICAL ( DYNAMIC-FUNCTION ("ProlintProperty", "filters.IgnoreAppbuilderstuff")).

/* This variable stays the same through all runs of the rule. */
DEFINE VARIABLE warnings AS CHARACTER INITIAL "Both" NO-UNDO.

/* Runtime argument from wrapper .p's. 
 * If this procedure is run directly, without this argument being supplied, 
 * it will run for "Both" kinds of warnings.  
 * The wrappers will contain: 
 *      &SetWarnings="ASSIGN warnings = 'Major'."   
 * or   &SetWarnings="ASSIGN warnings = 'Minor'." 
 *
 */
{&SetWarnings}


RUN searchNodeQueries            (hTopnode,      /* "Program_root" node          */
                           "InspectNode":U,      /* name of callback procedure   */
                           "IF":U).              /* list of nodetypes to search  */
RETURN.







PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
/* purpose : callback from searchNode. Inspect the node found by searchNode */

  DEFINE INPUT  PARAMETER ifNode         AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodeFilename AS CHARACTER NO-UNDO.
  DEFINE VARIABLE shortName    AS CHARACTER NO-UNDO.

  DEFINE VARIABLE numResults   AS INTEGER NO-UNDO.
  DEFINE VARIABLE i1           AS INTEGER NO-UNDO.
  DEFINE VARIABLE parent       AS INTEGER NO-UNDO.
  DEFINE VARIABLE compNode     AS INTEGER NO-UNDO.
  DEFINE VARIABLE subNode      AS INTEGER NO-UNDO.
  DEFINE VARIABLE nextNode     AS INTEGER NO-UNDO.
  DEFINE VARIABLE tmpNode      AS INTEGER NO-UNDO.

  DEFINE VARIABLE ifColumn     AS INTEGER NO-UNDO.
  DEFINE VARIABLE otherColumn  AS INTEGER NO-UNDO.
  DEFINE VARIABLE currLine     AS INTEGER NO-UNDO.
  DEFINE VARIABLE found        AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE firstTime    AS LOGICAL INITIAL TRUE NO-UNDO.


  ASSIGN
    parent    = parserGetHandle()
    compNode  = parserGetHandle()
    subNode   = parserGetHandle()
    nextNode  = parserGetHandle()
    tmpNode   = parserGetHandle().
  


  IF parserAttrGet(ifNode, "statehead":U) = "" THEN RETURN. 


  /* If we're excluding AppBuilder stuff, find out now. Don't bother checking 
   * the indents of IFs from the AppBuilder generated code. This is just 
   * a quick check to see if the IF node comes from $DLC code. A more thorough 
   * check will be done later in PublishResult if we're actually going to give 
   * a warning.
   */   
  IF IgnoreAppbuilderstuff THEN
     IF IgnoreAB THEN DO:
       ASSIGN nodefilename = RelativeFilename(parserGetNodeFilename(ifNode)).
       IF (nodefilename MATCHES "src/adm/*~~.i":U)
       OR (nodefilename MATCHES "src/adm2/*~~.i":U) THEN RETURN.
     END.


  /* First, calculate IF's indent. If the IF is an ELSE IF,
   * use the ELSE's indent as the IF's indent.
   */
  IF  parserNodeParent(ifNode,parent) = "ELSE"
  THEN ifColumn = parserGetNodeColumn(parent).
  ELSE ifColumn = parserGetNodeColumn(ifNode).




  ASSIGN currLine = parserGetNodeLine(ifNode).

  /* Next, check all of the IF's children nodes. */

  /* Do an unfiltered query for all children subnodes of the IF node. */
  numResults = parserQueryCreate(ifNode, "query_unf", "").


  SUBBLOCK: 
  DO i1 = 1 TO numResults:

    parserQueryGetResult("query_unf", i1, subNode).
 
    /* Skip synthetic nodes. */
    IF parserGetNodeText(subNode) = "" THEN NEXT SUBBLOCK. 

    IF parserGetNodeFilename(subNode) = parserGetNodeFilename(ifNode) THEN DO: 
 
      /* All these nodes are on the same line as last time, so they have at least 
       * as much indent as the first real node on this line. 
       */
      IF parserGetNodeLine(subNode) = currLine THEN NEXT SUBBLOCK. 

      ELSE DO: /* different line num */
 
        otherColumn = parserGetNodeColumn(subNode).

        /* Compare indents. If the indents are equal, that's okay. */
        IF  ifColumn > otherColumn
        AND warnings <> "Minor" THEN 
          RUN PublishResult            (compilationunit,
                                        parserGetNodeFilename(subNode),
                                        parserGetNodeLine(subNode),
                                        SUBSTITUTE("#102: More indent expected for node &1. Node's indent should be at least &2, is &3.":T,
                                                    SUBSTRING(parserGetNodeText(subNode),1,20),
                                                    ifColumn - 1,
                                                    otherColumn - 1),
                                        rule_id).


        ASSIGN currLine = parserGetNodeLine(subNode). 

      END. /* else do - different line num */

    END. /* IF parserGetNodeFilename(subNode)... */




    /* A subNode is in a different file than the ifNode. Just warn about this once per IF.
     * It's impossible to realistically compare any indents across files. 
     * This warning may indicate bad coding practice.
     */
    ELSE   
    IF  warnings <> "Major"
    AND firstTime THEN DO: 
      ASSIGN shortName = "..." + SUBSTRING(parserGetNodeFilename(ifNode),
                         LENGTH(parserGetNodeFilename(ifNode)) - 15). 
      /*
       * RUN PublishResult            (compilationunit,
       *                             parserGetNodeFilename(subNode), /* can be include */
       *                             parserGetNodeLine(subNode),
       *                             SUBSTITUTE("#203: Subnode &1 is in a different file. IF is in &2, line &3. Can't compare to IF's indent.":T,
       *                                         SUBSTRING(parserGetNodeText(subNode),1,20),
       *                                         shortName,
       *                                         parserGetNodeLine(ifNode)),
       *                             rule_id).
       */
      ASSIGN firstTime = FALSE.
    END.



  END. /* SUBBLOCK: do i1... */

  parserQueryClear ("query_unf":U).







  /* Now check for statements not controlled by the IF, but indented from 
   * the IF like they are. We'll only check the next sibling node of the IF, 
   * if it exists. If it's in a different file than the IF, we can't compare indents.
   */
  NEXTBLOCK: 
  DO: 
    parserCopyHandle(ifNode,compNode).
    ASSIGN found = FALSE.

    /* Try to find a comparison node */
    IF parserNodeNextSibling(compNode,compNode) <> "" THEN DO:

        IF parserGetNodeText(compNode) <> "" THEN
           ASSIGN found = TRUE.
        ELSE DO:
           /* If the sibling is synthetic, look at its' children to find the first real node. */

           /* Do an unfiltered query for all children subnodes of this sibling.
            * We could just go through the children of this sibling, but the
            * unfiltered query adjusts to infix notation for us.
            */
           ASSIGN
              numResults = parserQueryCreate(compNode, "query_sib", "")
              i1 = 0.
           DO WHILE (i1 < numResults) AND (NOT found) :
                i1 = i1 + 1.
                parserQueryGetResult("query_sib", i1, tmpNode).
       
                /* Once we've got a real node, we can go check its' indent. */
                IF parserGetNodeText(tmpNode) <> "" THEN DO:
                  parserCopyHandle(tmpNode,compNode).
                  ASSIGN found = TRUE.
                END.
           END. /* do i1... */
           parserQueryClear ("query_sib":U).
        END. /* else do */
    END.
    

    /* If we don't have a next sibling node to compare to, we're done with this IF. */
    IF NOT found THEN LEAVE NEXTBLOCK.
  

    /* If the next statement isn't in the same file, we don't do anything. 
     * With future changes to Proparse, we may be more easily able to check these. 
     */
    ELSE
    IF parserGetNodeFilename(compNode) <> parserGetNodeFilename(ifNode) THEN DO:
    /*
     * IF warnings <> "Major" THEN
     *   RUN PublishResult            (compilationunit,
     *                                 parserGetNodeFilename(compNode), /* can be include */
     *                                 parserGetNodeLine(compNode),
     *                                 SUBSTITUTE("#201: Next statement &1 is not in same file as IF. Can't compare indent with IF on line &2.":T,
     *                                             SUBSTRING(parserGetNodeText(compNode),1,20),
     *                                             parserGetNodeLine(ifNode)),
     *                                 rule_id).
     */
      LEAVE NEXTBLOCK.
    END. 



    /* Otherwise, we have a comparison node, so compare and report. */
    otherColumn = parserGetNodeColumn(compNode).

    IF otherColumn > ifColumn THEN DO:
      IF warnings <> "Minor" THEN
        RUN PublishResult            (compilationunit,
                                      parserGetNodeFilename(compNode),
                                      parserGetNodeLine(compNode),
                                      SUBSTITUTE("#101: Node &1 has greater indent than IF on line &2. Expected to be &3, is &4.":T,
                                                  SUBSTRING(parserGetNodeText(compNode),1,20),
                                                  parserGetNodeLine(ifNode),
                                                  ifColumn - 1,
                                                  otherColumn - 1),
                                      rule_id).
      LEAVE NEXTBLOCK.
    END. 




    ELSE 
    IF otherColumn < ifColumn THEN DO:

      /* If it's going to be a 202, do some checks first to suppress false positives:
       * 1. if compNode is an END, it's ok to have less indent than the IF.
       * 2. if compNode is ELSE, use compNode's statehead's indent to compare to.
       * 3. if ELSE's statehead is a DO, use DO's statehead's indent to compare to.
       * 4. if compNode and ifNode's statehead have same indent, then ok.
       * 5. if ifNode's statehead is a DO, use DO's statehead's indent to compare to.
       */

      IF warnings = "Major" THEN LEAVE NEXTBLOCK. 

      IF parserGetNodeType(compNode) = "END" THEN
        LEAVE NEXTBLOCK. 

      IF  parserGetNodeType(compNode) = "ELSE"
      AND parserNodeStateHead(compNode,tmpNode) <> "" THEN DO: 
        IF  parserGetNodeColumn(tmpNode) = otherColumn
        THEN LEAVE NEXTBLOCK.

        ELSE 
        IF  parserGetNodeType(tmpNode) = "DO"         /* compNode's statehead is a DO */
        AND parserNodeStateHead(tmpNode,tmpNode) <> "" 
        AND parserGetNodeColumn(tmpNode) = otherColumn
        THEN LEAVE NEXTBLOCK.
      END. 

      /* If that didn't work, compare otherColumn and ifNode's statehead's indent. */
      IF parserNodeStateHead(ifNode,tmpNode) <> "" THEN DO:
        IF  parserGetNodeColumn(tmpNode) = otherColumn
        THEN LEAVE NEXTBLOCK.

        ELSE 
        IF  parserGetNodeType(tmpNode) = "DO"           /* ifNode's statehead is a DO */  
        AND parserNodeStateHead(tmpNode,tmpNode) <> "" 
        AND parserGetNodeColumn(tmpNode) = otherColumn
        THEN LEAVE NEXTBLOCK.
      END. 

      /* If we're still here, give warning. */
      RUN PublishResult            (compilationunit,
                                    parserGetNodeFilename(compNode),
                                    parserGetNodeLine(compNode),
                                    SUBSTITUTE("#202: Node &1 has less indent than IF on line &2. Expected to be &3, is &4.":T,
                                                SUBSTRING(parserGetNodeText(compNode),1,20),
                                                parserGetNodeLine(ifNode),
                                                ifColumn - 1,
                                                otherColumn - 1),
                                    rule_id).
    END. 


  END. /* NEXTBLOCK */  




  parserReleaseHandle(parent).
  parserReleaseHandle(compNode).
  parserReleaseHandle(subNode).
  parserReleaseHandle(nextNode).
  parserReleaseHandle(tmpNode).
    
END PROCEDURE.


