/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
 
 /*------------------------------------------------------------------------------
  File        :   RunTests.p
  Package     :   OEUnit.Automation.Pct
  Description :   Run test classes in the given testLocation. If testLocation 
                  value contains a class file, that file will be executed as a 
                  test case. If testLocation contains a directory, it will be
                  searched for test classes to execute. 
  ------------------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.Object.
USING OEUnit.Automation.*.
USING OEUnit.Runner.TestResult.
USING OEUnit.Runners.OEUnitRunner.
USING OEUnit.Util.*.

/* Named streams */
DEFINE STREAM sParams.

DEFINE VARIABLE cLine     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE hasErrors AS LOGICAL NO-UNDO INITIAL FALSE. 
DEFINE VARIABLE i AS INTEGER NO-UNDO.

/* Checks for valid parameters */
IF (SESSION:PARAMETER EQ ?) THEN
    RETURN '20'.

IF (NUM-ENTRIES(SESSION:PARAMETER) NE 3) THEN
    RETURN '30'.

MESSAGE "Out directory : " + ENTRY(2,SESSION:PARAMETER).

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
  DEFINE VARIABLE errors AS List NO-UNDO.
  DEFINE VARIABLE err AS Progress.Lang.Error NO-UNDO.
  
  test = Instance:FromFile(classFile).
  
  DEFINE VARIABLE runner AS OEUnitRunner NO-UNDO.
  runner = NEW OEUnitRunner().

  /* Run your test case or suite */
  runner:RunTest(test).
  IF runner:Results:GetStatus() <> TestResult:StatusPassed AND runner:Results:GetStatus() <> TestResult:StatusFailed THEN DO:
    IF runner:Results:GetStatus() EQ TestResult:StatusError THEN DO:
        hasErrors = TRUE.
        MESSAGE "  > Error Message : " + runner:Results:GetMessage().
    END.
    ELSE
          MESSAGE "  > Specific status : " + runner:Results:GetStatusAsString().
  END.
  ELSE DO:
      IF runner:Results:GetStatus() EQ TestResult:StatusFailed THEN
        MESSAGE "  > At least one failure.".
        
      /* If OK, log the results */
      DEFINE VARIABLE reporter AS BaseReporter NO-UNDO.
      
      IF OPSYS = "WIN32" THEN 
        className = "~\" + className.
      ELSE 
        className = "/" + className.
        
      CASE ENTRY(3,SESSION:PARAMETER):
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
              MESSAGE "Unknown reporter format : " + ENTRY(3,SESSION:PARAMETER).
          END.
      END.
      reporter:Report(runner:Results).
  END.

  FINALLY:
    DELETE OBJECT test NO-ERROR.
    DELETE OBJECT runner NO-ERROR.
    IF reporter NE ? THEN
        DELETE OBJECT reporter NO-ERROR.    
  END FINALLY.
    
END PROCEDURE.