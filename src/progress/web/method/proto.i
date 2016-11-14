/*********************************************************************
* Copyright (C) 2005,2009 by Progress Software Corporation. All rights    *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
/*--------------------------------------------------------------------------
    Library     : proto.i
    Purpose     : Public function prototypes for files in src/web/method

    Syntax      : {src/web/method/proto.i}
    Author(s)   : B.Burton 
    Created     : 02/03/97
    Notes       : This file is included by cgidefs.i.  
  ------------------------------------------------------------------------*/

/* Make sure this file is only included once */
&IF DEFINED(PROTO_I) = 0 &THEN
&GLOBAL-DEFINE PROTO_I TRUE

/* ***************************  Definitions  ************************** */

/* If we're included by web-util.p, define forward prototypes, otherwise
   define external prototypes. */
&IF DEFINED(WEB-UTIL_P) = 0 &THEN
&SCOPED-DEFINE FORWARD IN web-utilities-hdl
&ELSE
  &IF "{&WEB-UTIL_P}" = "SUPER" 
  &THEN
    &SCOPED-DEFINE FORWARD IN SUPER
  &ELSE
    &SCOPED-DEFINE FORWARD FORWARD
  &ENDIF
&ENDIF

/** webstart.p */
FUNCTION getEnv                RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) in web-utilities-hdl.

/*
** cgiutils.i
*/
FUNCTION convert-datetime       RETURNS CHARACTER
  (INPUT p_conversion           AS CHARACTER,
   INPUT p_idate                AS DATE,
   INPUT p_itime                AS INTEGER,
   OUTPUT p_odate               AS DATE,
   OUTPUT p_otime               AS INTEGER) {&FORWARD}.
FUNCTION format-datetime        RETURNS CHARACTER
  (INPUT p_format               AS CHARACTER,
   INPUT p_date                 AS DATE,
   INPUT p_time                 AS INTEGER,
   INPUT p_options              AS CHARACTER) {&FORWARD}.
FUNCTION get-binary-data        RETURNS MEMPTR
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-cgi                RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-cgi-long           RETURNS LONGCHAR
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-field              RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-fieldEx            RETURNS LONGCHAR
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-from-form-fields   RETURNS LOGICAL
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-long-value         RETURNS LONGCHAR
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-value              RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-valueEx            RETURNS LONGCHAR
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION get-user-field         RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION hidden-field           RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER,
   INPUT p_value                AS CHARACTER) {&FORWARD}.
FUNCTION hidden-field-list      RETURNS CHARACTER
  (INPUT p_name-list            AS CHARACTER) {&FORWARD}.
FUNCTION html-encode            RETURNS CHARACTER
  (INPUT p_in                   AS CHARACTER) {&FORWARD}.
FUNCTION multi-session-agent    RETURNS LOGICAL
  (  )                                        {&FORWARD}.
FUNCTION output-content-type    RETURNS LOGICAL
  (INPUT p_type                 AS CHARACTER) {&FORWARD}.
FUNCTION output-http-header     RETURNS CHARACTER
  (INPUT p_header               AS CHARACTER,
   INPUT p_value                AS CHARACTER) {&FORWARD}.
FUNCTION set-user-field         RETURNS LOGICAL
  (INPUT p_name                 AS CHARACTER,
   INPUT p_value                AS CHARACTER) {&FORWARD}.
FUNCTION set-wseu-cookie        RETURNS CHARACTER
  (INPUT p_cookie               AS CHARACTER) {&FORWARD}.
FUNCTION url-decode             RETURNS CHARACTER
  (INPUT p_in                   AS CHARACTER) {&FORWARD}.
FUNCTION url-encode             RETURNS CHARACTER
  (INPUT p_value                AS CHARACTER,
   INPUT p_enctype              AS CHARACTER) {&FORWARD}.
FUNCTION url-field              RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER,
   INPUT p_value                AS CHARACTER,
   INPUT p_delim                AS CHARACTER) {&FORWARD}.
FUNCTION url-field-list         RETURNS CHARACTER
  (INPUT p_name-list            AS CHARACTER,
   INPUT p_delim                AS CHARACTER) {&FORWARD}.
FUNCTION url-format             RETURNS CHARACTER
  (INPUT p_url                  AS CHARACTER,
   INPUT p_name-list            AS CHARACTER,
   INPUT p_delim                AS CHARACTER) {&FORWARD}.

/*
** cookie.i
*/
FUNCTION delete-cookie          RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER,
   INPUT p_path                 AS CHARACTER,
   INPUT p_domain               AS CHARACTER) {&FORWARD}.
FUNCTION get-cookie             RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.
FUNCTION set-cookie             RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER,
   INPUT p_value                AS CHARACTER,
   INPUT p_date                 AS DATE,
   INPUT p_time                 AS INTEGER,
   INPUT p_path                 AS CHARACTER,
   INPUT p_domain               AS CHARACTER,
   INPUT p_options              AS CHARACTER) {&FORWARD}.

/*
** message.i
*/
FUNCTION available-messages     RETURNS LOGICAL
  (INPUT p_grp                  AS CHARACTER) {&FORWARD}.
FUNCTION get-messages           RETURNS CHARACTER
  (INPUT p_grp                  AS CHARACTER,
   INPUT p_delete               AS LOGICAL) {&FORWARD}.
FUNCTION get-message-groups     RETURNS CHARACTER {&FORWARD}.
FUNCTION output-messages        RETURNS INTEGER
  (INPUT p_option               AS CHARACTER,
   INPUT p_grp                  AS CHARACTER,
   INPUT p_message              AS CHARACTER) {&FORWARD}.
FUNCTION queue-message          RETURNS INTEGER
  (INPUT p_grp                  AS CHARACTER,
   INPUT p_message              AS CHARACTER) {&FORWARD}.

/*
** web-util.p
*/
FUNCTION check-agent-mode       RETURNS LOGICAL
  (INPUT p_mode                 AS CHARACTER) {&FORWARD}.
FUNCTION get-config             RETURNS CHARACTER
  (INPUT p_name                 AS CHARACTER) {&FORWARD}.


/*
** Webspeed Open Source Integration 
** (weblib.p --> stdfunctions.p, webconfig.p, session.p, dbtools.p )
*/
 {web/method/session.i} 

&ENDIF  /* DEFINED(PROTO_I) = 0 */

/* end */
