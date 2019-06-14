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

DEFINE VARIABLE mXML AS MEMPTR NO-UNDO.
DEFINE VARIABLE retVal AS CHARACTER NO-UNDO.

RUN pct/XMLSchema.p (OUTPUT mXML) NO-ERROR.
retVal = RETURN-VALUE.
OUTPUT TO VALUE(SESSION:PARAMETER).
EXPORT mXML.
OUTPUT CLOSE.
SET-SIZE(mXML) = 0.
RETURN retVal.