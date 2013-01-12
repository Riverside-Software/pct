 
 /*------------------------------------------------------------------------
    File        : ContextTree
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:44:10 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

class OpenEdge.DataAdmin.Binding.ContextTree implements IContextTree: 
    define private variable mSummary as character no-undo.
    define variable counter as integer no-undo.
    define variable mDataset as handle no-undo.
    
    define temp-table ttTable no-undo
        field name       as char
        field num        as int
        field DataHandle as handle
        field FieldList  as char
        field rid        as rowid
        field parent     as char
        field joinfields  as char
        field reposJoin   as logical 
        field newhandle   as handle
        field filter as char
      index num num  
      index name as unique name.  
    
	define public property Parse as logical no-undo 
	get.
	set. 

    method private void AddHandle(cname as char, h as handle):
        find ttTable where ttTable.name = cname no-error.
        if not avail ttTable then this-object:add(cname).
        ttTable.datahandle = h.
       
    end method.
    
    method private void Add(cname as char):
        counter = counter + 1. 
        create ttTable.
        assign name = cname 
               num = counter.
    end method.    
    
    method private void UpdateJoin(cparent as char,cname as char,cfields as char,plRepos as log):      
        find ttTable where ttTable.name = cname no-error.
        if not avail ttTable then this-object:add(cname).
        assign ttTable.parent = cparent 
               ttTable.joinfields = cfields
               ttTable.reposJoin = plRepos.
    end method.    
   
    method private void UpdateFilter(cname as char,cfilter as char):      
        find ttTable where ttTable.name = cname no-error.
        if not avail ttTable then this-object:add(cname).
        
        ttTable.filter  = filter.
    end method.    
   
    method public void SetName(cname as char):
        this-object:add(cname).
    end method.
    
    method public void SetList(cname as char,cList as char):
        this-object:add(cname).
        ttTable.FieldList  = clist.
    end method.
    
    method public void SetJoin(cParent as char,name as char,cFieldPairs as char):
        UpdateJoin(cparent,name,cfieldpairs,false).
    end method. 
   
    method public void SetRepositionJoin(cParent as char,name as char,cFieldPairs as char):
        UpdateJoin(cparent,name,cfieldpairs,true).
    end method. 
   
    method public void SetFilter(name as char,cFilter as char):
        UpdateFilter(name,cfilter).
    end method. 
   
    method public void SetHandle(name as char,h as handle):
        addHandle(name,h).
    end method.
    
    method public void SetHandle(name as char, h as handle,filter as char):
        addHandle(name,h).    
        ttTable.filter  = filter.
    end method.
    
    method public void SetHandle(name as char, h as handle, rid as rowid):
        addHandle(name,h).     
        ttTable.rid  = rid.
    end method. 
    
	method override public character ToString(  ):
	    define variable cc as character no-undo.
	    cc = super:ToString() + chr(10)
	            + getSummary(  ).
	    return right-trim(cc,chr(10)).  
	end method.
	  
	method private char GetSummary(  ):    
        define variable iCount as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cc as character no-undo.
        for each ttTable on error undo, throw:
            cc = cc + string(ttTable.num ) + " Name: " + ttTable.name 
                 + " Parent: " 
                 + ttTable.parent 
                 + " FieldList: " 
                 + ttTable.fieldlist 
                 + " JoinFields: "
                 + ttTable.joinfields 
                 + " Handle:Type: "
                 + (if valid-handle(ttTable.DataHandle) then ttTable.DataHandle:type else "?")
                 + " Rowid: "
                 + (if ttTable.rid <> ? then string(ttTable.rid) else "?")              
                 + " Tablehandle: "
                 + (if valid-handle(ttTable.DataHandle) 
                    then if ttTable.DataHandle:type = "buffer" 
                         then string(ttTable.DataHandle:Table-handle) 
                         else ""
                    else "")
                 + " HasRecs: "
                 + (if valid-handle(ttTable.DataHandle) 
                    then if ttTable.DataHandle:type = "buffer" 
                         then string(ttTable.DataHandle:Table-handle:has-records) 
                         else ""
                    else "")
                
                   + chr(10)   .
        end.
        return if cc = ? then "<empty>" else right-trim(cc,chr(10)).
        
    end method.

    method public handle GetWriteHandle():
        define variable iCount as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cc as character no-undo.
       
        return CreateWriteDataset().
    end method.
    
    method public handle GetReadHandle():
        define variable iCount as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cc as character no-undo.
        
        return CreateDataset("read").
    end method.
    
    method private handle CreateWriteDataset():    
        return CreateDataset("write").
    end method.    
    
    method private handle GetNewHandle(name as char):    
        define buffer bttTable for ttTable.
        find bttTable where bttTable.name = name no-error.
        if avail bttTable then
        do:
       
             return bttTable.newhandle.
        end.
        return ?.
    end method.  
    
    method private handle CreateDataset(pcmode as char):
        define variable hds as handle no-undo.
        define variable hParent as handle no-undo.
        define variable hbuffer as handle no-undo.
        create dataset mDataset. 
        mDataset:serialize-name = "root".
         
        for each ttTable on error undo,throw:
           
            if ttTable.DataHandle:type = "dataset" then
            do:  
                hbuffer = ttTable.DataHandle:get-buffer-handle (1). 
            end.
            else do: 
                hbuffer = ttTable.DataHandle. 
            end. 
            
            if ttTable.num = 1 then 
            do:
               if pcMode = "write" and ttTable.rid <> ? then 
                   ttTable.newhandle = CreateTopBuffer(hbuffer,ttTable.rid).
               else 
                   ttTable.newhandle = Addbuffer(ttTable.name,hbuffer).
               if ttTable.filter > "" then 
               do:
/*                   mdataset:top-nav-query(hbuffer:name):query-prepare ("for each ttTable where ttTable.Name = " + quoter("customer")).*/
               end.            
            
            end.
            else do:
               if ttTable.joinfields  > "" then
               do:
