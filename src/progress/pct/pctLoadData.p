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
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
function FileExists returns logical (input cFile as character) forward.

define variable cLine as character no-undo.
define variable i     as integer   no-undo.

/*
 * Parameters from ANT call
 */
define variable cSrcDir    as character no-undo.
define variable cTableList as character no-undo.

define stream sParams.

/*
 * Checks for valid parameters
 */
if (session:parameter = ?) then
   return '1'.

if not FileExists(session:parameter) then
   return '2'.

/*
 * Reads config
 */
input stream sParams from value(file-info:full-pathname).
repeat:
   import stream sParams unformatted cLine.
   if (num-entries(cLine, '=':U) = 2) then
   case entry(1, cLine, '=':U):
      when 'TABLES':U then
         assign cTableList = entry(2, cLine, '=':U).
      when 'SRCDIR':U then
         assign cSrcDir = entry(2, cLine, '=':U).
      otherwise
         message "Unknown parameter: " + cLine.
   end case.
end.
input stream sParams close.

if not FileExists(cSrcDir) then do:
   message "Source Directory does not exist".
   return "1":U.
end.

if cTableList = '':U then
   run prodict/load_d.p ("ALL":U, cSrcDir + '/').
else
   run prodict/load_d.p (cTableList, cSrcDir). 

return "0":U.

function FileExists returns logical (input cFile as character):
   assign file-info:file-name = cFile.
   return (file-info:full-pathname <> ?).
end function.
