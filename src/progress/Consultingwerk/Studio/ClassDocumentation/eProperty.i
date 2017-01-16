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
    File        : eProperty.i
    Purpose     : Temp-Table for Property

    Syntax      :

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Sep 10 18:59:26 CEST 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE {&ACCESS} TEMP-TABLE eProperty NO-UNDO {&REFERENCE-ONLY} BEFORE-TABLE ePropertyBefore
    FIELD GUID               AS CHARACTER
    FIELD Modifier           AS CHARACTER 
    FIELD SetModifier        AS CHARACTER 
    FIELD GetModifier        AS CHARACTER 
    FIELD IsStatic           AS LOGICAL INIT FALSE 
    FIELD IsAbstract         AS LOGICAL INIT FALSE 
    FIELD Name               AS CHARACTER 
    FIELD DataType           AS CHARACTER 
    FIELD PropertyComment    AS CLOB COLUMN-CODEPAGE "UTF-8":U
    FIELD Inheritance        AS CHARACTER
    FIELD Extent             AS INTEGER 
    INDEX GUID IS UNIQUE GUID
    INDEX Name IS PRIMARY Name
    .
