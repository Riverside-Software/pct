 
 /*------------------------------------------------------------------------
    File        : DataSaveError
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

class OpenEdge.DataAdmin.Error.DataSaveError inherits DataAdminError: 
    
		
	constructor public DataSaveError (cEntity as char,  e as error):
	    super (TransformMessage(cEntity,e),e ).
	end constructor.

    method private character TransformMessage(c as char, e as Error):
        define variable msg as character no-undo.
        case e:GetMessageNum(1):
            when 132 then
            do:
                msg = e:GetMessage(1).
                entry(2,msg," ") = c.
                msg = replace(msg,"(" + string(e:GetMessageNum(1)) + ")","").
                return msg.
            end.
            otherwise 
                return "Error on save of " + c.
        end.
        
    end method.     

end class.
