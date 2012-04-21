/* -----------------------------------------------------------------------------
   file       :  prolint/rules/findstate.p
   purpose    :  To find Find statements that don't have a qualifier
   ----------------------------------------------------------------------------
    Copyright (C) 2001,2002,2003,2004 Breck Fairley,
                                      Jamie Ballarin,
                                      Jurjen Dijkstra,
                                      Sven Persijn

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

   Feb 22, 2006 : Carl Verbiest
     look for buffer definition in Program_root if not found in procedure
   -------------------------------------------------------------------------- */


{prolint/core/ruleparams.i}

run searchNode            (
    input hTopnode,              /* "Program_root" node                 */
    input "priv-InspectNode":U,  /* name of callback procedure          */
    input "FIND":U).             /* list of statements to search, ?=all */

return.


FUNCTION IfFindByRowid RETURNS LOGICAL ( INPUT theNode AS INTEGER, INPUT id AS CHARACTER ) :
    /* purpose : "FIND buffer WHERE ROWID(buffer)=rw" requires no FIRST|LAST|PREV|NEXT */

    DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodeRowid  AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodeParent AS INTEGER NO-UNDO.
    DEFINE VARIABLE i          AS INTEGER NO-UNDO.
    DEFINE VARIABLE foundMatch AS LOGICAL NO-UNDO INITIAL NO.

    numResults = parserQueryCreate(TheNode, "qryROWID":U, id).
    IF numResults > 0 THEN DO:
       ASSIGN
           nodeRowid  = parserGetHandle()
           nodeParent = parserGetHandle()
           i          = 1.
       DO WHILE i<=numResults AND NOT foundMatch :
          parserQueryGetResult("qryROWID":U, i, nodeRowid).
          IF "EQ":U = parserNodeParent(nodeRowid, nodeParent) THEN
             foundMatch = TRUE.
          i = i + 1.
       END.
       parserReleaseHandle(nodeRowid).
       parserReleaseHandle(nodeParent).
    END.
    parserQueryClear("qryROWID":U).

    RETURN foundMatch.

END FUNCTION.

procedure GetTableFields:
    DEFINE INPUT  PARAMETER cTable AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER list   AS CHARACTER NO-UNDO.

&IF INTEGER(ENTRY(1,PROVERSION,'.'))>=9 &THEN
    DEFINE VARIABLE i      AS INTEGER NO-UNDO.
    DEFINE VARIABLE hb     AS HANDLE  NO-UNDO.
    DEFINE VARIABLE hField AS HANDLE  NO-UNDO.

    CREATE BUFFER hb FOR TABLE cTable NO-ERROR.
    IF VALID-HANDLE(hb) THEN DO:
       DO i=1 TO hb:NUM-FIELDS :
          hField = hb:BUFFER-FIELD(i).
          list = list + ",":U + hField:NAME.
       END.
       list = SUBSTRING( list, 2).
       DELETE OBJECT hb.
    END.
&ENDIF

END PROCEDURE.

PROCEDURE GetIndexFields :
    DEFINE INPUT  PARAMETER cTable AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER list   AS CHARACTER NO-UNDO.

&IF INTEGER(ENTRY(1,PROVERSION,'.'))>=9 &THEN

    DEFINE VARIABLE htt     AS HANDLE    NO-UNDO.
    DEFINE VARIABLE bhtt    AS HANDLE    NO-UNDO.
    DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE j       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cInfo   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE sublist AS CHARACTER NO-UNDO.

    CREATE TEMP-TABLE htt.
    htt:CREATE-LIKE(cTable) NO-ERROR.
    htt:TEMP-TABLE-PREPARE("TempTable":U) NO-ERROR.
    bhtt = htt:DEFAULT-BUFFER-HANDLE NO-ERROR.
    IF ERROR-STATUS:ERROR OR bhtt=? THEN DO:
        DELETE OBJECT htt.
        RETURN.
    END.

    loop_index:
    DO WHILE TRUE:
        i = i + 1.
        cInfo = bhtt:INDEX-INFORMATION(i).
        IF cInfo=? THEN LEAVE loop_index.
        IF ENTRY(2,cInfo)="1":U THEN DO:
            sublist = "".
            j = 5.
            DO WHILE j < NUM-ENTRIES(cInfo) :
                sublist = sublist + "," + ENTRY(j,cInfo).
                j = j + 2.
            END.
            list = list + "|":U + TRIM(sublist,",").
        END.
    END.

    DELETE OBJECT htt.
    list = TRIM(list,"|").

&ENDIF

END PROCEDURE.


