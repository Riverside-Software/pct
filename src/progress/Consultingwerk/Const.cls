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
    File        : Const
    Purpose     : Framework constants 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Sep 13 10:42:23 CEST 2011
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS Consultingwerk.Const: 

    /*------------------------------------------------------------------------------
        Purpose: The list of built in ABL data types 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY ABL_DATA_TYPES AS CHARACTER INITIAL 'BLOB,CHARACTER,CLOB,COM-HANDLE,DATE,DATETIME,DATETIME-TZ,DECIMAL,HANDLE,INT64,INTEGER,LOGICAL,Progress.Lang.Object,RECID,ROWID':U NO-UNDO 
    GET.
     
    /*------------------------------------------------------------------------------
        Purpose: The maximum value a 32 bit integer variable can hold
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MAX_INTEGER AS INTEGER NO-UNDO INIT 2147483647 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: The maximum value a 64 bit integer variable can hold
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MAX_INT64 AS INT64 NO-UNDO INIT 9223372036854775807 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: The minimum value a 32 bit integer variable can hold
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MIN_INTEGER AS INTEGER NO-UNDO INIT -2147483648 
    GET.
    
    /*------------------------------------------------------------------------------
        Purpose: The minimum value a 64 bit integer variable can hold
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MIN_INT64 AS INT64 NO-UNDO INIT -9223372036854775808 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: The longers possible delimited list pattern for a SUBSTITUTE operation                                                                       
        Notes:   &9 (ampersand 9) represents the list delimiter
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY DELIMITED_LIST_FOR_SUBSTITUTE AS CHARACTER INITIAL '&1&9&2&9&3&9&4&9&5&9&6&9&7&9&8' NO-UNDO 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE Const ():
        SUPER ().
        
    END CONSTRUCTOR.

END CLASS.