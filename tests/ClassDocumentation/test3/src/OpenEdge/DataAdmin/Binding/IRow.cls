/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/** ------------------------------------------------------------------------
    Purpose     : Wrapper for passing row info in messages/events 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Oct 08 14:17:49 EDT 2011
    Notes       : A standard implementations are expected to be lightweight without 
                  any object references that may prevent garbage collection.
                  IRequestInfo is allowed (RequestInfo property inherited from IElement), 
                  since it should have no references whatsoever. 
               -  Implementers will need to take care of destroying the object if 
                  refrences are needed.    
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Core.IElement from propath.

interface OpenEdge.DataAdmin.Binding.IRow inherits IElement:  
    /** serializename is used in child and parent defintitions  */
    define public property SerializeName as character no-undo get. 
    
    /** is  - true means that values are not refrehsed 
            - use for message only don't store  */
    define public property IsSnapShot as logical no-undo get. 
    
    /** comma separated list of keyfields */
    define public property KeyFields as character no-undo get. 
    
    /** comma separated list of fields whose value is available in GetColumnValue
        blank means none. It is undefined and up to the implementer of an instance to decide 
        whether the KeyFields values are available here or not. */
    define public property FieldNames as character no-undo get. 

    /** returns the values that correspond to KeyFields for this row */
    define public property KeyValues as character extent no-undo get. 

    /** returns the value that correspond to a single entry KeyField for this row */
    define public property KeyValue as character  no-undo get. 
    
    /** returns the integer value that correspond to a single entry KeyField for this row */
    define public property KeyIntValue as integer  no-undo get. 
    
    /** Optional character value of a field, also internal fields that are defined as 
        serialize-hidden and not accessible as properties in the corresponding IDataAdminElement, 
        for example relation fields. Note that optional means that the method typically will 
        throw an error in most implementations as the method only need to support fields 
        that are needed for object communication. The FieldNames property can be used to check 
        if a call to the method would throw an error. 
     -  Expected to throw error for references that cannot be returned. 
        The error is typically IllegalArgument, but it could  also throw UnsupportedOperation 
        if no columns are supported or for columns that exists, but are not currently supported.
        Note that it may also throw IllegalArgument for this case, so implementers are not required to have info about all
        theoretically possible values. */

    method public character FieldValue(pcColumn as char).
  
end interface.