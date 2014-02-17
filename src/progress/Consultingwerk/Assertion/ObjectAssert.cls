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
    File        : ObjectAssert
    Purpose     : Provides generic methods for validating of object references
    Syntax      : 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner
    Created     : Mon Dec 12 16:10:01 CET 2011
    Notes       : Static methods, throw error on failed test.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Assertion.*  FROM PROPATH . 
USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Assertion.ObjectAssert: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ObjectAssert ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Validates an object reference and raises an Exception when the 
                 reference is valid                                                                   
        Notes:                              
        Throws:  Consultingwerk.Assertion.AssertException
        @param poObject The object reference to validate                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsNotValid (poObject AS Progress.Lang.Object):
        
        IF VALID-OBJECT (poObject) THEN 
            UNDO, THROW NEW AssertException ("Object reference is valid."{&TRAN}, 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an object reference and raises an Exception when the 
                 reference is valid                                                                                                                                      
        Notes:   
        Throws:  Consultingwerk.Assertion.AssertException                           
        @param poObject The object reference to validate                                       
        @param pcObjectDesc The optional description of the object reference used in the InvalidReferenceException
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsNotValid (poObject AS Progress.Lang.Object,
                                          pcObjectDesc AS CHARACTER):
        
        IF VALID-OBJECT (poObject) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("&1 reference is valid."{&TRAN}, pcObjectDesc), 
                                             0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates an object reference and raises an InvalidReferenceException
                 when the widget is invalid                                                                   
        Notes:                              
        Throws:  Consultingwerk.Exceptions.InvalidReferenceException
        @param poObject The object reference to validate                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsValid (poObject AS Progress.Lang.Object):
        
        IF NOT VALID-OBJECT (poObject) THEN 
            UNDO, THROW NEW InvalidReferenceException () .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an object reference and raises an InvalidReferenceException
                 when the widget is invalid                                                                   
        Notes:   
        Throws:  Consultingwerk.Exceptions.InvalidReferenceException                           
        @param poObject The object reference to validate                                       
        @param pcObjectDesc The optional description of the object reference used in the InvalidReferenceException
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsValid (poObject AS Progress.Lang.Object,
                                       pcObjectDesc AS CHARACTER):
        
        IF NOT VALID-OBJECT (poObject) THEN 
            UNDO, THROW NEW InvalidReferenceException (pcObjectDesc) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an object reference for validity and the passed in typename
                 and raises error when the tests fail 
        Notes: Use this method to test for ABL types only
        Throws:  Consultingwerk.Exceptions.InvalidTypeException
        @param poObject The object reference to validate
        @param pcClassName The object type (ABL class) to test against
        @param pcObjectDesc The optional description of the object reference used in the Error
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID TypeOf (poObject AS Progress.Lang.Object,
                                      pcClassName AS CHARACTER,
                                      pcObjectDesc AS CHARACTER):

        IF pcObjectDesc > "":U THEN 
            Consultingwerk.Assertion.ObjectAssert:IsValid (poObject, 
                                                           pcObjectDesc) .
        ELSE 
            Consultingwerk.Assertion.ObjectAssert:IsValid (poObject) .         

        IF NOT poObject:GetClass ():IsA (pcClassName) THEN 
            UNDO, THROW NEW InvalidTypeException (pcClassName,
                                                  poObject:GetClass():TypeName) .   

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates an object reference for validity and the passed in typename
                 and raises error when the tests fail 
        Notes: Use this method to test for ABL types only                              
        Throws:  Consultingwerk.Exceptions.InvalidTypeException
        @param poObject The object reference to validate
        @param pcClassName The object type (ABL class) to test against
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID TypeOf (poObject AS Progress.Lang.Object,
                                      pcClassName AS CHARACTER):

        Consultingwerk.Assertion.ObjectAssert:IsValid (poObject) .         

        IF NOT poObject:GetClass ():IsA (pcClassName) THEN 
            UNDO, THROW NEW InvalidTypeException (pcClassName,
                                                  poObject:GetClass():TypeName) .   

    END METHOD .

END CLASS.
