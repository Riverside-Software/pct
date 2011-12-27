/* ------------------------------------------------------------------------
   file    :  prolint/rules/incslash.p
   by      :  Wilco Weultjes
   purpose :  check if {stuff\includefile.i} does not have backslashes
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
   DEFINE VARIABLE vIncludeFile     AS CHARACTER NO-UNDO.

   INPUT STREAM xrf FROM VALUE (xreffile).
   DO WHILE TRUE :
     
     /* clear values in case the next line doesn't have this many fields */ 
     ASSIGN 
       vSourceFile      = ""
       iLineNumber      = 0
       cLineNumber      = ""
       vOperation       = ""
       vIncludeFile     = ""
       vComment         = "".

     /* use the IMPORT statement to be sure to read filenames properly even if they contain spaces */ 
     IMPORT STREAM xrf
        ^
        vSourceFile
        cLineNumber
        vOperation
        vIncludeFile
        ^
        vComment.
      
      IF (vOperation EQ "INCLUDE":U) THEN DO:

         ASSIGN iLineNumber = INTEGER(cLineNumber) NO-ERROR.
         vIncludeFile = ENTRY(1,vIncludeFile," ":U).

         IF vIncludeFile MATCHES "*~\*":U THEN
         RUN PublishResult            (compilationunit,
                                       vSourcefile,
                                       iLinenumber,
                                       SUBSTITUTE("Compile will fail on Unix, don't use backslash in includefiles: &1":T, vIncludeFile),
                                       rule_id).
      END.
      
   END.
   INPUT STREAM xrf CLOSE.       

      
RETURN.
   
