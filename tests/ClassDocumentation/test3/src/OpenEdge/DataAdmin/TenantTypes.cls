 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Valid values for tenant:type 
    Syntax      : tenant = new Tenant("MyTenant").
                  tenant:Type = TenantTypes:Regular.
    Description : 
    Author(s)   : hdaniels
    Created     : 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

routine-level on error undo, throw.

class  OpenEdge.DataAdmin.TenantTypes  : 
    define public static variable Regular as char init "Regular" no-undo. 
  	define public static variable Super as char init "Super" no-undo. 
    define public static variable Default as char init "Default" no-undo. 
    
	constructor static TenantTypes (  ):
	end constructor.


end class.