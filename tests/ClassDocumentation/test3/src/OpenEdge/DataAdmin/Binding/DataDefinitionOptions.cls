 
 /*------------------------------------------------------------------------
    File        : DataDefinitionOptions
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Oct 12 13:38:43 EDT 2010
    Notes       : abstract 
                  - prodict/dump/_load_options subclass exists to only 
                    depend on OpenEdge.DataAdmin at compile time.
                
       WARNING  : inherited by prodict/dump/_load_options         
                 used for both load and read/parse 
                - this should ideally be separated ?    
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.DataDefinitionOptions abstract implements IDataDefinitionOptions: 
	
	define public property FileName as char no-undo 
        get. 
        set.
    
    /* init ? - important - signal to not touch session:schema-change
       NOTE: the class supports both SchemaChange and AddObjectsOnline 
             which controls the same behavior. 
          -  SchemaChange could however change if the ABL adds more 
             functionality and is exposed as such in the  
             prodict/load_df.p widely used by customers .   
        */
    define public property SchemaChange as char    no-undo 
        init ? /* WARNING prodict see above */
        get.
        set.     
    
    define public property AddObjectsOnline   as logical no-undo 
        init ? /* WARNING prodict see above */
        get():
           if AddObjectsOnline = ? and SchemaChange <> ? then
               return SchemaChange = "NEW OBJECTS".
           return AddObjectsOnline.            
        end.     
        set(lonline as log):
           if lonline then 
               SchemaChange = "NEW OBJECTS".
           else if lonline = false then   
               SchemaChange = "".
           else
               SchemaChange = ?.
           AddObjectsOnline = lonline.
        end. 
           
    define public property ForceIndexDeactivate as logical no-undo get. set.    
    define public property ForceSharedSchema as logical no-undo get. set.   
    
    define public property ForceCommit        as logical no-undo get. set.   	
	
	define public property Logger as IDataDefinitionLoader no-undo 
        get.
        protected set.
  
	define public property IsLogger  as logical no-undo 
	    get():
            return valid-object(Logger). 
	    end.          
           
	define public property ErrorLog as character no-undo 
        get.
        set. 
    
    constructor public DataDefinitionOptions(loader as IDataDefinitionLoader  ):
        super ().
        Logger = loader. 
    end constructor.

	constructor public DataDefinitionOptions(  ):
		super ().		
	end constructor.

end class.