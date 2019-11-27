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
    File        : AssemblyParser
    Purpose     : Parses an verifies the contents of the assemblies.xml
                  file
    Syntax      :
    Description :
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Aug 24 20:48:20 CEST 2013
    Notes       :
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.*                       FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .
USING Consultingwerk.Util.*                  FROM PROPATH .
USING Consultingwerk.Studio.AssemblyParser.* FROM PROPATH .
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Studio.AssemblyParser.AssemblyParser
    IMPLEMENTS ISaxReader:

    {Consultingwerk/Studio/AssemblyParser/ttAssemblies.i}

    DEFINE VARIABLE hSaxHandler          AS HANDLE        NO-UNDO .

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the AssemblyParser class
        Notes:   Parses the assemblies.xml file in the session -assemblies folder
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AssemblyParser ():

        &IF "{&WINDOW-SYSTEM}":U BEGINS "MS-WIN":U &THEN
        THIS-OBJECT (Progress.ClrBridge.AssemblyStore:Instance:AssembliesPath) .
        &ELSE
        UNDO, THROW NEW Progress.Lang.AppError ("Not supported on this platform.", 0) .
        &ENDIF

    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the AssemblyParser class
        Notes:
        @param pcAssemblies The folder that contains the assemblies.xml file
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC AssemblyParser (pcAssemblies AS CHARACTER):

        DEFINE VARIABLE hSaxReader AS HANDLE    NO-UNDO .
        DEFINE VARIABLE cFileName  AS CHARACTER NO-UNDO .

        SUPER ().

        ASSIGN cFileName = SUBSTITUTE ("&1/assemblies.xml":U,
                                       pcAssemblies) .

        FILE-INFORMATION:FILE-NAME = cFilename .
        IF FILE-INFORMATION:FULL-PATHNAME = ?  THEN
            UNDO, THROW NEW Progress.Lang.AppError (SUBSTITUTE ("Invalid file: &1":U, cFileName), 0) .

        RUN Consultingwerk/sax-reader-handler.p
            PERSISTENT SET hSaxHandler (THIS-OBJECT) .

        CREATE SAX-READER hSaxReader .
        hSaxReader:HANDLER = hSaxHandler .

        hSaxReader:SET-INPUT-SOURCE ("FILE":U, cFileName).

        hSaxReader:SAX-PARSE () .

        FINALLY:
            IF VALID-HANDLE (hSaxReader) THEN
                DELETE OBJECT hSaxReader .

            IF VALID-HANDLE (hSaxHandler) THEN
                DELETE OBJECT hSaxHandler .
        END FINALLY.

    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the ttAssemblies Temp-Table to the Caller
        Notes:
        @param ttAssemblies OUTPUT Temp-Table from Consultingwerk/Studio/AssemblyParser/ttAssemblies.i
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GetTable (OUTPUT TABLE ttAssemblies):

        /* noop */

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
                                      piNumChars AS INTEGER):

        /* noop */

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Invoked when the XML parser detects the end of an XML document.
        Notes:
        @param pcNamespaceURI A character string indicating the namespace URI of the element. If namespace processing is not enabled or the element is not part of a namespace, the string is of length zero.
        @param pcLocalName A character string indicating the non-prefixed element name. If namespace processing is not enabled, the string is of length zero.
        @param pcName A character string indicating the actual name of the element in the XML source. If the name has a prefix, qName includes it, whether or not namespace processing is enabled.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID SaxEndElement (pcNamespaceURI AS CHARACTER,
                                      pcLocalName AS CHARACTER,
                                      pcName AS CHARACTER):

        /* noop */

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
                                        pcLocalName AS CHARACTER,
                                        pcName AS CHARACTER,
                                        phAttributes AS HANDLE):

        DEFINE VARIABLE cName       AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cProperties AS CHARACTER           NO-UNDO .
        /*DEFINE VARIABLE oDictionary AS CharacterDictionary NO-UNDO .*/

        IF pcName = "assembly":U THEN DO ON ERROR UNDO, THROW:

            ASSIGN cName = phAttributes:GET-VALUE-BY-QNAME ("name":U) .

            IF cName > "":U THEN DO ON ERROR UNDO, THROW:
                CREATE ttAssemblies.
                ASSIGN ttAssemblies.AssemblyEntry  = cName
                       ttAssemblies.AssemblyName   = ENTRY (1, cName).

/***
                IF INDEX (cName, ",":U) > 0 THEN DO ON ERROR UNDO, THROW:
                    cProperties = SUBSTRING (cName, INDEX (cName, ",":U) + 1, -1, "CHARACTER":U) .

                    oDictionary = ListHelper:AlternatingListToDictionary
                                       (cProperties, ",":U, "=":U) .

                    IF oDictionary:ContainsKey ("Version":U) THEN
                        ttAssemblies.Version = oDictionary:GetValue ("Version":U) .

                    IF oDictionary:ContainsKey ("Culture":U) THEN
                        ttAssemblies.Culture = oDictionary:GetValue ("Culture":U) .

                    IF oDictionary:ContainsKey ("PublicKeyToken":U) THEN
                        ttAssemblies.PublicKeyToken = oDictionary:GetValue ("PublicKeyToken":U) .

                    FINALLY:
                        GarbageCollectorHelper:DeleteObject (oDictionary) .
                    END FINALLY.
                END.
***/
            END.
        END.

    END METHOD .

END CLASS.
