/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** ------------------------------------------------------------------------
    File        : Base properties needed by entities and for interobject 
                  communication in binding
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Oct 08 13:27:11 EDT 2011
    Notes       : Not expected to have any direct implementations. 
                  Known sub interfaces 
                -  OpenEdge.DataAdmin.IDataAdminElement
                -  OpenEdge.DataAdmin.Binding.IRow
  --------------------------------------------------------------------- */

using Progress.Lang.*.

using OpenEdge.DataAdmin.IRequestInfo from propath.
interface OpenEdge.DataAdmin.Core.IElement:  
    
   /** Tells whether the instance is newly created (not saved to service). 
       Modified is always false when Created is true  */
    define public property Created as logical no-undo           get.
   
    /** Tells whether an instance is modified after it was read from the service. 
        Can only be true for a persisted object and is thus always false if 
        Created is true. */
    define public property Modified as logical no-undo           get.  
end interface.

