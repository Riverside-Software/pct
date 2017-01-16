/**********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : parse-openedge-documentation.p
    Purpose     : Sample invokation of the OpenEdgeDocParser

    Syntax      :

    Description : Creates an index of the ABL classes contained in the 
                  OpenEdge HTML Documentation (contained in the oeide 
                  plugin com.openedge.pdt.langref.help

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Feb 16 18:31:20 CET 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.*                     FROM PROPATH . 
USING Consultingwerk.Studio.OpenEdgeDocs.* FROM PROPATH . 
USING Consultingwerk.Util.*                FROM PROPATH . 
USING Progress.Lang.*                      FROM PROPATH . 

{Consultingwerk/Studio/OpenEdgeDocs/ttClassDocumentation.i} .

DEFINE VARIABLE oParser AS OpenEdgeDocParser NO-UNDO . 

/* ***************************  Main Block  *************************** */

oParser = NEW OpenEdgeDocParser () .

oParser:ParseClassDocumentation ("111":U,
                                 OUTPUT TABLE ttClassDocumentation) .

TEMP-TABLE ttClassDocumentation:WRITE-XML ("file":U, 
                                           "111.xml":U, 
                                           TRUE) .

oParser:ParseClassDocumentation ("102b":U,
                                 OUTPUT TABLE ttClassDocumentation) .

TEMP-TABLE ttClassDocumentation:WRITE-XML ("file":U, 
                                           "102b.xml":U, 
                                           TRUE) .
