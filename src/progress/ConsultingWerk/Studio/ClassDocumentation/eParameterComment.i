/**********************************************************************
 * Copyright 2012 Consultingwerk Ltd.                                 *
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
    File        : eParameterComment
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Sebastian D�ngel / Consultingwerk Ltd.
    Created     : Thu Oct 11 21:03:59 CEST 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE {&ACCESS} TEMP-TABLE eParameterComment NO-UNDO {&REFERENCE-ONLY} BEFORE-TABLE eParameterCommentBefore
    FIELD Name           AS CHARACTER 
    FIELD Comment        AS CLOB 
    INDEX Name IS UNIQUE NAME
    .