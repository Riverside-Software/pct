/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation ("PSC"),       *
* 14 Oak Park, Bedford, MA 01730, and other contributors as listed   *
* below.  All Rights Reserved.                                       *
*                                                                    *
* The Initial Developer of the Original Code is PSC.  The Original   *
* Code is Progress IDE code released to open source December 1, 2000.*
*                                                                    *
* The contents of this file are subject to the Possenet Public       *
* License Version 1.0 (the "License"); you may not use this file     *
* except in compliance with the License.  A copy of the License is   *
* available as of the date of this notice at                         *
* http://www.possenet.org/license.html                               *
*                                                                    *
* Software distributed under the License is distributed on an "AS IS"*
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. You*
* should refer to the License for the specific language governing    *
* rights and limitations under the License.                          *
*                                                                    *
* Contributors:                                                      *
*                                                                    *
*********************************************************************/
/*----------------------------------------------------------------------------

File: adestds.i

Description:
         Defines standard colors and fonts to be used by all ADE applications.
         
         Defines standard offsets and margins for the ADE.

         This file is included when you need to use the variables defined
         here for your ADE dialog boxes.
         
         It is included in the ADE wrappers as well.  The ADE wrappers
         must also run the adecomm/_adeload.p routine after including
         this file to load the ADE default colors and fonts.

         The DEFINE NEW GLOBAL SHARED declaration defines and initializes
         the vars only the first time referenced.  Subsequent inclusion
         and refernece to this file has no affect on the values of the vars
         (because they are GLOBAL).  

         This file is part of a trio: adestds.i okform.i okrun.i.  This file 
         should be included to provide standard margins and offsets to be 
         used by the ADE.  For more information on this, see the document 
         design\ade\misc\sullivan.doc.

         This file contains pre-processor definitions that should be used for
         consistent user interface layout across dialog boxes.

	Defines all the product names

Author: Wm.T.Wood + Ravi-Chandar Ramalingam + Mike Pacholec

Date Created: January 14, 1993
          
         05-05-93 mikep Merged standard offsets/margins with this file
         05-10-93 jep   Converted vars to DEFINE NEW GLOBAL SHARED
         05-11-93 dlee  Add app name for UIB
         05-11-93 mikep remove underscores from globals (disturbing ccall)
         05-14-93 mikep changed editor phrase handing
         05-17-93 wood  remove quotes from definition for UIB_SHORT_NAME
	 05-19-93 ravi  changed UIB-name to Window Builder and added new
		        copyright information which will not require us to
			type this log as it will be a part of RCS/SCC log
----------------------------------------------------------------------------*/
&GLOBAL ADESTDSI "" /* allow to check if this file has already been included */

/* Include the file extensions and application names file */

{adecomm/adefext.i}

DEFINE NEW GLOBAL SHARED VARIABLE initialized_adestds AS LOGICAL 
       INITIAL no NO-UNDO.
   /* designates whether the resource file has already been read for these */
   /* files */

/* ---------------------------- ADE COLORS --------------------------------- */
/*        Standard Color Variables to be used by ADE dialog boxes            */

/* used as the bgcolor for the section dividers (title bands) */
DEFINE NEW GLOBAL SHARED VARIABLE std_div_fgcolor AS INTEGER 
       INITIAL 15 NO-UNDO. /* white */
DEFINE NEW GLOBAL SHARED VARIABLE std_div_bgcolor AS INTEGER 
       INITIAL 1  NO-UNDO. /* blue */
        
/* used as the bgcolor for the button section separator (rectangle 
   behind the OK CANCEL row) */
DEFINE NEW GLOBAL SHARED VARIABLE std_okbox_fgcolor AS INTEGER 
       INITIAL 1 NO-UNDO. /* blue */
DEFINE NEW GLOBAL SHARED VARIABLE std_okbox_bgcolor AS INTEGER 
       INITIAL ? NO-UNDO. /* grey */
        
