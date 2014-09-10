 
 /*------------------------------------------------------------------------
    File        : FirstTestSuite
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Bastien
    Created     : Wed Jan 22 10:38:55 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS FirstTestSuite INHERITS OEUnit.Runner.TestSuite:
   
    CONSTRUCTOR FirstTestSuite():
     AddTest(NEW FirstOEUnitTest()). 
     AddTest(NEW StandAloneTests()).
   END CONSTRUCTOR.
   
END CLASS.