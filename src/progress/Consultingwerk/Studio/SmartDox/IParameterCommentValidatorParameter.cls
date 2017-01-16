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
    File        : IParamterCommentValidatorParamtee
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Wed Feb 06 11:13:40 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Consultingwerk.Studio.SmartDox.* FROM PROPATH .  
USING Progress.Lang.*                  FROM PROPATH.

INTERFACE Consultingwerk.Studio.SmartDox.IParameterCommentValidatorParameter:  

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the source directory, where is the classdoc reference dirrectory.
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY SourceDir AS CHARACTER NO-UNDO 
    GET.
    SET. 

END INTERFACE.