 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
  
 /*------------------------------------------------------------------------
    File        : DataDefinitionParser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Oct 03 00:59:29 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath. 
using OpenEdge.DataAdmin.Binding.IDataDefinitionParser from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath. 
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Binding.DataDefinitionLoader from propath. 
using OpenEdge.DataAdmin.DataAccess.FileData from propath.
using OpenEdge.DataAdmin.DataAccess.AreaData from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Lang.WebUtil from propath.
routine-level on error undo, throw.
 
class OpenEdge.DataAdmin.Binding.DataDefinitionParser inherits DataDefinitionLoader implements IDataDefinitionParser: 
    
    {daschema/schema.i reference-only }
    {daschema/table.i reference-only }
    {daschema/field.i reference-only }
    {daschema/index.i reference-only }
    {daschema/sequence.i reference-only }
    {daschema/change.i reference-only}
   
    {daschema/area.i}
    
    define dataset dsSchemachanges reference-only 
        for ttSchema,ttTable,ttIndex,ttField,ttSequence,
            ttTableChange,ttIndexChange,ttFieldChange,ttSequenceChange.
    
    define variable mCount   as integer no-undo.
    define variable mAreaURL as character no-undo.
    define variable mCurrentTable   as character no-undo.

    define private property WebUtil as WebUtil no-undo 
        get():
            if not valid-object(WebUtil) then
                WebUtil = new WebUtil().
            return WebUtil.     
        end. 
        set.    
    
    define public property MultiTenantOnly as logical no-undo 
        get.
        set. 
    /*
    define public property MultiTenantChangesOnly as logical no-undo
        get.
        set(l as log):
            undo, throw new UnsupportedOperationError("Data Definition parse filter on multi tenant changes"). 
        end. 
    */
    
    define public property URL as character no-undo 
        get.
        set(c as char):
            mAreaURL = c + "/areas/".
            URL = c.
        end.     
     
    define private property TableRequest as IFetchRequest no-undo 
        get():
            if not valid-object(TableRequest) then 
            do:
                TableRequest = GetTableRequest().
            end.
            return TableRequest.
        end.        
        set. 
    
    define private property SequenceRequest as IFetchRequest no-undo 
        get():
            if not valid-object(SequenceRequest) then 
            do:
                SequenceRequest = GetSequenceRequest().
            end.
            return SequenceRequest.
        end.        
        set. 
    
    define private property AreaRequest as IFetchRequest no-undo 
        get():
            if not valid-object(AreaRequest) then 
            do:
                AreaRequest = GetAreaRequest().
            end.
            return AreaRequest.
        end.        
        set. 
    
    define private property SchemaAccess as FileData no-undo 
        get():
            if not valid-object(SchemaAccess) then 
            do:
                SchemaAccess = new FileData().
            end.
            return SchemaAccess.
        end.        
        set. 
    
    define private property AreaAccess as AreaData no-undo 
        get():
            if not valid-object(AreaAccess) then 
            do:
                AreaAccess = new AreaData().
            end.
            return AreaAccess.
        end.        
        set. 
        
    constructor public DataDefinitionParser (h as handle, purl as char):
        this-object (h).
        URL = purl.     
    end constructor.
    
    constructor public DataDefinitionParser (h as handle):
        super ().
        
        Bind(dataset-handle h bind).       
        IsReader = true.
    end constructor.
    
    method private void Bind(input dataset dsSchemachanges bind):      
    end method.
    
    method public override void AddTable(pcAction as char, h as handle,piArea as integer):
        define variable lMt      as logical no-undo.
        define variable lMtChange      as logical no-undo.
        define variable lKeep    as logical no-undo.
        define variable cArea as character no-undo.
        define variable cRename  as character no-undo.
        lMt   =  h:buffer-field("_File-attributes"):buffer-value(1). 
        lKeep =  h:buffer-field("_File-attributes"):buffer-value(2). 
        
        if pcAction = "a" then
        do:
            if MultiTenantOnly and not lMt then
                return.
            cArea = FetchAreaName(piArea).   
            create ttTable.
            assign
               ttTable.SchemaName = h::_Owner
               ttTable.Name = h::_File-name
               ttTable.AreaName  = cArea
               ttTable.AreaUrl   = mAreaUrl + WebUtil:URLEncode(cArea,"") 
               lMtChange = lMt.
        end.    
        else
        do:     
            find ttTable where ttTable.Name = h::_File-Name no-error. 
            if not avail ttTable then 
            do:
                cRename = TableNewName(h::_File-Name). 
                if cRename > "" then 
                   find ttTable where ttTable.Name = cRename no-error. 
                else do:
                   FetchTable(h::_File-Name).         
                   find ttTable where ttTable.Name = h::_File-Name no-error. 
                end. 
            end.                
            
            if not avail ttTable then
            do:
                if not MultiTenantOnly then
                    undo, throw new AppError(GetAction(pcAction) + " table " + h::_File-Name + " not found."). 
                else 
                    return.
            end.  
        end.
        /** 
        if pcAction = "m" and not lAlready and MultiTenantChangesOnly then
        do: 
            if ttTable.IsMultiTenant   = lMt
            and ttTable.KeepDefaultArea = lKeep then
            do:
                RemoveTable(ttTable.Name).
                return.
            end.
        end.
         **/
        if pcAction = "m" and ttTable.IsMultiTenant = false and lmt then
        do:
            lMtChange = true.
            for each ttIndexChange where ttIndexChange.TableName = ttTable.Name and ttIndexChange.name = GetAction("a") :
                ttIndexChange.IsMultitenantchange = lMtChange.
            end.    
         
            for each ttFieldChange where ttFieldChange.TableName = ttTable.Name and ttFieldChange.name = GetAction("a"):
                ttFieldChange.IsMultitenantchange = lMtChange.
            end.    
        end.
        assign          
            ttTable.IsMultiTenant   = lMt
            ttTable.KeepDefaultArea = lKeep.
        
        if pcAction > "" then
        do:
            createTableChange(pcAction,ttTable.Name). 
            ttTableChange.IsMultitenantchange = lMtChange.
        end.   
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.
    end method.
    
    method private void CreateTableChange(pcaction as char, pcname as char):
        mCount = mcount + 1.
        create ttTableChange.
        assign
            ttTableChange.Tablename = pcname
            ttTableChange.name =  GetAction(pcAction)
            ttTableChange.seq  = mCount.
    end method.
    
    method private void CreateSequenceChange(pcaction as char, pcname as char):
        mCount = mcount + 1.
        create ttSequenceChange.
        assign
            ttSequenceChange.Sequencename = pcname
            ttSequenceChange.name =  GetAction(pcAction)
            ttSequenceChange.seq  = mCount.
    end method.     
      
    method private void CreateIndexChange(pcaction as char, pctable as char, pcname as char):
        mCount = mcount + 1.
        create ttIndexchange.
        assign
            ttIndexChange.TableName = pctable
            ttIndexChange.Indexname = pcname
            ttIndexChange.name =  GetAction(pcAction)
            ttIndexChange.seq  = mCount.
    end method.
    
    method private void CreateFieldChange(pcaction as char, pctable as char, pcname as char):
        mCount = mcount + 1.
        create ttFieldchange.
        assign
            ttfieldChange.TableName = pctable
            ttfieldChange.Fieldname = pcname
            ttfieldChange.name =  GetAction(pcAction)
                    ttfieldChange.seq  = mCount.
    end method.
    
      
    method public override void AddSequence(pcAction as char, h as handle):
        define variable lMt      as logical no-undo.
        define variable lMtChange      as logical no-undo.
       
        define variable cRename  as character no-undo.
        lMt =  h:buffer-field("_Seq-attributes"):buffer-value(1).
        
        if pcAction = "a" then 
        do:
            if MultiTenantOnly and not lMt then
                return.
            create ttSequence.
            assign
                ttSequence.SchemaName = h::_Seq-owner
                ttSequence.Name = h::_Seq-name 
                lMtChange = lMt.
        end.    
        else do:
            find ttSequence where ttSequence.Name = h::_Seq-name no-error.
            if not avail ttSequence then
            do:
                cRename = SequenceNewName(h::_Seq-Name). 
                if cRename > "" then 
                    find ttSequence where ttSequence.Name = cRename no-error. 
                else do:
                    FetchSequence(h::_Seq-name).
                    find ttSequence where ttSequence.Name = h::_Seq-name no-error. 
                end.    
            end.    
            if not avail ttSequence then
            do:
                if not MultiTenantOnly then
                    undo, throw new AppError(GetAction(pcAction) + " sequence " + h::_Seq-name + " not found."). 
                else 
                    return.
            end.  
        
        end.
        if pcAction = "m" and ttSequence.IsMultiTenant = false and lmt then
            lMtChange = true.
        ttSequence.IsMultiTenant = lMt.
        
        assign
                ttSequence.InitialValue = h::_Seq-Init
                ttSequence.IncrementValue = h::_Seq-Incr
                ttSequence.MinimumValue = h::_Seq-Min 
                ttSequence.MaximumValue = h::_Seq-Max
                ttSequence.isCyclic     = h::_Cycle-Ok.
            
        if pcAction > "" then
        do: 
            CreateSequenceChange(pcaction,ttSequence.Name).
            ttSequenceChange.IsMultiTenantChange = lMtChange.
        end.
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.
          
    end method.
     
     method public override void AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int):
        define variable cArea as character no-undo.
        define variable cRename as character no-undo.
        if pcAction = "a" and pcTable = ? then
        do:
            pcTable = mCurrentTable.
            if pcTable = "" then 
               undo, throw new IllegalArgumentError("AddIndex called with unknown table and no new table present.").
        end.
    
        cRename = TableNewName(pctable).
        if cRename > "" then
        do:
            pcTable = cRename.
        end.
        else do:
            FetchTable(pcTable).
            /* throw error if not found */
            find ttTable where ttTable.Name = pcTable.  
        end.    
           
        /* if not (pcAction = "m" and MultiTenantChangesOnly) */       
        
        if pcAction = "a" then
        do:
            cArea = FetchAreaName(piArea).
            create ttIndex.
            assign 
                ttIndex.TableName = pcTable 
                ttIndex.Name = h::_index-name
                ttIndex.AreaName  = cArea.
                
             ttIndex.AreaUrl   = mAreaUrl + WebUtil:URLEncode(cArea ).
        end.    
        else
        do:
            find ttIndex where ttIndex.TableName = pcTable 
                           and ttIndex.Name = h::_index-name.  
        end.
        
        ttIndex.IsMultiTenant = ttTable.IsMultitenant.
        
        if pcAction > "" then
        do:
            CreateIndexChange(pcaction, ttIndex.TableName,ttIndex.Name).
            if pcAction = "a" and ttIndex.IsMultiTenant then 
                ttIndexChange.IsMultiTenantchange = true.
        end.
       
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.
    end method.
     
    method public override void AddField(pcAction as char, pcTable as char, h as handle, piArea as int):
        define variable cArea as character no-undo.
        define variable cRename as character no-undo.
        if pcAction = "a" and pcTable = ? then
        do:
            pcTable = mCurrentTable.
            if pcTable = "" then 
               undo, throw new IllegalArgumentError("AddField called with unknown table and no new table present.").
        end.
        if (h::_data-type = "clob" or h::_data-type = "blob") then 
        do:
            cRename = TableNewName(pctable).
            if cRename > "" then
            do:
                pcTable = cRename.
            end.
            else do:
                FetchTable(pcTable).
                /* throw error if not found */
                find ttTable where ttTable.Name = pcTable.  
            end.    
            
            if pcAction = "a" then
            do: 
                create ttField.
                cArea = FetchAreaName(piArea).
                assign 
                    ttField.TableName = pcTable
                    ttField.Name = h::_field-name
                    ttField.DataType = h::_data-type 
                    ttField.AreaName  = cArea.
                    
                ttField.AreaUrl   = mAreaUrl + WebUtil:URLEncode(cArea ). 
            end.
            else do:
                
                find ttField where ttField.TableName = pcTable 
                               and ttField.Name      = h::_field-name.  
            
            end.
                    
            ttField.IsMultiTenant = ttTable.IsMultitenant.
            
            if pcAction > "" then
            do:
                CreateFieldChange(pcaction, ttField.TableName,ttField.Name).
                if pcAction = "a" and ttField.IsMultiTenant then 
                    ttFieldChange.IsMultiTenantchange = true.
            end.
        end. /* lob */
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.
    end method.
    
    /* ddl rename happens before updates and updates references new name */
    method public override void RenameTable(pcname as char,pcNewname as char):
        find ttTable where ttTable.Name = pcname no-error.
        if not avail ttTable then 
        do: 
            if not FetchTable(pcname) then 
                undo, throw new AppError(GetAction("r") + " table " + pcname + " not found."). 
        
            find ttTable where ttTable.Name = pcname no-error.
        end.
       
        RenameTableAndChildren(pcname,pcNewname).  
        
        createTableChange("r",pcNewName). 
        ttTablechange.rename = pcname.
 
        catch e as Progress.Lang.Error :
         	AddError(e).	
        end catch.    
    end method.
    
    method public override void RenameField(pcTable as char, pcname as char,pcNewname as char):
        define variable cRename as character no-undo.
        find ttTable where ttTable.Name = pcTable no-error. 
        if not avail ttTable then 
        do:
            cRename = TableNewName(pcTable). 
            if cRename > "" then 
                pcTable = cRename. 
            else do:
               FetchTable(pcTable). 
               /* field not avail - not lob */
               find ttField where ttField.TableName = pcTable 
                     and   ttField.Name      = pcname no-error.  
               if not avail ttfield then 
               do: 
                   RemoveTable(pcTable).
                   return.
               end.    
            end.   
        end. 
         
        find ttTable where ttTable.Name = pcTable. 
        /* no-error - ttfield has only lob fields */           
        find ttField where ttField.TableName = pcTable 
                     and   ttField.Name      = pcname no-error.  
        if avail ttfield then
        do: 
            for each ttFieldChange where ttFieldChange.TableName = ttTable.Name
                                     and  ttFieldChange.FieldName = pcName:
                  ttFieldChange.FieldName = pcNewname.
            end.    
            ttField.name = pcNewname.
            CreateFieldChange("r", ttField.TableName,ttField.Name).
            ttFieldChange.Rename = pcname.
        end.
        catch e as Progress.Lang.Error :
        	AddError("RenameField:  " + e:GetMessage(1)).	
        end catch.
    end method.
    
     method public override void RenameIndex(pcTable as char, pcname as char,pcNewname as char):
        define variable cRename as character no-undo.
        find ttTable where ttTable.Name = pcTable no-error. 
        if not avail ttTable then 
        do:
            cRename = TableNewName(pcTable). 
            if cRename > "" then 
               pcTable = cRename. 
            else do:
               FetchTable(pcTable). 
            end.   
        end. 
        
        find ttTable where ttTable.Name = pcTable. 
                   
        find ttIndex where ttIndex.TableName = pcTable 
                     and   ttIndex.Name      = pcname.  
        
        for each ttIndexChange where ttIndexChange.TableName = ttTable.Name
                                and  ttIndexChange.IndexName = pcName:
             ttIndexChange.IndexName = pcNewname.
        end.    
        ttIndex.name = pcNewname.
        CreateIndexChange("r", ttIndex.TableName,ttIndex.Name).
        ttIndexChange.Rename = pcname.
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.
  
    end method.
    
    method public override void RenameSequence(pcname as char,pcNewname as char):
        find ttSequence where ttSequence.Name = pcname no-error. 
        if not avail ttSequence then 
        do: 
            if not FetchSequence(pcname) then 
                undo, throw new AppError(GetAction("r") + " sequence " + pcname + " not found."). 
        
            find ttSequence where ttSequence.Name = pcname no-error. 
        end.
        ttSequence.Name = pcNewName.
        CreateSequenceChange("r",pcNewName).
        ttSequenceChange.rename = pcname.
 
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.    
    end method. 
    
    method public override char TableOldName(pcNewname as char):
       define buffer tchg for ttTableChange. 
       find tchg where tchg.tablename = pcNewname  and tchg.name = GetAction("r")  no-error.
     
       if avail tchg then
           return tchg.Rename.
       
       return "".      
     
    end method.
    
    method public override char TableNewName(pcOldname as char):
       define buffer tchg for ttTableChange. 
       find tchg where tchg.rename = pcOldname no-error.
     
       if avail tchg then
           return tchg.TableName.
       return "".      
    
    end method.
    
    method public override char SequenceNewName(pcOldname as char):
       define buffer tchg for ttSequenceChange. 
       find tchg where tchg.rename = pcOldname no-error.
     
       if avail tchg then
           return tchg.SequenceName.
       return "".      
    
    end method.
    
    method public override char FieldOldName(pcTable as char, pcNewname as char):
       define buffer tchg for ttFieldChange. 
       find tchg where tchg.tablename = pctable and tchg.FieldName = pcNewname  and tchg.name = GetAction("r") no-error.
       if avail tchg then
           return tchg.Rename.
       return "".    
    end method.
    
    method public override char FieldNewName(pcTable as char, pcOldname as char):
       define buffer tchg for ttFieldChange. 
       find tchg where tchg.tablename = pctable and tchg.Rename = pcOldname and tchg.name = GetAction("r") no-error.
       if avail tchg then
           return tchg.FieldName.
       return "".    
    end method.
    
    method public override char IndexOldName(pcTable as char, pcNewname as char):
       define buffer tchg for ttIndexChange. 
       find tchg where tchg.tablename = pctable and tchg.IndexName = pcNewname  and tchg.name = GetAction("r") no-error.
       if avail tchg then
           return tchg.Rename.
       return "".      
    end method.
    
    method public override char IndexNewName(pcTable as char, pcOldname as char):
       define buffer tchg for ttIndexChange. 
       find tchg where tchg.tablename = pctable and tchg.Rename = pcOldname and tchg.name = GetAction("r") no-error.
       if avail tchg then
           return tchg.IndexName.
       return "".      
    end method.
    
    method public override char SequenceOldName(pcNewname as char):
       define buffer tchg for ttSequenceChange. 
       find tchg where tchg.sequencename = pcNewname  and tchg.name = GetAction("r")  no-error.
       if avail tchg then
           return tchg.rename.   
       return "".                
    end method. 
    
    /* called from _lodsddl to check and keep track of current new table
       _lod_fld and _lod_idx passes ? as table to AddIndex and AddField to use this  */           
    method public override logical IsNewTable(pcTable as char):
        find ttTable where ttTable.Name = pcTable no-error.
        if avail ttTable then 
        do:
           find ttTablechange where ttTablechange.TableName = pcTable
                                and ttTablechange.name      = GetAction("a") no-error.
           if avail ttTablechange then 
           do:
              mCurrentTable = pcTable. 
              return true. 
           end.
        end.   
        mCurrentTable = "".                      
        return false.
    end method.
    
    method private void RenameTableAndChildren(pcold as char,pcnew as char):
        find ttTable where ttTable.Name = pcold no-error.
        define variable cc as character no-undo.
        if avail ttTable then 
        do:
            for each ttTableChange where ttTableChange.TableName = ttTable.Name:
                ttIndex.TableName = pcnew.
            end.    
            for each ttIndex where ttIndex.TableName = ttTable.Name:
                ttIndex.TableName = pcnew.
            end.    
            for each ttIndexChange where ttIndexChange.TableName = ttTable.Name:
                ttIndexChange.TableName = pcnew.
            end.    
            for each ttField where ttField.TableName = ttTable.Name:
                ttField.TableName = pcnew.
            end.   
            for each ttFieldChange where ttFieldChange.TableName = ttTable.Name:
                ttFieldChange.TableName = pcnew.
            end.    
            
            ttTable.Name = pcnew.  
        end.     
    end method.
    
    
    method private void RemoveTable(pcTable as char):
        find ttTable where ttTable.Name = pcTable no-error.
        if avail ttTable then 
        do:
            for each ttIndex where ttIndex.TableName = ttTable.Name:
                delete ttIndex.
            end.    
            for each ttField where ttField.TableName = ttTable.Name:
                delete ttField.
            end.   
            delete ttTable. 
        end.     
    end method.
    
    method private IFetchRequest GetTableRequest():
        define variable contexttree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        
        contexttree = new ContextTree().
        contextTree:SetHandle("tables",temp-table ttTable:default-buffer-handle).
        contextTree:SetJoin("tables","indexes","name,tablename").
        contextTree:SetHandle("indexes",temp-table ttIndex:default-buffer-handle). 
        contextTree:SetJoin("tables","fields","name,tablename").
        contextTree:SetHandle("fields",temp-table ttfield:default-buffer-handle). 
        msg = new FetchRequest(contextTree:GetReadHandle()).
        return msg.     
    end method.      
    
    method private IFetchRequest GetSequenceRequest():
        define variable contexttree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        
        contexttree = new ContextTree().
        contextTree:SetHandle("sequences",temp-table ttSequence:default-buffer-handle).
        msg = new FetchRequest(contextTree:GetReadHandle()).
        return msg.     
    end method.      
    
    method private IFetchRequest GetAreaRequest():
        define variable contexttree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        
        contexttree = new ContextTree().
        contextTree:SetHandle("areas",temp-table ttArea:default-buffer-handle).
        msg = new FetchRequest(contextTree:GetReadHandle()).
        return msg.     
    end method.      
    
    method private logical FetchTable(pcTable as char):
        define variable cQuery as character no-undo. 
        
        find ttTable where ttTable.name = pcTable no-error.
        if not avail ttTable then 
        do:
            cQuery = "for each ttTable where ttTable.name = " + quoter(pcTable).
            if MultiTenantOnly then
                cQuery = cQuery + " and ttTable.IsMultitenant = " + quoter(true).
            TableRequest:SetTableQuery("ttTable",cQuery).
            SchemaAccess:FetchData(TableRequest).
            find ttTable where ttTable.name = pcTable no-error.
        end.
        return avail ttTable.
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.     
    end method.  
    
    method private logical FetchSequence(pcSequence as char):
        define variable cQuery as character no-undo. 
        
        find ttSequence where ttSequence.Name = pcSequence no-error.
        if not avail ttSequence then 
        do:
            cQuery = "for each ttSequence where ttSequence.name = " + quoter(pcSequence).
            if MultiTenantOnly then
                cQuery = cQuery + " and ttSequence.IsMultitenant = " + quoter(true).
            SequenceRequest:SetTableQuery("ttSequence",cQuery).
            SchemaAccess:FetchData(SequenceRequest).
            find ttSequence where ttSequence.Name = pcSequence no-error.
        end.
        return avail ttSequence.
        catch e as Progress.Lang.Error :
            AddError(e).    
        end catch.     
    end method.  
    
    method private char FetchAreaName(piArea as int):
        define variable cQuery as character no-undo. 
       
        find ttArea where ttArea.number = piArea   no-error.
        if not avail ttArea then
        do:
            cQuery = "for each ttArea where ttArea.Number = " + quoter(piArea).
            AreaRequest:SetTableQuery("ttArea",cQuery).
            AreaAccess:FetchData(AreaRequest).
            find ttArea where ttArea.number = piArea   no-error.
        end.    
        if avail ttArea then
           return ttArea.Name. 
        else 
           return "".   
    end method.
    
    method private char GetAction(imod as char):  
        return IF imod = "cp":u THEN "ADD/MODIFY"
                ELSE IF imod = "a":u  THEN "ADD"
                ELSE IF imod = "m":u  THEN "MODIFY"
                ELSE IF imod = "r":u  THEN "RENAME"
                ELSE IF imod = "d":u  THEN "DELETE"
                ELSE IF imod = "e":u  THEN ""
                ELSe ?.
    end method.
            
end class.