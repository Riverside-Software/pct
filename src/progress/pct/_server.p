/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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

/**
 * This is a stripped down and customized version of _server.p used in OEA.
 */
 
DEFINE VARIABLE hSocket AS HANDLE  NO-UNDO.
DEFINE VARIABLE aOk     AS LOGICAL NO-UNDO.

DEFINE TEMP-TABLE ttMsgs NO-UNDO
 FIELD msgLine AS CHARACTER.

DEFINE VARIABLE portNumber AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE threadNumber AS INTEGER NO-UNDO INITIAL -1.

log-manager:logfile-name = "c:/truc.txt".

ASSIGN portNumber = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'portNumber').
IF (portNumber EQ ?) THEN RETURN '17'.
ASSIGN threadNumber = INTEGER(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'threadNumber')) NO-ERROR.
IF (threadNumber EQ -1) THEN RETURN '18'.

CREATE SOCKET hSocket.
RUN ConnectToServer NO-ERROR.

/* Now that we have connected, loop forever listening for data from the server.
 * When we receive data, pass it to the read handler and then start looping again. */
EternalLoop:
DO WHILE aOk:
    IF VALID-HANDLE(hSocket) THEN DO:
        WAIT-FOR READ-RESPONSE OF hSocket.
    END.
END.
RETURN '0'.
/* QUIT. */

/* Connects ANT session */
PROCEDURE ConnectToServer.
    
    /* IF (portNumber EQ ?) THEN
        RETURN ERROR "No port number defined. Please log a bug". */
    ASSIGN aOk = hSocket:CONNECT("-H localhost -S " + portNumber) NO-ERROR.
    if NOT aOK THEN
        RETURN ERROR "Connection to ANT failed on port " + portNumber.
    ELSE DO:
        hSocket:SET-READ-RESPONSE-PROCEDURE("ReceiveCommand").
        DEFINE VARIABLE packet AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE packetBuffer AS MEMPTR      NO-UNDO.
        packet = STRING(threadNumber) + "~n".
        COPY-LOB FROM packet TO packetBuffer.
        hSocket:WRITE(packetBuffer, 1, GET-SIZE(packetBuffer)).
        SET-SIZE(packetBuffer) = 0.    
    END.
        /* RUN SendConnectionGreeting. */
END PROCEDURE.

/* Sends greeting message and declaring socket callback */
PROCEDURE SendConnectionGreeting:
    DEFINE VARIABLE greeting AS CHARACTER NO-UNDO.
  
    hSocket:SET-READ-RESPONSE-PROCEDURE("ReceiveCommand").
    CREATE ttMsgs.
    assign ttMsgs.msgLine = "Connected".
    /* ASSIGN greeting = "Hello from _server.p~n END.~n". */
    RUN WriteToSocket(/*greeting*/ TRUE, "Init", "").
END.

