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
    File        : dsClassDocumentation.i
    Purpose     : Dataset for Class Documentation

    Syntax      :

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Sep 11 05:51:28 CEST 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

&SCOPED-DEFINE ACCESS {&ACCESS}
&SCOPED-DEFINE REFERENCE-ONLY {&REFERENCE-ONLY}

{ Consultingwerk/Studio/ClassDocumentation/eUnit.i }
{ Consultingwerk/Studio/ClassDocumentation/eInterfaces.i }
{ Consultingwerk/Studio/ClassDocumentation/eConstructor.i }
{ Consultingwerk/Studio/ClassDocumentation/eMethod.i }
{ Consultingwerk/Studio/ClassDocumentation/eParameter.i }
{ Consultingwerk/Studio/ClassDocumentation/eProperty.i }
{ Consultingwerk/Studio/ClassDocumentation/eEvent.i }
{ Consultingwerk/Studio/ClassDocumentation/eUsing.i }

DEFINE {&ACCESS} DATASET dsClassDocumentation {&REFERENCE-ONLY} FOR 
    eUnit, eInterfaces, eConstructor, eMethod, eParameter, eProperty, eEvent, eUsing
    .    