PROCEDURE FindBufferDefinition :
   /* purpose: if recordname was defined as a buffer, try to
               determine the real database table name */
   DEFINE INPUT        PARAMETER theNode    AS INTEGER NO-UNDO.
   DEFINE INPUT        PARAMETER buffername AS CHARACTER NO-UNDO.
   DEFINE OUTPUT       PARAMETER recordname AS CHARACTER NO-UNDO.

   DEFINE VARIABLE parentnode AS INTEGER   NO-UNDO.
   DEFINE VARIABLE blocknode  AS INTEGER   NO-UNDO.
   DEFINE VARIABLE blocktype  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE nodetype   AS CHARACTER NO-UNDO.
   DEFINE VARIABLE numresults AS INTEGER   NO-UNDO.
   DEFINE VARIABLE i          AS INTEGER   NO-UNDO.
   DEFINE VARIABLE childnode  AS INTEGER   NO-UNDO.
   DEFINE VARIABLE found      AS LOGICAL   NO-UNDO.

   DEFINE VARIABLE parentblocktypes AS CHARACTER NO-UNDO.

   ASSIGN
      recordname = buffername
      parentnode = parserGetHandle()
      blocknode  = parserGetHandle()
      childnode  = parserGetHandle()
      parentblocktypes = "PROCEDURE,FUNCTION,Program_root".

ExamineBlock:
DO WHILE not found and blocktype <> "Program_root":U:

      blocktype  = parserNodeParent(theNode, blocknode).

   DO WHILE LOOKUP (blocktype, parentblocktypes) = 0:
       blocktype = parserNodeParent(blocknode, blocknode).
   END.

   numresults = parserQueryCreate(blocknode, "findstatebuffer":U, "BUFFER":U).
   DO i=1 TO numresults :
      found = FALSE.
      parserQueryGetResult("findstatebuffer":U, i, childnode).
      IF parserNodeParent (childnode, parentnode) = "DEFINE":U THEN DO:
         nodetype = parserNodeNextSibling(childnode, childnode).
         DO WHILE nodetype<>'' :
            CASE nodetype :
               WHEN "ID":U THEN
                     IF parserGetNodeText(childnode)=buffername THEN
                        found = TRUE.
               WHEN "RECORD_NAME":U THEN
                     IF found THEN
                        ASSIGN
                           recordname = parserGetNodeText(childnode)
                           buffername = recordname.
            END CASE.
            nodetype = parserNodeNextSibling(childnode, childnode).
         END.
      END.
   END.
   parserQueryClear ("findstatebuffer":U).
   if blocktype = "Program_root":U then leave ExamineBlock.
   parentblocktypes = "Program_root".
END.

   parserReleaseHandle(blocknode).
   parserReleaseHandle(childnode).
   parserReleaseHandle(parentnode).

END PROCEDURE.


FUNCTION UniqueWhereClause RETURNS LOGICAL ( INPUT theNode AS INTEGER ) :
  /* purpose: identify the fields in the WHERE-clause,
              compare them to fields in unique indexes to determine
              if the WHERE-clause performs a unique find.
              When in doubt, return FALSE                         */

&IF INTEGER(ENTRY(1,PROVERSION,'.'))<9 &THEN
   /* until we can get index information in DCL8... */
   RETURN FALSE.
