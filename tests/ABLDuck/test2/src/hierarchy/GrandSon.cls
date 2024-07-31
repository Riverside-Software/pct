 
 /*------------------------------------------------------------------------
    File        : Son
    Purpose     : THE GRAND SON
    Syntax      : 
    Description : 
    Author(s)   : Han Solo
    Created     : Mon Dec 02 16:34:10 CET 2019
    Notes       : 
  ----------------------------------------------------------------------*/


USING hierarchy.Son FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS hierarchy.GrandSon INHERITS Son: 
 
        /*------------------------------------------------------------------------------
     Purpose: Say Hello from GrandSon
     Notes:
         @param pName Name to say hello from GrandSon
    ------------------------------------------------------------------------------*/

    METHOD PUBLIC VOID HelloWorldGrandSon ( INPUT pName AS CHARACTER  ):
        
        RETURN.

    END METHOD.
END CLASS.