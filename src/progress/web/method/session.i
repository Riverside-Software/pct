/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*  Per S Digre (pdigre@progress.com)                                 *
*                                                                    *
*********************************************************************/
/*--------------------------------------------------------------------
 File:    webutil/session.i
 Purpose: Include for the session module
 Updated: 04/04/98 pdigre@progress.com
            Initial version
          04/26/01 adams@progress.com
            WebSpeed integration
          05/23/01 mbaker@progress.com
            Dynamics integration
---------------------------------------------------------------------*/

&IF DEFINED(session-included) = 0 &THEN
&GLOBAL-DEFINE session-included YES

DEFINE NEW GLOBAL SHARED VARIABLE gscSessionId AS CHARACTER NO-UNDO.

FUNCTION setSession RETURNS LOGICAL
  ( cName AS CHARACTER, cValue AS CHARACTER) {&FORWARD}.
FUNCTION getSession RETURNS CHARACTER 
  ( cName AS CHARACTER) {&FORWARD}.
FUNCTION setGlobal RETURNS LOGICAL 
  ( cName AS CHARACTER, cValue AS CHARACTER) {&FORWARD}.
FUNCTION getGlobal RETURNS CHARACTER 
  ( cName AS CHARACTER) {&FORWARD}.
FUNCTION logNote RETURNS LOGICAL 
  ( pcLogType AS CHARACTER, pcLogText AS CHARACTER ) {&FORWARD}.

&ENDIF
