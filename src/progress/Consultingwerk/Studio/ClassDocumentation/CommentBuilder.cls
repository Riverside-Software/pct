/**********************************************************************
 * Copyright 2013 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        * 
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
 *                                                                    *
 **********************************************************************/
 /*------------------------------------------------------------------------
    File        : CommentBuilder
    Purpose     : Parse a longchar and build a formated HTML string.  
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Mon Apr 29 09:18:13 CEST 2013
    Notes       : Define in a seperate class, then you can define your own
                  comment style for the HTML Documentation tool.
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

CLASS Consultingwerk.Studio.ClassDocumentation.CommentBuilder
    IMPLEMENTS Consultingwerk.Studio.ClassDocumentation.ICommentBuilder:
    
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i &REFERENCE-ONLY=REFERENCE-ONLY } 

    /*------------------------------------------------------------------------------
        Purpose: Parse the full comment block. 
        Notes:   
        @param pcComment A longchar value which formated from the comment block.
        @return Get the comment block 
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR ParseComment (pcComment AS LONGCHAR):
            
        DEFINE VARIABLE lcLine      AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE iCount      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cEntry      AS CHARACTER NO-UNDO.            
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE iIndex      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cName       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cComment    AS LONGCHAR  NO-UNDO.     
                
        FIX-CODEPAGE (lcLine) = "utf-8":U .
        FIX-CODEPAGE (lcResult) = "utf-8":U .
        FIX-CODEPAGE (cComment) = "utf-8":U .  
        
        DetailLoop:    
        DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR (10)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine = TRIM (ENTRY (iCount, pcComment, CHR (10))).
              
            IF NOT lcLine BEGINS "@param":U AND 
               NOT lcLine BEGINS "@return":U AND
               NOT lcLine BEGINS "/***":U AND
               NOT lcLine BEGINS "/*-":U AND
               NOT lcLine BEGINS "/** -":U AND
               NOT lcLine BEGINS "*":U AND
               NOT lcLine BEGINS "---":U THEN DO:
                
                /* Sebastian Düngel, Consultingwerk Ltd. 13.05.2013
                   Cleaning Peter's openedge comments*/
                IF lcLine BEGINS "@author":U THEN 
                    ASSIGN lcLine = REPLACE (lcLine, "@author":U, "Author(s) :":U).
        
                IF lcLine BEGINS "/**":U THEN 
                    ASSIGN lcLine = REPLACE (lcLine, "/**":U, "Purpose:":U).
                
                ASSIGN lcResult = SUBSTITUTE ("&1&2&3":U, lcResult, lcLine, CHR (10)).
            END.
        END.
        
        ASSIGN lcResult = REPLACE (lcResult, "**/":U, "":U)
               lcResult = REPLACE (lcResult, "*/":U, "":U).
        
        RETURN lcResult.
    END.
    
    /*------------------------------------------------------------------------------
        Purpose: create a parameter temp-table for the paramter detail output. 
        Notes: The template DocumentDetailsParamter style the parameter output 
        @param pcComment A longchar value which is formated from the comment block.
        @param eParameterComment The temp-table for the comments.
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC VOID FillDetailParameterTempTable (pcComment AS LONGCHAR,
                                                     TABLE eParameterComment):
        
        DEFINE VARIABLE iCount         AS INTEGER        NO-UNDO.
        DEFINE VARIABLE lcLine         AS LONGCHAR       NO-UNDO.
        DEFINE VARIABLE cName          AS CHARACTER      NO-UNDO.    
        DEFINE VARIABLE iIndex         AS INTEGER        NO-UNDO.
        DEFINE VARIABLE cComment       AS LONGCHAR       NO-UNDO.        
        
        FIX-CODEPAGE (lcLine) = "utf-8":U . 
        FIX-CODEPAGE (cComment) = "utf-8":U . 
        
        ParamLoop: 
        DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR (10)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine = TRIM (ENTRY (iCount, pcComment, CHR (10))).
            
            IF lcLine BEGINS "@param":U THEN DO:
    
                IF NUM-ENTRIES (lcLine, " ":U) > 1 THEN 
                    ASSIGN cName = TRIM (STRING (ENTRY (2, lcLine, " ":U))).
                ELSE
                    NEXT ParamLoop.  
                
                IF Consultingwerk.CharacterType:IsNullOrEmpty (cName) THEN 
                    NEXT ParamLoop.
                  
                IF CAN-FIND (eParameterComment WHERE eParameterComment.Name = cName) THEN
                    NEXT ParamLoop.

                CREATE eParameterComment.    
                ASSIGN iIndex                    = INDEX (lcLine, cName)
                       cComment                  = TRIM (SUBSTRING (STRING (lcLine), iIndex + LENGTH (cName)))
                       eParameterComment.Name    = cName
                       eParameterComment.Comment = cComment
                       .
                RELEASE eParameterComment .
                 
            END.
            ELSE IF lcLine BEGINS "@return":U THEN DO:
                
                CREATE eParameterComment.
                ASSIGN /* Sebastian Düngel, Consultingwerk Ltd. 12.10.2012
                          @RETURN is not a valid identifier */
                       eParameterComment.Name = "RETURN":U
                       iIndex   = INDEX (lcLine, "@return":U)
                       lcLine   = REPLACE (lcLine, "*/":U, "":U)
                       eParameterComment.Comment = TRIM (SUBSTRING (STRING (lcLine), iIndex + LENGTH ("@return":U)))
                       .
                       
                RELEASE eParameterComment . 
                
            END.
        END.
        
        CATCH err AS Progress.Lang.Error:
        	DEFINE VARIABLE oException AS Consultingwerk.Exceptions.Exception NO-UNDO . 
        	
        	oException = NEW Consultingwerk.Exceptions.Exception (err, 
        	                                                      SUBSTITUTE ("Error parsing comment: &1":U,
        	                                                                  pcComment),
        	                                                      0) .
            UNDO, THROW oException .         	                                                      	
        END CATCH.
          
    END.
    
    /*------------------------------------------------------------------------------
        Purpose: Create a formated comment for the summary 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC LONGCHAR SummaryComment (pcComment AS LONGCHAR):
	    
        DEFINE VARIABLE cResult     AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iCount      AS INTEGER  NO-UNDO.
        DEFINE VARIABLE lcLine      AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lTrigger    AS LOGICAL  NO-UNDO INIT FALSE.
                
        FIX-CODEPAGE (cResult) = "utf-8":U . 
        FIX-CODEPAGE (lcLine) = "utf-8":U . 
        
        DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR (10)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine = TRIM (ENTRY (iCount, pcComment, CHR (10))).
            
            IF lcLine BEGINS "Purpose:":U THEN DO:
                ASSIGN lTrigger = TRUE
                       cResult  = TRIM (REPLACE (lcLine, "Purpose:":U, "":U))
                       .
            END.
            ELSE  
                IF lTrigger = TRUE AND lcLine BEGINS "Notes:":U THEN 
                    RETURN cResult.
                ELSE 
                    ASSIGN cResult = SUBSTITUTE ("&1&2&3":U, cResult, CHR (10), lcLine).
            
        END.
        
        RETURN cResult.
        
	END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Create a formated unit comment from the commentparser comment. 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR UnitCommentFormater (pcComment AS LONGCHAR):
        
        DEFINE VARIABLE iCount          AS INTEGER  NO-UNDO .
        DEFINE VARIABLE lcHeader        AS LONGCHAR NO-UNDO .
        DEFINE VARIABLE lcFooter        AS LONGCHAR NO-UNDO .
        DEFINE VARIABLE lcContent       AS LONGCHAR NO-UNDO .        
        DEFINE VARIABLE lFirstOutputted AS LOGICAL  NO-UNDO INIT FALSE .
        DEFINE VARIABLE lcLine          AS LONGCHAR NO-UNDO .
        DEFINE VARIABLE lcTempLine      AS LONGCHAR NO-UNDO .
        DEFINE VARIABLE lcEntry         AS LONGCHAR NO-UNDO .
        
        FIX-CODEPAGE (lcHeader) = "utf-8":U . 
        FIX-CODEPAGE (lcFooter) = "utf-8":U . 
        FIX-CODEPAGE (lcContent) = "utf-8":U . 
        FIX-CODEPAGE (lcLine) = "utf-8":U . 
        FIX-CODEPAGE (lcTempLine) = "utf-8":U . 
        FIX-CODEPAGE (lcEntry) = "utf-8":U .
        
        ASSIGN lcHeader  = "<table><tbody style='vertical-align: top'>":U
               lcFooter  = "</tbody></table>":U
               pcComment = REPLACE (pcComment, CHR(10), CHR(1)).
        
        countLoop: DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR(1)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine     = TRIM (ENTRY (iCount, pcComment, CHR(1)))
                   lcTempLine = lcLine
                   lcEntry    = ENTRY (1, lcLine, " ":U)
                   lcLine     = TRIM (SUBSTRING (lcLine, LENGTH (lcEntry) + 1))
                   .
            
            /* Sebastian Düngel, Consultingwerk Ltd. 01.03.2013
               Has the line only one word than outputted lcEntry */
            IF TRIM (lcEntry) = TRIM (lcTempLine) THEN
                ASSIGN lcLine = lcEntry.
                
            /* Mike Fechner, Consultingwerk Ltd. 22.02.2013
               Don't output unitcommentparam, when the unitcommentdesc is empty */
            IF lcEntry > "":U AND NOT TRIM (SUBSTRING (lcLine, 2)) > "":U THEN DO:
                ASSIGN lFirstOutputted = FALSE.
                
                IF lcLine = ":":U THEN 
                    NEXT countLoop .
            END.
            
            IF ENTRY (1, lcLine, " ":U) = ":":U THEN
                ASSIGN lFirstOutputted = TRUE
                        /* Mike Fechner, Consultingwerk Ltd. 06.02.2013
                           SMARTDOX-49: Nesting ENTRY in SUBSTITUTE may fail on 10.2B
                           http://knowledgebase.progress.com/articles/Article/P138807
                           http://knowledgebase.progress.com/articles/Article/000035493 */
                       lcContent = lcContent + SUBSTITUTE ("<tr><td class='unitcommentparam'>&1:</td>":U, lcEntry) .
            
            IF lFirstOutputted = TRUE THEN DO:
                /* Mike Fechner, Consultingwerk Ltd. 06.02.2013
                   SMARTDOX-49: Nesting ENTRY in SUBSTITUTE may fail on 10.2B
                   http://knowledgebase.progress.com/articles/Article/P138807
                   http://knowledgebase.progress.com/articles/Article/000035493 */
                ASSIGN lcContent = lcContent + SUBSTITUTE ("<td class='unitcommentdesc'>&1 </td></tr>":U, 
                                                           TRIM (SUBSTRING (lcLine, 2))).
            END.
            ELSE DO:
                IF TRIM (lcTempLine) > "":U THEN
                    ASSIGN lcContent = lcContent + SUBSTITUTE ("<td class='unitcommentparam'></td><td class='unitcommentdesc'>&1 </td></tr>":U, 
                                                               lcTempLine).
            END.

            ASSIGN lFirstOutputted = FALSE.
        END.
        
        ASSIGN lcContent = SUBSTITUTE ("&1&2&3":U, lcHeader, lcContent, lcFooter).
        
        RETURN lcContent.
            
        CATCH err AS Progress.Lang.Error :
            MESSAGE "Error while processing line:":U STRING (lcLine) .
            
            UNDO, THROW err .   
        END CATCH.
          
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Build a HTML Output for the comment from the commentparser comment. 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR CommentFormater (pcComment AS LONGCHAR):
        
        DEFINE VARIABLE iCount             AS INTEGER   NO-UNDO .
        DEFINE VARIABLE lcHeader           AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcFooter           AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcContent          AS LONGCHAR  NO-UNDO .        
        DEFINE VARIABLE lFirstOutputted    AS LOGICAL   NO-UNDO INIT FALSE.
        DEFINE VARIABLE lcLine             AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcEntry            AS LONGCHAR  NO-UNDO . 
        
        FIX-CODEPAGE (lcHeader) = "utf-8":U . 
        FIX-CODEPAGE (lcFooter) = "utf-8":U . 
        FIX-CODEPAGE (lcContent) = "utf-8":U . 
        FIX-CODEPAGE (lcLine) = "utf-8":U . 
        FIX-CODEPAGE (lcEntry) = "utf-8":U . 
        
        ASSIGN lcHeader  = "<table><tbody style='vertical-align: top'>":U
               lcFooter  = "</tbody></table>":U
               pcComment = REPLACE (pcComment, CHR (10), CHR(1)).
        
        DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR(1)) ON ERROR UNDO, THROW:           
            ASSIGN lcLine = TRIM (ENTRY (iCount, pcComment, CHR(1))).

            IF INDEX (ENTRY (1, TRIM (lcLine), " ":U), ":":U) > 0 AND INDEX (ENTRY (1, TRIM (lcLine), " ":U), "http://":U) = 0 THEN
                ASSIGN lFirstOutputted  = TRUE 
                        /* Mike Fechner, Consultingwerk Ltd. 06.02.2013
                           SMARTDOX-49: Nesting ENTRY in SUBSTITUTE may fail on 10.2B 
                           http://knowledgebase.progress.com/articles/Article/P138807
                           http://knowledgebase.progress.com/articles/Article/000035493 */
                       lcEntry   = ENTRY (1, TRIM (lcLine), " ":U)
                       lcContent = lcContent + SUBSTITUTE ("<tr><td class='paramname'>&1 </td>":U, lcEntry) .                  
          
            IF lFirstOutputted = TRUE THEN DO:
                IF NUM-ENTRIES (ENTRY (1, TRIM (lcLine), " ":U), ":":U) > 1 THEN
                    /* Mike Fechner, Consultingwerk Ltd. 06.02.2013
                       SMARTDOX-49: Nesting ENTRY in SUBSTITUTE may fail on 10.2B 
                       http://knowledgebase.progress.com/articles/Article/P138807
                       http://knowledgebase.progress.com/articles/Article/000035493 */                 
                    ASSIGN lcEntry   = TRIM (SUBSTRING (TRIM (lcLine), INDEX (TRIM (lcLine), ":":U) + 1))
                           lcContent = lcContent + SUBSTITUTE ("<td class='paramdesc'>&1 </td></tr>":U, lcEntry).
            END.
            ELSE DO: 
                IF TRIM (lcLine) > "":U THEN 
                    ASSIGN lcContent = lcContent + SUBSTITUTE ("<td class='paramname'></td><td class='paramdesc'>&1 </td></tr>":U, lcLine).
            END. 
            
            ASSIGN lFirstOutputted = FALSE.
        END.
        
        ASSIGN lcContent = SUBSTITUTE ("&1&2&3":U, lcHeader, lcContent, lcFooter).
            
        RETURN lcContent.
            
        CATCH err AS Progress.Lang.Error :
            MESSAGE "Error while processing line:":U STRING (lcLine) .
            
            UNDO, THROW err .   
        END CATCH.   
        
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Get the purpose comment form the unit                                                                        
        Notes:
        @param plcComment A longcharvalue with the purpose comment.
        @return A longchar value                                                                
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LONGCHAR GetUnitPurpose (plcComment AS LONGCHAR):
    
        DEFINE VARIABLE lcCommentPurpose AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iStart           AS INTEGER  NO-UNDO INIT 0. 
        DEFINE VARIABLE iEnd             AS INTEGER  NO-UNDO INIT 0. 
        
        FIX-CODEPAGE (lcCommentPurpose) = "utf-8":U .
        
        ASSIGN iStart           = INDEX (plcComment, "purpose     :":U) + LENGTH ("purpose     :":U)
               iEnd             = INDEX (plcComment, "Syntax      :":U)
               .
        
        IF iStart > 0 AND iEnd > 0 THEN 
            ASSIGN lcCommentPurpose = SUBSTRING (plcComment, iStart, iEnd - iStart).
        
        RETURN lcCommentPurpose.
                    
    END METHOD.
    
END CLASS.
