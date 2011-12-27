/* -----------------------------------------------------------------------------
   file    :  prolint/rules/varusage2.p
   by      :  Jurjen Dijkstra, John Green, Breck Fairley
   purpose :  search for variables/parameters that are never used
              also: this version considers non-used output parameters to be NOT
                    USED if varusage_OutputParamsAreUsed is defined in prolint.properties.p
              also: warn for variables/parameters that are assigned but never
                    accessed
              also: warn for local variable with same name as large-scoped variable.
   custom  : Niek Knijnenburg
             SkipNewShared property so you can configure to skip new shared vars, ProLint can not check if these are never used
   -----------------------------------------------------------------------------

    Copyright (C) 2001,2007 Jurjen Dijkstra,
                            John Green,
                            Breck Fairley,
                            Jamie Ballarin

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
def temp-table tt_object no-undo
    field sourcefile  as char  /* sourcefile where object was defined               */
    field linenumber  as inte  /* linenumber in sourcefile where object was defined */
    field ProcRowid   as rowid /* function|procedure where object was defined       */
    field ParamType   as char  /* INPUT/INPUTOUTPUT/OUTPUT */
    field objType     as char  /* parameter|variable                                */
    field objName     as char  /* identifier                                        */
    field IsUsed      as logi  /* is this variable referenced anywhere              */
    field IsAccessed  as logi  /* is this variable accessed anywhere                */
    field newshared   as logi  /* is this a new shared variable                     */

    index idx_objname  as primary objname ProcRowid
    index idx_procedure           ProcRowid
    index idx_used_accessed       IsUsed IsAccessed.

def var child               as inte no-undo.
def var grandchild          as inte no-undo.
def var greatgrandchild     as inte no-undo.
def buffer btt_procedure    for tt_procedure.

define variable superclassname      as character no-undo.
define variable OutputParamsAreUsed as logical no-undo.
define variable SkipNewShared       as logical no-undo.

run GetSuperClass in hLintSuper(hTopNode, output superclassname, output child).

OutputParamsAreUsed = logical(dynamic-function("ProlintProperty", "rules.varusage.OutputParamsAreUsed")).
SkipNewShared       = logical(dynamic-function("ProlintProperty", "rules.varusage.SkipNewShared")).

