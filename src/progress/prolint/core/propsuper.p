/* =======================================================================
   file    : prolint/core/propsuper.p
   purpose : manage Prolint properties
   by      : Jurjen Dijkstra
    -----------------------------------------------------------------

    Copyright (C) 2006 Jurjen Dijkstra

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
   ====================================================================== */

   /* this procedure is temporarily session:super so every Prolint program can call it */
   SESSION:ADD-SUPER-PROCEDURE (THIS-PROCEDURE).
   SUBSCRIBE TO "IsProlintPropertiesRunning":U ANYWHERE.

   DEFINE TEMP-TABLE tt_prop NO-UNDO
       FIELD property AS CHARACTER
       FIELD stringvalue AS CHARACTER
       INDEX idx_prop AS PRIMARY UNIQUE property.

   DEFINE VARIABLE cInstance AS INTEGER NO-UNDO INITIAL 0.

   /* fetch default properties  */
   RUN prolint/prolint.properties.p.

   /* fetch custom properties, if they exist */
   IF SEARCH("prolint/custom/prolint.properties.p")<>? THEN
      RUN prolint/custom/prolint.properties.p.

   /* repair a few properties, if necessary: */

   /* 1. outputdirectory must end with a slash */
   FIND tt_prop WHERE tt_prop.property = "outputhandlers.outputdirectory" NO-ERROR.
   IF AVAILABLE tt_prop THEN
      IF tt_prop.stringvalue > "" THEN
         IF NOT ((SUBSTRING(tt_prop.stringvalue, LENGTH(tt_prop.stringvalue,"CHARACTER":U)) = '~\':U) OR (SUBSTRING(tt_prop.stringvalue, LENGTH(tt_prop.stringvalue,"CHARACTER":U)) = '/':U)) THEN
            tt_prop.stringvalue = tt_prop.stringvalue + '/':U.

   
/* this procedure is called from prolint.properties.p : */
PROCEDURE SetProlintProperty :
   DEFINE INPUT PARAMETER property  AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER propvalue AS CHARACTER NO-UNDO.

   FIND tt_prop WHERE tt_prop.property = property NO-ERROR.
   IF NOT AVAILABLE tt_prop THEN CREATE tt_prop.
   ASSIGN tt_prop.property = property
          tt_prop.stringvalue = propvalue.

END PROCEDURE.


/* this function is called from wherever you want to read a property: */
FUNCTION ProlintProperty RETURNS CHARACTER (INPUT property AS CHARACTER) :

   FIND tt_prop WHERE tt_prop.property = property NO-ERROR.
   IF AVAILABLE tt_prop THEN
      RETURN tt_prop.stringvalue.
   ELSE
      RETURN "".

END FUNCTION.

/* instance counting */
PROCEDURE IsProlintPropertiesRunning :
   DEFINE OUTPUT PARAMETER isrunning AS LOGICAL NO-UNDO INITIAL TRUE.
END PROCEDURE.

PROCEDURE IncrementProlintPropertySubscribers :
   cInstance = cInstance + 1.
END PROCEDURE.

PROCEDURE DecrementProlintPropertySubscribers :
   cInstance = cInstance - 1.
   IF cInstance = 0 THEN
      DELETE PROCEDURE THIS-PROCEDURE:HANDLE.
END PROCEDURE.


