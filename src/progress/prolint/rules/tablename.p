/* -----------------------------------------------------------------------------
   file    :  prolint/rules/tablename.p
   by      :  Jurjen Dijkstra, based on ideas by Marlene La Varta
              Procedure is almost a copy of varusage.p
   purpose :  search for fieldnames that are not qualified with buffername
              e.g. search for fieldname not buffername.fieldname
   -----------------------------------------------------------------------------

    Copyright (C) 2003 Jurjen Dijkstra

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

/* tt_object contains all variables and parameters, defined in CompilationUnit */
DEFINE TEMP-TABLE tt_object NO-UNDO
  FIELDS ProcRowid    AS ROWID /* function|procedure where object was defined       */
  FIELDS objName      AS CHARACTER  /* identifier                                        */
  INDEX idx_objname  AS PRIMARY objname ProcRowid.

DEFINE VARIABLE child          AS INTEGER NO-UNDO.
DEFINE VARIABLE superclassname AS CHARACTER NO-UNDO.

RUN GetSuperClass in hLintSuper(hTopNode, OUTPUT superclassname, OUTPUT child).

MAIN-BLK:
DO ON ERROR UNDO MAIN-BLK, LEAVE MAIN-BLK:

    ASSIGN
      child           = parserGetHandle().

    /* get the list of all functions and procedures */
    RUN ProcedureListGet IN hLintSuper (OUTPUT TABLE tt_procedure).

    /* STEP 1:  exclude a couple of special cases to reduce false positives */
    RUN searchNode            (
      INPUT hTopNode,
      INPUT "ExcludeFields":U,
      INPUT "FIELDS":U ).

    RUN searchNode            (
      INPUT hTopNode,
      INPUT "ExcludeExcept":U,
      INPUT "EXCEPT":U ).

    RUN searchNode            (
      INPUT hTopNode,
      INPUT "ExcludeUsing":U,
      INPUT "USING":U ).

    RUN searchNode            (
      INPUT hTopNode,
      INPUT "ExcludeRelationFields":U,
      INPUT "RELATIONFIELDS":U ).


    /* AIM: To build a complete list of tt_object (all variables and    */
    /*      parameters).                                                */

    /* STEP 2: Build a list of all variables/parameters within this     */
    /*         compilation unit and its internal procedures.            */
    /*         First, get local vars and params in internal             */
    /*         procs/functions. Be sure to mark them as "already looked */
    /*         at" so they are skipped when querying the Program scope. */

    FOR EACH tt_procedure
    WHERE NOT tt_procedure.prototype :

        /* create a list of variables and parameters, store them in tt_object */
        RUN searchNode            (
          INPUT tt_procedure.startnode,
          INPUT "BuildList":U,
          INPUT "DEFINE":U ).

        RUN searchNode            (
          INPUT tt_procedure.startnode,
          INPUT "BuildListForm":U,
          INPUT "FORMAT":U ).
          
        RUN searchNode            (
          INPUT tt_procedure.startnode,
          INPUT "MessageUpdate":U,
          INPUT "UPDATE":U ).

        /* if tt_procedure is a function, we must do some extra work to get parameters */
        IF tt_procedure.proctype = "FUNCTION":U OR 
           tt_procedure.proctype = "METHOD":U  OR 
           tt_procedure.proctype = "CONSTRUCTOR":U OR
           tt_procedure.proctype = "Property_setter":U THEN
          RUN AddFunctionParameters(INPUT tt_procedure.startnode).

    END.

    /*         Second, add the objects at the program scope.            */
    /*         Because we have set pragma_number attributes we are      */
    /*         able to skip variables and parameters at local scopes.   */

    RELEASE tt_procedure NO-ERROR. /* we must have not available */
    RUN searchNode            (
      INPUT hTopNode,
      INPUT "BuildList":U,
      INPUT "DEFINE":U ).

    RUN searchNode            (
      INPUT hTopNode,
      INPUT "BuildListForm":U,
      INPUT "FORMAT":U ).

    RUN searchNode            (
      INPUT hTopNode,
      INPUT "MessageUpdate":U,
      INPUT "UPDATE":U ).

    /* Inspect if vars and params in each tt_procedure are assigned.    */
    /* This means that the object is "assigned" a value but does not    */
    /* necessarily mean that the object's value is "accessed".          */
    /* Once again, perform checks within the internal procedures first. */

    FOR EACH tt_procedure
    WHERE NOT tt_procedure.prototype :

        RUN SearchNode            (
          INPUT tt_procedure.startnode,
          INPUT "InspectFieldref":U,
          INPUT "Field_ref":U ).

    END.

    /* Inspect the top "Program_root" scope for remaining objects.      */
    /* This is very similar to the loop for a single tt_procedure, but  */
    /* we must be sure to skip all vars/params which already past the   */
    /* first loop. The pragma_number attribute assists us here.         */

    RELEASE tt_procedure NO-ERROR. /* we must have not available */
    RUN SearchNode            (
      INPUT hTopNode,
      INPUT "InspectFieldref":U,
      INPUT "Field_ref":U ).


    /* We are done. Release all handles as we don't need kids anymore.  */
    parserReleaseHandle(child).

    RETURN.

