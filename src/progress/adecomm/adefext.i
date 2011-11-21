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

File: adefext.i

Description:
	
	Defines all the product names and file extensions.

Author: David Lee

Date Created: May 26, 1993

Modifications
  9/16/93 wood   changed "Freeze Frame" to "FreezeFrame" (conforms to doc).
          
----------------------------------------------------------------------------*/

&GLOBAL ADEFEXTI "" /* allow to check if this file has already been included */

/* ------------------------ APPLICATION NAMES  ----------------------------- */

/* Application Names */

&GLOBAL-DEFINE  UIB_NAME        AppBuilder
&GLOBAL-DEFINE  UIB_SHORT_NAME  AB

&GLOBAL-DEFINE  FF_NAME         FreezeFrame

/* --------------------------- TEMP FILE EXTENSIONS ------------------------ */

&GLOBAL-DEFINE  STD_TYP_UIB_BROWSER   "br"
&GLOBAL-DEFINE  STD_TYP_UIB_DUP       "dp"
&GLOBAL-DEFINE  STD_TYP_UIB_DUP       "dp"
&GLOBAL-DEFINE  STD_TYP_UIB_CLIP      "cb"
&GLOBAL-DEFINE  STD_TYP_UIB_LAST      "ef"
&GLOBAL-DEFINE  STD_TYP_UIB_RADIO     "rb"
&GLOBAL-DEFINE  STD_TYP_UIB_DBFIELD   "db"
&GLOBAL-DEFINE  STD_TYP_UIB_COMPILE   "cf"
&GLOBAL-DEFINE  STD_TYP_UIB_TEMPLATE  "ct"
&GLOBAL-DEFINE  STD_EXT_UIB           ".ab"
&GLOBAL-DEFINE  STD_EXT_UIB_QS        ".qs"
&GLOBAL-DEFINE  STD_EXT_UIB_WVX       ".wrx"

&GLOBAL-DEFINE  STD_EXT_FF            ".ff"


