/* ------------------------------------------------------------------------
   file    :  prolint/rules/backslash.p
   by      :  Jurjen Dijkstra
   purpose :  if the program is supposed to run on Unix/Linux, then
              every "\" should be "~\" or "/"
    -----------------------------------------------------------------

    Copyright (C) 2002 Jurjen Dijkstra

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
{prolint/core/ttprocedure.i}

RUN Ignore_RTB_xref_generator.

RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectString":U,       /* name of callback procedure   */
                           "QSTRING":U).            /* list of statements to search */

RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectFilename":U,     /* name of callback procedure   */
                           "FILENAME":U).           /* list of statements to search */

RETURN.


PROCEDURE Ignore_RTB_xref_generator :
/* purpose: all strings and filenames inside internal procedure "RTB_xref_generator"
            should be ignored, so mark them with a pragma attribute */
   DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
   DEFINE VARIABLE i          AS INTEGER NO-UNDO.
   DEFINE VARIABLE childnode  AS INTEGER NO-UNDO.

            
   RUN ProcedureListGet IN hLintSuper (OUTPUT TABLE tt_procedure).
   FIND tt_procedure WHERE tt_procedure.proctype = "PROCEDURE":U
                       AND tt_procedure.procname = "RTB_xref_generator":U
                     NO-LOCK NO-ERROR.
                     
   IF AVAILABLE tt_procedure THEN DO:
      childnode = parserGetHandle().
      numResults = parserQueryCreate(tt_procedure.startnode, "rtb_xref":U, "FILENAME":U).
      DO i=1 TO numResults :
        IF parserQueryGetResult("rtb_xref":U, i, childnode) THEN
           parserAttrSet(childnode, pragma_number, 1).
      END.
      parserQueryClear("rtb_xref":U).
      parserReleaseHandle(childnode).
   END.                            


   /* ignore backslashes in alternative WRX location in AB-generated procedure control_load.
      You can safely ignore these, because WRX will not run on UNIX anyway */
   FIND tt_procedure WHERE tt_procedure.proctype = "PROCEDURE":U
                       AND tt_procedure.procname = "control_load":U
                     NO-LOCK NO-ERROR.
   IF AVAILABLE tt_procedure THEN DO:
      childnode = parserGetHandle().
      numResults = parserQueryCreate(tt_procedure.startnode, "control_load":U, "QSTRING":U).
      DO i=1 TO numResults :
        IF parserQueryGetResult("control_load":U, i, childnode) THEN
           parserAttrSet(childnode, pragma_number, 1).
      END.
      parserQueryClear("control_load":U).
      parserReleaseHandle(childnode).
   END.                            
     
   FOR EACH tt_procedure :
      DELETE tt_procedure.
   END.     
   
END PROCEDURE.


PROCEDURE InspectString :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode in ruledefs.i */                                                    
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.

  DEFINE VARIABLE OrigString  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE CopyString AS CHARACTER NO-UNDO.
  DEFINE VARIABLE quote      AS CHARACTER NO-UNDO.

  OrigString  = parserGetNodeText(theNode).
  quote      = SUBSTRING(OrigString,1,1).
  OrigString  = SUBSTRING(OrigString, 2, R-INDEX(OrigString, quote) - 2).
  CopyString = OrigString.

  /* see if theString contains \ ignoring ~\  */
  CopyString = REPLACE (CopyString, "~~~\":U, "xx":U).
  CopyString = REPLACE (CopyString, "~\~\":U, "yy":U).
  IF INDEX(CopyString, "~\":U) > 0 THEN
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   SUBSTITUTE("backslash in string '&1' (not Unix-compatible)":T,
                                              REPLACE(SUBSTRING(OrigString,1,20),"~n":U," ":U)),
                                   rule_id).

END PROCEDURE.                            


PROCEDURE InspectFilename :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode in ruledefs.i */                                                    
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.

  DEFINE VARIABLE theString AS CHARACTER NO-UNDO.
  DEFINE VARIABLE quote     AS CHARACTER NO-UNDO.

  theString = parserGetNodeText(theNode).

  /* see if theString contains \ ignoring ~\  */
  theString = REPLACE (theString, "~~~\":U, "xx":U).
  IF INDEX(theString, "~\":U) > 0 THEN
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   SUBSTITUTE("backslash in filename '&1' (not Unix-compatible)":T, parserGetNodeText(theNode)),
                                   rule_id).

  /* TODO: but what about UNC naming convention ??? */                                   

END PROCEDURE.                            



