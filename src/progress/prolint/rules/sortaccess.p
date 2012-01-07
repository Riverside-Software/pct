/* ------------------------------------------------------------------------
   file    :  prolint/rules/sortaccess.p
   by      :  Jurjen Dijkstra
   purpose :  Find "SORT-ACCESS" in compiler XREF file
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   ------------------------------------------------------------------------ */   
{prolint/core/ruleparams.i}  

   DEFINE STREAM xrf.

   DEFINE VARIABLE vSourceFile      AS CHARACTER NO-UNDO.
   DEFINE VARIABLE iLineNumber      AS INTEGER   NO-UNDO.
   DEFINE VARIABLE cLineNumber      AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vOperation       AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vTable           AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vDb              AS CHARACTER NO-UNDO.
   DEFINE VARIABLE StripLdbName     AS LOGICAL   NO-UNDO.

   StripLdbName = LOGICAL (DYNAMIC-FUNCTION ("ProlintProperty", "rules.RemoveLogicalDatabaseName")).
   
   INPUT STREAM xrf FROM VALUE (xreffile).
   DO WHILE TRUE :
   
     /* clear values in case the next line doesn't have this many fields */ 
     ASSIGN 
       vSourceFile      = ""
       iLineNumber      = 0
       cLineNumber      = ""
       vOperation       = ""
       vTable           = "".

     /* use the IMPORT statement to be sure to read filenames properly even if they contain spaces */ 
     IMPORT STREAM xrf
        ^
        vSourceFile
        cLineNumber
        vOperation
        vTable.  


     IF vOperation EQ "SORT-ACCESS":U THEN DO:

       ASSIGN iLineNumber = INTEGER(cLineNumber) NO-ERROR.
       vDb = "".
       IF NUM-ENTRIES(vTable, '.':U)=2 THEN DO:
          vDb    = ENTRY(1, vTable, '.':U).
          IF StripLdbName THEN
             vTable = ENTRY(2, vTable, '.':U).
       END.
                
       IF vDB NE "" THEN /* because vDb="" means that vTable is a temp-table */
          RUN PublishResult            (compilationunit,
                                        vSourcefile,
                                        iLinenumber,
                                        SUBSTITUTE("SORT-ACCESS found in xref on table &1":T, vTable),
                                        rule_id).


     END.   
   
   END.
   INPUT STREAM xrf CLOSE.       
      
RETURN.
   
                                              
