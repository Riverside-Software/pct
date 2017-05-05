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
    File        : eTreeNode.i
    Purpose     : Temp-Table for TreeNodes

    Syntax      :

    Description : 

    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Wed Apr 17 09:46:48 CEST 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE {&ACCESS} TEMP-TABLE eTreeNode NO-UNDO {&REFERENCE-ONLY} BEFORE-TABLE eBeforeTreeNode
    FIELD NodeParent         AS CHARACTER
    FIELD NodeType           AS CHARACTER
    FIELD NodeName           AS CHARACTER
    FIELD NodeParentFullname AS CHARACTER
    FIELD Order              AS INTEGER
    FIELD PackageLink        AS CHARACTER
    
    INDEX NodeParentName NodeParent NodeName 
    INDEX NodeType NodeType 
    INDEX NodeParentTypeOrder NodeParent NodeType Order
    INDEX NodeParentOrder NodeParent Order NodeName
    .
