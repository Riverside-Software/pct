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
    File        : WidgetTypeEnum
    Purpose     : Widget TYPE Constants (CHARACTER) 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Aug 28 16:05:31 CEST 2011
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.

CLASS Consultingwerk.WidgetTypeEnum: 

    DEFINE PUBLIC STATIC PROPERTY AsyncRequest       AS CHARACTER NO-UNDO INIT "ASYNC-REQUEST":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY Browse             AS CHARACTER NO-UNDO INIT "BROWSE":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY BrowseColumn       AS CHARACTER NO-UNDO INIT "BROWSE-COLUMN":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY Buffer             AS CHARACTER NO-UNDO INIT "BUFFER":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY BufferField        AS CHARACTER NO-UNDO INIT "BUFFER-FIELD":U         GET . 
    DEFINE PUBLIC STATIC PROPERTY Button             AS CHARACTER NO-UNDO INIT "BUTTON":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY ComboBox           AS CHARACTER NO-UNDO INIT "COMBO-BOX":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY ControlFrame       AS CHARACTER NO-UNDO INIT "CONTROL-FRAME":U        GET .  
    DEFINE PUBLIC STATIC PROPERTY DataRelation       AS CHARACTER NO-UNDO INIT "DATA-RELATION":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY Dataset            AS CHARACTER NO-UNDO INIT "DATASET":U              GET . 
    DEFINE PUBLIC STATIC PROPERTY DataSource         AS CHARACTER NO-UNDO INIT "DATA-SOURCE":U          GET . 
    DEFINE PUBLIC STATIC PROPERTY DialogBox          AS CHARACTER NO-UNDO INIT "DIALOG-BOX":U           GET .  
    DEFINE PUBLIC STATIC PROPERTY Editor             AS CHARACTER NO-UNDO INIT "EDITOR":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY FillIn             AS CHARACTER NO-UNDO INIT "FILL-IN":U              GET .  
    DEFINE PUBLIC STATIC PROPERTY FieldGroup         AS CHARACTER NO-UNDO INIT "FIELD-GROUP":U          GET .  
    DEFINE PUBLIC STATIC PROPERTY Frame              AS CHARACTER NO-UNDO INIT "FRAME":U                GET .  
    DEFINE PUBLIC STATIC PROPERTY Image              AS CHARACTER NO-UNDO INIT "IMAGE":U                GET .  
    DEFINE PUBLIC STATIC PROPERTY Literal            AS CHARACTER NO-UNDO INIT "LITERAL":U              GET .
    DEFINE PUBLIC STATIC PROPERTY Menu               AS CHARACTER NO-UNDO INIT "MENU":U                 GET .  
    DEFINE PUBLIC STATIC PROPERTY MenuItem           AS CHARACTER NO-UNDO INIT "MENU-ITEM":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY RadioSet           AS CHARACTER NO-UNDO INIT "RADIO-SET":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY Procedure          AS CHARACTER NO-UNDO INIT "PROCEDURE":U            GET . 
    DEFINE PUBLIC STATIC PROPERTY Query              AS CHARACTER NO-UNDO INIT "QUERY":U                GET . 
    DEFINE PUBLIC STATIC PROPERTY Rectangle          AS CHARACTER NO-UNDO INIT "RECTANGLE":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY SaxAttributes      AS CHARACTER NO-UNDO INIT "SAX-ATTRIBUTES":U       GET . 
    DEFINE PUBLIC STATIC PROPERTY SaxReader          AS CHARACTER NO-UNDO INIT "SAX-READER":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY Server             AS CHARACTER NO-UNDO INIT "SERVER":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY ServerSocket       AS CHARACTER NO-UNDO INIT "SERVER-SOCKET":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY SelectionList      AS CHARACTER NO-UNDO INIT "SELECTION-LIST":U       GET .  
    DEFINE PUBLIC STATIC PROPERTY Slider             AS CHARACTER NO-UNDO INIT "SLIDER":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY SoapFault          AS CHARACTER NO-UNDO INIT "SOAP-FAULT":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY SoapFaultDetail    AS CHARACTER NO-UNDO INIT "SOAP-FAULT-DETAIL":U    GET . 
    DEFINE PUBLIC STATIC PROPERTY SoapHeader         AS CHARACTER NO-UNDO INIT "SOAP-HEADER":U          GET . 
    DEFINE PUBLIC STATIC PROPERTY SoapHeaderEntryRef AS CHARACTER NO-UNDO INIT "SOAP-HEADER-ENTRYREF":U GET . 
    DEFINE PUBLIC STATIC PROPERTY Socket             AS CHARACTER NO-UNDO INIT "SOCKET":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY SubMenu            AS CHARACTER NO-UNDO INIT "SUB-MENU":U             GET .  
    DEFINE PUBLIC STATIC PROPERTY TempTable          AS CHARACTER NO-UNDO INIT "TEMP-TABLE":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY Text               AS CHARACTER NO-UNDO INIT "TEXT":U                 GET .  
    DEFINE PUBLIC STATIC PROPERTY ToggleBox          AS CHARACTER NO-UNDO INIT "TOGGLE-BOX":U           GET .  
    DEFINE PUBLIC STATIC PROPERTY Window             AS CHARACTER NO-UNDO INIT "WINDOW":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY XDocument          AS CHARACTER NO-UNDO INIT "X-DOCUMENT":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY XNodeRef           AS CHARACTER NO-UNDO INIT "X-NODEREF":U            GET . 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE WidgetTypeEnum ():
        SUPER ().
        
    END CONSTRUCTOR.

END CLASS.