/* ------------------------------------------------------------------------
   file    :  prolint/rules/inclowercase.p
   by      :  Wilco Weultjes
   purpose :  check if {IncludeFile.i} is all lowercase
   -----------------------------------------------------------------

    Copyright (C) 2007 Wilco Weultjes

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
   DEFINE VARIABLE vComment         AS CHARACTER NO-UNDO.
   DEFINE VARIABLE StripLdbName     AS LOGICAL   NO-UNDO.
   DEFINE VARIABLE vIncludeFileCS   AS CHARACTER NO-UNDO CASE-SENSITIVE.

   INPUT STREAM xrf FROM VALUE (xreffile).
   DO WHILE TRUE :
     
     /* clear values in case the next line doesn't have this many fields */ 
     ASSIGN 
       vSourceFile      = ""
       iLineNumber      = 0
       cLineNumber      = ""
       vOperation       = ""
       vIncludeFileCS   = ""
       vComment         = "".

     /* use the IMPORT statement to be sure to read filenames properly even if they contain spaces */ 
     IMPORT STREAM xrf
        ^
        vSourceFile
        cLineNumber
        vOperation
        vIncludeFileCS
        ^
        vComment.
      
      IF (vOperation EQ "INCLUDE":U) THEN DO:

         ASSIGN iLineNumber = INTEGER(cLineNumber) NO-ERROR.
         vIncludeFileCS = ENTRY(1,vIncludeFileCS," ":U).

         IF NOT (vIncludeFileCS = LC(vIncludeFileCS)) THEN
         RUN PublishResult            (compilationunit,
                                       vSourcefile,
                                       iLinenumber,
                                       SUBSTITUTE("Compile will fail on Unix, use only lower-case includefiles: &1":T, vIncludeFileCS),
                                       rule_id).
      END.
      
   END.
   INPUT STREAM xrf CLOSE.       

      
RETURN.
   
