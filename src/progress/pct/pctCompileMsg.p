/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ========================?===========================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

DEFINE TEMP-TABLE ttXref NO-UNDO
    FIELD xProcName   AS CHARACTER
    FIELD xFileName   AS CHARACTER
    FIELD xLineNumber AS INTEGER
    FIELD xRefType    AS CHARACTER
    FIELD xObjID      AS CHARACTER.

PROCEDURE importXref.
    DEFINE INPUT  PARAMETER pcFile AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcOut  AS CHARACTER NO-UNDO.

    EMPTY TEMP-TABLE ttXref.

    INPUT FROM VALUE (pcFile).
    REPEAT:
        CREATE ttXref.
        IMPORT ttXref.
        IF ttXref.xRefType EQ 'INCLUDE':U THEN
            ttXref.xObjID = ENTRY(1, TRIM(ttXref.xObjID), ' ':U).
        ELSE
            DELETE ttXref.
    END.
    DELETE ttXref. /* ttXref is non-undo'able */
    INPUT CLOSE.
    OUTPUT TO VALUE (pcOut).
    FOR EACH ttXref NO-LOCK GROUP BY ttXref.xObjID:
    	IF FIRST-OF (ttXref.xObjID) THEN
            PUT UNFORMATTED SEARCH(ttXref.xObjID) SKIP.
    END.
    OUTPUT CLOSE.
END PROCEDURE.

PROCEDURE finish.
    DEFINE INPUT PARAMETER piComp   AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER piNoComp AS INTEGER   NO-UNDO.

    MESSAGE "Compiled " + STRING(piComp) + " file(s)".
    IF (piNoComp NE 0) THEN
        MESSAGE "Failed compile " + STRING(piNoComp) + " file(s)".

END PROCEDURE.
