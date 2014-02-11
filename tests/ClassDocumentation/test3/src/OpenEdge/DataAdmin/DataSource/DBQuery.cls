/*------------------------------------------------------------------------------
  Purpose:     DBQuery   
  Parameters:  pcTables         - Buffer names. 
               pcPhysicalTables - Physical names.          
  Notes:                 
------------------------------------------------------------------------------*/
routine-level on error undo, throw.   
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.Query.DataAdminQuery from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.DataSource.DBQuery  inherits DataAdminQuery    :
  
  define public override property Tables as char no-undo
      get.
      protected set.
  
  define protected property TempSourceBuffer as handle no-undo
      get.
      private set.
  
  constructor public DBQuery(pcTables as char,pcKeyFields as char): 
       this-object(pcTables,pcTables,pcKeyFields).
  end constructor.
  
  constructor public DBQuery(pcTables as char,pcPhysicalTables as char,pcKeyFields as char): 
  
     
    if pcPhysicalTables = '' then
       pcPhysicalTables = pcTables.
    assign
        PhysicalTables = pcPhysicalTables
        Tables         = pcTables  
        KeyFields      = pcKeyFields
        QueryMode = "FOR"
        QueryLock = "NO-LOCK".
  end constructor.
  
  constructor public DBQuery(phTempSource as handle,pcTables as char,pcPhysicalTables as char,pcKeyFields as char): 
      this-object(phTempsource:name + "," + pcTables,phTempsource:name + "," + pcPhysicalTables,pcKeyFields).   
      TempSourceBuffer = phTempSource.
  end constructor.
  
  /* add temp source at end */
  constructor public DBQuery(pcTables as char,pcPhysicalTables as char,pcKeyFields as char,phTempSource as handle): 
      this-object(pcTables,phTempsource:name + "," + pcPhysicalTables,pcKeyFields + "," + phTempsource:name ).   
      TempSourceBuffer = phTempSource.
  end constructor.
  
   method protected override handle extent GetBufferHandles():
        undo, throw new UnsupportedOperationError("GetBufferHandles called in DataSource.").
   end method.    
    
  
  method override protected void CreateQuery():
      define variable iBuffer    as integer no-undo.
      define variable hBuffer    as handle  no-undo.
      
      define variable cPhysTable as character no-undo.
      DeleteQuery().
      create query QueryHandle.
      do iBuffer = 1 to num-entries(PhysicalTables):
          cPhysTable = entry(iBuffer,PhysicalTables).
          if valid-handle(TempSourceBuffer) and TempSourceBuffer:name = cPhysTable then
              create buffer hBuffer for table TempSourceBuffer.
          else
              create buffer hBuffer 
                 for table cPhysTable buffer-name entry(iBuffer,Tables).
 
          QueryHandle:add-buffer(hBuffer).
      end.
  end method.
  
end.

