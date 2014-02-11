/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UnknownValueError
    Purpose     : 
    Syntax      : 
                 method void MyOper(param as char):
                    if param = ? 
                        then undo, throw new UnknownValueError("Myoper","param").
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : Use in calls that does not support unknown 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Error.DataAdminError.

class OpenEdge.DataAdmin.Error.UnknownValueError inherits DataAdminError: 
    constructor public UnknownValueError (pOperation as char, parg as char, pcMoretext as char):  
        super("Cannot call " + poperation + " with unknown " + parg + "."
              + if pcMoreText > "" then " " + pcMoreText ELSE "").
    end method. 
    
    constructor public UnknownValueError (pOperation as char, parg as char):  
        this-object(pOperation,parg,"").
    end method. 
     
    constructor public UnknownValueError (pAttribute as char):  
        super("Cannot set " + pAttribute + " to unknown.").
    end method. 
         
end class.
