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
    File        : ListChangedEventArgs
    Purpose     : Event argument for the ListChanged event of lists,
                  collections or dictionaries that implement the 
                  ISupportsListChanged event
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jan 19 22:01:47 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.EventArgs        FROM PROPATH .
USING Consultingwerk.Framework.Enum.* FROM PROPATH .
USING Progress.Lang.*                 FROM PROPATH .

CLASS Consultingwerk.Framework.Base.ListChangedEventArgs INHERITS EventArgs: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the type of the List modification as a ListChangedTypeEnum value                                                                       
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ListChangedType AS ListChangedTypeEnum NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ListChangedEventArgs class                                                                        
        Notes:   Thakes the value for read only ListChangedType property as a parameter
        @param poListChangedType The value for the ListChangeType property                                                                      
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ListChangedEventArgs (poListChangedType AS ListChangedTypeEnum):
        SUPER ().
        
        Consultingwerk.Assertion.ObjectAssert:IsValid (poListChangedType, "ListChangedType":U) .
        
        THIS-OBJECT:ListChangedType = poListChangedType . 
        
    END CONSTRUCTOR.

END CLASS.