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
using OpenEdge.DataAdmin.Binding.ITableDataMonitor from propath .
using Progress.Lang.Class.

{ prodict/dictvar11.i NEW }
{ prodict/user/uservar113.i NEW }

define variable callbackCls as character no-undo.
define variable callback as rssw.pct.ILoadDataCallback.
define variable ctbl as character no-undo.

assign ctbl = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tableName').
assign callbackCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'callbackClass').
if (callbackCls > "") then do:
    callback = cast(Class:GetClass(callbackCls):new(), rssw.pct.ILoadDataCallback).
end.

if dynamic-function('getParameter' IN SOURCE-PROCEDURE, INPUT 'append') = 'false' then do:
  if valid-object(callback) then callback:beforePurge().

  define variable hFile as handle no-undo.  
  define variable hQuery as handle no-undo.
  
  create buffer hFile for table ctbl.
  create query hQuery.
  hQuery:SET-BUFFERS(hFile).
  hQuery:QUERY-PREPARE('FOR EACH ' + cTbl).
  hQuery:QUERY-OPEN().
  REPEAT TRANSACTION:
      hQuery:GET-NEXT(EXCLUSIVE-LOCK).
      IF hQuery:QUERY-OFF-END THEN LEAVE.
      hFile:buffer-delete().
  END.
  hQuery:QUERY-CLOSE().
  delete object hFile.
  delete object hQuery.
  
  if valid-object(callback) then callback:afterPurge().  
end.

define variable logger as rssw.pct.LoadDataLogger. 
logger = new rssw.pct.LoadDataLogger().
assign dictMonitor = logger. 

if valid-object(callback) then callback:beforeLoad(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName')).  
assign user_env[1] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tableName')
       user_env[2] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'srcdir') + '/' + DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName')
       user_env[3] = "NO-MAP"
       user_env[4] = "100"
       user_env[5] = ""
       user_env[6] = "utf-8".

/*message user_env[1] skip user_env[2] skip user_env[3].*/
find first _db.
      ASSIGN drec_db     = RECID(_Db)
             user_dbname = (IF _Db._Db-name = ? THEN 
                              LDBNAME("DICTDB") ELSE _Db._Db-Name)
             user_dbtype = (IF _Db._Db-name = ? THEN 
                              DBTYPE("DICTDB") ELSE _Db._Db-Type).

run prodict/dump/_loddata.p no-error.
if valid-object(callback) then callback:afterLoad(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName'), logger).  


return "0":U.