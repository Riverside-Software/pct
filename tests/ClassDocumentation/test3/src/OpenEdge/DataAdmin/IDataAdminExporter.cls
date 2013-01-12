/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** ------------------------------------------------------------------------
    Purpose     : interface for export of data admin serializable object 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Nov 20 14:46:58 EST 2010
    Notes       : 
  --------------------------------------------------------------------- */
 
using OpenEdge.DataAdmin.IDataAdminSerializable from propath.

interface OpenEdge.DataAdmin.IDataAdminExporter:  
          
    /** WriteToFile 
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param FileName file name IDataAdminSerializable is implemented by all entities and collections 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public void WriteToFile(serializable as IDataAdminSerializable,pcFile as char,pcMode as char):
    
    /** WriteToLongchar 
        @returns longchar with exported data  
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public longchar WriteToLongchar(serializable as IDataAdminSerializable,pcMode as char):
    
    /** WriteToMemptr
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param Memptr for output 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public void WriteToMemptr(serializable as IDataAdminSerializable,m as memptr,pcMode as char):    
    
    /** WriteToStream 
        @param Serializable IDataAdminSerializable is implemented by all entities and collections 
        @param Stream-handle 
        @param Mode All, Object - Unsupported,  List - Unsupported 
                    collection names */ 
    method public void WriteToStream(serializable as IDataAdminSerializable,phStream as handle,pcMode as char):
          
end interface.