MAIN-BLK:
do on error undo MAIN-BLK, leave MAIN-BLK:

    assign
        child           = parserGetHandle()
        grandchild      = parserGetHandle()
        greatgrandchild = parserGetHandle().

    /* get the list of all functions and procedures */
    run ProcedureListGet in hLintSuper (output table tt_procedure).


    /* AIM: To build a complete list of tt_object (all variables and    */
    /*      parameters).                                                */


    /* STEP 1: Remove any procedures that are in a SUPER procedure,     */
    /*         within a HANDLE or EXTERNAL...                           */
    /*         Collect parameters for prototypes                        */
    /*         (IN SUPER, IN prochandle, EXTERNAL, ...).                */
    /*         We don't care at all about these parameters, so we will  */
    /*         delete the tt_objects anyway.                            */
    /*         We only use this step because we need to set the "already*/
    /*         looked at" attributes.                                   */

    for each tt_procedure
        where tt_procedure.prototype :

        /* create a list of variables and parameters, store them in tt_object */
        run searchNode            (
            input tt_procedure.startnode,
            input "BuildList":U,
            input "DEFINE":U ).

        empty temp-table tt_object.
    end.


    /* STEP 2: Build a list of all variables/parameters within this     */
    /*         compilation unit and its internal procedures.            */
    /*         First, get local vars and params in internal             */
    /*         procs/functions. Be sure to mark them as "already looked */
    /*         at" so they are skipped when querying the Program scope. */

    for each tt_procedure
        where not tt_procedure.prototype :

        /* create a list of variables and parameters, store them in tt_object */
        run searchNode            (
            input tt_procedure.startnode,
            input "BuildList":U,
            input "DEFINE":U ).

        /* if tt_procedure is a function, or a method, we must do some extra work to get parameters */
        if tt_procedure.proctype = "FUNCTION":U OR
           tt_procedure.proctype = "METHOD":U OR
           tt_procedure.proctype = "CONSTRUCTOR":U OR
           tt_procedure.proctype = "Property_setter":U then
           run AddFunctionParameters(input tt_procedure.startnode).

    end.

    /*         Second, add the objects at the program scope.            */
    /*         Because we have set pragma_number attributes we are      */
    /*         able to skip variabless and parameters at local scopes.  */

    release tt_procedure no-error. /* we must have not available */
    run searchNode            (
        input hTopNode,
        input "BuildList":U,
        input "DEFINE":U ).

    /* We have now collected all variables and parameters. From here    */
    /* it's easy to see if local objects are hiding program-scoped      */
    /* objects.                                                         */

    run SearchNameConflicts.


    /* Inspect if vars and params in each tt_procedure are assigned.    */
    /* This means that the object is "assigned" a value but does not    */
    /* necessarily mean that the object's value is "accessed".          */
    /* Once again, perform checks within the internal procedures first. */

    for each tt_procedure
        where not tt_procedure.prototype :

        /* find where variables are assigned */

       run SearchNode            (
            input tt_procedure.startnode,
            input "MarkAssigns":U,
            input "ASSIGN":U ).

       run SearchNode            (
            input tt_procedure.startnode,
            input "MarkImports":U,
            input "IMPORT":U ).

       run SearchNode            (
            input tt_procedure.startnode,
            input "MarkSets":U,
            input "SET":U ).

    end.

    /* Inspect the top "Program_root" scope for remaining objects.      */
    /* This is very similar to the loop for a single tt_procedure, but  */
    /* we must be sure to skip all vars/params which already past the   */
    /* first loop. The pragma_number attribute assists us here.         */

    release tt_procedure no-error. /* we must have not available */

    /* find where variables are assigned. */
    run SearchNode            (
        input hTopNode,
        input "MarkAssigns":U,
        input "ASSIGN":U ).

    run SearchNode            (
        input hTopNode,
        input "MarkImports":U,
        input "IMPORT":U ).

    run SearchNode            (
        input hTopNode,
        input "MarkSets":U,
        input "SET":U ).


    /* We have just set Access flags to No on all the tt_objects that   */
    /* are assigned a value. Because we have set the pragmas of these   */
    /* objects, all the remaining Field_refs should be accesses.        */
    /* Once again, perform checks within the internal procedures first. */

    for each tt_procedure
        where not tt_procedure.prototype :

        /* find where variables are accessed */
        run SearchNode            (
            input tt_procedure.startnode,
            input "ProcessFieldRAccess":U,
            input "Field_ref":U ).

    end.

    /* Inspect the top "Program_root" scope for remaining objects.      */
    /* This is very similar to the loop for a single tt_procedure, but  */
    /* we must be sure to skip all vars/params which already past the   */
    /* first loop. The pragma_number attribute assists us here.         */

    release tt_procedure no-error. /* we must have not available */

    /* find where variables are accessed */
    run SearchNode            (
        input hTopNode,
        input "ProcessFieldRAccess":U,
        input "Field_ref":U ).


    /* We are done. Release all handles as we don't need kids anymore.  */
    parserReleaseHandle(child).
    parserReleaseHandle(grandchild).
    parserReleaseHandle(greatgrandchild).


    /* Start outputting the results */

    /* If used but not accessed, then report the object as "assigned but */
    /* never accessed".                                                  */

    for each tt_object
        where tt_object.IsUsed=TRUE
          AND tt_object.objType <> "property":U
          and tt_object.IsAccessed=false
          and tt_object.newshared <> SkipNewShared:

        run PublishResult            (
            input compilationunit,
            input tt_object.sourcefile,
            input tt_object.linenumber,
            input substitute("&1 &2 is assigned but never accessed":T,tt_object.ObjType,tt_object.ObjName),
            input rule_id).

    end.

    /* If not used, then report the object as "never used". */

    for each tt_object
        where tt_object.IsUsed=FALSE
          AND tt_object.objType <> "property":U
          and (not (OutputParamsAreUsed AND tt_object.ParamType matches "*OUTPUT":U))
          and tt_object.newshared <> SkipNewShared:

        run PublishResult            (
            input compilationunit,
            input tt_object.sourcefile,
            input tt_object.linenumber,
            input substitute("&1 &2 is never used":T,tt_object.ObjType,tt_object.ObjName),
            input rule_id ).

    end.

    return.

end. /* MAIN-BLK */



procedure SearchNameConflicts :
/* purpose: see if vars or params in ip's have same name as vars/params on program scope */

def buffer buf_object for tt_object.

    for each tt_object
        where tt_object.ProcRowid = ? :

        for each buf_object
            where buf_object.ProcRowid <> ?
              and buf_object.ObjName = tt_object.ObjName :

            find first tt_procedure
                where rowid(tt_procedure) = buf_object.ProcRowid.

            run PublishResult            (
                input compilationunit,
                input buf_object.sourcefile,
                input buf_object.linenumber,
                input substitute("&1 &2 in &3 &4 hides object in program scope":T,
                                 buf_object.ObjType,
                                 buf_object.ObjName,
                                 tt_procedure.proctype,
                                 tt_procedure.procname),
                input rule_id ).

       end.

   end.

   release tt_procedure.
   release buf_object.
   release tt_object.

end procedure.


procedure BuildList :
/* purpose : recognize variable or parameter and add it to tt_object */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.