/*                   message ttTable.parent GetNewHandle(ttTable.parent) ttTable.name hbuffer ttTable.joinfields*/
/*                   view-as alert-box.                                                                         */
                 /* to do change to parent name */
                   ttTable.newhandle = AddChild(GetNewHandle(ttTable.parent),ttTable.name,hbuffer,ttTable.joinfields,ttTable.reposJoin).     
               end.
               else 
                  ttTable.newhandle = Addbuffer(ttTable.name,hbuffer).          
            end. 
        end.      
        EmptyTable().
        return mDataset.
    end method.    
    
    method private handle CreateTopBuffer(hBuffer as handle, rid as rowid):
        define variable hTbl as handle no-undo.
        create temp-table htbl.
        
        htbl:create-like(hBuffer).
        htbl:temp-table-prepare (hBuffer:name).
        hBuffer:find-by-rowid(rid).
        htbl:default-buffer-handle:buffer-copy (hBuffer).
        htbl:default-buffer-handle:serialize-name = hbuffer:serialize-name . 
        mDataset:add-buffer(htbl).
        return hTbl:default-buffer-handle. 
    end.    
    
    method public handle AddBuffer(name as char, hBuffer as handle):
        define variable h as handle no-undo.
        create buffer hBuffer for table hBuffer.
        hBuffer:serialize-name = name.
        mDataset:add-buffer(hBuffer).
        return hBuffer.
    end.
     
    method public handle AddChild(hParent as handle,name as char,hchild as handle,link as char,plRepos as log):
        define variable h as handle no-undo.
        
        create buffer hchild for table hChild.
        hChild:serialize-name = name.
        mDataset:add-buffer(hchild).
        
/*   errors here are pretty badly reported                          */
/*        message                                                      */
/*          "name" name skip                                           */
/*          "link" link skip                                           */
/*           "ds" valid-handle(mDataset)                               */
/*         if valid-handle(mDataset) then mDataset:type else "bad" skip*/
/*           "child" valid-handle(hchild)                              */
/*         if valid-handle(hchild) then hchild:type else "bad" skip    */
/*           "parent" valid-handle(hParent)                            */
/*         if valid-handle(hParent) then hParent:type else "bad"       */
/*         skip                                                        */
/*         view-as alert-box.                                          */
         
        mDataset:add-relation(hparent,hchild,link,plRepos,yes,yes,no,yes).
     
          /*
        ADD-RELATION ( parent-buffer-handle, child-buffer-handle,  
         [ pairs-list [, reposition-mode [, nested [, not-active [, recursive 
          [, foreign-key-hidden ] ] ] ] ] ]) */ 
        return hchild. 
    end.
    
    method private void EmptyTable():
        empty temp-table ttTable.
    end.    
end class.
