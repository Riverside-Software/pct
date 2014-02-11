 /*************************************************************/
 /* Copyright (c) 2011 by Progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AllTableDataSource
    Purpose     : All tables (not filtered on PUB and hidden = false)
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jan 31 12:09:33 EST 2012
    Notes       : Currently Only supported for REST.  
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.TableDataSource.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.AllTableDataSource inherits TableDataSource: 
		
	constructor public AllTableDataSource (  ):
		super (yes).
	end constructor.

end class.