def var havevar     as logi no-undo.
def var varname     as char no-undo.
def var vartype     as char no-undo.
def var nodetype    as char no-undo.
def var IsUsed      as logi no-undo.
def var IsAccessed  as logi no-undo.
def var ParamType   as char no-undo.
def var newshared   as logi no-undo.


    /* set an attrib to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    if available tt_procedure and tt_procedure.prototype then
        return.

    assign
      SearchChildren = No
      nodetype       = parserNodeFirstChild(theNode,child)
      IsUsed         = No
      IsAccessed     = No
      havevar        = No
      ParamType      = "".

    do while nodetype <> "" :

        case nodetype :
          when "NEW"           then assign newshared = yes.
          when "VARIABLE":U    then assign havevar = Yes
                                           vartype = 'variable':U.
          when "PROPERTY":U    then assign havevar = Yes
                                           vartype = 'property':U.
          when "INPUT":U or
          when "OUTPUT":U or
          when "INPUTOUTPUT":U then assign ParamType = nodetype
                                           IsAccessed = if nodetype = "OUTPUT":U or
                                                           nodetype = "INPUTOUTPUT":U then
                                                            Yes
                                                        else
                                                            No.   /* output parameters can't be "not used" */
          when "PARAMETER":U   then assign havevar = Yes
                                           vartype = 'parameter':U.
          when "ID":U          then if varname = "":U then
                                    assign varname = parserGetNodeText(child).
          when "BUFFER":U or
          when "TABLE":U       then if vartype='parameter':U then
                                       /* suppress warning on "def .. param table for ..." */
                                    assign havevar = No.
        end case.

        nodetype = parserNodeNextSibling(child,child).
    end.

    /* add to list tt_object */
    if havevar then

        run AddToList (
            input RelativeFileName(parserGetNodeFilename(theNode)),
            input parserGetNodeLine(theNode),
            input vartype,
            input varname,
            input IsUsed,
            input IsAccessed,
            input ParamType,
            input newshared).

end procedure.


procedure AddToList :
/* purpose: create a new record tt_object */

def input param pSourceFile as char no-undo.
def input param pLine       as inte no-undo.
def input param pType       as char no-undo.
def input param pName       as char no-undo.
def input param pUsed       as logi no-undo.
def input param pAccessed   as logi no-undo.
def input param pParamType  as char no-undo.
def input param pNewshared  as logi no-undo.


   create tt_object.
   assign tt_object.sourcefile = pSourceFile
          tt_object.linenumber = pLine
          tt_object.ParamType  = pParamType
          tt_object.objType    = pType
          tt_object.objName    = pName
          tt_object.IsUsed     = pUsed
          tt_object.IsAccessed = pAccessed
          tt_object.NewShared  = pNewShared
          tt_object.ProcRowid  = if available tt_procedure then rowid(tt_procedure) else ?.


   /* is objectname a an inherited attribute (from some superclass? */
   IF superclassname > "" THEN
      IF IsInheritedAttribute(superclassname, pName) THEN
            run PublishResult            (
                input compilationunit,
                input tt_object.sourcefile,
                INPUT tt_object.linenumber,
                input substitute("&1 &2 in &3 &4 hides object inherited from superclass":T,
                                 tt_object.ObjType,
                                 tt_object.ObjName,
                                 IF AVAILABLE tt_procedure THEN tt_procedure.proctype ELSE "",
                                 IF AVAILABLE tt_procedure THEN tt_procedure.procname ELSE ""),
                input rule_id ).


end procedure.


procedure AddFunctionParameters :
/* purpose: add parameters for user-defined functions and methods to tt_object */

def input param thenode as inte no-undo.

def var paramType as char no-undo.
def var paramID   as inte no-undo.
def var nodetype  as char no-undo.


    assign
        nodetype = parserNodeFirstChild(thenode, child)
        paramID  = parserGetHandle().

    /* First find the Parameter_list */
    do while nodetype <> "" and nodetype <> "Parameter_list":U:
        nodetype = parserNodeNextSibling(child,child).
    end.

    /* Now find each input, output, and inputoutput parameter node.
       We aren't interested in buffer parameter nodes. */
    if nodetype = "Parameter_list":U then
    do: /* have parameter list */
        nodetype = parserNodeFirstChild(child,child).
        do while nodetype <> "":
            paramType = nodetype.
            /* TOdo: decide if we should ignore output and inputoutput parameters */
            if paramType = "INPUT":U or paramType = "OUTPUT":U or paramType = "INPUTOUTPUT":U then
            do:
                /* The first child is either ID or table. We only want ID. */
                if parserNodeFirstChild(child, paramID) = "ID":U then

                    run AddToList (
                        input RelativeFileName(parserGetNodeFilename(paramID)),
                        input parserGetNodeLine(paramID),
                        input "parameter":U,
                        input parserGetNodeText(paramID),
                        input No,
                        input if paramType = "OUTPUT":U or
                                 paramType = "INPUTOUTPUT":U then
                                  Yes
                              else
                                  No,
                        input paramType,
                        input no ). /* never new shared */

            end.
            nodetype = parserNodeNextSibling(child,child).
        end.
    end.
    parserReleaseHandle(paramID).