/* used as the bgcolor/fgcolor for any fillin fields or editor widgets used
   for standard data entry */
DEFINE NEW GLOBAL SHARED VARIABLE std_fillin_fgcolor AS INTEGER 
       INITIAL 0  NO-UNDO. /* black */
&IF DEFINED(USE-3D) = 0 OR "{&WINDOW-SYSTEM}" = "OSF/Motif" &THEN
DEFINE NEW GLOBAL SHARED VARIABLE std_fillin_bgcolor AS INTEGER 
       INITIAL 8 NO-UNDO. /* gray */
&ELSE
DEFINE VARIABLE std_fillin_bgcolor AS INTEGER 
       INITIAL ? NO-UNDO. /* White */
&ENDIF
       
/* used as the bgcolor/fgcolor for any editor widgets used for extended
   4GL program entry like the section editor and procedure editor */
DEFINE NEW GLOBAL SHARED VARIABLE std_ed4gl_fgcolor AS INTEGER 
       INITIAL ?  NO-UNDO. /* default */
DEFINE NEW GLOBAL SHARED VARIABLE std_ed4gl_bgcolor AS INTEGER 
       INITIAL ?  NO-UNDO.  /* default */
        
/* used as the bgcolor/fgcolor for any editor widgets not used for extended
   4GL program entry like the query builder or dictionary validation */
DEFINE NEW GLOBAL SHARED VARIABLE std_ed4gl_small_fgcolor AS INTEGER 
       INITIAL 0 NO-UNDO. /* black */
&IF DEFINED(USE-3D) = 0 OR "{&WINDOW-SYSTEM}" = "OSF/Motif" &THEN
DEFINE NEW GLOBAL SHARED VARIABLE std_ed4gl_small_bgcolor AS INTEGER 
       INITIAL 8 NO-UNDO. /* grey */
&ELSE
DEFINE VARIABLE std_ed4gl_small_bgcolor AS INTEGER 
       INITIAL ? NO-UNDO. /* White */
&ENDIF        
/* ---------------------------- ADE FONTS ---------------------------------- */
/* Standard Font Variables to be used by ADE applications (and dialog boxes) */

DEFINE NEW GLOBAL SHARED VARIABLE fixed_font AS INTEGER INITIAL 0 NO-UNDO.
   /* used where a fixed font is needed (eg. in a selection list) */
   /* (this will be FONT 0).  It should be the same as the        */
   /* DefaultFixedFont */

DEFINE NEW GLOBAL SHARED VARIABLE std_font AS INTEGER INITIAL 1 NO-UNDO.
   /* proportional font used for most text and input fields (FONT 1) */
   /* (This should be the same as FONT ? = Default Font).  We need   */
   /* this if we every want to make a integer fill-in in the default */
   /* variable font. */

DEFINE NEW GLOBAL SHARED VARIABLE editor_font AS INTEGER INITIAL 2 NO-UNDO.
   /* used for most ADE editor widgets (FONT 2).  Usually this will  */
   /* be a smaller fixed font */
   /* Used ONLY for editor-widgets that will contain 4GL-Code! All */
   /* other editor-widgets are to be treated like standard fill-ins */

DEFINE NEW GLOBAL SHARED VARIABLE editor_tab AS INTEGER INITIAL 4 NO-UNDO.
   /* Sets default ADE editor tab stop value. */
   
/* ----------------------- ADE 'RUN' indicator ----------------------------- */

DEFINE NEW GLOBAL SHARED VARIABLE h_ade_tool AS HANDLE    NO-UNDO.
   /* The active ADE tool assigns its procedure handle to this var. This     */
   /* allows Procedure Windows to disable the active ADE tool.               */
   /* The ADE tool assigns its proc handle at startup, when it runs          */
   /* enable_widgets, and assigns to ? (unknown) when it runs disable_widgets*/

DEFINE NEW GLOBAL SHARED VARIABLE wfRunning  AS CHARACTER NO-UNDO.
   /* Any ADE tool which 'runs' a program will use this flag to indicate that*/
   /* they are in the middle of doing so by placing its name into this var.  */
   
