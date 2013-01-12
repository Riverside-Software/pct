/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Interface for index 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 02:53:33 EDT 2010
    Notes       : Currently only for MT
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.ISchemaElement from propath.
 
using OpenEdge.DataAdmin.ITable from propath.
 

interface OpenEdge.DataAdmin.IIndex inherits ISchemaElement:
    /** Parent table of the index */
    define public property Table         as ITable    no-undo get. 
    
    /*    define public property Fields        as IFieldSet no-undo get.*/
    
       /** Description of index */
    define public property Description  as character no-undo get.  
    
    /** Returns true if the index is active  */
    define public property IsActive      as logical   no-undo get.  
    
    /** Returns true if the index is unique  */
    define public property IsUnique      as logical   no-undo get.  
    
    /** Returns true if the index is the primary index  */
    define public property IsPrimary     as logical   no-undo get.  
    
    /** Returns true if the index is a word index  */
    define public property IsWordIndex   as logical   no-undo get.  
     
end interface.
