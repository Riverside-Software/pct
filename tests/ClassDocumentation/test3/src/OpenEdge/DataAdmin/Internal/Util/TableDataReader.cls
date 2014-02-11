 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableDataReader
    Purpose     : wrapper for dataadmin .d import
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28 
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Util.ITableImportUtility.
using OpenEdge.DataAdmin.Internal.Util.TableDataUtility.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.TableDataReader inherits TableDataUtility implements ITableImportUtility: 
    define public property AcceptableErrorPercentage as int no-undo get. set.
    define public property IgnoreMissingFiles        as log no-undo get. set.
    define public property IgnoreMissingDirectories  as log no-undo get. set.
	
	constructor public TableDataReader ( ):
        super ("TableDataReader").
	end constructor.
    
    method protected override void Serialize():
        /* assigns tt fields for super class */
        super:Serialize().
        assign 
            ttUtilityOptions.AcceptableErrorPercentage = this-object:AcceptableErrorPercentage
            ttUtilityOptions.IgnoreMissingFiles = this-object:IgnoreMissingFiles
            ttUtilityOptions.IgnoreMissingDirectories = this-object:IgnoreMissingDirectories
            .
    end method.     
    
    method protected override void Deserialize():
        /* assigns properties  for super class */
        super:Deserialize().
        assign 
            this-object:AcceptableErrorPercentage = ttUtilityOptions.AcceptableErrorPercentage
            this-object:IgnoreMissingFiles        = ttUtilityOptions.IgnoreMissingFiles
            this-object:IgnoreMissingDirectories  = ttUtilityOptions.IgnoreMissingDirectories
            .
             
    end method.     
    
    method protected override char GetValidateQuery():
        return "IsAvailable = 'false' or CanImport = 'false'".
    end method.
          
end class.