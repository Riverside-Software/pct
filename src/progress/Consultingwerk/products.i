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
    File        : products.i
    Purpose     : Contains compile time flags indicating the available
                  Consultingwerk framework products / developer toolkits  

    Syntax      : include file

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Feb 03 21:35:47 CET 2011
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Mike Fechner, Consultingwerk Ltd. 08.08.2011
   The GUI for .NET products do require compilation on 
   MS Windows anyhow - so this seems like a good practice */
&IF "{&WINDOW-SYSTEM}":U BEGINS "MS-WIN":U &THEN  
/*&GLOBAL-DEFINE Dynamics4NET*/
/*&GLOBAL-DEFINE SmartComponentLibrary*/
/*&GLOBAL-DEFINE WinKit*/
&ENDIF
/*&GLOBAL-DEFINE SmartFramework*/
/*&GLOBAL-DEFINE OpenEdgeBPM   */
/*&GLOBAL-DEFINE WinKitDemo    */

/* Mike Fechner, Consultingwerk Ltd. 15.12.2011
   The use of the SimpleDynamicsRepositoryService is optional, requires an ICFDB */
/*&GLOBAL-DEFINE UseSimpleDynamicsRepositoryService*/

/* default path to OERA Service Interface */
/*&GLOBAL-DEFINE OERASI OERA/support*/

/* Compilation allowed that accesses .NET classes?
   In 10.2B it would be sufficient to test for
   "{&WINDOW-SYSTEM}". For OE11 support for .NET 
   on the AppServer Character client is announced.
   Currently we do expect that in OE11 the test 
   for "{&WINDOW-SYSTEM} would not be sufficient 
   to know if .NET assemblies are accesible. */
   
&GLOBAL-DEFINE DotNetAccessible 

/* Include conditional compilation for Infragistics Controls */
&GLOBAL-DEFINE Infragistics

/* Ability to explude procedural OERA from prosi... procedures.

   The support for the procedural OERA is now optional in the 
   service interface. To disable the support, please set the 
   ExcludeProceduralOERA in Consultingwerk/products.i. When set, 
   Business Entity Names without a . (dot) will be considered 
   object-oriented. It's no longer required to deploy beSupport.p, 
   daSupport.p and service.p when using this option. 

   Note, the use of the procedural business entities is still 
   supported. However we've received requests from customers just 
   using the OO versions of the business entities that this is 
   considered unnecessary legacy code... As the OO OERA backend 
   has more functionality (e.g. FindOnServer, backwards batching) 
   we do not intend to implement an "ExcludeObjectOrientedOERA" 
   switch for customers that are not (yet) using OO business 
   entities. */
/*&GLOBAL-DEFINE ExcludeProceduralOERA*/
 
/* Mike Fechner, Consultingwerk Ltd. 03.01.2012
   Title of the Progress IDE (OpenEdge Architect 
   or Progress Developer Studio for OpenEdge */
&IF PROVERSION GE "11" &THEN
&GLOBAL-DEFINE ProgressIDE Progress Developer Studio for OpenEdge
&ELSE 
&GLOBAL-DEFINE ProgressIDE OpenEdge Architect 
&ENDIF 

/* Mike Fechner, Consultingwerk Ltd. 12.06.2012
   Ability to customize the Consultingwerk.Forms.BaseForm and 
   Consultingwerk.WindowIntegrationKit.Forms.EmbeddedWindowBaseForm
   classes without having to modify the actual classes itself */
&GLOBAL-DEFINE CustomBaseFormImplements   
&GLOBAL-DEFINE CustomBaseFormIncludeFile 
&GLOBAL-DEFINE CustomBaseFormConstructorInclude 
&GLOBAL-DEFINE CustomBaseFormDestructorInclude 
&GLOBAL-DEFINE CustomBaseFormUsingInclude 

&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormImplements   
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormIncludeFile
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormConstructorInclude 
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormDestructorInclude 
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormUsingInclude

/* Mike Fechner, Consultingwerk Ltd. 27.01.2012
   Support for Actional Instrumentation, only with OpenEdge 11.0, no longer supported on OpenEdge 11.1 */
&IF PROVERSION EQ "11.0" &THEN
&GLOBAL-DEFINE ActionalInstrumentation   
&ENDIF   

/* Mike Fechner, Consultingwerk Ltd. 24.11.2012
   Optional Support for ZeroMQ for inter process communication */
/*&GLOBAL-DEFINE UseZeroMQ*/
   