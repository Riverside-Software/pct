/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DataAccessError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Aug 06 13:23:06 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.IDataMapper from propath.
using OpenEdge.DataAdmin.Error.DataError from propath.

class OpenEdge.DataAdmin.DataAccess.DataAccessError inherits DataError:    
	/*------------------------------------------------------------------------------
	Purpose:  																	  
	Notes:   																	  
	------------------------------------------------------------------------------*/
		
	constructor public DataAccessError (msg as char ):
		super (msg).
	end constructor.
    
    constructor public DataAccessError (mapper as IDataMapper,e as Error):
        super (TransformMessage(e:GetMessage(1),e:GetMessageNum(1),mapper),e).  
        /* store the mapper if needed for addmessage ?*/
    end constructor.
    
    /* constructor added specifically to handle authenticationsystem already exists 
      (replace "domain type" with "name" in message and pass it as char) */
    constructor public DataAccessError (mapper as IDataMapper,cmsg as char, num as int, e as error):
        super (TransformMessage(cMsg,num,mapper),e).  
    end constructor.

	constructor public DataAccessError ( e as Error ):
		super (input e).
	end constructor.
	
	constructor public DataAccessError ( cMsg as character, e as Error ):
		super (input cMsg, input e).	
	end constructor.

    method protected character TransformMessage(pMsg as char,pNum as int,pMapper as IDataMapper):
        define variable i   as integer no-undo.
        define variable cWord as character no-undo. 
        define variable cTarget as character no-undo. 
        do i = 1 to num-entries(pMsg," "):
           cWord = entry(i,pMsg," ").
           if num-entries(cWord,".") = 1 then                 
               cTarget = pMapper:GetTargetTable(cWord).
         
           if cTarget = "" then
               cTarget = pMapper:GetTargetColumn(cWord).
           
           if cTarget > "" then 
               entry(i,pMsg," ") = cTarget.
                
        end.
        pMsg = replace(pMsg,"(" + string(pNum) + ")","").
        return pmsg.   
    end method.     
    
end class.
