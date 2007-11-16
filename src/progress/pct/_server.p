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

DEFINE VARIABLE portNumber AS CHARACTER  NO-UNDO INITIAL ?.

ASSIGN portNumber = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'portNumber').
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
QUIT.

/* Connects ANT session */
PROCEDURE ConnectToServer.
    
    IF (portNumber EQ ?) THEN
        RETURN ERROR "No port number defined. Please log a bug".
    ASSIGN aOk = hSocket:CONNECT("-H localhost -S " + portNumber) NO-ERROR.
    if NOT aOK THEN
        RETURN ERROR "Connection to ANT failed on port " + portNumber.
    ELSE 
        RUN SendConnectionGreeting.

END PROCEDURE.

/* Sends greeting message and declaring socket callback */
PROCEDURE SendConnectionGreeting:
    DEFINE VARIABLE greeting AS CHARACTER NO-UNDO.
  
    hSocket:SET-READ-RESPONSE-PROCEDURE("ReceiveCommand").
    ASSIGN greeting = "Hello from _server.p~n END.~n".
    RUN WriteToSocket(greeting).
END.

/* Handles writing of response data back to the eclipse session */
PROCEDURE WriteToSocket:
    DEFINE INPUT PARAMETER packet AS CHARACTER NO-UNDO.
  
    DEFINE VARIABLE packetBuffer AS MEMPTR NO-UNDO.

    IF VALID-HANDLE(hSocket) THEN DO:
        IF hSocket:CONNECTED() THEN DO:
	        SET-SIZE(packetBuffer) = LENGTH(packet) + 1.
	        PUT-STRING(packetBuffer, 1, LENGTH(packet)) = packet.
	        hSocket:WRITE(packetBuffer, 1, LENGTH(packet)).
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
        RUN WriteToSocket("ERR:Unable to execute " + cCmd + "~nEND.~n").
        RETURN ''.
    END.
        
    DontQuit:
    DO ON ERROR UNDO, RETRY ON STOP UNDO, RETRY ON ENDKEY UNDO, RETRY ON QUIT UNDO, RETRY:
        IF RETRY THEN DO:
            ASSIGN cRet = "ERR:".
            LEAVE DontQuit.
        END.
        
        RUN VALUE(cCmd) IN hProc (INPUT cPrm).
        ASSIGN cRet = RETURN-VALUE.
        ASSIGN cRet = "OK:" + (IF cRet EQ ? THEN "" ELSE cRet).
    END.
        
    ASSIGN cRet = cRet + "~nEND.~n".
    RUN WriteToSocket(cRet).
    
END PROCEDURE.

/* This will terminate the infinite loop of waiting for commands and
 * quit out of the Progress session */
PROCEDURE QUIT:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
    
    ASSIGN aOk = FALSE.
    APPLY "close" TO THIS-PROCEDURE.
    RETURN "TERMINATED.".

END PROCEDURE.

/* Changes PROPATH */
PROCEDURE PROPATH:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.

    IF cPrm <> "" THEN PROPATH = cPrm + PROPATH.
    RETURN "OK:" + PROPATH.

END PROCEDURE.


/* Connect to databases */
PROCEDURE Connect :
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE c1          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cStatus     AS CHARACTER  NO-UNDO.
  
  CONNECT VALUE(cPrm) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN
      ASSIGN cStatus = "ERR:" + ERROR-STATUS:GET-MESSAGE(1).
  ELSE
      ASSIGN cStatus = "OK:".
      
  RETURN cStatus.
  
END PROCEDURE.


/* Run a particular procedure persistently */
PROCEDURE launch:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  
    DEFINE VARIABLE cStatus AS CHARACTER  NO-UNDO.
    
    RUN VALUE(cPrm) PERSISTENT NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
        ASSIGN cStatus = "ERR:" + ERROR-STATUS:GET-MESSAGE(1).
    ELSE
        ASSIGN cStatus = "OK:".
  
    RETURN cStatus.
  
END PROCEDURE.