/* ------------------- GENERIC MARGINS AND WIDTHS  ------------------------- */
/* generic and button specific minimum margins within a frame */

&GLOBAL-DEFINE PATH_WIDG 255 /* Supported length of the full path name */

&GLOBAL VM_WID        0.1 /* minimum vertical margin between widgets within
                             the same group  - only required for widgets 
                             that would otherwise touch like fillins under
                             Windows */

&IF "{&WINDOW-SYSTEM}" = "TTY" &THEN
 &GLOBAL VM_WIDG      1   /* minimum vertical margin between widget groups */
&ELSE
 &GLOBAL VM_WIDG      0.5 /* minimum vertical margin between widget groups */
&ENDIF

&GLOBAL HM_WIDG       2.5 /* minimum horizontal margin between widget groups */
&GLOBAL HM_BTN        0.5 /* horizontal margin between buttons in the same 
                             group */
&GLOBAL HM_BTNG       2.5 /* horizontal margin between button groups */

&IF "{&WINDOW-SYSTEM}" = "OSF/Motif" &THEN
 &GLOBAL HM_DBTN      0   /* horizontal margin between default buttons in the 
                             same group. Def. btn. mote is more than enough */
 &GLOBAL HM_DBTNG     2   /* horizontal margin between default button groups */
&ELSE
 &GLOBAL HM_DBTN      {&HM_BTN}  /* horizontal margin between default buttons 
      	       	     	      	    in the same group */
 &GLOBAL HM_DBTNG     {&HM_BTNG} /* horizontal margin between default button 
      	       	     	      	    groups */
&ENDIF

/* generic margins relating to the frame */
&IF "{&WINDOW-SYSTEM}" = "TTY" &THEN
 &GLOBAL TFM_WID      1   /* minimum top frame margin between the top of the 
                             frame and any widget */
 &GLOBAL TFM_ROW      2   /* row that corresponds to a widget after skipping
                             TFM_WID */
&ELSE
 &GLOBAL TFM_WID      0.5 /* minimum top frame margin between the top of the 
                             frame and any widget */
 &GLOBAL TFM_ROW      1.5 /* row that corresponds to a widget after skipping
                             TFM_WID */
&ENDIF

&GLOBAL HFM_WID       1   /* minimum horizontal frame margin between the left
                             and right sides of the frame and any widget */

/* ----------------- OK CANCEL HELP BUTTON STANDARDS  ---------------------- */

/* 
** standards particular to the ok button row and the button separator 
*/

&IF "{&WINDOW-SYSTEM}" = "TTY" &THEN
 &GLOBAL W_OKBTN      4  /* width  of the ok button and others in that row */
 &GLOBAL H_OKBTN      1.00 /* height of the ok button and others in that row */
 &GLOBAL WHEN_HELP    WHEN SESSION:DISPLAY-TYPE <> "TTY":u
&ELSEIF DEFINED(WIN95-BTN) &THEN
 &GLOBAL W_OKBTN      15 /* width  of the ok button and others in that row */
 &GLOBAL H_OKBTN      1.125 /* height of the ok button and others in that row */
&ELSEIF "{&WINDOW-SYSTEM}" BEGINS "MS-WIN" &THEN
 &GLOBAL W_OKBTN      10 /* width  of the ok button and others in that row */
 &GLOBAL H_OKBTN      1.00 /* height of the ok button and others in that row */
&ELSE
 &GLOBAL W_OKBTN      10 /* width  of the ok button and others in that row */
 &GLOBAL H_OKBTN      1.00 /* height of the ok button and others in that row */
&ENDIF

/* Since there's no button box on TTY or Motif, OK margin can be smaller. */
&IF "{&WINDOW-SYSTEM}" BEGINS "MS-WIN" &THEN
 &GLOBAL AT_OKBTN     AT 3 /* leave a 3 PPU margin between the ok button and 
                              the left edge of the frame */
