 /*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
  
 /*------------------------------------------------------------------------
    File        : Log
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Oct 21  2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

class OpenEdge.DataAdmin.Core.FileLogger: 
    define stream log.
	define public property FileName as character no-undo 
	get.
	set. 
    
    define public property TaskName as character no-undo 
    get.
    set. 
    
    define public property DateFormat as character no-undo 
    init "ymd"
    get.
    set. 
    
	constructor public FileLogger ( pFileName as character  ):
		super ().
		FileName = pFileName.
	    output stream log to value(FileName).
	end constructor.

    method public void Log(pcStatus as char):
        define variable cdf as character no-undo.
        define variable cTask as character no-undo.
        cdf = session:date-format.
        if TaskName > "" then 
            cTask = TaskName + ":".
        
        session:date-format = DateFormat.
       
        put stream log unformatted now " " cTask pcStatus skip.        
        
        session:date-format = cdf.
       
    end method.
    
    destructor public FileLogger (  ):
        output stream log close.
    end .        
end class.