/* -----------------------------------------------------------------------------
   file    :  prolint/rules/leavemodal.p
   purpose :  find leave triggers which contain a "return no-apply" or
              a message statement.
   -----------------------------------------------------------------------------

    Copyright (C) 2007 Tim Townsend

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

&global-define Node int


   RUN searchNode            (hTopnode,           /* "Program_root" node          */
                              "InspectNode":U,    /* name of callback procedure   */
                              "ON":U).            /* list of nodetypes to search for */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   def input  parameter theNode        as {&Node} no-undo.
   def output parameter AbortSearch    as log     no-undo init false.
   def output parameter SearchChildren as log     no-undo init true.
                             
   def var icEventList     as char         no-undo.
   def var inChild         as {&Node}      no-undo.
   def var icChild         as char         no-undo.
   def var icEvent         as char         no-undo.
   def var iiNumResults    as int          no-undo.
   def var iiResultNum     as int          no-undo.
   def var inReturnNode    as {&Node}      no-undo.
   def var inMessageNode   as {&Node}      no-undo.

   /* we don't care about an on phrase, i.e. part of a do block header, etc. */
   if parserAttrGet(theNode,"statehead":u) <> "t":u then return.

   run BuildEventList(theNode,
                      output icEventList).

   if lookup("leave":u,icEventList) > 0 then do:

       /* look for 'return no-apply' */
       inReturnNode  = parserGetHandle().
       inChild       = parserGetHandle().

       iiNumResults = parserQueryCreate(theNode,
                                        "QueryReturns":u,
                                        "RETURN":u).
       do iiResultNum = 1 to iiNumResults:
           parserQueryGetResult("QueryReturns":u,
                                iiResultNum,
                                inReturnNode).
           icChild = parserNodeFirstChild(inReturnNode,inChild).

           do while icChild > "":
               if icChild = "NOAPPLY":u then do:
                   run PublishResult (compilationunit,
                                      parserGetNodeFilename(inChild),
                                      parserGetNodeLine(inChild),
                                      "Modal Leave Trigger -- has RETURN NO-APPLY":T,
                                      rule_id).
               end.
               icChild = parserNodeNextSibling(inChild,inChild).
           end.
       end.  /* 1..? */

       parserQueryClear("QueryReturns":u).
       parserReleaseHandle(inReturnNode).
       parserReleaseHandle(inChild).

       /* look for message statement */
       inMessageNode = parserGetHandle().
       iiNumResults = parserQueryCreate(theNode,
                                        "QueryMsg":u,
                                        "MESSAGE":u).

       do iiResultNum = 1 to iiNumResults:
            parserQueryGetResult("QueryMsg":u,
                                 iiResultNum,
                                 inMessageNode).
            run PublishResult (compilationunit,
                               parserGetNodeFilename(inMessageNode),
                               parserGetNodeLine(inMessageNode),
                               "Modal Leave Trigger -- has MESSAGE":T,
                               rule_id).
        end.  /* 1..? */

        parserQueryClear("QueryMsg":u).
        parserReleaseHandle(inMessageNode).
   end.
   
   return.
END PROCEDURE.                            


procedure BuildEventList:
/* Builds a list of all the events referenced in an ON trigger */
def input  parameter pnOnTrigger as {&Node}  no-undo.
def output parameter pcEventList as char     no-undo.

def var inChild         as {&Node}      no-undo.
def var icChild         as char         no-undo.
def var inStateHead     as {&Node}      no-undo.
def var icEvent         as char         no-undo.
def var iiNumResults    as int          no-undo.
def var iiResultNum     as int          no-undo.
def var inEventListNode as {&Node}      no-undo.

    inEventListNode = parserGetHandle().
    inChild         = parserGetHandle().
    inStateHead     = parserGetHandle().

    iiNumResults = parserQueryCreate(pnOnTrigger,
                                     "QueryEvents":u,
                                     "Event_list":u).
    do iiResultNum = 1 to iiNumResults:
        parserQueryGetResult("QueryEvents":u,
                             iiResultNum,
                             inEventListNode).
        icChild = parserNodeFirstChild(inEventListNode,inChild).

        do while icChild > "":
           parserNodeStateHead(inChild,inStateHead).

           /* we only want events that are for this node directly, not for triggers nested
              inside this one.  */
           if parserIsSameNode(inStateHead,pnOnTrigger) then do:
               icEvent = parserGetNodeText(inChild).
               /* known issue -- we treat all commas as list delimiters but it could be an event
                  on the comma keypress itself.  */
               if icEvent <> "," then
                 pcEventList = pcEventList + "," + icEvent.
           end.

           icChild = parserNodeNextSibling(inChild,inChild).
        end.
    end.  /* 1..? */
    
    pcEventList = trim(pcEventList,",").
    parserQueryClear("QueryEvents":u).
    parserReleaseHandle(inEventListNode).
    parserReleaseHandle(inChild).
    parserReleaseHandle(inStateHead).

    return.
end procedure.
