 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Factory for DataAccess objects
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Aug 06 09:11:08 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ServerCommand.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.ServerCommand.ServerCommandFactory: 
    define property ServiceName as character no-undo get. private set.
    
    constructor ServerCommandFactory ( name as char):
		super ().	
        this-object:ServiceName =  name. 
	end constructor.
        
    method public IServerCommand GetCommand(name as char):
        define variable cmd as IServerCommand no-undo.
        create alias "dictdb" for database value(ServiceName).
        do on error undo, throw:
            /* case sensitive on unix !*/
            cmd = dynamic-new "OpenEdge.DataAdmin.ServerCommand." + name + "Command" (ServiceName). 
         
            catch e as Progress.Lang.Error :
                undo, throw new UnsupportedOperationError("ServerCommandFactory cannot provide ServerCommand for " + quoter(name) + "."
                                  + "~n" + e:GetMessage(1)).
            end catch.
        end.
        return cmd.  
    end method.    
    
    
     
end class.