/* Handles writing of response data back to the eclipse session */
PROCEDURE WriteToSocket:
    DEFINE INPUT PARAMETER plOK AS LOGICAL NO-UNDO.
    DEFINE INPUT PARAMETER pcCmd AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcPrm AS CHARACTER   NO-UNDO.

    /* DEFINE INPUT PARAMETER packet AS CHARACTER NO-UNDO. */
  
    DEFINE VARIABLE packetBuffer AS MEMPTR NO-UNDO.
	/*DEFINE VARIABLE packetLength AS INTEGER NO-UNDO.*/
	define variable packet as longchar no-undo.
	define variable lfirst as logical no-undo.
	
    packet = string(threadNumber) + ":" + (if plok then "OK" else "ERR") + ":" + pcCmd + ":" + pcPrm + "~n".
	for each ttmsgs:
	  /* if (lfirst) then do:
	    packet = string(threadNumber) + ":" + (if plok then "OK" else "ERR") + ":" + pcCmd + ":" + ttMsgs.msgLine + "~n".
	    lfirst = false.
	  end.
	  else do: */
	    packet = packet + string(threadNumber) + ":MSG:" + ttMsgs.msgLine + "~n".
	  /* end. */
	end.
	packet = packet + string(threadNumber) + ":END~n".

	copy-lob from packet to packetBuffer. 
	/*log-manager:write-message("ecriture du paquet " + packet).*/
	/*ASSIGN packetLength = LENGTH(packet) + LENGTH(STRING(threadNumber)) + 2.*/
    IF VALID-HANDLE(hSocket) THEN DO:
        IF hSocket:CONNECTED() THEN DO:
	        /* SET-SIZE(packetBuffer) = packetLength.
	        PUT-STRING(packetBuffer, 1, packetLength - 1) = STRING(threadNumber) + ':' + packet. */
            LOG-MANAGER:WRITE-MESSAGE(string(threadNumber) + " Avant écriture socket").
	        hSocket:WRITE(packetBuffer, 1, GET-SIZE(packetBuffer)).
            LOG-MANAGER:WRITE-MESSAGE(string(threadNumber) + " Après écriture socket").
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
    DEFINE VARIABLE iBytes  AS INTEGER.

    IF NOT SELF:CONNECTED() THEN DO:
        RETURN ERROR "Socket disconnected".
    END.

    ASSIGN iBytes = SELF:GET-BYTES-AVAILABLE()
           SET-SIZE(mReadBuffer) = iBytes
           aOk  = SELF:READ(mReadBuffer, 1, iBytes)
           cCmd = GET-STRING(mReadBuffer, 1, iBytes)
           SET-SIZE(mReadBuffer) = 0.
    ASSIGN cCmd = REPLACE(cCmd, CHR(13), '').  /* Strip CR */

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
    
    EMPTY TEMP-TABLE ttMsgs.

    DEFINE VARIABLE cRet  AS CHARACTER  NO-UNDO.
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
        CREATE ttmsgs.
        ASSIGN ttmsgs.msgline = "Unable to execute procedure".
        RUN writeToSocket(FALSE, cCmd, "").
        /*RUN WriteToSocket("ERR:Unable to execute " + cCmd + "~nEND.~n").*/
        RETURN ''.
    END.
        
    DEFINE VARIABLE lOK AS LOGICAL     NO-UNDO.

    DontQuit:
    DO ON ERROR UNDO, RETRY ON STOP UNDO, RETRY ON ENDKEY UNDO, RETRY ON QUIT UNDO, RETRY:
        IF RETRY THEN DO:
            /*ASSIGN cRet = "ERR:".*/
            ASSIGN lOK = FALSE.
            CREATE ttmsgs.
            ASSIGN ttmsgs.msgline = "Error during execution".
            LEAVE DontQuit.
        END.
        LOG-MANAGER:WRITE-MESSAGE(STRING(threadNumber) + " avant exec commande " + ccmd).
        RUN VALUE(cCmd) IN hProc (INPUT cPrm, OUTPUT lOK).
        LOG-MANAGER:WRITE-MESSAGE(STRING(threadNumber) + " apres exec commande " + ccmd).
        /*ASSIGN cRet = RETURN-VALUE.
        ASSIGN cRet = "OK:" + (IF cRet EQ ? THEN "" ELSE cRet).*/
    END.
        
    /*ASSIGN cRet = cRet + "~nEND.~n".*/
    RUN WriteToSocket(lOK, cCmd, cprm).
    
END PROCEDURE.

/* This will terminate the infinite loop of waiting for commands and
 * quit out of the Progress session */
PROCEDURE QUIT:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
	define output parameter opok as logical no-undo.
	
	opok = true.    
    ASSIGN aOk = FALSE.
    APPLY "close" TO THIS-PROCEDURE.
    RETURN "TERMINATED.".

END PROCEDURE.

/* Changes PROPATH */
PROCEDURE PROPATH:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
	define output parameter opok as logical no-undo.

opok = true.
    IF cPrm <> "" THEN PROPATH = cPrm + PROPATH.
    RETURN .

END PROCEDURE.


/* Connect to databases */
PROCEDURE Connect :
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
	define output parameter opok as logical no-undo.
  
  
    CONNECT VALUE(cPrm) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN do:
        opok = false.
      create ttmsgs.
      assign ttmsgs.msgline = error-status:get-message(1).
    end.
    ELSE do:
      opOk = true.
    end.
      
  RETURN .
  
END PROCEDURE.


/* Run a particular procedure persistently */
PROCEDURE launch:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK AS LOGICAL     NO-UNDO.
  
    
    RUN VALUE(cPrm) PERSISTENT NO-ERROR.
    IF ERROR-STATUS:ERROR THEN do:
        ASSIGN opOK = false.
        create ttmsgs.
        assign ttmsgs.msgline = error-status:get-message(1).
    end.
    ELSE do:
        opOk = true.
    end.

    RETURN .
  
END PROCEDURE.


PROCEDURE logError:
    DEFINE INPUT  PARAMETER ipMsg AS CHARACTER   NO-UNDO.

    CREATE ttMsgs.
    ASSIGN ttMsgs.msgLine = ipMsg.

END.
