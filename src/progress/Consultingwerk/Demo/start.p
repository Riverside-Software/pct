/*------------------------------------------------------------------------
    File        : start.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Mon Dec 17 13:35:22 UTC 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oParser AS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter NO-UNDO . 

{ Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
{ Consultingwerk/Util/TempTables/ttFileNames.i }

DEFINE VARIABLE oDoc      AS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter      NO-UNDO.
DEFINE VARIABLE oParamter AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter NO-UNDO.

/* ***************************  Main Block  *************************** */

oParamter = NEW Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter ().
ASSIGN oParamter:DocumentationTitle  = "Demo SmartDox":U
       oParamter:TargetDir           = "C:\Work\SmartComponents4NET\Trunk\SmartDoxOSS\Documentation":U
       oParamter:SourceDir           = "C:\Work\SmartComponents4NET\Trunk\SmartDoxOSS\classdoc":U
       oParamter:TemplateSourceDir   = "C:\Work\SmartComponents4NET\Trunk\SmartDoxOSS\Consultingwerk\Studio\ClassDocumentation\Templates":U
       .

oDoc = NEW Consultingwerk.Studio.ClassDocumentation.DocumentationWriter ().
oDoc:GenerateDocumentation (oParamter).