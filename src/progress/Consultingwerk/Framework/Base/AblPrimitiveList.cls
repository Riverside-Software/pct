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
    File        : AblPrimitiveList
    Purpose     : Abstract foundation for lists of ABL primitive 
                  values
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consulingwerk Ltd.
    Created     : Sun Feb 11 00:01:08 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.*     FROM PROPATH . 
USING Consultingwerk.Framework.Base.* FROM PROPATH .
USING Consultingwerk.Framework.Enum.* FROM PROPATH .
USING Consultingwerk.Util.*           FROM PROPATH .  
USING Progress.Lang.*                 FROM PROPATH .

CLASS Consultingwerk.Framework.Base.AblPrimitiveList 
    IMPLEMENTS ISupportsListChanged
    ABSTRACT: 
    
    /*------------------------------------------------------------------------------
        Purpose: Raised when the List is changed by adding or removing items or 
                 clearing the list
        Notes:      
        @param sender The sender of the event
        @param e The ListChangedEventArgs object instance with the data of the ListChanged event                                                                  
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC EVENT ListChanged SIGNATURE VOID (sender AS Progress.Lang.Object, e AS ListChangedEventArgs).
    
    /*------------------------------------------------------------------------------
        Purpose: Gets the number of key/value pairs contained in the List                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Count AS INTEGER NO-UNDO 
    GET:
        IF THIS-OBJECT:Values > "":U THEN 
            RETURN NUM-ENTRIES (THIS-OBJECT:Values, 
                                THIS-OBJECT:ValueDelimiter) .
        ELSE 
            RETURN 0 . 
        
    END GET . 

    /*------------------------------------------------------------------------------
        Purpose: Returns the Delimiter used for the Values list                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ValueDelimiter AS CHARACTER NO-UNDO INIT ",":U
    GET.
    PROTECTED SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the list of Values in the List                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Values AS LONGCHAR NO-UNDO 
    GET.
    PROTECTED SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the AblPrimitiveList class                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AblPrimitiveList ():
        
        SUPER () .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the AblPrimitiveList class                                                                     
        Notes:   Defaults to the comma (",") as teh delimiter for Keys and Values
        @param pcValues The initial list of Values                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AblPrimitiveList (pcValues AS LONGCHAR):
        
        THIS-OBJECT (pcValues, ",":U) . 
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the AblPrimitiveList class                                                                     
        Notes:                                                                        
        @param pcValues The initial list of Values                                                                        
        @param pcValueDelimiter The delimiter for the Values
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AblPrimitiveList (pcValues AS LONGCHAR,
                                         pcValueDelimiter AS CHARACTER):
        SUPER ().
            
        IF LENGTH (pcValueDelimiter) <> 1 THEN 
            UNDO, THROW NEW InvalidParameterValueException ("pcValueDelimiter":U,
                                                            pcValueDelimiter,
                                                            THIS-OBJECT:GetClass():TypeName) .
        
        ASSIGN THIS-OBJECT:Values         = pcValues
               THIS-OBJECT:ValueDelimiter = pcValueDelimiter .
        
    END CONSTRUCTOR.    
    
    /*------------------------------------------------------------------------------
        Purpose: Removes all keys and values from the List                                                                        
        Notes:   Raises the ListChanged event                                                                      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Clear ():
        
        ASSIGN THIS-OBJECT:Values = "":U .
               
        THIS-OBJECT:OnListChanged (NEW ListChangedEventArgs (ListChangedTypeEnum:ListCleared)) .
 
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Adds the specified value to the list.                                                                       
        Notes:   Internal method, used by derived class (which converts from the 
                 original value type to the CHARACTER value expected by this method)
        @param pcValue The value for the key/value pair to add to the List
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID InternalAdd (pcValue AS CHARACTER):
        
        DEFINE VARIABLE cValues AS LONGCHAR NO-UNDO.
        
        THIS-OBJECT:ValidateValue (pcValue) .
        
        IF pcValue = ? THEN     
            ASSIGN pcValue = "?":U  .
        
        IF THIS-OBJECT:Count > 0 THEN DO:
            ASSIGN cValues = THIS-OBJECT:Values + 
                             THIS-OBJECT:ValueDelimiter +
                             pcValue . 
        END.
        ELSE 
            ASSIGN cValues = pcValue .

        THIS-OBJECT:OnListChanged (NEW ListChangedEventArgs (ListChangedTypeEnum:ListItemAdded)) .

        ASSIGN THIS-OBJECT:Values = cValues . 
               
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Determines whether the List contains the specified value.                                                                        
        Notes:   Internal method, used by derived class (which converts from the 
        @param pcValue The value to locate in the List  
        @return True, when the value is contained in the List, otherwise false  
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LOGICAL InternalContainsValue (pcValue AS CHARACTER):
        
        THIS-OBJECT:ValidateValue (pcValue) .
        
        IF THIS-OBJECT:Values > "":U THEN .
        ELSE 
            RETURN FALSE .
        
        IF LOOKUP (pcValue,
                   THIS-OBJECT:Values,
                   THIS-OBJECT:ValueDelimiter) > 0 THEN 
            RETURN TRUE . 
        ELSE 
            RETURN FALSE . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the Value for the specified Index                                                                       
        Notes:   Internal method, used by derived class (which converts from the 
                 original value type to the CHARACTER value expected by this method)   
        @param piIndex The index to remove from the List   
        @return The Value for the specified Index    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED CHARACTER InternalGetValue (piIndex AS INTEGER):
        
        IF piIndex > THIS-OBJECT:Count THEN 
            UNDO, THROW NEW InvalidParameterValueException ("piIndex":U,
                                                            STRING (piIndex),
                                                            THIS-OBJECT:GetClass():TypeName) .
                
        RETURN ENTRY (piIndex,
                      THIS-OBJECT:Values,
                      THIS-OBJECT:ValueDelimiter) .                                                     
                                                            
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Inserts the specified value to the List at the specified position                                                                      
        Notes:   
        @param pcValue The value for the key/value pair to add to the List
        @param piPosition The position to add the new value to
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID InternalInsert (pcValue AS CHARACTER,
	                                      piPosition AS INTEGER):
		
		THIS-OBJECT:Values = ListHelper:InsertEntry (THIS-OBJECT:Values, 
                    		                         piPosition,
                    		                         pcValue,
                    		                         THIS-OBJECT:ValueDelimiter) .
	
        THIS-OBJECT:OnListChanged (NEW ListChangedEventArgs (ListChangedTypeEnum:ListItemAdded)) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Assigns the Value for the specified Key                                                                      
        Notes:   Internal method, used by derived class (which converts from the 
                 original value type to the CHARACTER value expected by this method)   
        @param piIndex The index to remove from the List      
        @param pcValue The value to assign for the Key in the List      
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID InternalSetValue (piIndex AS INTEGER, 
                                            pcValue AS CHARACTER):

        DEFINE VARIABLE cValues AS LONGCHAR NO-UNDO.
        
        THIS-OBJECT:ValidateValue (pcValue) .

        IF piIndex > THIS-OBJECT:Count THEN 
            UNDO, THROW NEW InvalidParameterValueException ("piIndex":U,
                                                            STRING (piIndex),
                                                            THIS-OBJECT:GetClass():TypeName) .
        
        ASSIGN cValues = THIS-OBJECT:Values 
               ENTRY (piIndex,
                      cValues,
                      THIS-OBJECT:ValueDelimiter) = pcValue 
               THIS-OBJECT:Values = cValues.                                                     

        THIS-OBJECT:OnListChanged (NEW ListChangedEventArgs (ListChangedTypeEnum:ListItemChanged)) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Raises the ListChanged event
        Notes:                              
        @param e The ListChangedEventArgs object instance with the data of the ListChanged event                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID OnListChanged (e AS ListChangedEventArgs):
        
        Consultingwerk.Assertion.EventArgsAssert:IsValid (e, "ListChanged":U) .
        
        THIS-OBJECT:ListChanged:Publish (THIS-OBJECT, e) .      

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Removes the Value on the given Index from the List
        Notes:   Internal method, used by derived class (which converts from the 
                 original value type to the CHARACTER value expected by this method)   
        @param piEntry The index to remove from the List      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Remove (piEntry AS INTEGER):
        
        DEFINE VARIABLE cValues AS LONGCHAR  NO-UNDO.

        ASSIGN cValues = Consultingwerk.Util.ListHelper:RemoveEntry (THIS-OBJECT:Values,
                                                                     piEntry,
                                                                     THIS-OBJECT:ValueDelimiter)
               THIS-OBJECT:Values = cValues .
              
        THIS-OBJECT:OnListChanged (NEW ListChangedEventArgs (ListChangedTypeEnum:ListItemRemoved)) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates a Value                                        
        Notes:                      
        @param pcValue The value to validate                                                  
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID ValidateValue (pcValue AS CHARACTER):
        
        IF pcValue = THIS-OBJECT:ValueDelimiter THEN        
            UNDO, THROW NEW InvalidParameterValueException ("pcValue":U,
                                                            pcValue,
                                                            THIS-OBJECT:GetClass():TypeName) .

    END METHOD.

END CLASS.