&ELSE
   DEFINE VARIABLE childnode  AS INTEGER   NO-UNDO.
   DEFINE VARIABLE idnode     AS INTEGER   NO-UNDO.
   DEFINE VARIABLE wherenode  AS INTEGER   NO-UNDO.
   DEFINE VARIABLE ofnode     AS INTEGER   NO-UNDO.
   DEFINE VARIABLE recordname AS CHARACTER NO-UNDO.
   DEFINE VARIABLE ofname     AS CHARACTER NO-UNDO.
   DEFINE VARIABLE realrecordname AS CHARACTER NO-UNDO.
   DEFINE VARIABLE fieldname  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE indexlist  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE indexlistof AS CHARACTER NO-UNDO.
   DEFINE VARIABLE fieldlist  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE whereclause AS CHARACTER NO-UNDO.
   DEFINE VARIABLE ofclause   AS CHARACTER NO-UNDO.
   DEFINE VARIABLE numresults AS INTEGER   NO-UNDO.
   DEFINE VARIABLE i          AS INTEGER   NO-UNDO.
   DEFINE VARIABLE j          AS INTEGER   NO-UNDO.
   DEFINE VARIABLE equality   AS LOGICAL   NO-UNDO INITIAL TRUE.
   DEFINE VARIABLE indexused  AS LOGICAL   NO-UNDO.

   childnode = parserGetHandle().

   /* try to find the name of the buffer.
      this is the first child of the FIND node */

   IF parserNodeFirstChild(TheNode,childnode)="RECORD_NAME":U THEN
      recordname = parserGetNodeText(childnode).
   RUN GetIndexFields(recordname, OUTPUT indexlist).
   IF indexlist = "" THEN DO:
      /* try again. it may be a named buffer */
      RUN FindBufferDefinition ( INPUT theNode, INPUT recordname, OUTPUT realrecordname).
      RUN GetIndexFields(realrecordname, OUTPUT indexlist).
   END.
   IF indexlist = "" THEN DO:
      parserReleaseHandle(childnode).
      RETURN FALSE.
   END.

   /* find all fields in the WHERE clause:
      Just query for Field_ref.
      validate : Parent of Field_ref must be EQ.
      validate : WHERE must not contain OR or NOT  */

   /* find the one and only WHERE node: */
   wherenode = parserGetHandle().
   whereclause = parserNodeFirstChild(childnode,wherenode).
   DO WHILE whereclause <> "":U:

    /* check "FIND customer OF order". Accept this if it uses a unique index. */
    IF whereclause = "OF":U THEN DO:
      ofnode = parserGetHandle().
      ofclause = parserNodeFirstChild(wherenode,ofnode).
      IF ofclause = "RECORD_NAME":U THEN DO:
        ofname = parserGetNodeText(ofnode).
        RUN GetTableFields(ofname, OUTPUT indexlistof).
        DO i=1 TO NUM-ENTRIES(indexlist,"|":U) :
            indexused = TRUE.
            DO j=1 TO NUM-ENTRIES(ENTRY(i,indexlist,"|":U)) :
              fieldname = ENTRY(j,ENTRY(i,indexlist,"|":U)).
              IF LOOKUP(fieldname, indexlistof)=0 THEN
                  indexused = FALSE.
            END.
            IF indexused THEN
              RETURN TRUE.
        END.
      END.
    END.

    whereclause = parserNodeNextSibling(wherenode,wherenode).
   END.

   IF 1 = parserQueryCreate(theNode, "findstatewhere":U, "WHERE":U) THEN
      parserQueryGetResult("findstatewhere":U, 1, wherenode).
   ELSE DO:
      parserReleaseHandle(childnode).
      parserReleaseHandle(wherenode).
      parserQueryClear ("findstatewhere":U).
      RETURN FALSE.
   END.
   parserQueryClear ("findstatewhere":U).

   /* the WHERE clause must not contain OR */
   numresults = parserQueryCreate(wherenode, "findstategarbage":U, "OR":U).
   parserQueryClear ("findstategarbage":U).
   IF numresults>0 THEN DO:
      parserReleaseHandle(childnode).
      parserReleaseHandle(wherenode).
      RETURN FALSE.
   END.

   /* the WHERE clause must not contain NOT, but there are exceptions:
          where a.logicalfield = (NOT logicalvariable)
      so the case is:  NOT is fine when it is a (grand)child of EQ */

   DEFINE VARIABLE validNot AS LOGICAL NO-UNDO.
   numresults = parserQueryCreate(wherenode, "findstategarbage":U, "NOT":U).
   /* for each "NOT", check if it is a (grand) child of "EQ" */
   DO i=1 TO numresults :
      parserQueryGetResult("findstategarbage":U, i, childnode).
      /* move up the tree until you find EQ (good) or WHERE (bad) */
      validNot = FALSE.
      DO WHILE parserGetNodeType(childnode) <> "WHERE":U :
         IF parserNodeParent(childnode,childnode)="EQ":U THEN
            validNot = TRUE.
      END.
   END.
   parserQueryClear ("findstategarbage":U).
   IF numresults>0 AND validNot=FALSE THEN DO:
      parserReleaseHandle(childnode).
      parserReleaseHandle(wherenode).
      RETURN FALSE.
   END.

   /* now find all Field_ref nodes in the WHERE clause */
   idnode = parserGetHandle().
   numresults = parserQueryCreate(wherenode, "findstatefields":U, "Field_ref":U).
   DO i=1 TO numresults :
      parserQueryGetResult("findstatefields":U, i, childnode).
      IF parserNodeFirstChild(childnode,idnode)="ID":U THEN DO:
         fieldname = parserGetNodeText(idnode).
         IF fieldname MATCHES recordname + ".*":U THEN DO:
            /* check if there is an equality match */
            IF parserNodeParent(childnode,idnode)<>"EQ":U THEN
               equality = FALSE.
            ELSE DO:
               fieldname = SUBSTRING(fieldname, LENGTH(recordname) + 2).
               fieldlist = fieldlist + ",":U + fieldname.
            END.
         END.
      END.
   END.
   parserQueryClear ("findstatefields":U).
   parserReleaseHandle(childnode).
   parserReleaseHandle(wherenode).
   parserReleaseHandle(idnode).

   IF NOT equality THEN
      RETURN FALSE.

   /* now see if we used every field in any unique index */
   fieldlist = TRIM(fieldlist, ",":U).
   DO i=1 TO NUM-ENTRIES(indexlist,"|":U) :
      indexused = TRUE.
      DO j=1 TO NUM-ENTRIES(ENTRY(i,indexlist,"|":U)) :
         fieldname = ENTRY(j,ENTRY(i,indexlist,"|":U)).
         IF LOOKUP(fieldname, fieldlist)=0 THEN
            indexused = FALSE.
      END.
      IF indexused THEN
         RETURN TRUE.
   END.

   RETURN FALSE.

