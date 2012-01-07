/*  file    : prolint/rules/nonestinc.p
    purpose : Prolint rule program to detect nested include files
    -----------------------------------------------------------------

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

DEFINE STREAM lstStream.

DEFINE VARIABLE IncludeLvl      AS CHAR      NO-UNDO.
DEFINE VARIABLE LineNumber      AS CHAR      NO-UNDO.
DEFINE VARIABLE LIneStr         AS CHAR      NO-UNDO.  
DEFINE VARIABLE intLineNumber   AS INT      NO-UNDO.  
DEFINE VARIABLE PrevInc         AS INTEGER   NO-UNDO.  
DEFINE VARIABLE IntIncludeLvl   AS INT       NO-UNDO.  
DEFINE VARIABLE InputString     AS CHARACTER NO-UNDO.
DEFINE VARIABLE PrevLine        AS INT       NO-UNDO.  
DEFINE VARIABLE SrcFile         AS CHARACTER NO-UNDO.
DEFINE VARIABLE PrevSrcFile     AS CHARACTER NO-UNDO.
DEFINE VARIABLE startBracket    AS INTEGER NO-UNDO.
DEFINE VARIABLE endBracket      AS INTEGER NO-UNDO.
DEFINE VARIABLE accumSw         AS LOG NO-UNDO INIT NO.
DEFINE VARIABLE PassSw          AS LOG NO-UNDO INIT NO.
DEFINE VARIABLE accumInc        AS CHAR NO-UNDO .

DEFINE VARIABLE stack           AS CHAR NO-UNDO.



FUNCTION pushStack RETURNS LOGICAL (pEntry AS CHAR ) FORWARD.
FUNCTION pullStack RETURNS LOGICAL () FORWARD.
FUNCTION getStack RETURNS CHAR () FORWARD.


stack = compilationunit.

INPUT STREAM lstStream FROM VALUE (listingfile ).

DO WHILE TRUE :
     
   /* use the IMPORT UNFORMATTED to handle the fact that coumns are irregular */ 
   IMPORT STREAM lstStream UNFORMATTED InputString.

  
   ASSIGN IncludeLvl = SUBSTRING(InputString,1,2)
          LineNUmber = SUBSTRING(InputString,4,4)
          LineStr = SUBSTRING(InputString,13).

   IncludeLvl = TRIM(IncludeLvl ).
  
   IF IncludeLvl  BEGINS "." OR IncludeLvl BEGINS "~{" OR IncludeLvl BEGINS "Fi" OR LineStr = "" THEN
      NEXT.
         
   ASSIGN PrevInc = intIncludeLvl.
          PrevLine = intLineNUmber.
   
   ASSIGN intIncludeLvl = INTEGER(IncludeLvl) NO-ERROR.
   IF ERROR-STATUS:ERROR  THEN
      NEXT.
   
   ASSIGN intLineNumber = INTEGER(LineNumber) NO-ERROR.
   IF ERROR-STATUS:ERROR  THEN
      NEXT.
 
   IF INDEX(lineStr,"~{") > 0 THEN
      DO:
         startBracket = INDEX(LineStr,"~{").
         
         IF startBracket > 1 THEN 
            IF SUBSTRING(LIneStr,startBracket - 1,1) = "~~" THEN
               LEAVE.
         
         ASSIGN accumSw = YES
                passSW  = YES 
                accumInc = SUBSTRING(LIneStr,startBracket).  
                
      END.

   IF INDEX(LineStr,"~}") > 0 THEN
      DO:
         endBracket = INDEX(LineStr,"~}").
         IF endBracket > 1 THEN 
         IF SUBSTRING(lineStr,endBracket - 1,1) = "~~" THEN
            LEAVE.

         ASSIGN accumSw = NO
                passSW  = YES
                accumInc = accumInc + SUBSTRING(lineStr,1,endBracket).          
                               
      END.

   IF accumSw AND NOT passSW THEN 
      accumInc = accumInc + lineStr.
   
   IF passSW  THEN passSW = NO.

   IF PrevInc < intIncludeLvl THEN  
      pushStack(TRIM(SUBSTRING(accumInc,1,INDEX(accumInc,".") + 1),"~{")).
   
   IF PrevInc > intIncludeLvl THEN
      pullStack().
              
   IF PrevInc < intIncludeLvl AND intIncludeLvl > 1 THEN
         RUN PublishResult (compilationunit, getStack() , prevLine, "Nested Include Found: " + accumInc,rule_id).
      
END.
INPUT STREAM lstStream CLOSE.       

      
RETURN.


FUNCTION pushStack RETURNS LOGICAL (pEntry AS CHAR ):
   stack = pEntry + "," +  stack.
END FUNCTION.


FUNCTION pullStack RETURNS LOGICAL ():
   
   stack = SUBSTRING(stack,INDEX(stack,",") + 1).
   
END FUNCTION.

FUNCTION getStack RETURNS CHAR ():

   RETURN ENTRY(2,stack).
END FUNCTION.


