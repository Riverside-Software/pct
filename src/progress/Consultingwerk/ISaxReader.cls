/**********************************************************************
 * Copyright 2012 Consultingwerk Ltd.                                 *
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
    File        : ISaxReader
    Purpose     : Allows SAX reader handling from OOABL classes
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Sep 10 18:46:17 CEST 2012
    Notes       : This interface enforces only the basic handling methods.
                  For the remaining SAX-READER handlers, a ISaxReaderExt 
                  Interface should be created (using Interface inheritance, 
                  OpenEdge 11.0 +).
  ----------------------------------------------------------------------*/

USING Consultingwerk.* FROM PROPATH .  
USING Progress.Lang.* FROM PROPATH.

INTERFACE Consultingwerk.ISaxReader:  

    /*------------------------------------------------------------------------------
        Purpose: Invoked when the XML parser detects character data.                                                                      
        Notes:   The parser calls this method to report each chunk of character data. 
                 It might report contiguous character data in one chunk, or split it 
                 into several chunks. If validation is enabled, whitespace is reported 
                 by the IgnorableWhitespace callback                                                                      
        @param plcCharData A LONGCHAR that contains a chunk of character data.
        @param piNumChars The number of characters contained in the MEMPTR.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SaxCharacters (plcCharData AS LONGCHAR,
                                      piNumChars  AS INTEGER) . 
        
    /*------------------------------------------------------------------------------
        Purpose: Invoked when the XML parser detects the end of an XML document.                                                                     
        Notes:                                                                        
        @param pcNamespaceURI A character string indicating the namespace URI of the element. If namespace processing is not enabled or the element is not part of a namespace, the string is of length zero.
        @param pcLocalName A character string indicating the non-prefixed element name. If namespace processing is not enabled, the string is of length zero.
        @param pcName A character string indicating the actual name of the element in the XML source. If the name has a prefix, qName includes it, whether or not namespace processing is enabled.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SaxEndElement (pcNamespaceURI AS CHARACTER,
                                      pcLocalName    AS CHARACTER, 
                                      pcName         AS CHARACTER) .

    /*------------------------------------------------------------------------------
        Purpose: Invoked when the XML parser detects the beginning of an element.                                                                     
        Notes:      
        @param pcNamespaceURI A character string indicating the namespace URI of the element. If namespace processing is not enabled or the element is not part of a namespace, the string is of length zero.
        @param pcLocalName A character string indicating the non-prefixed element name. If namespace processing is not enabled, the string is of length zero.
        @param pcName A character string indicating the actual name of the element in the XML source. If the name has a prefix, qName includes it, whether or not namespace processing is enabled.
        @param phAttributes A handle to a SAX-attributes object, which provides access to all attributes specified for the element. If the element has no attributes, attributes is still a valid handle, and the NUM-ITEMS attribute is zero.      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SaxStartElement (pcNamespaceURI AS CHARACTER,
                                        pcLocalName    AS CHARACTER,
                                        pcName         AS CHARACTER,
                                        phAttributes   AS HANDLE) .
  
END INTERFACE.
