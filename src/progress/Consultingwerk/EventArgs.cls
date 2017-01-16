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
    File        : EventArgs
    Purpose     : Generic event argument class
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Dec 19 15:09:13 CET 2009
    Notes       : The SmartComponent Library does as of February 2012
                  by default use the .NET System.EventArgs instead of 
                  Consultingwerk.EventArgs as in OpenEdge 11.0 the Visual 
                  Designer causes serious issues when editing components 
                  that use non .NET derived objects as event arguments.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.* FROM PROPATH .

CLASS Consultingwerk.EventArgs:

    DEFINE PRIVATE STATIC VARIABLE oEmpty AS Consultingwerk.EventArgs NO-UNDO . 

    /*------------------------------------------------------------------------------
        Purpose: Returns the default instance of the Consultingwerk.EventArgs class                                                                     
        Notes:   
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC STATIC PROPERTY Empty AS Consultingwerk.EventArgs NO-UNDO 
    GET:
        IF NOT VALID-OBJECT (oEmpty) THEN
            oEmpty = NEW Consultingwerk.EventArgs () .
             
        RETURN oEmpty . 
    END GET.

END CLASS.
