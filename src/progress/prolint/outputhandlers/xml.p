/* =======================================================================================
    file    : prolint/outputhandlers/showhtml.p
    purpose : write results (found by rules) to an xml file
    by      : Gilles QUERRET
   ======================================================================================= */
{prolint/core/dlc-version.i}

DEFINE VARIABLE logfile AS CHAR NO-UNDO.

DEFINE VARIABLE xDoc  AS HANDLE NO-UNDO.
DEFINE VARIABLE xRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE xNode AS HANDLE NO-UNDO.

                                            
SUBSCRIBE TO "Prolint_InitializeResults" ANYWHERE.
SUBSCRIBE TO "Prolint_Status_FileStart" ANYWHERE.
SUBSCRIBE TO "Prolint_AddResult" ANYWHERE.
SUBSCRIBE TO "Prolint_Status_FileEnd" ANYWHERE.
SUBSCRIBE TO "Prolint_FinalizeResults" ANYWHERE.
   
RETURN.

PROCEDURE Prolint_InitializeResults :  
   /* purpose : start with an empty logfile. If one exists make it empty */
   DEFINE INPUT PARAMETER pClearOutput AS LOGICAL NO-UNDO.

END PROCEDURE.              
                           
                           
PROCEDURE Prolint_Status_FileStart :
  /* purpose: Prolint notifies you it starts on a new sourcefile. You may use this as an 
              opportunity to open a new table in htm */
  DEFINE INPUT PARAMETER pSourceFile AS CHAR NO-UNDO.
  
  ASSIGN logFile = DYNAMIC-FUNCTION("ProlintProperty", "outputhandlers.outputdirectory") + pSourceFile + ".xml".
  
  CREATE X-DOCUMENT xDoc.
  xDoc:ENCODING = "utf-8".
  CREATE X-NODEREF xRoot.
  CREATE X-NODEREF xNode.
  xDoc:CREATE-NODE(xRoot, 'lint':U, 'ELEMENT':U).
  xDoc:APPEND-CHILD(xRoot).

END PROCEDURE.
                           
   
PROCEDURE Prolint_AddResult :              
   /* purpose: add one result from a 'rule' to the logfile, 
               using the format of your choice.
               The format in this example looks pretty useless to me */
   {&_proparse_ prolint-nowarn(varusage)}            
   DEFINE INPUT PARAMETER pCompilationUnit  AS CHAR    NO-UNDO.  /* the sourcefile we're parsing          */
   DEFINE INPUT PARAMETER pSourcefile       AS CHAR    NO-UNDO.  /* may be an includefile                 */
   DEFINE INPUT PARAMETER pLineNumber       AS INTEGER NO-UNDO.  /* line number in pSourceFile            */
   DEFINE INPUT PARAMETER pDescription      AS CHAR    NO-UNDO.  /* human-readable hint                   */
   DEFINE INPUT PARAMETER pRuleID           AS CHAR    NO-UNDO.  /* defines rule-program and maps to help */
   DEFINE INPUT PARAMETER pSeverity         AS INTEGER NO-UNDO.  /* importance of this rule, scale 0-9    */
   
   xDoc:CREATE-NODE(xNode, 'rule':U, 'ELEMENT':U).
   xNode:SET-ATTRIBUTE('line', STRING(pLineNumber)).
   xNode:SET-ATTRIBUTE('description', pDescription).
   xNode:SET-ATTRIBUTE('id', pRuleID).
   xNode:SET-ATTRIBUTE('severity', STRING(pSeverity)).
   xRoot:APPEND-CHILD(xNode).

END PROCEDURE.

PROCEDURE Prolint_Status_FileEnd :
  /* purpose: Prolint notifies you when it's done linting a sourcefile. You may use this as an 
              opportunity to close the table in htm or print some totals, etc */

    xDoc:SAVE("FILE":U, logFile).

END PROCEDURE.

   
PROCEDURE Prolint_FinalizeResults :                                    
   /* purpose: close the logfile and/or show it. Free resources  */
   
   /* don't use closing tags like </body></html> so you can append to it later. 
      most browsers don't care much about these closing tags */

  DELETE OBJECT xNode.
  DELETE OBJECT xRoot.
  DELETE OBJECT xDoc.
  
  /* This procedure will not be invoked again, so it can exit */
  DELETE PROCEDURE THIS-PROCEDURE.                          
   
END PROCEDURE.