/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
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
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

DEFINE INPUT  PARAMETER srcDF      AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER tblspcTab  AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER tblspcIdx  AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER oraDbName  AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER oraVersion AS INTEGER    NO-UNDO.

{ prodict/user/uservar.i NEW }
{ prodict/ora/oravar.i NEW }

ASSIGN user_env[1]  = srcDF
       user_env[2]  = "yes"
       user_env[3]  = ""
       user_env[4]  = "n"
       user_env[5]  = ";"
       user_env[6]  = "y"
       user_env[7]  = "y"
       user_env[8]  = "y"
       user_env[9]  = "ALL"
       user_env[11] = "char" 
       user_env[12] = "date"
       user_env[13] = "number"
       user_env[14] = "number"
       user_env[15] = "number"
       user_env[16] = "number"
       user_env[17] = "number"
       user_env[19] = "number"
       user_env[20] = "##"
       user_env[21] = "y"
       user_env[22] = "ORACLE"
       user_env[23] = "30"
       user_env[24] = "15"
       user_env[25] = "y"
       user_env[27] = "y"
       user_env[28] = "30"
       user_env[29] = "26"
       user_env[31] = "-- ** "
       user_env[32] = ?
       user_env[34] = tblspcTab
       user_env[35] = tblspcIdx.

ASSIGN ora_dbname  = oraDbName
       ora_version = oraVersion
       osh_dbname  = oraDbName.

RUN prodict/ora/_gendsql.p.

