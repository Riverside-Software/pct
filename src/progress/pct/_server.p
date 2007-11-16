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
DEFINE VARIABLE lEmpty  AS LOGICAL NO-UNDO.

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

/* Connexion à la session ANT */
PROCEDURE ConnectToServer.
    
    IF (portNumber EQ ?) THEN
        RETURN ERROR "No port number defined. Please log a bug".
    ASSIGN aOk = hSocket:CONNECT("-H localhost -S " + portNumber) NO-ERROR.
    if NOT aOK THEN
        RETURN ERROR "Connection to PCT failed on port " + portNumber.
    ELSE 
        RUN SendConnectionGreeting.

END PROCEDURE.

/* Envoi du message de bienvenue et ajout du callback */
PROCEDURE SendConnectionGreeting:
    DEFINE VARIABLE greeting AS CHARACTER NO-UNDO.
  
    hSocket:SET-READ-RESPONSE-PROCEDURE("ReceiveCommand").
    ASSIGN greeting = "Hello from _server.p~n END.~n".
    RUN WriteToSocket(greeting).
END.

/* handles writing of response data back to the eclipse session */
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
		    RUN QUIT ("").
  	    END.
    END.
END.

/* Respond to events from eclipse */
PROCEDURE ReceiveCommand:
  /* Read procedure for socket */
  DEFINE VARIABLE cCmd AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i1   AS INTEGER  NO-UNDO.
  DEFINE VARIABLE mReadBuffer AS MEMPTR NO-UNDO.
  DEFINE VARIABLE iBytes  AS INTEGER.

  IF NOT SELF:CONNECTED() THEN DO:
     RETURN ERROR "Socket disconnected".
  END.

  iBytes = SELF:GET-BYTES-AVAILABLE().
  SET-SIZE(mReadBuffer) = iBytes.
  aOk = SELF:READ (mReadBuffer,1,iBytes).
  cCmd = GET-STRING(mReadBuffer,1,iBytes).  /*Unmarshal data*/
  
  SET-SIZE(mReadBuffer) = 0.
  cCmd = REPLACE(cCmd,CHR(13),'').  /* strip linefeed and cr */
  
  /* Check if a full command */
  SELF:PRIVATE-DATA = "".
  cCmd = SELF:PRIVATE-DATA + cCmd.
  i1   = INDEX(cCmd,CHR(10)).
  
  IF NOT aOk THEN DO:
      APPLY "close" TO THIS-PROCEDURE.
      RETURN ERROR "Something bad happened.".
  END.

  IF i1 > 0 THEN DO:
    RUN executeCmd( TRIM(SUBSTRING(cCmd,1,i1 - 1)) ). 
    SELF:PRIVATE-DATA = ENTRY(1,SUBSTRING(cCmd,i1),CHR(10)).
  END.
  ELSE 
    SELF:PRIVATE-DATA = cCmd.

END PROCEDURE.

/* If a command was received from eclipse then process it here and
*  call the appropriate procedure
*/

PROCEDURE executeCmd:
  /* Read procedure for socket */
  DEFINE INPUT PARAMETER cCmd AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cRet AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cPrm AS CHARACTER NO-UNDO.
  def var hproc as handle no-undo.

    ERROR-STATUS:ERROR = FALSE NO-ERROR.
    DO ON ERROR UNDO, LEAVE ON STOP UNDO, LEAVE:
    ASSIGN
      lEmpty = FALSE
      cRet = "Command not found (" + cCmd + ")"
      cCmd = cCmd + " "
      cPrm = TRIM(SUBSTRING(cCmd,INDEX(cCmd,' ') + 1))
      cCmd = TRIM(ENTRY(1,cCmd,' '))
      cRet = "".
    /* MESSAGE cCmd "--" THIS-PROCEDURE:INTERNAL-ENTRIES VIEW-AS ALERT-BOX INFO BUTTONS OK. */

        /* Si méthode nondisponible en interne */
        IF NOT CAN-DO(THIS-PROCEDURE:INTERNAL-ENTRIES, cCmd) THEN DO:
            /* Vérification si dispo dans les procédures persistentes */
            ASSIGN hproc = SESSION:FIRST-PROCEDURE.
            Rech:
            do while (NOT CAN-DO(hProc:INTERNAL-ENTRIES,cCmd)):
                assign hproc = hproc:next-sibling.
                if (hproc eq ?) then do:
                    ccmd = "".
                    leave rech.
                end.
            end.
            if (hproc eq ?) then return "ERROR:".
            DontQuit:
            DO ON ERROR     UNDO, LEAVE DontQuit
               ON STOP      UNDO, LEAVE DontQuit
               ON ENDKEY    UNDO, LEAVE DontQuit
               ON QUIT      UNDO, LEAVE DontQuit:
                run value(ccmd) in hProc(cPrm).
            END.
            cret = return-value.
            RUN WriteToSocket(cRet).
            return ''.
        end.

    IF cCmd > "" THEN do: 
      ERROR-STATUS:ERROR = FALSE.
      DONTQUIT:
      DO ON ERROR     UNDO, LEAVE DONTQUIT
         ON STOP      UNDO, LEAVE DONTQUIT
         ON ENDKEY    UNDO, LEAVE DONTQUIT
         ON QUIT      UNDO, LEAVE DONTQUIT:
	      RUN VALUE(cCmd)(cPrm). 
      END.
      cRet = RETURN-VALUE.
    END.
    ELSE
    	cRet = "ERROR:FileNotFound".
  END.
  IF cRet = "" AND (ERROR-STATUS:ERROR OR ERROR-STATUS:GET-MESSAGE(1) > "") THEN 
    cRet = "ERROR:" + ERROR-STATUS:GET-MESSAGE(1).
 
  IF lEmpty THEN RETURN. 
  cRet = cRet + "~nEND.~n".
  RUN WriteToSocket(cRet).
END PROCEDURE.

/* this will terminate the infinite loop of waiting for commands and
*  quit out of the Progress session
*/
PROCEDURE QUIT:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
    
    ASSIGN aOk = FALSE.
    APPLY "close" TO THIS-PROCEDURE.
    RETURN "TERMINATED.".

END PROCEDURE.

PROCEDURE PROPATH:
    DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.

    /* FIXME File.separatorChar */
    IF cPrm <> "" THEN PROPATH = cPrm + ";" + propath.
    RETURN "OK:" + PROPATH.

END PROCEDURE.


/* connect to databases
*/
PROCEDURE Connect :
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  DEFINE VARIABLE c1          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE i1          AS INTEGER.
  DEFINE VARIABLE cStatus     AS CHARACTER INIT "Connecting databases:".
  cPrm = TRIM(cPrm).
  CONNECT VALUE(cPrm) NO-ERROR.
  IF ERROR-STATUS:ERROR 
  THEN cStatus = "ERR:" + ERROR-STATUS:GET-MESSAGE(1).
  ELSE cStatus = "OK:" + cStatus.
  RETURN cStatus.
END PROCEDURE.


/* run a particular procedure persistently
*/
PROCEDURE launch:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  DEFINE VARIABLE h as HANDLE.
  RUN VALUE(cPrm) PERSISTENT SET h.
  RETURN "OK:" + cPrm .
END PROCEDURE.


