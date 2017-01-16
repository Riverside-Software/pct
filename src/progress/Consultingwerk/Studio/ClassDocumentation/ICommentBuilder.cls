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
    File        : ICommentParser
    Purpose     : Describes methods of a class than can return a 
                  formated comment. 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Mon Apr 29 09:09:28 CEST 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*            FROM PROPATH.

INTERFACE Consultingwerk.Studio.ClassDocumentation.ICommentBuilder: 
    
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i} 
    
    /*------------------------------------------------------------------------------
        Purpose: Create a temptable with the detail comments. 
        Notes:   
        @param pcComment A longchar value which formated from the comment block.
        @param eParameterComment The Temptable for the paramters and comments
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC VOID FillDetailParameterTempTable (pcComment AS LONGCHAR, TABLE eParameterComment).
    
    /*------------------------------------------------------------------------------
        Purpose: Create a formated comment block. 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR ParseComment (pcComment AS LONGCHAR).
    
    /*------------------------------------------------------------------------------
        Purpose: Create a formated comment for the summary. 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR SummaryComment (pcComment AS LONGCHAR).
    
    /*------------------------------------------------------------------------------
        Purpose: Create a formated unit comment from the commentparser comment. 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR UnitCommentFormater (pcComment AS LONGCHAR).

    /*------------------------------------------------------------------------------
        Purpose: Build a HTML Output for the comment from the commentparser comment. 
        Notes:   
        @param pcComment The comment string
        @return A valid HTML Longchar
    ------------------------------------------------------------------------------*/ 
    METHOD PUBLIC LONGCHAR CommentFormater (pcComment AS LONGCHAR).
    
    /*------------------------------------------------------------------------------
        Purpose: Get the purpose comment form the unit                                                                        
        Notes:
        @param pcComment A longcharvalue with the purpose comment.
		@return A longchar value                                                                
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LONGCHAR GetUnitPurpose (pcComment AS LONGCHAR).
    
END INTERFACE.
