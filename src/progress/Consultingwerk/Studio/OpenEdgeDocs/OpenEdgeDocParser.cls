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
    File        : OpenEdgeDocParser
    Purpose     : 
    Syntax      : 
    Description : Creates an index of the ABL classes contained in the 
                  OpenEdge HTML Documentation (contained in the oeide 
                  plugin com.openedge.pdt.langref.help
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Feb 15 13:31:32 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.OpenEdgeDocs.* FROM PROPATH .  
USING Consultingwerk.Util.*                FROM PROPATH . 
USING Progress.Lang.*                      FROM PROPATH .

CLASS Consultingwerk.Studio.OpenEdgeDocs.OpenEdgeDocParser 
    IMPLEMENTS Consultingwerk.ISaxReader: 

    {Consultingwerk/Studio/OpenEdgeDocs/ttClassDocumentation.i} .
    {Consultingwerk/Util/TempTables/ttFileNames.i}

    DEFINE VARIABLE hSaxHandler         AS HANDLE   NO-UNDO .
    DEFINE VARIABLE hSaxReader          AS HANDLE   NO-UNDO.
    DEFINE VARIABLE lcCharacterData     AS LONGCHAR NO-UNDO . 
    DEFINE VARIABLE lExpectingCharacter AS LOGICAL  NO-UNDO INIT FALSE .

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the OpenEdgeDocParser class
        Notes:   
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC OpenEdgeDocParser ():
		SUPER ().
		
        FIX-CODEPAGE (lcCharacterData) = "utf-8":U . 

        RUN Consultingwerk/sax-reader-handler.p 
            PERSISTENT SET hSaxHandler (THIS-OBJECT) .
				
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Parses/searches html documents in the OpenEdge HTML Documentation
                 for documents containing classes/interfaces and creates a document
                 index
        Notes:   
        @param pcFolder The name of the folder to parse html documents in 
        @param ttClassDocumentation OUTPUT Temp-Table with the document index 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID ParseClassDocumentation (pcFolder AS CHARACTER,
                                                OUTPUT TABLE ttClassDocumentation):

        DEFINE VARIABLE iIndex     AS INTEGER  NO-UNDO.
        DEFINE VARIABLE i          AS INTEGER  NO-UNDO LABEL "i":U      FORMAT "->,>>>,>>9":U .
        DEFINE VARIABLE iCount     AS INTEGER  NO-UNDO LABEL "iCount":U FORMAT "->,>>>,>>9":U .
        DEFINE VARIABLE lcDocument AS LONGCHAR NO-UNDO.

        EMPTY TEMP-TABLE ttClassDocumentation . 
        
        Consultingwerk.Util.FileHelper:GetFileList (pcFolder,
                                                    "langref*.html":U,
                                                    OUTPUT TABLE ttFileNames) .

        FOR EACH ttFileNames:
            ASSIGN iCount = iCount + 1. 
        END.

        CREATE SAX-READER hSaxReader . 
        hSaxReader:SUPPRESS-NAMESPACE-PROCESSING = TRUE . 
        hSaxReader:VALIDATION-ENABLED = FALSE . 
        hSaxReader:HANDLER = hSaxHandler . 

        FOR EACH ttFileNames ON ERROR UNDO, THROW:

            i = i + 1 . 

            DISPL i iCount ttFileNames.FileName FORMAT "x(50)":U . 
            PAUSE 0 . 
            PROCESS EVENTS . 

            COPY-LOB FROM FILE ttFileNames.FileName TO lcDocument .
    
            /* Mike Fechner, Consultingwerk Ltd. 17.02.2013
               Remove name space references from html source will greatly 
               enhance the parsing performance. */
            lcDocument = REPLACE (lcDocument, 
                                  "xmlns=~"http://www.w3.org/1999/xhtml~"":U,
                                  "":U) .
    
            lcDocument = REPLACE (lcDocument,
                                  "<!DOCTYPE html PUBLIC ~"-//W3C//DTD XHTML 1.0 Transitional//EN~" ~"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd~">":U,
                                  "":U) .
    
            hSaxReader:SET-INPUT-SOURCE ("LONGCHAR":U, lcDocument).
            
            hSaxReader:SAX-PARSE () .                

            IF STRING (lcCharacterData) MATCHES "* class*":U OR 
               STRING (lcCharacterData) MATCHES "* interface*":U THEN DO:
                CREATE ttClassDocumentation.
                ASSIGN ttClassDocumentation.FileName  = FileHelper:ShortFileName (ttFileNames.FileName) . 
                       ttClassDocumentation.ClassName = ENTRY (1, STRING (lcCharacterData), " ":U) . 
            END.
        END.

        FINALLY:
            IF VALID-HANDLE (hSaxReader) THEN 
                DELETE OBJECT hSaxReader . 
        END FINALLY.

    END METHOD .

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
                                      piNumChars  AS INTEGER):

        IF lExpectingCharacter THEN 
            ASSIGN lcCharacterData = lcCharacterData + plcCharData .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Invoked when the XML parser detects the end of an XML document.                                                                     
        Notes:                                                                        
        @param pcNamespaceURI A character string indicating the namespace URI of the element. If namespace processing is not enabled or the element is not part of a namespace, the string is of length zero.
        @param pcLocalName A character string indicating the non-prefixed element name. If namespace processing is not enabled, the string is of length zero.
        @param pcName A character string indicating the actual name of the element in the XML source. If the name has a prefix, qName includes it, whether or not namespace processing is enabled.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SaxEndElement (pcNamespaceURI AS CHARACTER,
                                      pcLocalName    AS CHARACTER, 
                                      pcName         AS CHARACTER):
        

        CASE pcName:
            WHEN "title":U THEN DO:
                ASSIGN lExpectingCharacter       = FALSE .
                
                hSaxReader:STOP-PARSING () .
            END.
        END CASE . 

    END METHOD .

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
                                        phAttributes   AS HANDLE):
        
        CASE pcName:
            WHEN "title":U THEN DO:
                ASSIGN lcCharacterData           = "":U
                       lExpectingCharacter       = TRUE .
            END.
        END CASE . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Destructor for the OpenEdgeDocParser class                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DESTRUCTOR PUBLIC OpenEdgeDocParser ():

        IF VALID-HANDLE (hSaxHandler) THEN 
            DELETE OBJECT hSaxHandler . 

    END DESTRUCTOR.

END CLASS.
