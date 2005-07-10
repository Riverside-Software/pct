/* ***********************************************************/
/* Copyright (c) 1984-2001 by Progress Software Corporation  */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/* Author: Per S Digre / PSC                                 */
/*                                                           */
/*************************************************************/
   
DEFINE VARIABLE hSocket AS HANDLE NO-UNDO.
DEFINE VARIABLE aOk     AS LOGICAL NO-UNDO.

DEFINE VARIABLE connectionFailures AS INTEGER NO-UNDO.
DEFINE VARIABLE runAppBuilder AS LOGICAL NO-UNDO INITIAL FALSE.

DEFINE NEW SHARED VARIABLE cPDIR    AS CHARACTER .
DEFINE VARIABLE cWork    AS CHARACTER .
DEFINE NEW SHARED VARIABLE cRoot    AS CHARACTER .
DEFINE NEW SHARED VARIABLE cRcode   AS CHARACTER.
DEFINE NEW SHARED VARIABLE cLinkedResources  AS CHARACTER.
DEFINE NEW SHARED VARIABLE cOptions AS CHARACTER INIT ",,,,".
DEFINE NEW SHARED VARIABLE lEmpty AS LOGICAL.
DEFINE VARIABLE cWorkspace AS CHARACTER  NO-UNDO.
DEFINE NEW SHARED STREAM sLog.
/*DEFINE NEW SHARED STREAM s1.*/ /* Used for output files */

/*DEFINE NEW GLOBAL SHARED VARIABLE OEIDE_ABSecEd    AS HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE OEIDE_Parameters AS CHARACTER NO-UNDO.*/

/*&global-define DEFAULT-SERVER-PORT 3333
&global-define MAX-CONNECTION-FAILURES 3*/

RUN OpenlogFile ("progress.log") NO-ERROR.
CREATE SOCKET hSocket.
RUN ConnectToServer NO-ERROR.

/* if something is wrong quit */
if NOT aok or ERROR-STATUS:ERROR or NOT hSocket:connected() THEN do:
  PUT STREAM sLog UNFORMATTED SKIP "Error Status: " ERROR-STATUS:ERROR.
  PUT STREAM sLog UNFORMATTED SKIP "Error Message: " ERROR-STATUS:GET-MESSAGE(1).
  PUT STREAM sLog UNFORMATTED SKIP "aOk variable: " aOk.
  PUT STREAM sLog UNFORMATTED SKIP "Socket connected: " hSocket:CONNECTED().
  PUT STREAM sLog UNFORMATTED SKIP STRING(TIME,"HH:MM:SS") "-" STRING(TODAY,"99/99/9999") " Log file closed" .
  OUTPUT STREAM sLog CLOSE.
  QUIT.
END.

/* now that we have connected, loop forever listening for
   data from the server
   When we receive data, pass it to the read handler and then
   start looping again. 
*/
ETERNALLOOP:
DO WHILE aOk:
/*  DONTQUIT1:
  DO :*/
    IF VALID-HANDLE(hsocket) THEN do:
      PROCESS EVENTS.
      PAUSE 1.
    end.
  /*END.*/
END.
QUIT.

PROCEDURE ConnectToServer.
  DEFINE VARIABLE cPort AS CHARACTER NO-UNDO.

  cPort = OS-GETENV("ECLIPSE_PORT").

  if cPort = "" OR cPort = ? THEN cPort = "{&DEFAULT-SERVER-PORT}".  /* Default port */

  PUT STREAM sLog UNFORMATTED SKIP  "Connecting to eclipse project".
  aOk = hSocket:CONNECT("-S " + cPort) NO-ERROR.
  PUT STREAM sLog UNFORMATTED SKIP  ERROR-STATUS:GET-MESSAGE(1).
  
  if NOT aOK THEN
    RETURN ERROR "Connection to eclipse project failed on port " + cPort.
  ELSE 
    RUN SendConnectionGreeting.

END PROCEDURE.

/*  Send the workspace name back to eclipse so that eclipse knows what Progress
 *  session just connected.
*/
PROCEDURE SendConnectionGreeting:
  DEFINE VARIABLE greeting AS CHARACTER NO-UNDO.
  
  PUT STREAM sLog UNFORMATTED SKIP "read-resp : " hSocket:SET-READ-RESPONSE-PROCEDURE("ReceiveCommand") skip.
  /*IF cWorkspace = "" OR cWorkspace = ? THEN DO:
  	PUT STREAM sLog UNFORMATTED SKIP  "Workspace name not passed in environment".
    aOk = FALSE.
    RETURN ERROR.
  END.*/
  greeting = "CLIENT~n" + cworkspace + "~n started successfully~n END.~n". /* Must have " END." marker */  
  PUT STREAM sLog UNFORMATTED SKIP "Envoi " greeting.
  PUT STREAM sLog UNFORMATTED SKIP  "Connected".
  run WriteToSocket(greeting).
END.

