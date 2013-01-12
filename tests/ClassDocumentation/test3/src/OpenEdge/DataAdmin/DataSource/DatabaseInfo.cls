/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DatabaseInfo
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Oct 30 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.      
using Progress.Lang.*.

class OpenEdge.DataAdmin.DataSource.DatabaseInfo: 
    
    define public property DatabaseRecid as recid no-undo 
        get.
        private set.
   
    define public property CodePage as char no-undo 
        get.
        private set.
        
    define public property IsMultiTenant as logical no-undo 
        get.
        private set.
    
    define public property IsUserSuperTenant as logical no-undo 
        get():
            return tenant-id("dictdb") < 0.
        end.
        private set.
    
    define public property StorageFieldJoin as char no-undo 
        get():
            return 
                "_StorageObject._db-recid = " + quoter(DatabaseRecid)
              + " and _StorageObject._object-type = 3"
              + " and _StorageObject._object-number = _field._Fld-stlen". 

        end.
        
    define public property StorageIndexJoin as char no-undo 
        get():
            return 
               "_StorageObject._db-recid = " + quoter(DatabaseRecid)
             + " and _StorageObject._object-type = 2"
             + " and _StorageObject._object-number = _index._idx-num". 
        end.
    
    define public property StorageFileJoin as char no-undo 
        get():
           return "_StorageObject._db-recid = " + quoter(DatabaseRecid)
             + " and _StorageObject._object-type = 1"
             + " and _StorageObject._object-number = _file._file-number".
        end.
    
    define public property FileDBExpression as character no-undo 
        get:
            return "_file._db-recid = " + quoter(DatabaseRecid).
        end.
         
 	define public property FileExpression as character no-undo 
    	get:
	        return FileDBExpression + " and  _file._owner = 'PUB' and _file._hidden = 'false'".
	    end.
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public DatabaseInfo (  ):
		define buffer bdb  for dictdb._db.
        define buffer btnt for dictdb._tenant.
        
		super ().
	    find first bdb where bdb._db-local = true no-lock.  
        this-object:DatabaseRecid = recid(bdb).      
	    this-object:IsMultiTenant = can-find(first btnt).
        this-object:CodePage = bdb._db-xl-name.
  
	end constructor.

               
end class.
	    