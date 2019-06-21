/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

/**
 * This is a stripped down and customized version of _server.p used in OEA.
 */
 
DEFINE VARIABLE hSocket AS HANDLE  NO-UNDO.
DEFINE VARIABLE aOk     AS LOGICAL NO-UNDO.
DEFINE VARIABLE aResp   AS LOGICAL NO-UNDO.

/* TODO Handle warning/error messages */
DEFINE TEMP-TABLE ttMsgs NO-UNDO
 FIELD msgNum  AS INTEGER
 FIELD level   AS INTEGER
 FIELD msgLine AS CHARACTER
 INDEX ttMsgs-PK IS PRIMARY UNIQUE msgNum.

DEFINE VARIABLE portNumber   AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE threadNumber AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE currentMsg   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE dbNum        AS INTEGER    NO-UNDO INITIAL 1.

ASSIGN portNumber = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'portNumber').
IF (portNumber EQ ?) THEN RETURN '17'.

/* PROCEDURE GetCurrentProcessId EXTERNAL "KERNEL32.DLL":
    DEFINE RETURN PARAMETER intProcessHandle AS LONG.
END PROCEDURE.

DEFINE VARIABLE pid AS INTEGER NO-UNDO.
LOG-MANAGER:LOGFILE-NAME = SESSION:TEMP-DIRECTORY + "/_server-" + STRING(portNumber) + ".txt".
RUN GetCurrentProcessId (OUTPUT pid). */

CREATE SOCKET hSocket.
RUN ConnectToServer NO-ERROR.

/* Now that we have connected, loop forever listening for data from the server.
 * When we receive data, pass it to the read handler and then start looping again. */
EternalLoop:
DO WHILE aOk:
    IF VALID-HANDLE(hSocket) THEN DO:
        ASSIGN aResp = FALSE.
        WAIT-FOR READ-RESPONSE OF hSocket PAUSE 10.
        IF NOT aResp THEN LEAVE EternalLoop.
    END.
END.
RETURN '0'.

/* Connects ANT session */
PROCEDURE ConnectToServer.
    
    DEFINE VARIABLE packet       AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE packetBuffer AS MEMPTR      NO-UNDO.
    
    ASSIGN aOk = hSocket:CONNECT("-H localhost -S " + portNumber) NO-ERROR.
    if NOT aOK THEN DO:
        RETURN ERROR "Connection to ANT failed on port " + portNumber.
    END.
    ELSE DO:
        hSocket:SET-READ-RESPONSE-PROCEDURE("ReceiveCommand").
        packet = STRING(threadNumber) + "~n".
        COPY-LOB FROM packet TO packetBuffer.
        hSocket:WRITE(packetBuffer, 1, GET-SIZE(packetBuffer)).
        SET-SIZE(packetBuffer) = 0.    
    END.

END PROCEDURE.

/* Handles writing of response data back to the eclipse session */
/* First line is in this format : */
/* [OK|ERR]:Custom_response */
/* Following lines are in this format */
/* MSG:message_line */
/* Last line is in this format */
/* END */
/* Message lines are read from the ttMsgs temp-table */
/* This temp-table is emptied when a new command is run */
PROCEDURE WriteToSocket:
    DEFINE INPUT  PARAMETER plOK   AS LOGICAL NO-UNDO.
    DEFINE INPUT  PARAMETER pcResp AS CHARACTER NO-UNDO.

    DEFINE VARIABLE packetBuffer AS MEMPTR   NO-UNDO.
    DEFINE VARIABLE packet       as longchar no-undo.

    ASSIGN packet = (IF plok THEN "OK" ELSE "ERR") + ":" + pcResp + "~n".
    FOR EACH ttMsgs:
    ASSIGN packet = packet + "MSG:" + STRING(ttMsgs.level) + ":" + ttMsgs.msgLine + "~n".
    END.
    ASSIGN packet = packet + "END~n".

    COPY-LOB FROM packet TO packetBuffer.
    IF VALID-HANDLE(hSocket) THEN DO:
        IF hSocket:CONNECTED() THEN DO:
            hSocket:WRITE(packetBuffer, 1, GET-SIZE(packetBuffer)).
            SET-SIZE(packetBuffer) = 0.
        END.
        ELSE DO:
            RUN Quit("").
        END.
    END.
END.

