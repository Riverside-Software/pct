/* -----------------------------------------------------------------------------
   file    :  prolint/rules/publicvar.p
   purpose :  detect public variables in classes. They should be replaced by properties.
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


    DEFINE VARIABLE child AS INTEGER NO-UNDO.
    DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
    DEFINE VARIABLE statehead AS INTEGER NO-UNDO.
    DEFINE VARIABLE grandchild AS INTEGER NO-UNDO.
    DEFINE VARIABLE varname AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ispublic AS LOGICAL NO-UNDO.

    child = parserGetHandle().
    nodetype = parserNodeFirstChild(hTopnode, child).
    DO WHILE nodetype = "USING":U :
        nodetype = parserNodeNextSibling(child,child).
    END.
    IF nodetype <> "CLASS":U THEN 
        parserReleaseHandle(child).
    ELSE DO:
        grandchild = parserGetHandle().
        nodetype = parserNodeFirstChild(child, child).
        DO WHILE NOT (nodetype="") :
           CASE nodetype :
              WHEN "Code_block":U THEN
                  DO:
                     statehead = parserGetHandle().
                     nodetype = parserNodeFirstChild(child, statehead).
                     DO WHILE nodetype<>"" :
                        IF nodetype="DEFINE":U THEN
                           IF parserAttrGet(statehead,"state2":U)="variable":U THEN DO:
                              /* dive in to get the variable name and to see if it is private/public/protected */
                              ispublic = FALSE.
                              varname = "".
                              nodetype = parserNodeFirstChild(statehead, grandchild).
                              DO WHILE nodetype<>"" :
                                 CASE nodetype:
                                    WHEN "public" THEN ispublic = TRUE.
                                    WHEN "id" THEN IF varname="" THEN DO:
                                                      varname = parserGetNodeText(grandchild).
                                                      IF ispublic THEN
                                                          RUN PublishResult    (compilationunit,
                                                                                parserGetNodeFilename(statehead),
                                                                                parserGetNodeLine(statehead),
                                                                                SUBSTITUTE("replace public variable &1 by property":T,varname),
                                                                                rule_id).
                                                   END.
                                 END.
                                 nodetype = parserNodeNextSibling(grandchild, grandchild).
                              END.
                           END.
                        nodetype = parserNodeNextSibling(statehead, statehead).
                     END.
                     parserReleaseHandle(statehead).
                  END.
           END CASE.
           nodetype = parserNodeNextSibling(child, child).
        END.
        parserReleaseHandle(grandchild).
        parserReleaseHandle(child).

    END.