/** handles writing of response data back to the eclipse session
*/

PROCEDURE WriteToSocket:

  DEFINE INPUT PARAMETER packet AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE packetBuffer AS MEMPTR NO-UNDO.

  IF VALID-HANDLE(hSocket) THEN DO:
    IF hSocket:CONNECTED() THEN DO:
	  SET-SIZE(packetBuffer) = LENGTH(packet) + 1.
	  PUT-STRING(packetBuffer,1, LENGTH(packet)) = packet.
	
	  hSocket:WRITE (packetBuffer,1,LENGTH(packet)).
	  SET-SIZE(packetBuffer) = 0.    
    END.
    ELSE DO:
   		PUT STREAM sLog UNFORMATTED SKIP  "Lost connection to eclipse project".
		RUN QUIT ("").
  	END.
  END.

END.

/* Respond to events from eclipse 
*
*/
PROCEDURE ReceiveCommand:
  /* Read procedure for socket */
  DEFINE VARIABLE cCmd AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i1   AS INTEGER  NO-UNDO.
  DEFINE VARIABLE mReadBuffer AS MEMPTR NO-UNDO.
  DEFINE VARIABLE iBytes  AS INTEGER.

  IF NOT SELF:CONNECTED() THEN
  DO:
	 IF runAppBuilder THEN
	 	RUN closeAppBuilder.
     RETURN ERROR "Socket disconnected".
  END.

  iBytes = SELF:GET-BYTES-AVAILABLE().
  SET-SIZE(mReadBuffer) = iBytes.
  aOk = SELF:READ (mReadBuffer,1,iBytes).
  cCmd = GET-STRING(mReadBuffer,1,iBytes).  /*Unmarshal data*/
  /*PUT STREAM sLog UNFORMATTED SKIP "Unmarshaled : " cCmd.*/
  
  SET-SIZE(mReadBuffer) = 0.
  cCmd = REPLACE(cCmd,CHR(13),'').  /* strip linefeed and cr */
  
  PUT STREAM sLog UNFORMATTED SKIP "Recu : " cCmd.
  /* Check if a full command */
  SELF:PRIVATE-DATA = "".
  cCmd = SELF:PRIVATE-DATA + cCmd.
  i1   = INDEX(cCmd,CHR(10)).
  
  IF NOT aOk THEN DO:
      PUT STREAM sLog UNFORMATTED SKIP "DIE DIE DIE...something bad happened while receiving data".
      APPLY "close" TO THIS-PROCEDURE.
      RETURN ERROR "Something bad happened.".
  END.

  IF i1 > 0 THEN DO:
    /* PUT STREAM sLog UNFORMATTED "JE VAIS PRENDRE " cCmd "--" i1. */
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
  PUT STREAM sLog UNFORMATTED SKIP  "Execute:" cCmd.

  ERROR-STATUS:ERROR = FALSE NO-ERROR.
  DO ON ERROR UNDO, LEAVE
     ON STOP UNDO, LEAVE:
    ASSIGN
      lEmpty = FALSE
      cRet = "Command not found (" + cCmd + ")"
      cCmd = cCmd + " "
      cPrm = TRIM(SUBSTRING(cCmd,INDEX(cCmd,' ') + 1))
      cCmd = TRIM(ENTRY(1,cCmd,' '))
      cRet = "".
    MESSAGE cCmd "--" THIS-PROCEDURE:INTERNAL-ENTRIES VIEW-AS ALERT-BOX INFO BUTTONS OK.

    IF NOT CAN-DO(THIS-PROCEDURE:INTERNAL-ENTRIES,cCmd) THEN do:
      PUT STREAM sLog UNFORMATTED SKIP "pas trouve en interne".
      assign hproc = session:first-procedure.
      rech:
      do while (NOT CAN-DO(hProc:INTERNAL-ENTRIES,cCmd)):
        assign hproc = hproc:next-sibling.
        if (hproc eq ?) then do:
          ccmd = "".
          leave rech.
        end.
      end.
      if (hproc eq ?) then return "ERROR:".
      PUT STREAM sLog UNFORMATTED SKIP "je vais lancer en externe".
      run value(ccmd) in hProc(cPrm).
      cret = return-value.
      PUT STREAM sLog UNFORMATTED SKIP  "Response:" cRet.
      RUN WriteToSocket(cRet).
      return ''.
    end.
    /*cCmd = SEARCH(cPDir + "_ide" + cCmd + ".p").*/
    PUT STREAM sLog UNFORMATTED SKIP  cCmd + "(" + cPrm + ")".
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
  PUT STREAM sLog UNFORMATTED SKIP  "Response:" cRet.
  cRet = cRet + "~nEND.~n".
  RUN WriteToSocket(cRet).
END PROCEDURE.