&ENDIF

END FUNCTION.


procedure priv-InspectNode :
/*    Purpose:  To Inspect Find statements to check for findwhich qualifier */

def input  param ipiTheNode%         as inte                 no-undo.
def output param oplAbortSearch%     as logi initial no      no-undo .
def output param oplSearchChildren%  as logi                 no-undo.

def var iChild%         as inte                         no-undo.
def var lFindWhere%     as logi initial false           no-undo.
def var sChildType%     as char                         no-undo.
def var sNodeType%      as char                         no-undo.
def var sRecordName%    as char                         no-undo.
def var iSibling%       as inte                         no-undo.
def var sSiblingType%   as char                         no-undo.
def var iSiblingChild%  as inte                         no-undo.
def var sSibChildType%  as char                         no-undo.

    IF IfFindByRowid(ipiTheNode%, "ROWID":U) THEN
       RETURN.
    IF IfFindByRowid(ipiTheNode%, "RECID":U) THEN
       RETURN.

    /* Assign handles and pointers to specific nodes in the Pares Tree */
    assign
        iChild%        = parserGetHandle()
        iSibling%      = parserGetHandle()
        iSiblingChild% = parserGetHandle()
        sNodeType%     = parserGetNodeType(ipiTheNode%)
        sChildType%    = parserNodeFirstChild(ipiTheNode%,iChild%)
        sSiblingType%  = parserNodeNextSibling(ipiTheNode%,iSibling%)
        sSibChildType% = parserNodeFirstChild(iSibling%,iSiblingChild%).
    if sChildType% = "" then
    do:
        parserReleaseHandle(iChild%).
        parserReleaseHandle(iSibling%).
        parserReleaseHandle(iSiblingChild%).
        return.
    end.

    /* we only want to look at real database tables, not temptables.
       temptables are inspected in rule "findstate-tt"                */
    IF sChildType% = "RECORD_NAME":U THEN
       IF parserAttrGet(iChild%,"storetype":U) <> "st-dbtable":U THEN
       DO:
          parserReleaseHandle(iChild%).
          parserReleaseHandle(iSibling%).
          parserReleaseHandle(iSiblingChild%).
          return.
       END.

    /* Check the Find statement for the findWhich qualifier that should follow   */
    /* or if a find statement has no findwhich then find the ambiguous statement */
    /* that follows directly after the Find statement.                           */
    if sNodeType% = "FIND":U then
    do:
        case sChildType%:
            when "FIRST":U then
                lFindWhere% = true.
            when "LAST":U then
                lFindWhere% = true.
            when "NEXT":U then
                lFindWhere% = true.
            when "PREV":U then
                lFindWhere% = true.
            when "CURRENT":U then
                lFindWhere% = true.
            otherwise
            do:
                if sSiblingType% = "IF":U then
                    if sSibChildType% <> "AMBIGUOUS":U then
                        assign
                            lFindWhere%  = false
                            sRecordName% = parserGetNodeText(iChild%).
                    else
                        lFindWhere% = true.
                else
                    assign
                        lFindWhere%  = false
                        sRecordName% = parserGetNodeText(iChild%).
            end.
        end case.
    end.

    if not lFindWhere% then
       IF NOT UniqueWhereClause (ipiTheNode%) THEN
          run priv-WriteResult (
              input ipiTheNode%,
              input sNodeType%,
              input sRecordName% ).

    parserReleaseHandle(iChild%).
    parserReleaseHandle(iSibling%).
    parserReleaseHandle(iSiblingChild%).

end procedure.


procedure priv-WriteResult :
/* purpose : send warning to the outputhandlers(s) */

def input param ipiTheNode%         as inte         no-undo.
def input param ipsNodeType%        as char         no-undo.
def input param ipsRecordName%      as char         no-undo.


    run PublishResult            (
        input compilationunit,
        input parserGetNodeFilename(ipiTheNode%),
        input parserGetNodeLine(ipiTheNode%),
        input substitute("&1 &2 statement defined without qualifer [ FIRST | LAST | NEXT | PREV | CURRENT ]":T, ipsNodeType%, ipsRecordName%),
        input rule_id ).

end procedure.


