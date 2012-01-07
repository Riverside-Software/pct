/* ------------------------------------------------------------------------
   file    :  prolint/rules/noeffect.p
   by      :  John Green
   purpose :  Find statements which are nothing but expressions.
              Of those, evaluate which /cannot/ have an effect.
              User-defined functions might have an effect,
              and methods might have an effect.
              Of the built-in functions, I am only aware of the following
              having any effect:
              DYNAMIC-FUNCTION
              ETIME
              SETUSERID
              SUPER
              CURRENT-LANGUAGE
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 John Green

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
   ------------------------------------------------------------------------
*/

{prolint/core/ruleparams.i}
{prolint/rules/inc/nobrackets.i}

RUN searchNode            (hTopnode,                /* "Program_root" node */
                           "InspectNode":U,         /* name of callback procedure */
                           "Expr_statement":U).     /* list of statements to search, ?=all */

RETURN.

PROCEDURE InspectNode:
  /* purpose: see if the statement in theNode is really a statement without effect */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE qname       AS CHARACTER NO-UNDO INITIAL "rule_noeffect":U.
  DEFINE VARIABLE i           AS INTEGER NO-UNDO.
  DEFINE VARIABLE numResults  AS INTEGER NO-UNDO.
  DEFINE VARIABLE result      AS INTEGER NO-UNDO.

  result = parserGetHandle().

  check-block:
  DO:

    IF parserQueryCreate(theNode, qname, "USER_FUNC":U) > 0 THEN
       LEAVE check-block.
    IF parserQueryCreate(theNode, qname, "DYNAMICFUNCTION":U) > 0 THEN
       LEAVE check-block.
    IF parserQueryCreate(theNode, qname, "LOCAL_METHOD_REF":U) > 0 THEN
       LEAVE check-block.
    IF parserQueryCreate(theNode, qname, "ETIME":U) > 0 THEN
       LEAVE check-block. 
    IF parserQueryCreate(theNode, qname, "SETUSERID":U) > 0 THEN
       LEAVE check-block.
    IF parserQueryCreate(theNode, qname, "SUPER":U) > 0 THEN
       LEAVE check-block.
    IF parserQueryCreate(theNode, qname, "NEXTVALUE":U) > 0 THEN
       LEAVE check-block.

    /* The last thing we check on is methods. 
       a statement like  handle:READ-ONLY has no effect, 
       a statement like  handle:GET-FIRST() does have effect,
       so look for OBJCOLON _not_ followed by node type "Method_param_list" */
    ASSIGN
      result = parserGetHandle()
      numResults = parserQueryCreate(theNode, qname, "OBJCOLON":U).
    DO i = 1 TO numResults:
      parserQueryGetResult(qname, i, result).
      /* from "widattr" in the tree spec:
       * (OBJCOLON . #(Array_subscript...)? #(Method_param_list...)? )+
       * First, move to the method or attribute name node - the . (i.e. any) token
       * after the OBJCOLON.
       * Then, simply  check next sibling twice. First time might be Array_subscript.
       */
      parserNodeNextSibling(result, result).

      /* methods are supposed to have (), but these can be omitted if there are
         no parameters. When omitted, noeffect will raise a warning.
         Try to suppress the warning for some of commonly used methods.
         Re-use the same list of methods in rule 'nobrackets' */
      IF LOOKUP(parserGetNodeText(RESULT),nobracketlist)>0 THEN
         LEAVE check-block.
      
      IF parserNodeNextSibling(result, result) = "Method_param_list":U THEN
         LEAVE check-block.
      IF parserNodeNextSibling(result, result) = "Method_param_list":U THEN
         LEAVE check-block.
    END.
                                        
                                        
    /* If we got here, then the expression statement probably has no effect.
     * "Expr_statement" is a synthetic node, so it won't have a line
     * number. Instead, use the first non-synthetic node for PublishResult.
     */                              
    parserNodeFirstChild(theNode, result).  
    DO WHILE parserGetNodeLine(result) EQ 0 :
       parserNodeFirstChild(result,result).
    END.   
  
    RUN PublishResult            (compilationunit,
                                  parserGetNodeFilename(result),
                                  parserGetNodeLine(result),
                                  "Statement has no effect":T,
                                  rule_id).

  END.  /* check-block */

  parserReleaseHandle(result).
  parserQueryClear(qname).

END PROCEDURE. /* InspectNode */

