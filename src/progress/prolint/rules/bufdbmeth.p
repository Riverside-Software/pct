/* -----------------------------------------------------------------------------
   file    :  prolint/rules/bufdbmeth.p
   purpose :  require DEFINE BUFFER for every database buffer that appears
              in a class method
   -----------------------------------------------------------------------------

    Copyright (C) 2007 Jurjen Dijkstra

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
   --------------------------------------------------------------------------------- */
  
{prolint/core/ruleparams.i}  

{prolint/core/ttprocedure.i}

DEFINE TEMP-TABLE tt_definedbuffers NO-UNDO
   FIELD buffername AS CHARACTER
   FIELD tablename AS CHARACTER.

DEFINE TEMP-TABLE tt_reportedtables NO-UNDO
   FIELD tablename AS CHARACTER.

DEFINE TEMP-TABLE tt_temptables NO-UNDO
   FIELD ttname AS CHARACTER.

   run ProcedureListGet in hLintSuper (output table tt_procedure).

   RUN searchNode (hTopnode,
                   "FindTemptableDefinitions":U,
                   "TEMPTABLE":U).

   FOR EACH tt_procedure WHERE LOOKUP(tt_procedure.proctype,"METHOD,CONSTRUCTOR,DESTRUCTOR,Property_setter,Property_getter":U)>0 AND tt_procedure.prototype=false :

       EMPTY TEMP-TABLE tt_definedbuffers.
       EMPTY TEMP-TABLE tt_reportedtables.

       RUN searchNode            (tt_procedure.startnode,
                                  "FindBufferDefinitions":U,
                                  "BUFFER":U).
   
       RUN searchNode            (tt_procedure.startnode,
                                  "InspectNodeA":U,
                                  "RECORD_NAME":U).

       RUN searchNode            (tt_procedure.startnode,
                                  "InspectNodeB":U,
                                  "Field_ref":U).
   END.

RETURN.


PROCEDURE FindTemptableDefinitions :
   /* find DEFINE BUFFER statements */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE nextsibling AS INTEGER NO-UNDO.
   DEFINE VARIABLE statehead AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.

   ASSIGN
     statehead   = parserGetHandle()
     nextsibling = parserGetHandle()
     nodetype    = parserNodeNextSibling(theNode,nextsibling).

   IF "DEFINE":U = parserNodeStatehead(theNode,statehead) THEN DO:
     DO WHILE nodetype<>"" :
        CASE nodetype :
           WHEN "ID":U THEN DO:
                               CREATE tt_temptables.
                               ASSIGN tt_temptables.ttname = parserGetNodeText(nextsibling).
                            END.
           WHEN "BEFORETABLE":U THEN
                                IF "ID":U = parserNodeFirstChild(nextsibling,nextsibling) THEN DO:
                                   CREATE tt_temptables.
                                   ASSIGN tt_temptables.ttname = parserGetNodeText(nextsibling).
                                END.
        END CASE.
        nodetype = parserNodeNextSibling(nextsibling,nextsibling).
     END.
   END.

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(nextsibling).
   parserReleaseHandle(statehead).
    
END PROCEDURE.                            


PROCEDURE FindBufferDefinitions :
   /* find DEFINE BUFFER statements */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE nextsibling AS INTEGER NO-UNDO.
   DEFINE VARIABLE statehead AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
   DEFINE VARIABLE buffername AS CHARACTER NO-UNDO.
   DEFINE VARIABLE tablename AS CHARACTER NO-UNDO.

   ASSIGN
     statehead   = parserGetHandle()
     nextsibling = parserGetHandle()
     nodetype    = parserNodeNextSibling(theNode,nextsibling).

   IF "DEFINE":U = parserNodeStatehead(theNode,statehead) THEN DO:
     DO WHILE nodetype<>"" :
        CASE nodetype :
           WHEN "ID":U THEN buffername = parserGetNodeText(nextsibling).
           WHEN "RECORD_NAME":U THEN DO:
                                         parserAttrSet(nextsibling, pragma_number ,1).
                                         tablename = parserGetNodeText(nextsibling).
                                         CREATE tt_definedbuffers.
                                         ASSIGN tt_definedbuffers.buffername = buffername
                                                tt_definedbuffers.tablename = tablename.
                                     END.
        END CASE.
        nodetype = parserNodeNextSibling(nextsibling,nextsibling).
     END.
   END.

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(nextsibling).
   parserReleaseHandle(statehead).
    
END PROCEDURE.                            


PROCEDURE InspectNodeA :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE nodetext AS CHARACTER NO-UNDO.

   nodetext = parserGetNodeText(theNode).

   IF NOT CAN-FIND(FIRST tt_temptables WHERE tt_temptables.ttname = nodetext) THEN
   IF NOT CAN-FIND(FIRST tt_definedbuffers WHERE tt_definedbuffers.buffername = nodetext) THEN
      IF NOT CAN-FIND(FIRST tt_reportedtables WHERE tt_reportedtables.tablename = nodetext) THEN DO:
         IF parserAttrGet(theNode,"storetype":U) = "st-dbtable":U THEN /* skip temp-tables */
             RUN PublishResult            (compilationunit,
                                           parserGetNodeFilename(theNode),
                                           parserGetNodeLine(theNode),
                                           SUBSTITUTE("no buffer defined for table &1":T, nodetext),
                                           rule_id).

         /* prevent double warnings. Store temp-tables too, to prevent warnings from InspectNodeB */
         CREATE tt_reportedtables.
         ASSIGN tt_reportedtables.tablename = nodetext.
      END.

END PROCEDURE.                            

PROCEDURE InspectNodeB :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE child    AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
   DEFINE VARIABLE nodetext AS CHARACTER NO-UNDO.
   DEFINE VARIABLE tablename AS CHARACTER NO-UNDO.
   DEFINE VARIABLE linenumber AS INTEGER NO-UNDO.

   ASSIGN
     child       = parserGetHandle()
     nodetype    = parserNodeFirstChild(theNode,child).

   DO WHILE NOT (nodetype="") :
      IF nodetype="ID":U THEN DO:
         nodetext = parserGetNodeText(child).
         linenumber = parserGetNodeLine(child).
         IF NUM-ENTRIES(nodetext,".":U) = 2 THEN
            tablename = ENTRY(1, nodetext, ".").
         ELSE
            IF NUM-ENTRIES(nodetext,".":U) = 3 THEN
               tablename = ENTRY(1, nodetext, ".") + ".":U + ENTRY(2, nodetext, ".").

      END.
      nodetype = parserNodeNextSibling(child, child).
   END.

   IF tablename>"" THEN DO:
     IF NOT CAN-FIND(FIRST tt_temptables WHERE tt_temptables.ttname = tablename) THEN
       IF NOT CAN-FIND(FIRST tt_definedbuffers WHERE tt_definedbuffers.buffername = tablename) THEN
          IF NOT CAN-FIND(FIRST tt_reportedtables WHERE tt_reportedtables.tablename = tablename) THEN DO:
             RUN PublishResult            (compilationunit,
                                           parserGetNodeFilename(theNode),
                                           linenumber,
                                           SUBSTITUTE("no buffer defined for table &1":T, tablename),
                                           rule_id).
             CREATE tt_reportedtables.
             ASSIGN tt_reportedtables.tablename = tablename.
          END.
       END.

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(child).
    
END PROCEDURE.                            



