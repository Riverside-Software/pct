&IF 1=0 &THEN
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
    File        : EnumMember.i
    Purpose     : Defines an Enum Member property in an Enum class

    Syntax      : {Consultingwerk/EnumMember.i Label Value TypeName}

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Aug 25 12:24:36 CEST 2010
    Notes       :
  ----------------------------------------------------------------------*/
&ENDIF

    DEFINE PUBLIC STATIC PROPERTY {1} AS {3} NO-UNDO 
    GET:
        IF NOT VALID-OBJECT ({3}:{1}) THEN 
            {3}:{1} = NEW {3} ({2}, "{1}":U) .
            
        RETURN {3}:{1} .           
    END GET . 
    PRIVATE SET. 
    
&IF "{&EnumMembers}":U NE "":U &THEN
&GLOBAL-DEFINE EnumMembers {&EnumMembers},{1}
&ELSE
&GLOBAL-DEFINE EnumMembers {1}
&ENDIF