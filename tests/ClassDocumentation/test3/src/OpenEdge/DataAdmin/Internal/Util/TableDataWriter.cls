 /*************************************************************/
 /* Copyright (c) 2011,2012 by Progress Software Corporation. */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : wrapper for dataadmin .d export
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28 
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.ITableExportUtility.
using OpenEdge.DataAdmin.Internal.Util.TableDataUtility.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.TableDataWriter inherits TableDataUtility
                                                       implements ITableExportUtility: 
	/** IExportUtility  */
    define public property CodePage       as character no-undo get. set.  
    define public property OverwriteFiles as logical no-undo get. set. 
    
    /** ITableExportUtility  */
    define public property NoMap                as logical no-undo get. set.
    define public property CharacterMap         as char no-undo get. set.
    define public property SkipCodePageValidation as logical   no-undo get. set.
      
	constructor public TableDataWriter (  ):
        super ("TableDataWriter").
	end constructor.
    
    method protected override void Serialize():
        /* assigns tt fields for super class */
        super:Serialize().
        assign 
            ttUtilityOptions.CodePage       = this-object:CodePage 
            ttUtilityOptions.OverwriteFiles = this-object:OverwriteFiles
            ttUtilityOptions.NoMap          = this-object:NoMap
            ttUtilityOptions.CharacterMap   = this-object:CharacterMap  
            ttUtilityOptions.SkipCodePageValidation = this-object:SkipCodePageValidation
            .
             
    end method.
    
    method protected override void Deserialize():
        /* assigns properties  for super class */
        super:Deserialize().
        assign 
            this-object:CodePage          = ttUtilityOptions.CodePage 
            this-object:OverwriteFiles    = ttUtilityOptions.OverwriteFiles
            this-object:NoMap             = ttUtilityOptions.NoMap   
            this-object:CharacterMap      = ttUtilityOptions.CharacterMap  
            this-object:SkipCodePageValidation = ttUtilityOptions.SkipCodePageValidation.
            . 
    end method.
    
    method protected override char GetValidateQuery():
        return "IsAvailable = 'true' or CanExport = 'false'".
    end method.
    
end class.