/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/*-------------------------------------------------------------------------

File: src/web/method/cgidefs.i

Description: Global include file for all WEB and CGI variables.

Notes:
  The NEW option must be specified when this file is included by the
  initial calling procedure.   
  
  Associated procedures for manipulating these variables are
  found in cgiutils.i

  This file includes src/web/method/proto.i to define function prototypes.

Author: B.Burton

Created: 05/14/96

---------------------------------------------------------------------------*/

/* Stream where we write all web output */
&IF DEFINED(WEBSTREAM) = 0 &THEN
  &GLOBAL-DEFINE WEBSTREAM STREAM WebStream
&ENDIF

/* Only define a stream if there's something to define */
&IF "{&WEBSTREAM}" <> "" &THEN
DEFINE {1} SHARED {&WEBSTREAM}.
&ENDIF

/*  For more information on the CGI 1.1 and HTTP variables, see
    http://hoohoo.ncsa.uiuc.edu/cgi/env.html. */

/* CGI 1.1 Variables */
DEFINE NEW GLOBAL SHARED VARIABLE GATEWAY_INTERFACE AS char 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE SERVER_SOFTWARE   AS char FORMAT "x(20)":U
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE SERVER_PROTOCOL   AS char 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE SERVER_NAME       AS char FORMAT "x(40)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE SERVER_PORT       AS char 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE REQUEST_METHOD    AS char 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE SCRIPT_NAME       AS char FORMAT "x(40)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE PATH_INFO         AS char FORMAT "x(40)":U
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE PATH_TRANSLATED   AS char FORMAT "x(60)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE QUERY_STRING      AS char FORMAT "x(60)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE REMOTE_ADDR       AS char FORMAT "x(15)":U
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE REMOTE_HOST       AS char FORMAT "x(30)":U
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE REMOTE_IDENT      AS char FORMAT "x(50)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE REMOTE_USER       AS char FORMAT "x(50)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE AUTH_TYPE         AS char FORMAT "x(10)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE CONTENT_TYPE      AS char FORMAT "x(50)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE CONTENT_LENGTH    AS INTEGER 
    NO-UNDO.

/* Common HTTP Header Variables */
DEFINE NEW GLOBAL SHARED VARIABLE HTTP_ACCEPT       AS char FORMAT "x(50)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE HTTP_COOKIE       AS char FORMAT "x(50)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE HTTP_REFERER      AS char FORMAT "x(60)":U
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE HTTP_USER_AGENT   AS char FORMAT "x(50)":U 
    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE HTTPS             AS char
    NO-UNDO.

/* Name of the program we're about to run */
DEFINE NEW GLOBAL SHARED VARIABLE AppProgram        AS char FORMAT "x(40)":U 
    NO-UNDO.

/* Relative URL where the application directory is the root. */
DEFINE NEW GLOBAL SHARED VARIABLE AppURL            AS char FORMAT "x(40)":U 
    NO-UNDO.

/* Relative URL for ourself from the server root directory. */
DEFINE NEW GLOBAL SHARED VARIABLE SelfURL           AS char FORMAT "x(60)":U 
    NO-UNDO.

/* Host and port part of URL. */
DEFINE NEW GLOBAL SHARED VARIABLE HostURL           AS char FORMAT "x(40)":U 
    NO-UNDO.

/* Default path for set-cookie() function.  Normally the same as AppURL.
   Otherwise, obtained from the DefaultCookiePath configuration option. */
DEFINE NEW GLOBAL SHARED VARIABLE CookiePath        AS char FORMAT "x(40)":U 
    NO-UNDO.

/* Relative path for our static HTML, JAVA, DOC, and IMG file off the web
   server's DOCUMENT_ROOT directory.                                    */   
DEFINE NEW GLOBAL SHARED VARIABLE RootURL           AS char FORMAT "x(60)":U 
    NO-UNDO.

/* Messenger Server Connection ID is inactive/active (0/1)              */   
DEFINE NEW GLOBAL SHARED VARIABLE useConnID         AS char FORMAT "x(60)":U 
    NO-UNDO.

/* Default domain for the set-cookie() function.  Normally blank. */
DEFINE NEW GLOBAL SHARED VARIABLE CookieDomain      AS char FORMAT "x(40)":U 
    NO-UNDO.

/* Delimiter for multiple items assigned to a single field name.
   Typically a comma or tab. */
DEFINE NEW GLOBAL SHARED VARIABLE SelDelim          AS char FORMAT "x":U 
    NO-UNDO INITIAL ",":U.

/* Flag set by the output-content-type() function to the Content-Type header
   value that was output.  If this is blank, then the output-content-type()
   function has not been run yet which should imply no other output has
   been sent either. */
DEFINE NEW GLOBAL SHARED VARIABLE output-content-type AS char NO-UNDO.

/* Newline characters to use for the output-http-header() function.
   Some web servers do not allow the CR, LF combination but only support
   an LF character. */
DEFINE NEW GLOBAL SHARED VARIABLE http-newline AS char NO-UNDO
    INITIAL "~r~n":U.

/* Offset from Coordinated Universal Time (UTC) or GMT time in seconds.
   This value is updated with each request.  A positive number is west of
   UTC.  This is used to calculate UTC time when setting Cookie expiration
   dates in the set-cookie() function. */
DEFINE NEW GLOBAL SHARED VARIABLE utc-offset AS INTEGER NO-UNDO INITIAL -1.

/* Handle for web utilities procedure. */
DEFINE NEW GLOBAL SHARED VARIABLE web-utilities-hdl AS HANDLE NO-UNDO.

/* Comma delimited list of debugging options. */
DEFINE NEW GLOBAL SHARED VARIABLE debug-options AS char FORMAT "x(20)":U
    NO-UNDO.

/* True if debugging is enabled via the configuration options Environment
   and Debugging. */
DEFINE NEW GLOBAL SHARED VARIABLE debugging-enabled AS LOGICAL NO-UNDO
    INITIAL TRUE.

/* List of Misc. variables above.  Used for dumping out all misc. values in
   debugging mode such as with printval.p. */
DEFINE NEW GLOBAL SHARED VARIABLE MiscVarList     AS char NO-UNDO 
    INITIAL "AppProgram,AppURL,HostURL,SelDelim,SelfURL,":U.

&GLOBAL-DEFINE OUT-STREAM PUT {&WEBSTREAM} UNFORMATTED
/* OUT-FILE is the same as OUT-STREAM, for now.  */
&GLOBAL-DEFINE OUT-FILE {&OUT-STREAM}
&GLOBAL-DEFINE OUT {&OUT-STREAM}
&GLOBAL-DEFINE OUT-LONG EXPORT {&WEBSTREAM}
&GLOBAL-DEFINE OUT-FMT PUT {&WEBSTREAM}
&GLOBAL-DEFINE DISPLAY DISPLAY {&WEBSTREAM}
&GLOBAL-DEFINE END .

/* Define function prototypes */
{web/method/proto.i}

/* end */
