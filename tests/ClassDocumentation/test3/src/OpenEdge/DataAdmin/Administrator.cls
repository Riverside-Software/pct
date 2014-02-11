 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : Administrator
    Purpose     : Manage administrators 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Jun 03 12:38:03 EDT 2011
    Notes       : This manages the can-do string that is propagated to 
                  several can* fields in several records in the database.
                - Somewhat of an overkill for a single string...   
                  Could be extended to support list of adminstrators - users 
                  - it is an open question if this then would be a header with a 
                    collection of users or if this class will extend user.
                  - The former would allow us to keep the get in dataadminserver
                    with no parameter and is more consistent with current
                    usage. 
                  - The latter can be handled by getAdministrators() 
                    that returns a collection of these(and no header)                  
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.*.
using Progress.Json.ObjectModel.JsonObject         from propath.
using Progress.Json.ObjectModel.ObjectModelParser  from propath.
using OpenEdge.DataAdmin.IDataAdminElement         from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable   from propath.
using OpenEdge.DataAdmin.Entity                    from propath.
using OpenEdge.DataAdmin.IAdministrator            from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.

class OpenEdge.DataAdmin.Administrator inherits Entity implements IDataAdminElement, IDataAdminSerializable, IAdministrator: 

	define public property Administrators as character no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Administrators.
            else
                return Administrators. 
        end.
        
        set(pAdministrators as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Administrators = pAdministrators.
            end.
            Administrators = pAdministrators.
        end. 

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/		
	constructor public Administrator( cntxt as IDataAdminContext ):
		super (cntxt).
	end constructor.
	
	/* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
     
    method public override void Import(pcfile as char):
        define variable parser as ObjectModelParser no-undo.
        define variable cText as character no-undo.
        define variable json as JSONObject no-undo.   
        parser = new ObjectModelParser().
        json  = cast(parser:ParseFile(pcfile),JSONObject).
        json = json:GetJsonObject(SerializeName). 
        Administrators = json:GetCharacter("administrators").   
    end method.
     
    method public override void Export(pcfile as char):
        define variable root as JSONObject no-undo.   
        define variable body as JSONObject no-undo.   
        root = new JsonObject().
        body = new JsonObject().
        root:Add(SerializeName,body).
        body:Add("administrators",Administrators).
        root:WriteFile(pcFile,yes).
    end method.

end class.