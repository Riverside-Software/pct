/**
 * Copyright 2005-2024 Riverside Software
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

class rssw.pct.AbstractLoadCallback implements rssw.pct.ILoadCallback:

  method public void beforeUnfreeze():
    // No-op
  end method.

  method public void beforeFileList():
    // No-op
  end method.

  method public void beforeFile(file as character):
    // No-op
  end method.

  method public void afterFile(file as character, logger as rssw.pct.LoadLogger):
    // No-op
  end method.

  method public void afterFileList():
    // No-op
  end method.

  method public void beforeRefreeze():
    // No-op
  end method.

  method public void afterRefreeze():
    // No-op
  end method.

end class.