END. /* MAIN-BLK */

PROCEDURE ExcludeFields :
/* purpose : put a pragma on fieldrefs in the FIELDS option of a record-phrase */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS logi NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS logi NO-UNDO INITIAL NO.

    DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
    DEFINE VARIABLE i1         AS INTEGER NO-UNDO.

   /* find all Field_refs in this FIELDS node (=theNode) and put a pragma on them */
    numResults = parserQueryCreate(theNode, "fieldrefs":U, "Field_ref":U).
    DO i1 = 1 TO numResults :
        parserQueryGetResult("fieldrefs":U, i1, child).
        parserAttrSet(child, pragma_number ,1).
    END.
    parserQueryClear ("fieldrefs":U).

END PROCEDURE.

PROCEDURE ExcludeExcept :
/* purpose : put a pragma on fieldrefs in the EXCEPT option of BUFFER-COPY statement */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS logi NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS logi NO-UNDO INITIAL NO.

    DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
    DEFINE VARIABLE i1         AS INTEGER NO-UNDO.

   /* verify if this EXCEPT node is in a BUFFER-COPY/COMPARE statement */
    IF parserNodeStateHead(theNode, child) <> "BUFFERCOPY":U and 
       parserNodeStateHead(theNode, child) <> "BUFFERCOMPARE":U THEN
      RETURN.      

   /* find all Field_refs in this EXCEPT node (=theNode) and put a pragma on them */
    numResults = parserQueryCreate(theNode, "fieldrefs":U, "Field_ref":U).
    DO i1 = 1 TO numResults :
        parserQueryGetResult("fieldrefs":U, i1, child).
        parserAttrSet(child, pragma_number ,1).
    END.
    parserQueryClear ("fieldrefs":U).

END PROCEDURE.

PROCEDURE ExcludeRelationFields :
/* purpose : put a pragma on fieldrefs in the RELATION-FIELDS option of DATA-RELATION option of DEFINE DATASET statement */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS logical NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS logical NO-UNDO INITIAL NO.

    DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
    DEFINE VARIABLE i1         AS INTEGER NO-UNDO.

   /* verify if this RELATION-FIELDS node is in a DATA-RELATION option */
    IF parserNodeParent(theNode, child) <> "DATARELATION":U THEN
      RETURN.

   /* find all Field_refs in this RELATION-FIELDS node (=theNode) and put a pragma on them */
    numResults = parserQueryCreate(theNode, "fieldrefs":U, "Field_ref":U).
    DO i1 = 1 TO numResults :
        parserQueryGetResult("fieldrefs":U, i1, child).
        parserAttrSet(child, pragma_number ,1).
    END.
    parserQueryClear ("fieldrefs":U).

END PROCEDURE.


PROCEDURE ExcludeUsing :
/* purpose : put a pragma on fieldrefs in the USING option of BUFFER-COMPARE statement */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS logi NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS logi NO-UNDO INITIAL NO.

    DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
    DEFINE VARIABLE i1         AS INTEGER NO-UNDO.

   /* verify if this EXCEPT node is in a BUFFER-COPY/COMPARE statement */
    IF parserNodeStateHead(theNode, child) <> "BUFFERCOPY":U and 
       parserNodeStateHead(theNode, child) <> "BUFFERCOMPARE":U THEN
      RETURN.      

   /* find all Field_refs in this USING node (=theNode) and put a pragma on them */
    numResults = parserQueryCreate(theNode, "fieldrefs":U, "Field_ref":U).
    DO i1 = 1 TO numResults :
        parserQueryGetResult("fieldrefs":U, i1, child).
        parserAttrSet(child, pragma_number ,1).
    END.
    parserQueryClear ("fieldrefs":U).

