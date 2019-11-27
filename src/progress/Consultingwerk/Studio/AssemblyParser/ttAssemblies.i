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
    File        : ttAssemblies.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Aug 24 20:52:55 CEST 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE {&ACCESS} TEMP-TABLE ttAssemblies NO-UNDO {&REFERENCE-ONLY} 
    FIELD AssemblyEntry AS CHARACTER 
    FIELD AssemblyName AS CHARACTER
    FIELD Version AS CHARACTER
    FIELD Culture AS CHARACTER 
    FIELD PublicKeyToken AS CHARACTER 
    INDEX Assembly AssemblyName Version .   
    