/* Respond to events from ANT */
PROCEDURE ReceiveCommand:
    DEFINE VARIABLE cCmd AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i1   AS INTEGER  NO-UNDO.
    DEFINE VARIABLE mReadBuffer AS MEMPTR NO-UNDO.
    DEFINE VARIABLE iBytes  AS INTEGER NO-UNDO.

    IF NOT SELF:CONNECTED() THEN DO:
        RETURN ERROR "Socket disconnected".
    END.

    ASSIGN iBytes = SELF:GET-BYTES-AVAILABLE()
           SET-SIZE(mReadBuffer) = iBytes
           aOk  = SELF:READ(mReadBuffer, 1, iBytes)
           cCmd = GET-STRING(mReadBuffer, 1, iBytes)
           SET-SIZE(mReadBuffer) = 0.
    ASSIGN cCmd = REPLACE(cCmd, CHR(13), '').  /* Strip CR */
    ASSIGN aResp = TRUE.

    /* Check if a full command */
    ASSIGN cCmd = (IF SELF:PRIVATE-DATA EQ ? THEN "" ELSE SELF:PRIVATE-DATA) + cCmd
           i1   = INDEX(cCmd, CHR(10)).

    IF NOT aOk THEN DO:
        APPLY "close" TO THIS-PROCEDURE.
        RETURN ERROR "Something bad happened".
    END.

    IF (i1 > 0) THEN DO:
        RUN executeCmd(TRIM(SUBSTRING(cCmd, 1, i1 - 1))).
        SELF:PRIVATE-DATA = (IF LENGTH(cCmd) GT i1 THEN SUBSTRING(cCmd, i1 + 1) ELSE "").
    END.
    ELSE
        SELF:PRIVATE-DATA = cCmd.

END PROCEDURE.

/* If a command was received from eclipse then process it here and
 * call the appropriate procedure */
PROCEDURE executeCmd:
    DEFINE INPUT PARAMETER cCmd AS CHARACTER NO-UNDO.
    
    /* LOG-MANAGER:WRITE-MESSAGE(STRING(pid) + " -- Executing " + cCmd). */

    EMPTY TEMP-TABLE ttMsgs.

    DEFINE VARIABLE cPrm  AS CHARACTER  NO-UNDO INITIAL "".
    DEFINE VARIABLE hProc AS HANDLE     NO-UNDO.
    DEFINE VARIABLE idx   AS INTEGER    NO-UNDO.

    ASSIGN idx = INDEX(cCmd, ' ').
    IF (idx NE 0) THEN DO:
        ASSIGN cPrm = TRIM(SUBSTRING(cCmd, idx + 1))
               cCmd = TRIM(SUBSTRING(cCmd, 1, idx)).
    END.

    /* Checks if internal method */
    IF (CAN-DO(THIS-PROCEDURE:INTERNAL-ENTRIES, cCmd)) THEN DO:
        ASSIGN hProc = THIS-PROCEDURE.
    END.
    ELSE DO:
        /* Checking super procedures */
        ASSIGN hProc = SESSION:FIRST-PROCEDURE.
        ProcSearch:
        DO WHILE (VALID-HANDLE(hProc) AND NOT CAN-DO(hProc:INTERNAL-ENTRIES, cCmd)):
            ASSIGN hProc = hProc:NEXT-SIBLING.
            IF (hProc EQ ?) THEN DO:
                LEAVE ProcSearch.
            END.
        END.
    END.
    IF (hProc EQ ?) OR (NOT VALID-HANDLE(hProc)) THEN DO:
        RUN logError ("Unable to execute procedure").
        RUN writeToSocket(FALSE, "").
        RETURN ''.
    END.
        
    DEFINE VARIABLE lOK  AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE cMsg AS CHARACTER NO-UNDO.

    DontQuit:
    DO ON ERROR UNDO, RETRY ON STOP UNDO, RETRY ON ENDKEY UNDO, RETRY ON QUIT UNDO, RETRY:
        IF RETRY THEN DO:
            ASSIGN lOK = FALSE.
            RUN logError ("Error during execution").
            LEAVE DontQuit.
        END.
        RUN VALUE(cCmd) IN hProc (INPUT cPrm, OUTPUT lOK, OUTPUT cMsg).
    END.
        
    RUN WriteToSocket(lOK, cMsg).
    
END PROCEDURE.

