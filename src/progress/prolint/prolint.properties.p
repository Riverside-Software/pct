/* ------------------------------------------------------------------
    file    : prolint/prolint.properties.p
    purpose : set default properties for Prolint, rules, outputhandlers etc
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
   ------------------------------------------------------------------ */


   /*
      >>>> DO NOT MODIFY THIS FILE! <<<<

      Instead, create a copy of this procedure file
      and place it in directory:
          prolint/custom
      so you get a file named:
          prolint/custom/prolint.properties.p

      Then modify the contents of prolint/custom/prolint.properties.p.
      You can change existing properties and you can add new ones too.

      It is recommended to delete lines from prolint/custom/prolint.properties.p
      for properties that you do NOT want to change. In other words: file
      prolint/custom/prolint.properties.p should ONLY contain MODIFIED properties!

      An other way of saying it:
      create an empty file named prolint/custom/prolint.properties.p
      and then add the properties to it that you want to change.

   */


   /* "outputhandlers.resultwindow"
      logwin.w  is the default resultwindow with the treeview and other ActiveX controls.
      logwin8.w is the old default that doesn't use any ActiveX controls */
   RUN SetProlintProperty ("outputhandlers.resultwindow", "prolint/outputhandlers/logwin.w").


   /* "outputhandlers.outputdirectory"
      the directory where outputhandlers save their outputfiles */
   RUN SetProlintProperty ("outputhandlers.outputdirectory", SESSION:TEMP-DIR).


   /* "logincode"
      some outputhandlers prepend logincode to their outputfile, which is convenient when
      several users access the same outputdirectory at the same time */
   IF CONNECTED("dictdb") AND USERID("dictdb")>"" THEN
      RUN SetProlintProperty ("logincode", USERID("dictdb")).
   ELSE
      RUN SetProlintProperty ("logincode", "").


   /* "url to help/rules"
       specifies how to open a helpfile for a rule, using the web browser */
   FILE-INFO:FILE-NAME= "prolint/help/rules".
   RUN SetProlintProperty ("url to help/rules", FILE-INFO:FULL-PATHNAME).


   /* "filters.excludelist"
      use filters/exclude.p or not? */
   RUN SetProlintProperty ("filters.excludelist", STRING( TRUE )).


   /* "filters.nowarnlist"
      TRUE:  use filters/nowarn.p
      FALSE: do not use filter/nowarn.p */
   RUN SetProlintProperty ("filters.nowarnlist", STRING( TRUE )).


   /* "filters.IgnoreAppbuilderstuff"
      if TRUE then try to ignore warnings caused from AB-generated code */
   RUN SetProlintProperty ("filters.IgnoreAppbuilderstuff", STRING( TRUE )).

   /* "rules.do1.StatementSkipList"
      customization for rule "do1":
      SkipList to state which single statements may be enclosed with a do: end. */
   run SetProlintProperty ("rules.do1.StatementSkipList", "case,do,for,if,repeat").

   /* "rules.varusage.OutputParamsAreUsed"
      customization for rule "varusage":
      if TRUE,  output parameters are always considered to be "used" and will not cause a warning.
      if FALSE, output parameters are considered to be "not used" unless they are explicitly assigned */
   RUN SetProlintProperty ("rules.varusage.OutputParamsAreUsed", STRING( TRUE )).

   /* "rules.varusage.SkipNewShared"
      customization for rule "varusage":
      if TRUE,  new shared vars are always considered to be "used" and will not cause a warning.
      if FALSE, new shared vars are checked like regular vars */
   run SetProlintProperty ("rules.varusage.SkipNewShared", string( true )).

   /* "rules.RemoveLogicalDatabaseName"
      if FALSE, don't remove the ldbname from tablename (send "sports.customer" to outputhandler)
      if TRUE, remove the ldbname from tablename (send "customer" to outputhandler) */
   RUN SetProlintProperty ("rules.RemoveLogicalDatabaseName", STRING( TRUE )).


   /* "compilationunit.filename.mask"
      list of filename wildcards that are considered compilation units,
      files that don't match these wildcards will be skipped by prolint */
   /* Please notice the double tilde: they are here to specify that the dot is a literal instead of a placeholder for any one character */
   RUN SetProlintProperty ("compilationunit.filename.mask", "*~~.p,*~~.pp,*~~.w,*~~.cls").


