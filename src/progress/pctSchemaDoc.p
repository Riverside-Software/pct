/*
  Base documenter - generates HTML documentation of databases.
  BaseDocPers.p 2001 by Gilles QUERRET
*/

/* 
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

PROCEDURE TableSummary.
    DEFINE INPUT  PARAMETER pcWhere AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcTable AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcTitle AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE hTables   AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hQuery    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFileName AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDumpName AS HANDLE     NO-UNDO.

    /* Open the query and set the buffers */
    CREATE BUFFER hTables FOR TABLE "_File".
    CREATE QUERY hQuery.
    hQuery:SET-BUFFERS (hTables).
    hQuery:QUERY-PREPARE ('FOR EACH _File ' + pcWhere).
    hQuery:QUERY-OPEN.
    hQuery:GET-FIRST.
    ASSIGN hFileName = hTables:BUFFER-FIELD ('_File-Name')
           hDumpName = hTables:BUFFER-FIELD ('_Dump-Name').

    PUT UNFORMATTED "<div id=""TableSummary"">" SKIP.
    PUT UNFORMATTED "<h1>" pcTitle "</h1>" SKIP.
    REPEAT:
        IF hQuery:QUERY-OFF-END THEN LEAVE.
	IF (hDumpName:BUFFER-VALUE EQ pcTable) THEN DO:
            PUT UNFORMATTED "<p id=""Highlight"">" SKIP.
	END.
	ELSE DO:
	    PUT UNFORMATTED "<p>" SKIP.
	END.
	IF (hDumpName:BUFFER-VALUE NE pcTable) THEN DO:
	    PUT UNFORMATTED "<a href=""".
	    IF (hDumpName:BUFFER-VALUE EQ ?) THEN
	        PUT UNFORMATTED hFileName:BUFFER-VALUE + ".html".
	    ELSE
	        PUT UNFORMATTED hDumpName:BUFFER-VALUE + ".html".
            PUT UNFORMATTED """>".
	END.
        PUT UNFORMATTED hFileName:BUFFER-VALUE.
	IF (hDumpName:BUFFER-VALUE NE pcTable) THEN DO:
            PUT UNFORMATTED "</a>".
        END.
	PUT UNFORMATTED "</p>" SKIP.
        hQuery:GET-NEXT (NO-LOCK).
    END.
    PUT UNFORMATTED "</div>" SKIP.
    hQuery:QUERY-CLOSE.
    DELETE OBJECT hFileName.
    DELETE OBJECT hDumpName.
    DELETE OBJECT hQuery.
    DELETE OBJECT hTables.
    
END PROCEDURE.

PROCEDURE DetailedTable.
    /* Handles for table _File */
    DEFINE VARIABLE hFile      AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBFile     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDump      AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTable     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTableDesc AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hPrime     AS HANDLE     NO-UNDO.
    /* Handles for table _Field */
    DEFINE VARIABLE hField     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBField    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hOrder     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFieldName AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDataType  AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hMandatory AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFormat    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hExtent    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hInitial   AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hLabel     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFieldDesc AS HANDLE     NO-UNDO.
    /* Handles for table _Index */
    DEFINE VARIABLE hIndex     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBIndex    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hIndexName AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hActive    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hIndexDesc AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hUnique    AS HANDLE     NO-UNDO.
    /* Handles for table _File-Trig */
    DEFINE VARIABLE hTrig     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBTrig    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hEvent    AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hProc     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hOverride AS HANDLE     NO-UNDO.
    /* Handles for table _Index_Field */
    DEFINE VARIABLE hIdxField   AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hBIdxField  AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFieldRecID AS HANDLE     NO-UNDO.
    
    DEFINE VARIABLE cQuery AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lEven  AS LOGICAL    NO-UNDO FORMAT "Even/Odd" INITIAL TRUE.
    
    /* Creating queries */
    CREATE QUERY hFile.
    CREATE QUERY hField.
    CREATE QUERY hIndex.
    CREATE QUERY hTrig.
    CREATE QUERY hIdxField.

    /* Creating buffers */
    CREATE BUFFER hBFile  FOR TABLE '_File'.
    CREATE BUFFER hBField FOR TABLE '_Field'.
    CREATE BUFFER hBIndex FOR TABLE '_Index'.
    CREATE BUFFER hBTrig  FOR TABLE '_File-Trig'.
    CREATE BUFFER hBIdxField FOR TABLE '_Index-Field'.

    /* Assigning buffers */
    hFile:SET-BUFFERS (hBFile).
    hField:SET-BUFFERS (hBField).
    hIndex:SET-BUFFERS (hBIndex).
    hTrig:SET-BUFFERS (hBTrig).
    hIdxField:SET-BUFFERS (hBIdxField).

    /* Getting buffer fields */
    ASSIGN hDump      = hBFile:BUFFER-FIELD ('_Dump-Name')
           hTable     = hBFile:BUFFER-FIELD ('_File-Name')
           hTableDesc = hBFile:BUFFER-FIELD ('_Desc')
           hPrime     = hBFile:BUFFER-FIELD ('_Prime-Index')
           hOrder     = hBField:BUFFER-FIELD ('_Order')
           hFieldName = hBField:BUFFER-FIELD ('_Field-Name')
           hDataType  = hBField:BUFFER-FIELD ('_Data-Type')
           hMandatory = hBField:BUFFER-FIELD ('_Mandatory')
           hFormat    = hBField:BUFFER-FIELD ('_Format')
           hExtent    = hBField:BUFFER-FIELD ('_Extent')
           hInitial   = hBField:BUFFER-FIELD ('_Initial')
           hLabel     = hBField:BUFFER-FIELD ('_Label')
           hFieldDesc = hBField:BUFFER-FIELD ('_Desc')
           hEvent     = hBTrig:BUFFER-FIELD ('_Event')
           hProc      = hBTrig:BUFFER-FIELD ('_Proc-Name')
           hOverride  = hBTrig:BUFFER-FIELD ('_Override')
           hIndexName = hBIndex:BUFFER-FIELD ('_Index-Name')
           hUnique    = hBIndex:BUFFER-FIELD ('_Unique')
           hActive    = hBIndex:BUFFER-FIELD ('_Active')
           hIndexDesc = hBIndex:BUFFER-FIELD ('_Desc')
           hFieldRecID = hBIdxField:BUFFER-FIELD ('_Field-recid').
    hFile:QUERY-PREPARE ('FOR EACH _File').
    hFile:QUERY-OPEN.
    hFile:GET-FIRST.
    REPEAT:
        IF hFile:QUERY-OFF-END THEN LEAVE.
        OUTPUT TO VALUE (SESSION:PARAMETER + "/" + (IF hDump:BUFFER-VALUE EQ ? THEN hTable:BUFFER-VALUE ELSE hDump:BUFFER-VALUE) + '.html').
        /* HTML header */        
        PUT UNFORMATTED "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">" SKIP.
	PUT UNFORMATTED "<html>" SKIP.
	PUT UNFORMATTED "<head>" SKIP.
        PUT UNFORMATTED "<title>" + hDump:BUFFER-VALUE + "</title>" SKIP.
        PUT UNFORMATTED "<meta http-equiv=""Content-Type"" content=""text/html; charset=ISO-8859-1""/>" SKIP.
        PUT UNFORMATTED "<link href=""style.css"" rel=""stylesheet"" type=""text/css"" media=""screen""/>" SKIP.
        PUT UNFORMATTED "</head>" SKIP (2).
        PUT UNFORMATTED "<body>" SKIP.
	    /* Table summary */
	RUN TableSummary ('WHERE _File._File-Number GT 0 AND NOT (_File._File-Name BEGINS "SYS") BY _File._File-Name', hTable:BUFFER-VALUE, 'Tables').
	&IF DEFINED (SYS_TAB) &THEN
	    RUN TableSummary ('WHERE _File._File-Name BEGINS "SYS" BY _File._File-Name', hTable:BUFFER-VALUE, 'System tables').
	&ENDIF
	&IF DEFINED (INTERNAL_TABS) &THEN
	    RUN TableSummary ('WHERE _File._File-Number LE 0', hTable:BUFFER-VALUE, 'Internal tables').
	&ENDIF
	
	PUT UNFORMATTED "<h1>" + hTable:BUFFER-VALUE + "</h1>" SKIP.
        IF (hTableDesc:BUFFER-VALUE NE ?) THEN 
            PUT UNFORMATTED "<h3>" + hTableDesc:BUFFER-VALUE + "</h3>" SKIP(2).

	PUT UNFORMATTED "<div id=""Lists"">" SKIP.
        
	/* Beginning of table */
        PUT UNFORMATTED "<div id=""FieldList"">" SKIP.
	PUT UNFORMATTED "<h1>Fields list</h1>" SKIP.
        ASSIGN cQuery = 'FOR EACH _Field WHERE _Field._File-recid = '
               cQuery = cQuery + STRING (hBFile:RECID) + ' BY _Field._Field-Name'.
        hField:QUERY-PREPARE (cQuery).
        hField:QUERY-OPEN.
        hField:GET-FIRST.
        REPEAT:
            IF hField:QUERY-OFF-END THEN LEAVE.
            PUT UNFORMATTED "<p>".
            PUT UNFORMATTED "<a href=""#" + hOrder:BUFFER-VALUE + """>" + hFieldName:BUFFER-VALUE + "</a>".
            PUT UNFORMATTED "</p>" SKIP.
            hField:GET-NEXT (NO-LOCK).
        END.
        hField:QUERY-CLOSE.
        PUT UNFORMATTED "</div>" SKIP(2).

        /* Creating trigger retrieval query */
        PUT UNFORMATTED "<div id=""TrigList"">" SKIP.
	PUT UNFORMATTED "<h1>Triggers list</h1>" SKIP.
        ASSIGN cQuery = 'FOR EACH _File-Trig WHERE _File-Trig._File-recid = ' + STRING (hBFile:RECID).
        hTrig:QUERY-PREPARE (cQuery).
        hTrig:QUERY-OPEN.
        hTrig:GET-FIRST.
        REPEAT:
            IF hTrig:QUERY-OFF-END THEN LEAVE.
	PUT UNFORMATTED "<p>".
            PUT UNFORMATTED "<a href=""#" + hEvent:BUFFER-VALUE + """>" + hEvent:BUFFER-VALUE + "</a>".
            PUT UNFORMATTED "</p>" SKIP.
            hTrig:GET-NEXT (NO-LOCK).
        END.
        hTrig:QUERY-CLOSE.
        PUT UNFORMATTED  "</div>" SKIP (2).

        /* Creating index retrieval query */
	PUT UNFORMATTED "<div id=""IdxList"">" SKIP.
	PUT UNFORMATTED "<h1>Indexes list</h1>" SKIP.
        ASSIGN cQuery = 'FOR EACH _Index WHERE _Index._File-recid EQ ' + STRING (hBFile:RECID).
        hIndex:QUERY-PREPARE (cQuery).
        hIndex:QUERY-OPEN.
        hIndex:GET-FIRST.
        REPEAT:
            IF hIndex:QUERY-OFF-END THEN LEAVE.
	    PUT UNFORMATTED "<p>".
            PUT UNFORMATTED "<a href=""#" + hIndexName:BUFFER-VALUE + """>" + hIndexName:BUFFER-VALUE + "</a>" SKIP.
            PUT UNFORMATTED "</p>" SKIP.
            hIndex:GET-NEXT (NO-LOCK).
        END.
        hIndex:QUERY-CLOSE.
        PUT UNFORMATTED  "</div>" SKIP(2).
        PUT UNFORMATTED "</div>" SKIP.
	
        /* Tableau HTML contenant différentes informations sur les champs de la table PROGRESS*/
	PUT UNFORMATTED "<div id=""Detail"">" SKIP.
        PUT UNFORMATTED "<table class=""Internal"">" SKIP.
        PUT UNFORMATTED "<tr><th colspan=""8"">Fields</th></tr>" SKIP.
        PUT UNFORMATTED "<tr>" SKIP.
        PUT UNFORMATTED "<th>Order</th>" SKIP.
        PUT UNFORMATTED "<th>Field Name</th>" SKIP.
        PUT UNFORMATTED "<th>Datatype</th>" SKIP.
        PUT UNFORMATTED "<th>Mandatory</th>" SKIP.
        PUT UNFORMATTED "<th>Format</th>" SKIP.
        PUT UNFORMATTED "<th>Extent</th>" SKIP.
        PUT UNFORMATTED "<th>Default</th>" SKIP.
        PUT UNFORMATTED "<th>Label</th>" SKIP.
        PUT UNFORMATTED "</tr>" SKIP.
	PUT UNFORMATTED "<tr>" SKIP.
	PUT UNFORMATTED "<th colspan=""8"">Description</th>" SKIP.
        PUT UNFORMATTED "</tr>" SKIP.
        ASSIGN cQuery = 'FOR EACH _Field WHERE _Field._File-recid = '
               cQuery = cQuery + STRING (hBFile:RECID) + ' BY _Field._Order'.
        hField:QUERY-PREPARE (cQuery).
        hField:QUERY-OPEN.
        hField:GET-FIRST.
	lEven = TRUE.
        REPEAT:
            IF hField:QUERY-OFF-END THEN LEAVE.
            PUT UNFORMATTED "<tr>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """><a name=""" + hOrder:BUFFER-VALUE + """>" + hOrder:BUFFER-VALUE + "</a></td>" SKIP. 
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>" + hFieldName:BUFFER-VALUE + "</td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>" + hDataType:BUFFER-VALUE + "</td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>" + STRING (hMandatory:BUFFER-VALUE) + "</td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>" + STRING (hFormat:BUFFER-VALUE) + "</td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>" + STRING (hExtent:BUFFER-VALUE) + "</td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>".
            IF (TRIM (STRING (hInitial:BUFFER-VALUE)) EQ '') THEN
                PUT UNFORMATTED "&nbsp;".
            ELSE
                PUT UNFORMATTED STRING (hInitial:BUFFER-VALUE).
            PUT UNFORMATTED "</td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>".
            IF (TRIM (STRING (hLabel:BUFFER-VALUE)) EQ '') THEN
                PUT UNFORMATTED "&nbsp;".
            ELSE
                PUT UNFORMATTED STRING (hLabel:BUFFER-VALUE).
            PUT UNFORMATTED "</td>" SKIP.
	    PUT UNFORMATTED "</tr>" SKIP.
	    PUT UNFORMATTED "<tr>" SKIP.
            PUT UNFORMATTED "<td colspan=""8"" class=""Field" + STRING(lEven, "Even/Odd") + """>".
            IF (TRIM (STRING (hFieldDesc:BUFFER-VALUE)) EQ '') THEN
                PUT UNFORMATTED "&nbsp;".
            ELSE
                PUT UNFORMATTED STRING (hFieldDesc:BUFFER-VALUE).
            PUT UNFORMATTED "</td></tr>" SKIP.
            hField:GET-NEXT (NO-LOCK).
	    lEven = NOT lEven.
        END.
        hField:QUERY-CLOSE.
        PUT UNFORMATTED "</table>" SKIP(2).
        
        PUT UNFORMATTED "<table class=""Internal"">" SKIP.
        PUT UNFORMATTED "<tr><th colspan=""3"">Triggers</th></tr>" SKIP.
        PUT UNFORMATTED "<tr>" SKIP.
        PUT UNFORMATTED "<th>Event</th>" SKIP.
        PUT UNFORMATTED "<th>Procedure</th>" SKIP.
        PUT UNFORMATTED "<th>Overridable ?</th></tr>" SKIP.
        ASSIGN cQuery = 'FOR EACH _File-Trig WHERE _File-Trig._File-recid = ' + STRING (hBFile:RECID).
        hTrig:QUERY-PREPARE (cQuery).
        hTrig:QUERY-OPEN.
        hTrig:GET-FIRST.
	lEven = TRUE.
        REPEAT:
            IF hTrig:QUERY-OFF-END THEN LEAVE.
            PUT UNFORMATTED "<tr>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>".
	    PUT UNFORMATTED "<a name=""" + hEvent:BUFFER-VALUE + """>" + hEvent:BUFFER-VALUE + "</a></td>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>".
	    PUT UNFORMATTED hProc:BUFFER-VALUE + "</TD>" SKIP.
            PUT UNFORMATTED "<td class=""Field" + STRING(lEven, "Even/Odd") + """>".
	    PUT UNFORMATTED STRING (hOverride:BUFFER-VALUE) + "</td>" SKIP.
            PUT UNFORMATTED "</tr>" SKIP.
            hTrig:GET-NEXT (NO-LOCK).
	    lEven = NOT lEven.
        END.
        hTrig:QUERY-CLOSE.
        PUT UNFORMATTED "</table>" SKIP (2).
                
        /* Tableau HTML contenant la description des index de la table PROGRESS*/
        PUT UNFORMATTED "<table class=""Internal"">".
        PUT UNFORMATTED "<tr><th colspan=""4"">Indexes</th></tr>" SKIP.
        PUT UNFORMATTED "<tr>" SKIP.
        PUT UNFORMATTED "<th>Flags</th>" SKIP.
        PUT UNFORMATTED "<th>Index name</th>" SKIP.
        PUT UNFORMATTED "<th>Fields name</th>" SKIP.
        PUT UNFORMATTED "<th>Description</th>" SKIP.
        PUT UNFORMATTED "</tr>" SKIP.
        ASSIGN cQuery = 'FOR EACH _Index WHERE _Index._File-recid EQ ' + STRING (hBFile:RECID) + ' BY _Index._Unique DESCENDING BY _Index._Index-Name'.
        hIndex:QUERY-PREPARE (cQuery).
        hIndex:QUERY-OPEN.
        hIndex:GET-FIRST.
	lEven = TRUE.
        REPEAT:
            IF hIndex:QUERY-OFF-END THEN LEAVE.
            PUT UNFORMATTED "<tr><td valign=""top"" class=""Field" + STRING(lEven, "Even/Odd") + """>" SKIP.
            IF (hPrime:BUFFER-VALUE EQ hBIndex:RECID) THEN
                PUT UNFORMATTED "Primary<br/>".
            IF hUnique:BUFFER-VALUE THEN
                PUT UNFORMATTED "Unique<br/>".
            IF NOT (hActive:BUFFER-VALUE) THEN
                PUT UNFORMATTED "Inactive<br/>".
            PUT UNFORMATTED "&nbsp;</td>" SKIP.
            PUT UNFORMATTED "<td valign=""top"" class=""Field" + STRING(lEven, "Even/Odd") + """>".
            PUT UNFORMATTED "<a name=""" + hIndexName:BUFFER-VALUE + """>" + hIndexName:BUFFER-VALUE + "</a></td>" SKIP.
            PUT UNFORMATTED "<td valign=""top"" class=""Field" + STRING(lEven, "Even/Odd") + """>".
            ASSIGN cQuery = 'FOR EACH _Index-Field WHERE _Index-Field._Index-recid EQ ' + STRING (hBIndex:RECID).
            hIdxField:QUERY-PREPARE (cQuery).
            hIdxField:QUERY-OPEN.
            hIdxField:GET-FIRST.
            REPEAT:
                IF hIdxField:QUERY-OFF-END THEN LEAVE.
                ASSIGN cQuery = 'FOR EACH _Field WHERE RECID (_Field) EQ ' + STRING (hFieldRecID:BUFFER-VALUE).
                hField:QUERY-PREPARE (cQuery).
                hField:QUERY-OPEN.
                hField:GET-FIRST.
                IF (NOT hField:QUERY-OFF-END) THEN DO:
                    PUT UNFORMATTED hFieldName:BUFFER-VALUE "<br/>" SKIP.
                END.
                hField:QUERY-CLOSE.
                hIdxField:GET-NEXT (NO-LOCK).
            END.
            hIdxField:QUERY-CLOSE.
	    PUT UNFORMATTED "</td>" SKIP.
            PUT UNFORMATTED "<td valign=""top"" class=""Field" + STRING(lEven, "Even/Odd") + """>".
            IF (TRIM (STRING (hIndexDesc:BUFFER-VALUE)) EQ '') THEN
                PUT UNFORMATTED "&nbsp;".
            ELSE
                PUT UNFORMATTED STRING (hIndexDesc:BUFFER-VALUE).
            PUT UNFORMATTED "</td></tr>" SKIP.
            hIndex:GET-NEXT (NO-LOCK).
	    lEven = NOT lEven.
        END.
        hIndex:QUERY-CLOSE.
        PUT UNFORMATTED "</table>" SKIP(2).
	PUT UNFORMATTED "</div>" SKIP.
        
        /* Fin du document HTML de présentation de la table PROGRESS */
        PUT UNFORMATTED "</body>" SKIP.
        PUT UNFORMATTED "</html>" SKIP.
        OUTPUT CLOSE.
        hFile:GET-NEXT (NO-LOCK).
    END.
END PROCEDURE.

RUN DetailedTable.
QUIT.

