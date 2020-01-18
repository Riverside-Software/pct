/**********************************************************************
 * Copyright 2019 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        *
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : sax-reader-handler.p
    Purpose     :

    Syntax      :

    Description : SAX reader handler procedure

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Sep 10 18:00:12 CEST 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.* FROM PROPATH .
USING Progress.Lang.*         FROM PROPATH .

DEFINE INPUT PARAMETER poParser AS Consultingwerk.ISaxReader NO-UNDO .

/* **********************  Internal Procedures  *********************** */

PROCEDURE Characters:
/*------------------------------------------------------------------------------
    Purpose: Invoked when the XML parser detects character data.
    Notes:   The parser calls this method to report each chunk of character data.
             It might report contiguous character data in one chunk, or split it
             into several chunks. If validation is enabled, whitespace is reported
             by the IgnorableWhitespace callback
    @param plcCharData A LONGCHAR that contains a chunk of character data.
    @param piNumChars The number of characters contained in the MEMPTR.
------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER plcCharData AS LONGCHAR NO-UNDO.
    DEFINE INPUT  PARAMETER piNumChars  AS INTEGER  NO-UNDO.

    poParser:SaxCharacters (plcCharData, piNumChars) .

END PROCEDURE.

PROCEDURE EndElement:
/*------------------------------------------------------------------------------
    Purpose: Invoked when the XML parser detects the end of an XML document.
    Notes:
    @param pcNamespaceURI A character string indicating the namespace URI of the element. If namespace processing is not enabled or the element is not part of a namespace, the string is of length zero.
    @param pcLocalName A character string indicating the non-prefixed element name. If namespace processing is not enabled, the string is of length zero.
    @param pcName A character string indicating the actual name of the element in the XML source. If the name has a prefix, qName includes it, whether or not namespace processing is enabled.
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pcNamespaceURI AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcLocalName    AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcName         AS CHARACTER NO-UNDO .

    poParser:SaxEndElement (pcNamespaceURI, pcLocalName, pcName) .

END PROCEDURE .

PROCEDURE StartElement:
/*------------------------------------------------------------------------------
    Purpose: Invoked when the XML parser detects the beginning of an element.
    Notes:
    @param pcNamespaceURI A character string indicating the namespace URI of the element. If namespace processing is not enabled or the element is not part of a namespace, the string is of length zero.
    @param pcLocalName A character string indicating the non-prefixed element name. If namespace processing is not enabled, the string is of length zero.
    @param pcName A character string indicating the actual name of the element in the XML source. If the name has a prefix, qName includes it, whether or not namespace processing is enabled.
    @param phAttributes A handle to a SAX-attributes object, which provides access to all attributes specified for the element. If the element has no attributes, attributes is still a valid handle, and the NUM-ITEMS attribute is zero.
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pcNamespaceURI AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcLocalName    AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER pcName         AS CHARACTER NO-UNDO .
    DEFINE INPUT PARAMETER phAttributes   AS HANDLE    NO-UNDO .

    poParser:SaxStartElement (pcNamespaceURI, pcLocalName, pcName, phAttributes) .

END PROCEDURE.
