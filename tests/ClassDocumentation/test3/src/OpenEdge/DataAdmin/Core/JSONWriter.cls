/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
 /*************************************************************/
/** ------------------------------------------------------------------------
    Purpose     : Write IDataAdminSerializable in JSON format 
                  to file, longchar, memptr or stream,  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:18:09 EDT 2010
    Notes       : This is often used by the various ExportTree and 
                  Export methods of the objects, but not always                  
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using Progress.Lang.* from propath. 
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Core.DataAdminWriter from propath. 
class OpenEdge.DataAdmin.Core.JSONWriter inherits DataAdminWriter implements IDataAdminExporter:  
     
	constructor public JSONWriter (  ):
		super ().
    end constructor.
      
    /** WriteToFile 
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param FileName  for output (typically .json)
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public void WriteToFile(serializable as IDataAdminSerializable,pcFile as char,pcMode as char):
        define variable h as handle no-undo.
        h = this-object:Write(serializable,pcMode).
        h:write-json ("File",pcFile,yes). 
    end method.
    
    /** WriteToLongchar 
        @returns longchar with exported data  
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */   
    method public longchar WriteToLongchar(serializable as IDataAdminSerializable,pcMode as char):
        define variable h as handle no-undo.
        define variable cl as longchar no-undo.
        h = this-object:Write(serializable,pcMode).
        h:write-json ("Longchar",cl,yes). 
    end method.
    
    /** WriteToMemptr 
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param Memptr for output 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public void WriteToMemptr(serializable as IDataAdminSerializable,m as memptr,pcMode as char):
        define variable h as handle no-undo.
      
        h = this-object:Write(serializable,pcMode).
        h:write-json ("memptr",m,yes). 
    end method.
    
    /** WriteToStream 
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param Stream-handle for output 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public void WriteToStream(serializable as IDataAdminSerializable,phStream as handle,pcMode as char):
        define variable h as handle no-undo.
        
        h = this-object:Write(serializable,pcMode).
        h:write-json ("STREAM-HANDLE",phStream,yes). 
    end method.
    
end class.