&ELSE
 &GLOBAL AT_OKBTN     AT 2 /* leave a 2 PPU margin between the ok button and 
                              the left edge of the frame */
&ENDIF

/* use this format phrase for the ok button and others in that row on GUI */
&IF "{&WINDOW-SYSTEM}" <> "TTY" &THEN
 &GLOBAL STDPH_OKBTN     SIZE {&W_OKBTN} BY {&H_OKBTN} MARGIN-EXTRA DEFAULT
&ELSE
 &GLOBAL STDPH_OKBTN
&ENDIF

/* ---------------------------- OK BOX STANDARDS  -------------------------- */

/* standards for the ok box for the bottom row of buttons */
&GLOBAL VM_OKBOX      0.25 /* vertical margin between the ok box and any widget
                            above, and the ok box and the bottom of the frame */
&GLOBAL AT_OKBOX      AT 2 /* leave a 1 PPU margin between the left edge of the
                              ok box and the frame */
&IF DEFINED(WIN95-BTN) &THEN
 &GLOBAL IVM_OKBOX    0.30 /* inner vertical margin for the button separator 
                              Windows: The inner margin between the buttons 
                              and the top or bottom of the sullivan box. */
&ELSE
 &GLOBAL IVM_OKBOX    0.25 /* This looks better in this case */
&ENDIF

&IF "{&WINDOW-SYSTEM}" = "OSF/Motif" &THEN
 &GLOBAL HFM_OKBOX    0 /* effectively, the horizontal frame margin between 
      	       	     	 frame and help btn since there's no ok box */
&ELSE
 &GLOBAL HFM_OKBOX    1 /* horizontal frame margin for the ok box */
&ENDIF
                                                                         
&IF DEFINED(WIN95-BTN) &THEN
  &GLOBAL OKBOX       0
&ELSEIF "{&WINDOW-SYSTEM}" BEGINS "MS-WIN" &THEN
 &GLOBAL OKBOX        1
&ELSE
 &GLOBAL OKBOX        0  /* don't do for Motif or TTY */
&ENDIF 

/* use this format phrase for the rectangle used as the ok box */
&GLOBAL STDPH_OKBOX   FGC std_okbox_fgcolor SIZE {&IVM_OKBOX} BY {&IVM_OKBOX} EDGE-PIXELS 2 NO-FILL

/* ---------------------- OTHER STANDARD PHRASES  -------------------------- */

/* Use this for fillin fields, or any editor widgets that are for data entry. 
   Do not use for editor widgets used for 4GL program entry. (see below) */
&GLOBAL STDPH_FILL   bgc std_fillin_bgcolor fgc std_fillin_fgcolor 
&GLOBAL STDPH_COMBO  {&STDPH_FILL} 
&GLOBAL STDPH_EDITOR {&STDPH_FILL}

/* Use this phrase for any editor widget that is used for 4GL program entry,
   and that widget is the focus for data entry.  This is the value the 
   customers will be able to modify in their PROGRESS.INI files.  */
&GLOBAL STDPH_ED4GL       bgc std_ed4gl_bgcolor fgc std_ed4gl_fgcolor font editor_font 

/* Use this phrase for any editor widget that is used for 4GL program entry,
   and that widget is NOT the focus for data entry. */
&GLOBAL STDPH_ED4GL_SMALL bgc std_ed4gl_small_bgcolor fgc std_ed4gl_small_fgcolor font editor_font 

/* Use this phrase when you want to force a fixed font at compile time on
   a selection list or editor widget. */
&GLOBAL STDPH_FIX    FONT 0

/* Use this phrase for section dividers (title bands). */
&GLOBAL STDPH_SDIV   bgc std_div_bgcolor fgc std_div_fgcolor 

/* Use this phrase for any non-ok buttons. */
&GLOBAL STDPH_BTN    /* not mandated */

/* Use this for bgcolor of read-only editors */
&GLOBAL READ-ONLY_BGC  8

