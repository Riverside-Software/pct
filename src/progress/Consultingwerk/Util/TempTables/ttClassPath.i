/**********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/   
/*------------------------------------------------------------------------
    File        : ttclasspath.i
    Purpose     : Temp-Table Definition to specify alternative folders
                  in which the class browser/class picker of the 
                  SmartComponent Library should search for classes R-Code

    Syntax      :

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Oct 25 22:20:26 CEST 2010
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE {&ACCESS} TEMP-TABLE {&PREFIX}ttClassPath NO-UNDO {&REFERENCE-ONLY} XML-NODE-NAME "ClassPath":U
    FIELD Directory AS CHARACTER XML-NODE-NAME "DirectoryEntry":U XML-NODE-TYPE "ATTRIBUTE":U
    FIELD Prefix AS CHARACTER XML-NODE-NAME "PrefixWith":U XML-NODE-TYPE "ATTRIBUTE":U
     .