/**********************************************************************
 * Copyright 2017 Consultingwerk Ltd.                                 *
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
    File        : eTempTable.i
    Purpose     : Temp-Table for Temp-Table

    Syntax      :

    Description :

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Sep 10 18:59:26 CEST 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE {&ACCESS} TEMP-TABLE eTempTable NO-UNDO {&REFERENCE-ONLY} BEFORE-TABLE eTempTableBefore
    FIELD GUID           AS CHARACTER
    FIELD UnitGUID       AS CHARACTER
    FIELD Name           AS CHARACTER
    FIELD definition     AS CHARACTER
    FIELD likeDefinition AS CHARACTER SERIALIZE-NAME "like":U
    FIELD noUndo         AS LOGICAL
    FIELD beforeTable    AS CHARACTER
    FIELD xmlnodename    AS CHARACTER
    FIELD SourceCode     AS CHARACTER
    INDEX GUID IS UNIQUE GUID
    INDEX Name IS PRIMARY UnitGUID Name
    .
