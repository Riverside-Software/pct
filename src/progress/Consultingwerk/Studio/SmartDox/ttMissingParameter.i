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
    File        : ttMissingParameter.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Sebastian Düngel / Consultingwerk Ltd. 
    Created     : Wed Feb 06 14:19:21 CET 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE {&ACCESS} TEMP-TABLE {&PREFIX}ttMissingParameter NO-UNDO {&REFERENCE-ONLY}
    FIELD ParameterScope   AS CHARACTER
    FIELD SourceType       AS CHARACTER
    FIELD SourceName       AS CHARACTER 
    FIELD MethodName       AS CHARACTER 
    FIELD MethodModifier   AS CHARACTER
    FIELD ParameterName    AS CHARACTER
    FIELD MissingComment   AS LOGICAL INIT "?"
    FIELD ParameterComment AS CHARACTER
    INDEX MissingParameter IS UNIQUE SourceName MethodName ParameterName.