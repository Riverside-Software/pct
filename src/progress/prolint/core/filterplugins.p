/* ------------------------------------------------------------------
    file    : prolint/core/filterplugins.p
    purpose : loads filter plug-ins
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra

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
   ------------------------------------------------------------------ */

{prolint/core/dlc-version.i}

DEFINE INPUT PARAMETER pProfileDirectory AS CHARACTER NO-UNDO.

DEFINE VARIABLE hLintSuper AS HANDLE NO-UNDO.
FUNCTION RelativeFilename RETURNS CHARACTER (pFileName AS CHARACTER) IN hLintSuper.

/* temp-table definition tt_filters
   contains the list of filter plugins */
DEFINE TEMP-TABLE tt_filters NO-UNDO
   FIELD filtername AS CHARACTER
   FIELD hpFilter AS HANDLE.

/* local tt_ignore. This is a filter, but not a plug-in.
   this one is used for _proparse_ prolint-nowarn directives
   for rules that cannot use proparse, like "whole-index" and "sort-access" */
DEFINE TEMP-TABLE tt_ignore NO-UNDO
   FIELD Sourcefile AS CHARACTER
   FIELD RuleID     AS CHARACTER
   FIELD LineNumber AS INTEGER
   INDEX idx_1 AS PRIMARY SourceFile RuleID LineNumber.

ON "CLOSE":U OF THIS-PROCEDURE DO:
  FOR EACH tt_filters :
     APPLY "CLOSE":U TO tt_filters.hpFilter.
  END.
  DELETE PROCEDURE THIS-PROCEDURE.
END.  
   
RUN InitializePlugins.
SUBSCRIBE TO "Prolint_Status_FileEnd" ANYWHERE.
RETURN.

/* ------------------------ internal procedures ------------------------------ */

PROCEDURE SethLintSuper :
    DEFINE INPUT PARAMETER ph AS HANDLE NO-UNDO.
    hLintSuper = ph.
END PROCEDURE.

PROCEDURE InitializePlugins :
   /* purpose: run filters\*.p persistent */
    DEFINE VARIABLE fulldir  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE progname AS CHARACTER NO-UNDO.

    FILE-INFORMATION:FILE-NAME = "prolint/filters":U.
    fulldir = FILE-INFORMATION:FULL-PATHNAME.
    INPUT FROM OS-DIR ( fulldir ).
    REPEAT:
        IMPORT progname.
        IF progname MATCHES "*~~.p":U THEN
        DO:
            CREATE tt_filters.
            RUN VALUE( "prolint/filters/":U + progname )
                PERSISTENT SET tt_filters.hpFilter ( pProfileDirectory ).
            tt_filters.filtername = LC( SUBSTRING( progname, 1, LENGTH( progname ) - 2 ) ).
        END.
    END.
    INPUT CLOSE.

END PROCEDURE.



PROCEDURE AddNowarnFilter :
   /* purpose: add entries for rules that do not use Proparse,
               but still need to suppress warnings from _proparse_ directives
               like rule whole-index */
   DEFINE INPUT PARAMETER pRuleID     AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER pSourcefile AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER pLineNumber AS INTEGER   NO-UNDO.

   DEFINE VARIABLE relname AS CHARACTER NO-UNDO.
   relname = RelativeFilename( pSourcefile ).

   FIND tt_Ignore WHERE
           tt_Ignore.sourcefile = relname
       AND tt_Ignore.RuleId     = pRuleId
       AND tt_Ignore.LineNumber = pLineNumber NO-ERROR.
   IF NOT AVAILABLE tt_Ignore THEN
   DO:
       CREATE tt_Ignore.
       ASSIGN 
           tt_Ignore.sourcefile = relname
           tt_Ignore.RuleId     = pRuleId
           tt_Ignore.LineNumber = pLineNumber.
   END.

   
END PROCEDURE.



PROCEDURE GetFilterResult :
/* purpose : call each filter's GetFilterResult procedure */
   DEFINE INPUT        PARAMETER pCompilationUnit AS CHARACTER NO-UNDO.
   DEFINE INPUT        PARAMETER pFullSource      AS CHARACTER NO-UNDO.
   DEFINE INPUT        PARAMETER pRelativeSource  AS CHARACTER NO-UNDO.
   DEFINE INPUT        PARAMETER pLineNumber      AS INTEGER   NO-UNDO.
   DEFINE INPUT        PARAMETER pRuleID          AS CHARACTER NO-UNDO.
   DEFINE INPUT        PARAMETER pIgnoreAB        AS LOGICAL   NO-UNDO.
   DEFINE INPUT-OUTPUT PARAMETER pDescription     AS CHARACTER NO-UNDO.
   DEFINE INPUT-OUTPUT PARAMETER pSeverity        AS INTEGER   NO-UNDO.
   DEFINE OUTPUT       PARAMETER filteredby       AS CHARACTER NO-UNDO.

   DEFINE VARIABLE filtered AS LOGICAL NO-UNDO.


   filtered = CAN-FIND(tt_ignore WHERE tt_ignore.SourceFile = pRelativeSource
                                   AND tt_ignore.RuleID     = pRuleID
                                   AND tt_ignore.LineNumber = pLineNumber).

   IF filtered THEN
      filteredby = "pragma":U.
   ELSE
      FOR EACH tt_filters :
         RUN GetFilterResult IN tt_filters.hpFilter  (pCompilationUnit,
                                                      pFullSource,
                                                      pRelativeSource,
                                                      pLineNumber,
                                                      pRuleID,
                                                      pIgnoreAB,
                                                      INPUT-OUTPUT pDescription,
                                                      INPUT-OUTPUT pSeverity,
                                                      OUTPUT filtered).
         IF filtered THEN DO:
            filteredby = TRIM(filteredby + ",":U + tt_filters.filtername,",":U).
            RETURN.
         END.
   END.

END PROCEDURE.


PROCEDURE Prolint_Status_FileEnd :
/* purpose : linting of a compilation unit is done. You can clean up now */
   FOR EACH tt_ignore :
      DELETE tt_ignore.
   END.

END PROCEDURE.