/* this will terminate the infinite loop of waiting for commands and
*  quit out of the Progress session
*/
PROCEDURE QUIT:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  aOk = FALSE.
  PUT STREAM sLog UNFORMATTED SKIP  "QUIT command received".
  PUT STREAM sLog UNFORMATTED SKIP  "Freeing up resources".
  APPLY "close" TO THIS-PROCEDURE.
  RETURN "TERMINATED.".
END PROCEDURE.

/* retrieve the propath
*/
PROCEDURE PROPATH:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  IF cPrm <> "" THEN PROPATH = cPrm + ";" + propath.
  RETURN "OK:" + REPLACE(PROPATH,",",";").
END PROCEDURE.

PROCEDURE RCODE:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  ASSIGN cRcode = cPrm.
  RETURN "OK:".
END PROCEDURE.


/* connect to databases
*/
PROCEDURE Connect :
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  DEFINE VARIABLE c1          AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE i1          AS INTEGER.
  DEFINE VARIABLE cStatus     AS CHARACTER INIT "Connecting databases:".
  cPrm = TRIM(cPrm).
  /*DO i1 = 1 to NUM-ENTRIES(cPrm) BY 3:
    c1 = TRIM(ENTRY(i1 + 2,cPrm)).
  	cStatus = cStatus + "~n" + ENTRY(i1,cPrm) + ":".
    IF NUM-ENTRIES(c1," ") = 2 AND "-db" = ENTRY(1,c1," ") THEN DO:
      cStatus = cStatus + " Starting".      
      OS-COMMAND SILENT VALUE("proserve " + ENTRY(2,c1," ")).
    END.
	CONNECT VALUE(c1) NO-ERROR.
	IF ERROR-STATUS:ERROR 
	THEN cStatus = cStatus + ERROR-STATUS:GET-MESSAGE(1).
	ELSE cStatus = cStatus + " OK".
  END.	*/
  CONNECT VALUE(cPrm) NO-ERROR.
  IF ERROR-STATUS:ERROR 
  THEN cStatus = "ERR:" + ERROR-STATUS:GET-MESSAGE(1).
  ELSE cStatus = "OK:" + cStatus.
  RETURN cStatus.
END PROCEDURE.


PROCEDURE OPTIONS:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  ASSIGN cOptions = cPrm.
  RETURN "OK:".
END PROCEDURE.

/* Return the proversion for an old project
*/
PROCEDURE proversion:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  RETURN "OK:~n" + PROVERSION.
END PROCEDURE.


/* run a particular procedure persistently
*/
PROCEDURE launch:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  DEFINE VARIABLE h as HANDLE.
  RUN VALUE(cPrm) PERSISTENT SET h.
  RETURN "OK:" + cPrm .
END PROCEDURE.


/* perform a Progress file search on the specified file
*/
PROCEDURE SEARCH:
  DEFINE INPUT PARAMETER cPrm AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cProject AS CHARACTER.
  DEFINE VARIABLE cFilename AS CHARACTER NO-UNDO.
  ASSIGN 
    cFilename = SEARCH(cPrm).
  IF cFilename = ? THEN RETURN "ERR:FileNotFound".
  ASSIGN
    FILE-INFO:FILE-NAME = cFileName
    cFileName = FILE-INFO:FULL-PATHNAME
    cFilename = REPLACE(cFilename,"~\","/")
    cFilename = REPLACE(cFilename,cRoot,"").
  RETURN "OK:~n" + cFilename.  
END PROCEDURE.



PROCEDURE OpenLogFile.

	DEFINE INPUT PARAMETER LogFile AS CHARACTER NO-UNDO.
	
	/* this is here to trap for a session reset which would
	   cause Progress to reset the execution of _server
	   but not close the log file.  By trapping the error
	   we can continue gracefully
	*/
	
	LOGOPEN:
	DO ON ERROR UNDO, LEAVE LOGOPEN
	   ON ENDKEY UNDO, LEAVE LOGOPEN
	   ON STOP UNDO, LEAVE LOGOPEN:
		OUTPUT STREAM sLog TO VALUE(LogFile) UNBUFFERED. /* Reroute later output */
	END.
	
	PUT STREAM sLog UNFORMATTED SKIP STRING(TIME,"HH:MM:SS") "-" STRING(TODAY,"99/99/9999") " Log file opened" .
	PUT STREAM sLog UNFORMATTED SKIP  "PATH=" OS-GETENV("PATH").
	PUT STREAM sLog UNFORMATTED SKIP  "DLC=" OS-GETENV("DLC").
	PUT STREAM sLog UNFORMATTED SKIP  "PROPATH=" PROPATH.
	/*PUT STREAM sLog UNFORMATTED SKIP  "ECLIPSE_PROJECT=" cWorkspace.*/
	PUT STREAM sLog UNFORMATTED SKIP  "ECLIPSE_PORT=" OS-GETENV("ECLIPSE_PORT").
	/*PUT STREAM sLog UNFORMATTED SKIP  "ECLIPSE_ROOT=" OS-GETENV("ECLIPSE_ROOT").*/

END PROCEDURE.

