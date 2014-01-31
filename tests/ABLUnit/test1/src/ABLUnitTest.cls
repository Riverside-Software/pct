 
 /*------------------------------------------------------------------------
    File        : FirstOEUnitTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bastien
    Created     : Wed Jan 22 09:46:35 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW. 
USING OpenEdge.ABLUnit.Assertions.Assert. 

CLASS ABLUnitTest: 
  
  DEFINE VARIABLE tests AS CLASS Classes.ThrowHardThings NO-UNDO.
   DEFINE PRIVATE VARIABLE cvarChar    AS CHARACTER  NO-UNDO INITIAL "Hello world !" .
    DEFINE PRIVATE VARIABLE dvarDate    AS DATE  NO-UNDO INITIAL "12/01/2014".
    DEFINE PRIVATE VARIABLE ivarInt     AS INTEGER  NO-UNDO INITIAL 10.
  
   @Test. 
   METHOD PUBLIC VOID IntegerTest():
     Assert:AssertEquals(ivarInt,10).
   END METHOD.
   
   @Test. 
   METHOD PUBLIC VOID StringTest():
       DEFINE VARIABLE flag AS LOGICAL NO-UNDO.
       DEFINE VARIABLE char2Test AS CHARACTER NO-UNDO.
        char2Test =  cvarChar.
       IF(char2Test EQ ? OR char2Test EG "") THEN flag = FALSE ELSE flag = TRUE.
     Assert:AssertTrue(flag).
   END METHOD.
 
   @Test. 
   METHOD PUBLIC VOID StringContainTest():
     Assert:AssertTrue(cvarChar MATCHES "*R*").
   END METHOD.
  
END CLASS.