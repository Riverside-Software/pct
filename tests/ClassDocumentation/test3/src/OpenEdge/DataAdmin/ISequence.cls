/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : interface for sequence (data source _sequence)
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
 
using OpenEdge.DataAdmin.ISequenceValueMap from propath.
using OpenEdge.DataAdmin.ISchema from propath.
 
interface OpenEdge.DataAdmin.ISequence inherits IDataAdminElement :  
    /** Name and unique identifier */
    define public property Name           as char no-undo get. 
    
    /** Schema  */
    define public property Schema         as ISchema no-undo get. 
    
    /** Returns true if the sequence is multi-tenant enabled.
        Can only be edited before the sequence is created.  */
    define public property IsMultitenant  as logical no-undo get. set.
    
    /** The initial value of the sequence   */
    define public property InitialValue   as int64 no-undo get. set.
   
    /** The maximum value of the sequence   */
    define public property MaximumValue   as int64 no-undo get. set.
    
    /** Collection of all tenant sequence values for a Multi-tenant sequence 
        Restricted access - Only a super tenant can see other sequence values for other tenants */
    define public property SequenceValues as ISequenceValueMap no-undo  get.  
    
    /* The current value for a shared (non Multi-tenant) sequence */
    define public property CurrentValue   as int64 no-undo get. set.
    
    /** The minimum value of the sequence   */
    define public property MinimumValue   as int64 no-undo get. set.
    
    /** The increment value of the sequence   */
    define public property IncrementValue as int64 no-undo get. set.
    
    /** Defines whether the sequence is cyclic or not */  
    define public property IsCyclic       as logical no-undo get. set.
  
end interface.
