 
    DEFINE VARIABLE iPointer AS INTEGER NO-UNDO.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the current item in the List
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Current AS {2} NO-UNDO 
    GET:
        IF iPointer > 0 AND iPointer <= THIS-OBJECT:List:Count THEN 
            RETURN CAST (THIS-OBJECT:List, {1}List):GetValue
                    (iPointer) .
        
    END GET . 

    /*------------------------------------------------------------------------------
        Purpose: Returns the List enumerated by this ListEnumerator instance 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY List AS AblPrimitiveList NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns if the List has changed and the Enumerator needs to be Reset() 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ListChanged AS LOGICAL NO-UNDO INIT FALSE 
    GET.
    PROTECTED SET.     
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ListEnumerator class                                                                       
        Notes:                                                  
        @param poList The AblPrimitiveList to Enumerate                   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC {1}ListEnumerator (poList AS AblPrimitiveList):
        SUPER ().
        
        Consultingwerk.Assertion.ObjectAssert:IsValid (poList, "AblPrimitiveList":U) .
        
        ASSIGN THIS-OBJECT:List = poList .

        THIS-OBJECT:Reset () .
               
        IF TYPE-OF (poList, ISupportsListChanged) THEN 
            CAST (poList, ISupportsListChanged):ListChanged:Subscribe (ListChangedHandler) .                
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Event handler for the ListChanged event of the IEnumerable instance                                                                      
        Notes:   Requires the ISupportsListChanged interface to by implemented by the List                                  
        @param sender The sender of the event
        @param e The ListChangedEventArgs object instance with the data of the ListChanged event                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID ListChangedHandler (sender AS Progress.Lang.Object, 
                                              e AS ListChangedEventArgs):
        
        THIS-OBJECT:ListChanged = TRUE . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Moves the enumerator to the next item                                                                        
        Notes:                      
        @return True when the next item is available, false when not.                                                 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL MoveNext ():
        
        IF THIS-OBJECT:ListChanged THEN 
            UNDO, THROW NEW Consultingwerk.Exceptions.NotSupportedException ("MoveNext":U,
                                                                             THIS-OBJECT:GetClass():TypeName) . 

        IF THIS-OBJECT:List:Values = "":U THEN 
            RETURN FALSE .  

        ASSIGN iPointer = iPointer + 1 . 

        IF iPointer <= THIS-OBJECT:List:Count THEN 
            RETURN TRUE . 
        ELSE 
            RETURN FALSE . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Resets the Enumerator (starts enumerating from the first item on)                                                                    
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Reset ():
        
        ASSIGN iPointer = 0 . 

    END METHOD.
