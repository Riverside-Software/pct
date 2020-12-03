/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

CLASS rssw.pct.AbstractCompileCallback IMPLEMENTS rssw.pct.ICompileCallback ABSTRACT:
  METHOD PUBLIC VOID initialize(hSrcProc AS HANDLE):
    // No-op
  END METHOD.

  METHOD PUBLIC INTEGER beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
    RETURN 0.
  END METHOD.

  METHOD PUBLIC VOID afterCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
    // No-op
  END METHOD.

END CLASS.
