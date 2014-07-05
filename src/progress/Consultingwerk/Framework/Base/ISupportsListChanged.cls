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
    File        : ISupportsListChanged
    Purpose     : Interface for List implementations that support the 
                  ListChanged event  
    Syntax      : 
    Description : The ListChanged event can be used to invalidate an 
                 enumerator when the List changes
    Author(s)   : Mike Fechner / Consultingwerk Ltd. 
    Created     : Fri Jan 20 23:42:11 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

USING Consultingwerk.Framework.Base.* FROM PROPATH .
USING Progress.Lang.*                 FROM PROPATH .

INTERFACE Consultingwerk.Framework.Base.ISupportsListChanged:  
  
    /*------------------------------------------------------------------------------
        Purpose: Raised when the List is changed by adding or removing items or 
                 clearing the list
        Notes:      
        @param sender The sender of the event
        @param e The ListChangedEventArgs object instance with the data of the ListChanged event                                                                  
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC EVENT ListChanged SIGNATURE VOID (sender AS Progress.Lang.Object, e AS ListChangedEventArgs).
  
END INTERFACE.