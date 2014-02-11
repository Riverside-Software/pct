 
 /*------------------------------------------------------------------------
    File        : DatasetWriter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:44:10 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.ContextWriter implements IContextWriter: 
    define private variable mSummary as character no-undo.
    define variable counter as integer no-undo.
    define variable mDataset as handle no-undo.
    
    define temp-table ttWrite no-undo
        field name as char
        field num as int
        field writehandle as handle
        field list as char
        field rid  as rowid
        field parent as char
        field fieldlist as char
        field filter as char
      index num num  
      index name as unique name.  
    
    method private void addHandle(cname as char, h as handle):
        find ttWrite where ttWrite.name = cname no-error.
        if not avail ttWrite then this-object:add(cname).
        ttWrite.writehandle = h.
    end method.
    
    method private void add(cname as char):
        counter = counter + 1. 
        create ttWrite.
        assign name = cname 
               num = counter.
    end method.    
    
    method private void updateJoin(cname as char,cparent as char,cfields as char):      
        find ttWrite where ttWrite.name = cname no-error.
        if not avail ttwrite then this-object:add(cname).
        assign ttWrite.parent = cparent 
               ttWrite.fieldlist = cfields.
    end method.    
   
    method public void WriteContext(cname as char):
        this-object:add(cname).
    end method.
    
    method public void WriteList(cname as char,cList as char):
        this-object:add(cname).
        ttWrite.list  = clist.
    end method.
    
    method public void WriteJoin(name as char,cParent as char,cFieldPairs as char):
        updateJoin(name,cparent,cfieldpairs).
    end method. 
   
    method public void WriteHandle(name as char,h as handle):
        addHandle(name,h).
    end method.
    
    method public void WriteHandle(name as char, h as handle,filter as char):
        addHandle(name,h).    
        ttWrite.filter  = filter.
    end method.
    
    method public void WriteBuffer(name as char, h as handle, rid as rowid):
        addHandle(name,h).     
        ttWrite.rid  = rid.
    end method. 
    
	method override public character ToString(  ):
	    define variable cc as character no-undo.
	    cc = super:ToString() + chr(10)
	            + getSummary(  ).
	    return right-trim(cc,chr(10)).  
	end method.
	  
	method private char getSummary(  ):    
		define variable iCount as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cc as character no-undo.
        for each ttWrite:
            cc = cc + string(ttwrite.num ) + " " + ttwrite.name 
                 + " " 
                 + ttWrite.parent 
                 + " " 
                 + ttWrite.fieldlist 
                 + " "
                 + (if ttWrite.writehandle <> ? then ttWrite.writehandle:type else "?")
                 + " "
                 + (if ttWrite.rid <> ? then string(ttWrite.rid) else "?")
                 + chr(10)
                  .
        end.
        return if cc = ? then "<empty>" else right-trim(cc,chr(10)).
		
	end method.

    method public handle GetWriteDataset():
        define variable iCount as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cc as character no-undo.
       
        return CreateWriteDataset().
    end method.
    
    method public handle GetReadDataset():
        define variable iCount as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cc as character no-undo.
        
        return CreateDataset("read").
    end method.
    
    method private handle CreateWriteDataset():    
        return CreateDataset("write").
    end method.    
    
    method private handle CreateDataset(pcmode as char):
        define variable hds as handle no-undo.
        define variable hParent as handle no-undo.
        define variable hbuffer as handle no-undo.
        create dataset mDataset. 
        mDataset:serialize-name = "root".
        for each ttWrite:
            
            if ttWrite.writehandle:type = "dataset" then
            do:  
                hbuffer = ttWrite.writehandle:get-buffer-handle (1). 
            end.
            else do: 
                hbuffer = ttWrite.writehandle. 
            end. 
            if ttWrite.num = 1 then 
            do:
               if pcMode = "write" and ttWrite.rid <> ? then 
                   hParent = CreateTopBuffer(hbuffer,ttWrite.rid).
               else hParent = Addbuffer(hbuffer).    
            end.
            else do:
               if ttWrite.fieldlist > "" then
                   /* to do change to parent name */
                   AddChild(hParent,hbuffer,ttWrite.fieldlist).
               else
                  Addbuffer(hbuffer).              
            end. 
        end.
          
        return mDataset.
    end method.    
    
    
    method private handle CreateTopBuffer(hBuffer as handle, rid as rowid):
        define variable hTbl as handle no-undo.
        create temp-table htbl.
        
        htbl:create-like(hBuffer).
        htbl:temp-table-prepare (hBuffer:name).
        hBuffer:find-by-rowid(rid).
        htbl:default-buffer-handle:buffer-copy (hBuffer).
        htbl:default-buffer-handle:serialize-name = hBuffer:serialize-name. 
        mDataset:add-buffer(htbl).
        return hTbl:default-buffer-handle. 
    end.    
     
    method public handle AddBuffer(phBuffer as handle):
        define variable h as handle no-undo.
        define variable hbuf as handle no-undo.
        create buffer hbuf for table phBuffer.
        hBuf:serialize-name = phBuffer:serialize-name.
        mDataset:add-buffer(hBuf).
        return hBuf.
    end.
    
    
    method public void AddChild(hParent as handle,hchild as handle,link as char):
        define variable h as handle no-undo.
    
        create buffer hchild for table hChild.
        hChild:serialize-name = "partitions".
        mDataset:add-buffer(hchild).
        mDataset:add-relation(hparent,hchild,link,no,yes,yes,no,yes).
        /*
        ADD-RELATION ( parent-buffer-handle, child-buffer-handle,  
         [ pairs-list [, reposition-mode [, nested [, not-active [, recursive 
          [, foreign-key-hidden ] ] ] ] ] ]) */ 
    
    end.
    
    
end class.
