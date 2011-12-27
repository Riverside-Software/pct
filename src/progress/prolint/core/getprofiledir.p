/* ==========================================================================================
    file    : prolint/core/getprofiledir.p
    purpose : determine the location of configuration settings.
              this would be "local-prolint/settings/" + pCustomProfile
                         or "prolint/settings/ + pCustomProfile
                    or just "prolint/settings"
    -----------------------------------------------------------------------------------------
    
    Copyright (C) 2008 Jurjen Dijkstra

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
   ========================================================================================== */
   
define input parameter  pProfileName as character no-undo.
define output parameter ProfileDirectory as character no-undo.
define output parameter foundlocally      AS LOGICAL INITIAL FALSE.
define output parameter no-override       AS LOGICAL INITIAL FALSE.

DEFINE VARIABLE PrivateDir     AS CHARACTER NO-UNDO.
DEFINE VARIABLE SharedDir      AS CHARACTER NO-UNDO.

   FILE-INFO:FILE-NAME  = "prolint/settings":U.
   SharedDir = FILE-INFO:FULL-PATHNAME.

   FILE-INFO:FILE-NAME = "local-prolint/settings":U.
   PrivateDir = FILE-INFO:FULL-PATHNAME.

run GetProfileDirectory.

PROCEDURE GetProfileDirectory :
  DEFINE VARIABLE SharedDirProfile AS CHARACTER NO-UNDO.
  DEFINE VARIABLE PrivateDirProfile AS CHARACTER NO-UNDO.
  

   /* is it a local profile, a shared profile or "<none>" ? */
   IF pProfileName = "":U OR pProfileName="<none>":U THEN
      ProfileDirectory = "prolint/settings":U.
   ELSE DO:

      IF PrivateDir = ? THEN
         ASSIGN
            PrivateDirProfile = ?
            SharedDirProfile  = SharedDir + "/":U + pProfileName.
      ELSE DO:
         FILE-INFO:FILE-NAME = PrivateDir + "/":U + pProfileName.
         PrivateDirProfile = FILE-INFO:FULL-PATHNAME.
         FILE-INFO:FILE-NAME = SharedDir + "/":U + pProfileName.
         SharedDirProfile = FILE-INFO:FULL-PATHNAME.
      END.

      IF PrivateDirProfile<>? AND SharedDirProfile=? THEN
         ASSIGN 
            ProfileDirectory = PrivateDirProfile
            foundlocally     = TRUE.
      ELSE
      IF PrivateDirProfile=? AND SharedDirProfile<>? THEN
         ProfileDirectory = SharedDirProfile.
      ELSE
      IF PrivateDirProfile<>? AND SharedDirProfile<>? THEN DO:
         /* are private settings allowed to override shared settings? */
         FILE-INFO:FILE-NAME = SharedDirProfile + "/no-local-settings.lk":U.
         IF FILE-INFO:FULL-PATHNAME = ? THEN
            ASSIGN 
               ProfileDirectory = PrivateDirProfile
               no-override      = FALSE
               foundlocally     = TRUE.
         ELSE
            ASSIGN 
               ProfileDirectory = SharedDirProfile  /* ignore PrivateDir */
               no-override      = TRUE.
      END.
   END.
   
END PROCEDURE.


