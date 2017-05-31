/**
 * Copyright 2017 MIP Holdings
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
package za.co.mip.ablduck.utilities;
import java.util.HashMap;

public class CommentParseResult {
    //Remaining formatted comment
    public String comment = "";
    
    //Deprecated version and note from @deprecated
    public String deprecatedVersion = "";        
    public String deprecatedText = "";
    
    //Parameter comments from @param tags
    public HashMap<String, String> parameterComments = new HashMap<>();
    
    //Internal flag from @internal
    public Boolean internal = false;
    
    //Return comment
    public String returnComment = "";
    
    //Author tag
    public String author = "";
}
