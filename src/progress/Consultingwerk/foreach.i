/**********************************************************************
 * Copyright 2013 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        * 
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : foreach.i
    Purpose     : Simplify the usage of Enumerators in the ABL, similar 
                  to the foreach statement in C# 

    Syntax      : {foreach <itemtype> <itemvariable> in <list>}
                  Consultingwerk/foreach.i System.Collections.DictionaryEntry oEntry in THIS-OBJECT:Model:Shapes
                  
                  The third parameter "in" should always be "in", to simulate the C# syntax.
            
                  The fifth parameter may be set as "nodefine" to avoid the creation 
                  of the variables
                  
    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri May 06 13:32:39 CEST 2011
    Notes       : See http://msdn.microsoft.com/en-us/library/ttw7t8t6(v=vs.71).aspx
                  for a reference of the C# foreach statement
  ----------------------------------------------------------------------*/

&IF "{5}" NE "nodefine" &THEN
    DEFINE VARIABLE {2}           AS {1} NO-UNDO . 
    DEFINE VARIABLE {2}Enumerator AS System.Collections.IEnumerator NO-UNDO . 
&ENDIF    
    
    ASSIGN {2}Enumerator = CAST({4}, System.Collections.IEnumerable):GetEnumerator() .
    
    {2}Enumerator:Reset() .
    
    DO WHILE {2}Enumerator:MoveNext() ON ERROR UNDO, THROW:
        ASSIGN {2} = CAST({2}Enumerator:Current, {1}) .  
