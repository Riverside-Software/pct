 
 /*------------------------------------------------------------------------
    File        : ThrowHardThings
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bastien
    Created     : Tue Jan 21 16:13:47 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/
CLASS ThrowHardThings: 
    
    DEFINE PRIVATE VARIABLE cvarChar    AS CHARACTER  NO-UNDO INITIAL "Hello world !" .
    DEFINE PRIVATE VARIABLE dvarDate    AS DATE  NO-UNDO INITIAL "12/01/2014".
    DEFINE PRIVATE VARIABLE ivarInt     AS INTEGER  NO-UNDO INITIAL 10.
    
    METHOD PUBLIC CHARACTER getChar():
        RETURN     cvarChar.
    END METHOD.
    
    METHOD PUBLIC DATE getDate():
        RETURN     dvarDate.
    END METHOD.
    
    METHOD PUBLIC INTEGER getInt():
        RETURN     ivarInt.
    END METHOD.

END CLASS.