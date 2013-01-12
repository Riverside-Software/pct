 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : ValidationError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Error.ValidationError inherits DataError: 
    define public property EntityName     as char no-undo get. protected set. 
    define public property EntityKey      as char no-undo get. protected set.  	
    define public property PropertyName  as char no-undo get. protected set.   
    
    constructor public ValidationError (cEntity as char, cKey as char, cProp as char, cWhy as char):
        super (cProp + " in " + centity + PaddedKey(ckey) + cWhy + ".").
        EntityName  = cEntity.
        EntityKey   = cKey.
        PropertyName = cProp.
    end constructor.
    
    constructor protected ValidationError (cProp as char, cWhy as char):
        super (cProp + " " + cWhy + ".").
        PropertyName = cProp.
    end constructor.
  
	constructor public ValidationError (cEntity as char, cKey as char, cProp as char):
        this-object(cEntity,cKey,cProp,"has an invalid value").
    end constructor. 
    
    method private char PaddedKey(pkey as char):
        if pkey > "" then 
           return  " " + DispValue(pKey)  + " ".
        else 
           return " ".   
    end method.     
    
    method protected logical IsNumeric(pvalue as char):
        define variable i as integer no-undo.
        i = int(pValue).
        return true.
        catch e as Progress.Lang.Error :
        	return false.	
        end catch.    
    end method.    
    
    method protected character DispValue(pvalue as char):
        if IsNumeric(pvalue) then 
            return pValue.
        else
            return quoter(pvalue).           
    end method.    
    
end class.
