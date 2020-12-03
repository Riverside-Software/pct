/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.Object.
USING OEUnit.Automation.BaseReporter.
USING OEUnit.Automation.CSVReporter.
USING OEUnit.Automation.JUnitReporter.
USING OEUnit.Automation.SureFireReporter.
USING OEUnit.Automation.TextReporter.
USING OEUnit.Runner.TestResult.
USING OEUnit.Runners.OEUnitRunner.
USING OEUnit.Util.List.
USING OEUnit.Util.Instance.

/* Named streams */
DEFINE STREAM sParams.

DEFINE VARIABLE reportFormat AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE hasErrors AS LOGICAL NO-UNDO INITIAL FALSE. 

/* Checks for valid parameters */
IF (SESSION:PARAMETER EQ ?) THEN
    RETURN '20'.

IF (NUM-ENTRIES(SESSION:PARAMETER) NE 3) THEN
    RETURN '30'.

MESSAGE "Out directory : " + ENTRY(2,SESSION:PARAMETER).

reportFormat = ENTRY(3,SESSION:PARAMETER).

/* Read file */  
INPUT STREAM sParams FROM VALUE(ENTRY(1,SESSION:PARAMETER)).
REPEAT:
    IMPORT STREAM sParams UNFORMATTED cLine.
    MESSAGE "Run test from : " + cLine.
    RUN RunClassAsTest(ENTRY(1,cLine,'='),ENTRY(2,cLine,'=')).
END.
INPUT STREAM sParams CLOSE.

RETURN (IF hasErrors THEN '10' ELSE '0').

/*----------------------------------------------------------------------------
    Run a single test class and record the results using the SureFire xml
    format.
  ----------------------------------------------------------------------------*/ 
PROCEDURE RunClassAsTest PRIVATE:
  DEFINE INPUT PARAMETER className AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER classFile AS CHARACTER NO-UNDO.
      
  DEFINE VARIABLE test AS Object NO-UNDO.
  
  test = Instance:FromFile(classFile).
  
  DEFINE VARIABLE runner AS OEUnitRunner NO-UNDO.
  runner = NEW OEUnitRunner().

  /* Run your test case or suite */
  runner:RunTest(test).
  IF runner:Results:GetStatus() EQ TestResult:StatusPassed OR runner:Results:GetStatus() EQ TestResult:StatusFailed THEN DO:
     IF runner:Results:GetStatus() EQ TestResult:StatusFailed THEN
        MESSAGE "  > At least one failure.".
        
      /* If OK, log the results */
      DEFINE VARIABLE reporter AS BaseReporter NO-UNDO.
      
      IF OPSYS = "WIN32" THEN 
        className = "~\" + className.
      ELSE 
        className = "/" + className.
        
      CASE reportFormat:
          WHEN 'SUREFIRE':U THEN DO: 
              reporter = NEW SureFireReporter(ENTRY(2,SESSION:PARAMETER)).
          END.
          WHEN 'JUNIT':U THEN DO: 
              reporter = NEW JUnitReporter(ENTRY(2,SESSION:PARAMETER) + className + ".xml").
          END.
          WHEN 'CSV':U THEN DO: 
              reporter = NEW CSVReporter(ENTRY(2,SESSION:PARAMETER) + className + ".csv").
          END.
          WHEN 'TEXT':U THEN DO: 
              reporter = NEW TextReporter(ENTRY(2,SESSION:PARAMETER) + className + ".txt").
          END.
          OTHERWISE DO:
              hasErrors = TRUE.
              MESSAGE "Unknown reporter format : " + reportFormat.
          END.
      END.
      reporter:Report(runner:Results).
  END.
  ELSE DO:
    IF runner:Results:GetStatus() EQ TestResult:StatusError THEN DO:
        hasErrors = TRUE.
        MESSAGE "  > Error Message : " + runner:Results:GetMessage().
    END.
    ELSE
          MESSAGE "  > Specific status : " + runner:Results:GetStatusAsString().
  END.

  FINALLY:
    DELETE OBJECT test NO-ERROR.
    DELETE OBJECT runner NO-ERROR.
    IF reporter NE ? THEN
        DELETE OBJECT reporter NO-ERROR.    
  END FINALLY.
    
END PROCEDURE.