END PROCEDURE.



PROCEDURE BuildList :
/* purpose : recognize variable or parameter and add it to tt_object */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS logi NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS logi NO-UNDO INITIAL NO.

    DEFINE VARIABLE havevar     AS logi NO-UNDO.
    DEFINE VARIABLE varname     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.


    /* set an attrib to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    ASSIGN
      SearchChildren = NO
      nodetype       = parserNodeFirstChild(theNode,child)
      havevar        = NO.

    DO WHILE nodetype <> "" :

        CASE nodetype :
            WHEN "VARIABLE":U    THEN ASSIGN havevar = YES.
            WHEN "PROPERTY":U    THEN ASSIGN havevar = YES.
            WHEN "PARAMETER":U   THEN ASSIGN havevar = YES.
            WHEN "FRAME":U       THEN ASSIGN havevar = YES.
            WHEN "BUTTON":U      THEN ASSIGN havevar = YES.
            WHEN "FILLIN":U      THEN ASSIGN havevar = YES.
            WHEN "RADIOSET":U    THEN ASSIGN havevar = YES.
            WHEN "TOGGLEBOX":U   THEN ASSIGN havevar = YES.
            WHEN "IMAGE":U       THEN ASSIGN havevar = YES.
            WHEN "RECTANGLE":U   THEN ASSIGN havevar = YES.
            WHEN "BROWSE":U      THEN ASSIGN havevar = YES.
            WHEN "MENU":U        THEN ASSIGN havevar = YES.
            WHEN "SUBMENU":U     THEN ASSIGN havevar = YES.
            WHEN "QUERY":U       THEN ASSIGN havevar = YES.
            WHEN "ID":U          THEN IF varname = "":U THEN
              ASSIGN varname = parserGetNodeText(child).
        END CASE.

        nodetype = parserNodeNextSibling(child,child).
    END.

    /* add to list tt_object */
    IF havevar THEN
      RUN AddToList ( varname ).

END PROCEDURE.


PROCEDURE BuildListForm :
/* purpose : add implicit variables in "FORM id AS CHARACTER" */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS logi NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS logi NO-UNDO INITIAL NO.

    DEFINE VARIABLE numResults  AS INTEGER NO-UNDO.
    DEFINE VARIABLE i           AS INTEGER NO-UNDO.

    /* we are looking for the FORM statement. Is theNode a statehead? */
    IF parserAttrGet(theNode, "statehead":U)="" THEN RETURN.

    /* set an attrib to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    /* query for occurences of "AS" */
    numResults = parserQueryCreate(theNode, "qBuildListForm":U, "AS":U).
    DO i = 1 TO numResults :
       parserQueryGetResult("qBuildListForm":U, i, child).
       IF "Format_phrase":U = parserNodeParent(child, child) THEN
          IF "Field_ref":U = parserNodePrevSibling(child,child) THEN
             IF "ID":U = parserNodeFirstChild(child,child) THEN
                RUN AddToList ( parserGetNodeText(child) ).
    END.
    parserQueryClear ("qBuildListForm":U).

END PROCEDURE.


PROCEDURE AddToList :
/* purpose: create a new record tt_object */

    DEFINE INPUT PARAMETER pName       AS CHARACTER NO-UNDO.

    CREATE tt_object.
    ASSIGN tt_object.objName    = pName
      tt_object.ProcRowid  = IF AVAILABLE tt_procedure THEN ROWID(tt_procedure) ELSE ?.

END PROCEDURE.

PROCEDURE AddFunctionParameters :
/* purpose: add parameters for user-defined functions to tt_object */

    DEFINE INPUT PARAMETER thenode AS INTEGER NO-UNDO.

    DEFINE VARIABLE paramID   AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodetype  AS CHARACTER NO-UNDO.
    define variable numResults as integer no-undo.
    define variable i1 as integer no-undo.

    ASSIGN
      nodetype = parserNodeFirstChild(thenode, child)
      paramID  = parserGetHandle().

    /* First find the Parameter_list */
    DO WHILE nodetype <> "" AND nodetype <> "Parameter_list":U:
        nodetype = parserNodeNextSibling(child,child).
    END.

    /* Now find each input, output, and inputoutput parameter node.
       We aren't interested in buffer parameter nodes. */
    IF nodetype = "Parameter_list":U THEN DO: /* have parameter list */
        numResults = parserQueryCreate(child, "paramlist_id":U, "ID":U).
        DO i1 = 1 TO numResults :
            parserQueryGetResult("paramlist_id":U, i1, paramID).
            RUN AddToList (parserGetNodeText(paramID)).
        END.
        parserQueryClear ("paramlist_id":U).
    END.
    parserReleaseHandle(paramID).

