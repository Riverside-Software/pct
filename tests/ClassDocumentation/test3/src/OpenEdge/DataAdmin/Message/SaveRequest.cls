 
 /*------------------------------------------------------------------------
    File        : SaveRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Sep 30   2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Message.* from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Message.SaveRequest inherits DataAdminMessage 
                                             implements ISaveRequest: 
        /*
    constructor public SaveRequest (h as handle ):
		super (h).	
	end constructor.
    
    constructor public SaveRequest (h as handle, pcurl as char ):
        super (h,pcurl).  
    end constructor.
    
    constructor public SaveRequest (ctnxtid as char,h as handle, pcurl as char ):
        super (ctnxtid,h,pcurl).  
    end constructor.
     */ 
    constructor public SaveRequest (name as char,ctnxtid as char,h as handle):
        super (name,ctnxtid,h).      
    end constructor.
   
end class.