PROCEDURE log PRIVATE:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER ipLvl AS INTEGER     NO-UNDO.

    ASSIGN currentMsg = currentMsg + 1.
    CREATE ttMsgs.
    ASSIGN ttMsgs.msgNum  = currentMsg
           ttMsgs.level   = ipLvl
           ttMsgs.msgLine = ipMsg.
END.

PROCEDURE logError:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.

    RUN log (ipMsg, 0).
END.

PROCEDURE logWarning:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.

    RUN log (ipMsg, 1).
END.

PROCEDURE logInfo:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.

    RUN log (ipMsg, 2).
END.

PROCEDURE logVerbose:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.

    RUN log (ipMsg, 3).
END.

PROCEDURE logDebug:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.

    RUN log (ipMsg, 4).
END.

/* Commands to be executed from executeCmd */
/* Each command should have an input param as char (command parameters) and */
/* an output param as logical, to tell ANT if command was executed successfully or not */


/* This will terminate the infinite loop of waiting for commands and
 * quit out of the Progress session */
PROCEDURE QUIT:
    DEFINE INPUT  PARAMETER cPrm AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER opMsg AS CHARACTER NO-UNDO.

    ASSIGN opok = TRUE
           aOk  = FALSE.
    APPLY "close" TO THIS-PROCEDURE.

END PROCEDURE.

/* Changes PROPATH */
PROCEDURE PROPATH:
    DEFINE INPUT  PARAMETER cPrm AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER opMsg AS CHARACTER NO-UNDO.

    ASSIGN opOK = TRUE.
    IF cPrm <> "" THEN PROPATH = cPrm + PROPATH.

END PROCEDURE.

/* Connect to databases */
PROCEDURE Connect :
    DEFINE INPUT  PARAMETER cPrm AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER opMsg AS CHARACTER NO-UNDO.

    /* Input parameter is a pipe separated list */
    /* First entry is connection string, followed by aliases */
    /* Each alias is comma separated list, alias name and 1 if no-error, 0 w/o no-error */
    DEFINE VARIABLE connectStr AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE zz         AS INTEGER     NO-UNDO.

    ASSIGN connectStr = ENTRY(1, cPrm, '|').
    CONNECT VALUE(connectStr) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        ASSIGN opok = FALSE.
        RUN logError (ERROR-STATUS:GET-MESSAGE(1)).
    END.
    ELSE DO:
        ASSIGN opOk = TRUE.

        DbAliases:
        DO zz = 2 TO NUM-ENTRIES(cPrm, '|') ON ERROR UNDO DbAliases, RETRY DbAliases:
            IF RETRY THEN DO:
                RUN logError('Unable to create alias ' + ENTRY(1, ENTRY(zz, cPrm, '|'))).
                ASSIGN opOK = FALSE.
                DISCONNECT VALUE(ENTRY(2, cPrm, '|')).
                LEAVE DbAliases.
            END.

            IF ENTRY(2, ENTRY(zz, cPrm, '|')) EQ '1' THEN
                CREATE ALIAS VALUE(ENTRY(1, ENTRY(zz, cPrm, '|'))) FOR DATABASE VALUE(LDBNAME(dbNum)) NO-ERROR.
            ELSE
                CREATE ALIAS VALUE(ENTRY(1, ENTRY(zz, cPrm, '|'))) FOR DATABASE VALUE(LDBNAME(dbNum)).
        END.
        ASSIGN dbNum = dbNum + 1.
    END.
      
END PROCEDURE.

PROCEDURE setThreadNumber:
    DEFINE INPUT  PARAMETER cPrm AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER opMsg AS CHARACTER NO-UNDO.

    ASSIGN threadNumber = INTEGER(cPrm).
    ASSIGN opOK = TRUE.

END PROCEDURE.

FUNCTION getThreadNumber RETURNS INTEGER:
    RETURN threadNumber.
END FUNCTION.

/* Run a particular procedure persistently */
PROCEDURE launch:
    DEFINE INPUT  PARAMETER cPrm AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER opMsg AS CHARACTER  NO-UNDO.

    RUN VALUE(cPrm) PERSISTENT NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        ASSIGN opOK = FALSE.
        RUN logError (ERROR-STATUS:GET-MESSAGE(1)).
    END.
    ELSE DO:
        ASSIGN opOk = TRUE.
    END.
  
END PROCEDURE.


