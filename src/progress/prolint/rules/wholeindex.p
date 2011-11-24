/* ------------------------------------------------------------------------
   file    :  prolint/rules/wholeindex.p
   by      :  Jurjen Dijkstra
   purpose :  Find "WHOLE-INDEX" in compiler XREF file
   ------------------------------------------------------------------------
   Change  : 23 july 2001
   by      : Patrick Tingen
   desc    : - Change the way a line with 'WHOLE-INDEX' is detected. 
             - Don't strip database name from filename in XREF output.
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra, Patrick Tingen

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
   DEFINE VARIABLE vComment         AS CHARACTER NO-UNDO.
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
       vTable           = ""
       vComment         = "".

     /* use the IMPORT statement to be sure to read filenames properly even if they contain spaces */ 
     IMPORT STREAM xrf
        ^
        vSourceFile
        cLineNumber
        vOperation
        vTable
        ^
        vComment.
      
      IF (vOperation EQ "SEARCH":U) AND (vComment EQ "WHOLE-INDEX":U) THEN DO:

         ASSIGN iLineNumber = INTEGER(cLineNumber) NO-ERROR.
         IF StripLdbName THEN
            IF NUM-ENTRIES(vTable, '.':U)=2 THEN
               vTable = ENTRY(2, vTable, '.':U).

         RUN PublishResult            (compilationunit,
                                       vSourcefile,
                                       iLinenumber,
                                       SUBSTITUTE("WHOLE-INDEX found in xref on table &1":T, vTable),
                                       rule_id).
      END.
      
   END.
   INPUT STREAM xrf CLOSE.       

      
RETURN.
   