END PROCEDURE.


PROCEDURE MessageUpdate :
/* purpose: "MESSAGE UPDATE answer AS LOGICAL" defines a variable */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

   /* verify if this UPDATE node is in a MESSAGE statement */
    IF parserNodeStateHead(theNode, child) <> "MESSAGE":U THEN
      RETURN.

    IF parserNodeFirstChild(theNode, theNode) <> "Field_ref":U THEN
      RETURN.
    IF parserNodeNextSibling(theNode,child) <> "Format_phrase":U THEN
      RETURN.

    IF "ID":U = parserNodeFirstChild(theNode,child) THEN
      RUN AddToList (parserGetNodeText(child)).

END PROCEDURE.

DEFINE STREAM xrf.

procedure InvokedInXrefFile :
  define input parameter pOperation as character no-undo.
  define input parameter pObjectname as character no-undo.
  define input parameter pFilename as character no-undo.
  define input parameter pLinenumber as character no-undo.
  define output parameter hasfound as logical no-undo initial false.

   DEFINE VARIABLE vSourceFile      AS CHARACTER NO-UNDO.
   DEFINE VARIABLE cLineNumber      AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vOperation       AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vArgument        AS CHARACTER NO-UNDO.
   
   INPUT STREAM xrf FROM VALUE (xreffile).
   
   DO WHILE TRUE :
   
     /* clear values in case the next line doesn't have this many fields */ 
     ASSIGN 
       vSourceFile      = ""
       cLineNumber      = ""
       vOperation       = ""
       vArgument        = "".

     /* use the IMPORT statement to be sure to read filenames properly even if they contain spaces */ 
     IMPORT STREAM xrf
        ^
        vSourceFile
        cLineNumber
        vOperation
        vArgument.

     if (vOperation=pOperation) and (vArgument matches ("*" + pObjectname + "*")) and pLinenumber=cLineNumber then 
        hasfound=true. 
   end.

   input stream xrf close.
       
end procedure.     

PROCEDURE InspectFieldref :
/* purpose: Mark all the variables assigned from assign statements */

    DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
    DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.

    DEFINE VARIABLE objectname             AS CHARACTER NO-UNDO.

    parserAttrSet(theNode, pragma_number ,1).

    /* theNode is a "Field_ref" node.
       its first child is an "ID" node. That's the node we want to check */

    IF "ID":U = parserNodeFirstChild(theNode,child) THEN DO:
       objectname = parserGetNodeText(child).

       /* does objectname contain a dot? Then it's a valid buffername.fieldname */
       IF objectname MATCHES "*~~.*":U THEN
          RETURN.

       /* is it a built-in function? (then why does it not have parenthesis?) */
       IF LOOKUP(objectname, "TODAY,NOW,GUID":U) > 0 THEN
          RETURN.

       /* is objectname a an inherited attribute (from some superclass? */
       IF superclassname > "" THEN
          IF IsInheritedAttribute(superclassname, objectname) THEN
             RETURN.

       /* is objectname a local variable or local parameter? Then it's ok */
       IF AVAILABLE tt_procedure THEN
          IF CAN-FIND (FIRST tt_object WHERE tt_object.ProcRowid=ROWID(tt_procedure)
                                         AND tt_object.objname  =objectname) THEN
             RETURN.

       /* is objectname a global variable or parameter? */
       IF CAN-FIND (FIRST tt_object WHERE tt_object.ProcRowid=?
                                      AND tt_object.objname  =objectname) THEN
          RETURN.

       /* it might be the name of a class that you're invoking */
       define variable retval as logical no-undo.
       run InvokedInXrefFile ("INVOKE":U, objectname, parserGetNodeFilename(child), string(parserGetNodeLine(child)), output retval).
       if retval then  
          RETURN.
       
       /* No, then it must be an unqualified buffer field. Publish warning! */
       RUN PublishResult            (
         INPUT compilationunit,
         INPUT parserGetNodeFilename(child),
         INPUT parserGetNodeLine(child),
         INPUT SUBSTITUTE("field &1 must be qualified with tablename":T,objectname),
         INPUT rule_id).

    END.

END PROCEDURE.


