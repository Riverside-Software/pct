/**********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : get-service.i
    Purpose     : Simplify the access of services form the default
                  service container  

    Syntax      : {Consultingwerk/get-service.i <ABL Service Type Name (Class)>} 
                  {Consultingwerk/get-service.i Consultingwerk.BusinessEntityDesigner.Services.IFieldNameGeneratorService}

                  Optinal second parameter: A reference (NEW statament) to the 
                  default service implementation

    Description : Returns a reference to a service of a give type, typically
                  an Interface type. Allows singleton like classes (framework
                  components) that are not tied to an actual class name, but
                  to an interface  

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Aug 02 14:12:07 CEST 2011
    Notes       : Sess Consultingwerk.Framework.ServiceContainer
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */

&IF "{2}":U EQ "":U &THEN

CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                (Progress.Lang.Class:GetClass ("{1}":U)),
                 {1})
                 
&ELSE

(IF VALID-OBJECT (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                            (Progress.Lang.Class:GetClass ("{1}":U))) THEN

    CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                (Progress.Lang.Class:GetClass ("{1}":U)), {1})
    ELSE
    CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:AddService
                (Progress.Lang.Class:GetClass ("{1}":U), {2}), {1})
)
&ENDIF
