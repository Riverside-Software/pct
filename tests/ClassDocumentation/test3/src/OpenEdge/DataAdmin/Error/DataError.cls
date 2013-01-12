 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : DataError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Jul 14 13:16:00 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Error.DataError inherits DataAdminError: 
    	
	constructor public DataError (cMsg as char):
        this-object(cMsg,?).
    end constructor.
	
	constructor public DataError (e as error):
	    this-object(e:GetMessage(1),e ).
	end constructor.
    
    constructor public DataError (cMsg as char,  e as error):
        super (cMsg,e ).
        HTTPErrorNum = 200.
    end constructor.
        
    method protected character TransformMessage(cEntity as char, e as Error):
        define variable msg as character no-undo.
        case e:GetMessageNum(1):
            when 132 then
            do:
                msg = e:GetMessage(1).
                entry(2,msg," ") = cEntity.
                msg = replace(msg,"(" + string(e:GetMessageNum(1)) + ")","").
                return msg.
            end.
            otherwise 
                return e:GetMessage(1).
        end.
        
    end method.     

end class.
