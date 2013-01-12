/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IDataDefinitionOptions
    Purpose     : Pass options to prodict load df
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Oct 2010
    Notes       : See/use extended interfaces/classes for more advanced 
                  options: IDataDefinitionsLoader IDataDefinitionsParser 
       WARNING  : used by prodict/dictvar.i and load of df procedures  
            NOTE: the class supports both SchemaChange and AddObjectsOnline 
                  which controls the same behavior. 
                  -  SchemaChange could however change if the ABL adds more 
                     functionality to session:schema-change. 
                  -  SchemaChange is exposed as character entry "NEW OBJECTS" in   
                     prodict/load_df.p used by (absolutely) everyone.
                  -  The use of character (not just YES, like the other option) 
                     means that users would expect load_df to support new 
                     functionality in session:schema-change. 
                     otherwise we could just translate "new objects"       
                  -  The unknown value in both of these signifies that 
                     ABL schema-change is set from outide. 
                               
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.IDataDefinitionLoader from propath.

interface OpenEdge.DataAdmin.Binding.IDataDefinitionOptions:
      
    /** Name of file with definitions */
    define public property FileName as char no-undo 
        get. 
        set.
    
    /** session:schema-change - "NEW OBJECTS" or blank */
    define public property SchemaChange       as char    no-undo 
        get.
        set.   
        
        
    /** allow online load - same as SchemaChange "NEW OBJECTS" */
    define public property AddObjectsOnline   as logical no-undo 
        get. 
        set.
           
    /** deactivate new indexes */
    define public property ForceIndexDeactivate as logical no-undo get. set.    
    
    /** force shared - ignore multi-tenant attributes  */
    define public property ForceSharedSchema as logical no-undo get. set.   

    /** force commit even if error encountered  */
    define public property ForceCommit        as logical no-undo get. set.      
    
    /** contains load errors if any  */
    define public property ErrorLog as character no-undo 
        get.
        set. 
    
    /** return true if this is a logger     */
    define public property IsLogger as logical no-undo 
        get.
        
    /** logger     */
    define public property Logger as IDataDefinitionLoader no-undo 
        get.
    
    
    
end interface.