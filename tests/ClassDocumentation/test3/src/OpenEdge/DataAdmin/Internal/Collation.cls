 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /** ------------------------------------------------------------------------
    Purpose     : Collation - not in use in 11.0.0
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       :  
----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Entity from propath.

using OpenEdge.DataAdmin.Internal.Collation from propath.
using OpenEdge.DataAdmin.Internal.ICollation from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
 

class OpenEdge.DataAdmin.Internal.Collation abstract inherits Entity implements ICollation use-widget-pool: 
 
    constructor public Collation (cntxt as IDataAdminContext ):
        super (cntxt).    
/*        Context = cntxt.*/
    end constructor.
    
    /* return local contaxt if needed (if entity has child collections).  */ 
    method protected override IDataAdminContext CreateLocalContext().
        return ?.
    end method.
    
end class.
 