end procedure.


procedure ProcessFieldRUsage :
/* purpose : a Field_ref has a child with nodetype="ID".
             This ID is an used but not necessarily accessed variable */

def input  param theNode        as inte no-undo.


    /* set an attrib, to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    /* From the tree spec:
     * #(Field_ref (input)? #((FRAME|BROWSE) ID)? ID (array_subscript)? )
     */
    FIND-ID-BLK:
    do:
        if parserNodeFirstChild(theNode, greatgrandchild) = "ID":U then
            leave FIND-ID-BLK.
        if parserNodeNextSibling(greatgrandchild, greatgrandchild) = "ID":U then
            leave FIND-ID-BLK.
        parserNodeNextSibling(greatgrandchild, greatgrandchild).
    end. /* FIND-ID-BLK */
    run AddDetectedUsage(greatgrandchild,No).
    return.

end procedure.


procedure ProcessFieldRAccess :
/* purpose : a Field_ref has a child with nodetype="ID".
             This ID is an accessed variable */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.


    /* set an attrib, to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    /* From the tree spec:
     * #(Field_ref (input)? #((FRAME|BROWSE) ID)? ID (array_subscript)? )
     */
    FIND-ID-BLK:
    do:
        if parserNodeFirstChild(theNode, child) = "ID":U then
            leave FIND-ID-BLK.
        if parserNodeNextSibling(child, child) = "ID":U then
            leave FIND-ID-BLK.
        parserNodeNextSibling(child, child).
    end. /* FIND-ID-BLK */
    run AddDetectedUsage(child,Yes).
    return.

end procedure.


procedure AddDetectedUsage :
/* purpose: mark tt_object.IsUsed = Yes and
            mark tt_object.IsAccessed = Yes/No */

def input param idnode  as inte no-undo.
def input param Access  as logi no-undo.

def var ObjectName      as char no-undo.


    objectname = parserGetNodeText(idnode).

    release tt_object no-error.

    if available tt_procedure then
    do:
        find first tt_object
            where tt_object.ProcRowid = rowid(tt_procedure)
              and tt_object.objname   = objectname
            no-error.
        if available tt_object and
           not (tt_object.IsUsed and tt_object.IsAccessed) then
            assign
                tt_object.IsUsed     = Yes
                tt_object.IsAccessed = if tt_object.ParamType = "OUTPUT":U or
                                          tt_object.ParamType = "INPUTOUTPUT":U then
                                           Yes
                                       else
                                           Access.
    end.

    /* if not, we must have referenced a variable on program scope */
    if not available(tt_object) or not available(tt_procedure) then
    do:
        find first tt_object
            where tt_object.ProcRowid = ?
              and tt_object.objname   = objectname
            no-error.
        if available tt_object and
           not (tt_object.IsUsed and tt_object.IsAccessed) then
            assign
                tt_object.IsUsed     = Yes
                tt_object.IsAccessed = if tt_object.ParamType = "OUTPUT" or
                                          tt_object.ParamType = "INPUTOUTPUT" then
                                           Yes
                                       else
                                           Access.
    end.

end procedure.


procedure MarkAssigns:
/* purpose: Mark all the variables assigned from assign statements */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.

def var nodetype                as char no-undo.


    parserAttrSet(theNode, pragma_number ,1).

    nodetype = parserNodeFirstChild(theNode,child).

    do while nodetype <> "" :
        if nodetype = "EQUAL":U and
           parserNodeFirstChild(child, grandchild) = "Field_ref":U then

            run ProcessFieldRUsage ( input grandchild ).

        nodetype = parserNodeNextSibling(child,child).
    end.

end procedure.


procedure MarkImports:
/* purpose: Mark all the variables assigned from import statements */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.

def var numResults              as inte no-undo.
def var i1                      as inte no-undo.


    parserAttrSet(theNode, pragma_number ,1).

    numResults = parserQueryCreate(theNode, "fieldrefs":U, "Field_ref":U).
    do i1 = 1 to numResults :
        parserQueryGetResult("fieldrefs":U, i1, grandchild).
        run ProcessFieldRUsage ( input grandchild ).
    end.
    parserQueryClear ("fieldrefs":U).

end procedure.


procedure MarkSets:
/* purpose: Mark all the variables assigned from set statements */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.


    parserAttrSet(theNode, pragma_number ,1).

    if parserNodeFirstChild(theNode,child) = "Field_ref":U then

        run ProcessFieldRUsage ( input child ).

end procedure.

