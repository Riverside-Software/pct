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

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.* FROM PROPATH.
USING OpenEdge.DataAdmin.Binding.IDataDefinitionLoader FROM PROPATH.
USING OpenEdge.DataAdmin.Binding.DataDefinitionOptions FROM PROPATH.

CLASS rssw.pct.LoadOptions INHERITS DataDefinitionOptions:

  CONSTRUCTOR PUBLIC LoadOptions (logger AS OpenEdge.DataAdmin.Binding.IDataDefinitionLoader):
    SUPER (logger).
  END CONSTRUCTOR.

  CONSTRUCTOR PUBLIC LoadOptions (  ):
    THIS-OBJECT(?).
  END CONSTRUCTOR.

END CLASS.
