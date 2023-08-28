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
    File        : OsErrorException
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Jan 30 14:53:35 CET 2012
    Notes       :
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.
USING Consultingwerk.Exceptions.Exception.

{Consultingwerk/products.i}

CLASS Consultingwerk.Exceptions.OsErrorException
    INHERITS Exception:

    /**
     * Purpose: Returns the OE-ERROR Value associated with this error
     * Notes:
     */
    DEFINE PUBLIC PROPERTY OS-ERROR AS INTEGER NO-UNDO
    GET.
    PROTECTED SET.

    /**
     * Purpose: Returns the error message matching the OS-ERROR value
     * Notes:
     */
    DEFINE PUBLIC PROPERTY OS-ERROR-TEXT AS CHARACTER NO-UNDO
    GET.
    PROTECTED SET.

    /**
     * Purpose: Constructor for the OsErrorException class
     * Notes:
     * @param piOsError The value of the OS-ERROR property
     */
    CONSTRUCTOR PUBLIC OsErrorException (piOsError AS INTEGER):
        SUPER (SUBSTITUTE ("&1 (&2)":U,
                           Consultingwerk.Util.FileHelper:OS-ERROR-TEXT (piOsError),
                           piOSError), 0).

        ASSIGN THIS-OBJECT:OS-ERROR = piOsError
               THIS-OBJECT:OS-ERROR-TEXT = Consultingwerk.Util.FileHelper:OS-ERROR-TEXT(piOsError) .

    END CONSTRUCTOR.

END CLASS.
