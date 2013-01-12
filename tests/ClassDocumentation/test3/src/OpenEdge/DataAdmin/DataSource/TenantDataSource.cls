/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TenantDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Oct 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.TenantDataSource inherits DataSource: 
    
    define temp-table ttType2 no-undo
       field IsType2 as logical.
    define buffer b_dataArea  for dictdb._Area.
    define buffer b_indexArea for dictdb._Area.
    define buffer b_LobArea   for dictdb._Area.
    define private property TenantURL  as character no-undo get. set.
    define private property AreaURL  as character no-undo get. set.
    define private property AreasURL as character no-undo  get. set.
       /* not really allowed - */
    define public property QueryString as character no-undo 
        get():
            return Queryhandle:prepare-string.   
        end.
    define private property mAreaQuery as character no-undo  
        get(): 
            return " each b_dataArea outer-join no-lock   where b_dataArea._area-number = _tenant._Tenant-DataArea-default,"
                   + " each b_indexArea outer-join no-lock  where b_indexArea._area-number = _tenant._Tenant-IndexArea-default,"
                   + " each b_LobArea outer-join no-lock   where b_LobArea._area-number = _tenant._Tenant-LobArea-default".   
        end.
             
    define protected variable mBuffer as handle no-undo.
    define variable mSave as logical no-undo.
    
    /* for attach */
    define protected property FieldMapNoArea as char no-undo 
        init "Id,_Tenantid,Name,_Tenant-name,Description,_Tenant-Description,ExternalId,_Tenant-Extid,isDataEnabled,_Tenant-attributes[1],isAllocated,_Tenant-attributes[2],DefaultAllocation,_Tenant-Allocation-default"
        get.
        set.
        
    define protected property FieldMap as char no-undo 
        init "Id,_Tenantid,Name,_Tenant-name,Description,_Tenant-Description,ExternalId,_Tenant-Extid,isDataEnabled,_Tenant-attributes[1],isAllocated,_Tenant-attributes[2],DefaultAllocation,_Tenant-Allocation-default,DefaultDataAreaName,b_dataarea._Area-name,DefaultIndexAreaName,b_indexarea._Area-name,DefaultLobAreaName,b_lobarea._Area-name"
        get.
     
	constructor public TenantDataSource ( ):	    
		this-object (FieldMap).
    end constructor.
    
    constructor public TenantDataSource (pfieldmap as char ):        
        super ("_Tenant,b_dataArea,b_indexArea,b_LobArea","dictdb._Tenant,dictdb._Area,dictdb._Area,dictdb._Area", pFieldMap). 
        BaseQuery = "for each _Tenant no-lock," + mAreaQuery.    
    end constructor.
   
    constructor public TenantDataSource (phChild as handle,pfieldmap as char ):        
        super ("_Tenant,b_dataArea,b_indexArea,b_LobArea","dictdb._Tenant,dictdb._Area,dictdb._Area,dictdb._Area",phchild, pFieldMap). 
        BaseQuery = "for each _Tenant no-lock," 
                  +  mAreaQuery
                  + ", each " + phChild:name + " no-lock".       
    end constructor.
    /* keep
    constructor public TenantDataSource (phParent as handle,pcJoin as char,pfieldmap as char ):        
        super (phParent, "_Tenant,b_dataArea,b_indexArea,b_LobArea","dictdb._Tenant,dictdb._Area,dictdb._Area,dictdb._Area",pFieldMap). 
        BaseQuery = "for each " + phParent:name + " no-lock,"
                  + " each _Tenant" 
                  + (if pcjoin > "" then " where " + pcjoin else "")
                  + " no-lock, " 
                  + mAreaQuery + " no-lock".       
    end constructor.
    */
   
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable lok as logical no-undo.
        phBuffer:set-callback("After-Row-fill","AfterRow").
        mBuffer = phBuffer.      
       
        lok = super:Prepare(phBuffer,pcTargetQuery,pcJoin).
       
        return lok.
    end method.
    
    method override protected void AfterSetUrl(): 
        TenantURL = url + "/tenants/".
        AreaURL = url + "/areas/".
        AreasURL = url + "/areas".
    end method.
    
    method protected override logical PrepareQueryString (poQueryString as QueryString):    
        define variable isOk as logical no-undo.
        define variable cQuery as character no-undo.
        
        cQuery = poQueryString:BuildQueryString(Tables).
     
        isOk = QueryHandle:query-prepare(cQuery).  
   
        return isOk.
    end method.
    
   /** tenant requires control of order , so this is not supported  */
    method public override logical Save(phbuffer as handle):
         undo, throw new UnsupportedOperationError("Save without state for " + this-object:GetClass():TypeName).
    end method.
    
    /**  refresh row-state 0  isallocated  */
    method public override logical Refresh(phbuffer as handle):
        define variable hQuery  as handle no-undo.
        create query hquery.
        hquery:add-buffer(phBuffer).
        hQuery:query-prepare("for each ttTenant where row-state(ttTenant) = 0 ").
        hquery:query-open().       
        hquery:get-first.   
        do while phbuffer:avail:
            /** @todo - remove no-error and throw something 
             also check if exclusive and validate is needed 
             (this was done late before ship) */ 
            find dictdb._tenant where dictdb._tenant._tenantid = phBuffer::id exclusive-lock no-wait no-error.
            if avail dictdb._tenant then
            do:
                validate dictdb._tenant.
                phBuffer::IsAllocated =  dictdb._tenant._Tenant-attributes[2]. 
            end.
            hquery:get-next.   
        end.
 
    end method.
    
    
   /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified) 
                      ? = all */
    method public override logical Save(phbuffer as handle,piState as int):
        define buffer b_user for dictdb._user.
        define buffer b_domain for dictdb._sec-authentication-domain.
        define buffer b_group-detail for dictdb._Partition-Set-Detail.
        
        define variable hDataset as handle no-undo. 
        define variable hBeforeBuff as handle    no-undo.
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable cMsg        as character no-undo.
        
        if piState  = ?  then
            undo, throw new IllegalArgumentError("TenantDataSource save does not support unknown value in state parameter." ).
        
        if piState < 1 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
       
        mSave = true.
           
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttTenantCopy where row-state(ttTenantCopy) = " + string(piState)).
        hquery:query-open().       
        hquery:get-first.   
     
        do transaction on error undo, throw:
            do while hBeforebuff:avail:
                /* now this is silly... */         
                if hBeforeBuff:row-state <> 0 then 
                do:
                    if hBeforeBuff:row-state = row-deleted then 
                    do:
                        find dictdb._tenant where dictdb._tenant._tenant-Name = hBeforeBuff::Name exclusive no-wait.
                        /* @TODO: add  permission checks */
                         
                        for each dictdb._User where dictdb._User._tenantid = dictdb._tenant._tenantid 
                        no-lock
                        on error undo , throw:
                            find b_User where rowid(b_user) = rowid(dictdb._User) exclusive no-wait.
                            delete b_User.
                        end.
                        
                        for each dictdb._sec-authentication-domain where dictdb._sec-authentication-domain._Tenant-Name = dictdb._tenant._tenant-name 
                        no-lock 
                        on error undo , throw:
                            find b_domain where rowid(b_domain) = rowid(dictdb._sec-authentication-domain) exclusive no-wait.
                            delete b_domain.
                        end.
                        
                        for each dictdb._Partition-Set-Detail
                             where dictdb._Partition-Set-Detail._TenantId = dictdb._Tenant._TenantId 
                        no-lock 
                        on error undo , throw:
                            find b_group-detail where rowid(b_group-detail) = rowid(dictdb._Partition-Set-Detail) exclusive no-wait.
                            delete b_group-detail.
                        end.
                               
                        delete dictdb._tenant. 
                         
                    end.    
                    else do:    
                       
                        phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                        /* avoid merge changes if not success set to false at end */ 
                        phBuffer:error = true.
                        
                        cType = phBuffer::Type.
                        if hBeforeBuff:row-state = row-created then 
                        do:
                            case cType:
                                when "Default" then 
                                    undo, throw new DataAccessError("Cannot create another ~"Default~" Tenant."
                                                                    + " A new Tenant must be of Type ~"Regular~" or ~"Super~".").
                                when "Regular" then 
                                    iType = 1.
                                when "Super"   then 
                                    iType = 2.
                                otherwise 
                                    undo, throw new DataAccessError("Tenant Type " + quoter(cType) + " is not valid."
                                                                   + " A new Tenant must be of Type ~"Regular~" or ~"Super~".").
                                
                            end. 
                           
                            create dictdb._tenant.
                            assign
                                dictdb._tenant._Tenant-name = phBuffer::Name
                                dictdb._tenant._tenant-type = iType                
                                phBuffer::Id = dictdb._tenant._Tenantid.    
                        
                        end. 
                        else do: 
                            if hBeforeBuff::Type <> phBuffer::Type then
                                undo, throw new DataAccessError("Cannot change the Type of an existing Tenant.").

                            find dictdb._tenant where dictdb._tenant._tenant-name = hBeforeBuff::name 
                            exclusive no-wait. 
                        
                            if dictdb._tenant._Tenant-name <> phBuffer::Name then 
                                dictdb._tenant._Tenant-name = phBuffer::Name. 
                       
                            /* allocated only makes sense when not new */
                            if dictdb._tenant._Tenant-attributes[2] <> phBuffer::isAllocated 
                            and phBuffer::isAllocated = true then 
                            do:
                                dictdb._tenant._Tenant-attributes[2] =  phBuffer::isAllocated.                    
                                RefreshPartitionState(phBuffer::name,phBuffer:dataset).
                            end.
                        end. 
                                            
                        if dictdb._tenant._Tenant-attributes[1] <> phBuffer::IsDataEnabled then
                            dictdb._tenant._Tenant-attributes[1] = phBuffer::IsDataEnabled.
                                               
                        /* note that the checks for changes was added when changes only were allowed 
                           to the allocated flag - feel free to remove if necessary, for example 
                           in order to use save-row-changes  
                        */
                            
                        /* source ? and blank ui means nothing changed */
                        if  dictdb._tenant._Tenant-description <> phBuffer::Description 
                        and (dictdb._tenant._Tenant-description <> ? or phBuffer::Description > "") then
                            dictdb._tenant._Tenant-description = phBuffer::Description. 
                        
                        /* source ? and blank ui means nothing changed */
                        if  dictdb._tenant._Tenant-Extid <> phBuffer::ExternalId
                        and (dictdb._tenant._Tenant-Extid <> ? or phBuffer::ExternalId > "") then
                            dictdb._tenant._Tenant-Extid = phBuffer::ExternalId.
                        
    /*                    if cType = "regular" then*/
    /*                    do:                      */
                        
                        if phbuffer::DefaultDataAreaName > "" then
                        do on error undo, throw:
                            find b_dataarea where b_dataarea._area-name = phbuffer::DefaultDataAreaName
                                no-lock.
                             catch e as Progress.Lang.Error :
                                 cmsg = "DefaultDataArea " + quoter(phbuffer::DefaultDataAreaName) + " does not exist".    
                                 undo, throw new DataAccessError(cMsg).
                             end.        
                        end.
                        if phbuffer::DefaultIndexAreaName > "" then
                        do on error undo, throw:
                            find b_indexarea where b_indexarea._area-name = phbuffer::DefaultIndexAreaName
                                no-lock. 
                             catch e as Progress.Lang.Error :
                                 cmsg = "DefaultIndexArea " + quoter(phbuffer::DefaultIndexAreaName) + " does not exist".    
                                 undo, throw new DataAccessError(cMsg).
                             end.        
                                
                        end.
                                
                        if phbuffer::DefaultLobAreaName > "" then
                        do on error undo, throw:
                            find b_lobarea where b_lobarea._area-name = phbuffer::DefaultLobAreaName
                                no-lock. 
                             catch e as Progress.Lang.Error :
                                 cmsg = "DefaultLobArea " + quoter(phbuffer::DefaultLobAreaName) + " does not exist".    
                                 undo, throw new DataAccessError(cMsg).
                             end.        
                        end.
                            
                        if avail b_dataarea and b_dataarea._area-number <> dictdb._tenant._Tenant-DataArea-default then                  
                            dictdb._tenant._Tenant-DataArea-default = b_dataarea._area-number.
                            
                        if avail b_indexarea and b_indexarea._area-number <> dictdb._tenant._Tenant-IndexArea-default then     
                            dictdb._tenant._Tenant-IndexArea-default = b_indexarea._area-number. 
                            
                        if avail b_lobarea and b_lobarea._area-number <> dictdb._tenant._Tenant-LobArea-default then
                            dictdb._tenant._Tenant-LobArea-default = b_lobarea._area-number.
                            
                        if dictdb._Tenant._Tenant-Allocation-default <> phBuffer::DefaultAllocation then
                             dictdb._Tenant._Tenant-Allocation-default = phBuffer::DefaultAllocation.     
    /*                     end.*/
                        
                        /* ensure partitions are created and partition changes are seen (IsAllocated)*/
                        validate dictdb._Tenant.
                        hdataset = phBuffer:dataset.
                        AfterRow(dataset-handle hdataset by-reference).    
                               
                        phBuffer:error = false.
                        phBuffer:rejected = false.
                    end.
                end.
                hQuery:get-next.
            end. /* do while hBeforebuff:avail */
            catch e2 as DataAccessError :
                 undo, throw e2.
            end.    
            catch e as Progress.Lang.Error :
                if e:GetMessageNum(1) = 110 then
                do:
                    /*---------------------------
                     ** _Tenant._Tenant-DataArea-default is mandatory, but has unknown (?) value. (110)
                     ---------------------------*/
                    cMsg = replace(e:GetMessage(1),"_Tenant._Tenant-","Tenant.Default").
                    cMsg = replace(cMsg,"-default",""). 
                    /*remove the number since it is not the same message and the number is not in
                     GetMessagenum of the throwwn. (?? feel free to change)  */
                    cMsg = replace(cMsg,"(110)","").                     
                    undo, throw new DataAccessError(cMsg).
                end.
                else
                    undo, throw new DataAccessError(
                
                    new DataMapper("Tenant,_Tenant,Table,bFile,Area,b_dataarea,Area,b_indexarea,Area,b_lobarea",
                    FieldMap),
                    e). 
            end catch.
          
        
        end. /* transaction */
        return true.     
        finally:
           delete object hQuery no-error. 
           mSave = false.     		
        end finally.
    end method.      
    
    /* set allocated in partitions that were changed . The Tenantcontext 
       will do a new request, but it does this before the changes are merged so
       partitions with pending updates will not be refreshed due to the
       protection in dataRefreshed */ 
    method public void RefreshPartitionState(pcTenant as char,hds as handle):
        define variable hQuery as handle no-undo.
        define variable hBuffer as handle no-undo.
        hBuffer = hds:get-buffer-handle ("ttPartition").
        if valid-handle(hBuffer) then
        do:
            create query hquery.
            hquery:add-buffer(hBuffer).
            hQuery:query-prepare("for each ttPartition where ttPartition.Tenantname = " + quoter(pcTenant)
                                 + " and ttPartition.AllocationState = 'Delayed'").
            hquery:query-open().       
            hquery:get-first.
            do while(hBuffer:avail):
                hBuffer::AllocationState = "Allocated".  
                hquery:get-next.
            end.    
        end.   
        finally:
           delete object hquery no-error.
        end finally. 
    end method. 
    
    method public override  void AfterRow(dataset-handle hds):
        define variable hbuffer       as handle no-undo.
        define variable cEncodeTenant as character no-undo.
        define variable iType         as integer no-undo.
        
        hBuffer =  hds:get-buffer-handle("ttTenant").
        if not mSave then
        do:    
           assign 
               iType         = DataSourceHandle:get-source-buffer(1)::_tenant-type
               hBuffer::Type = (if iType = 0 then "Default"
                                else if iType = 1 then "Regular"
                                else  "Super").
        end.    
        /* refresh this if saved ( save does validate ) */
        else if hBuffer::Type = "Regular" then 
        do:
            hBuffer::IsAllocated =  dictdb._tenant._Tenant-attributes[2].
        end.
        assign
            cEncodeTenant = WebUtil:UrlEncode(hBuffer::Name)  
            hBuffer::Url  = TenantURL + cEncodeTenant.
       
        if hBuffer::Type = "Regular" then
        do:       
            assign         
                hBuffer::DefaultDataAreaUrl  = AreaUrl + WebUtil:UrlEncode(hBuffer::DefaultDataAreaName)                   
                hBuffer::DefaultIndexAreaUrl = AreaUrl + WebUtil:UrlEncode(hBuffer::DefaultIndexAreaName)
                hBuffer::DefaultLobAreaUrl   = AreaUrl + WebUtil:UrlEncode(hBuffer::DefaultLobAreaName)
                hbuffer::DefaultAllocation   = caps(substr(hbuffer::DefaultAllocation,1,1)) 
                        + lc(substr(hbuffer::DefaultAllocation,2)). 
        end.
        assign
            hBuffer::PartitionsUrl     = TenantURL + cEncodeTenant + "/partitions"
            hBuffer::UsersUrl          = TenantURL + cEncodeTenant + "/users"
            hBuffer::DomainsUrl        = TenantURL + cEncodeTenant + "/domains"
            hBuffer::SequenceValuesUrl = TenantURL + cEncodeTenant + "/sequencevalues"
            hBuffer::TenantGroupMembersURL = Tenanturl + cEncodeTenant + "/tenantgroupmembers"
            hBuffer::AreasUrl      = AreasUrl.
 
    end method.  
    
    /* convert type char value in query to the integer value in the db */
    method public override character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        if pccolumn = "_tenant._Tenant-type" then
        do:
            if pcValue = "regular" then
                pcValue = "1".
            else if pcValue = "super" then
                pcValue = "2".
            else if pcValue = "default" then
                pcValue = "0".
            
            return pcColumn + ' ' + pcoperator + ' ' + quoter(pcValue).    
        end. 
        return ?.   
    end. 
    
    /**  type integer has same order as char value  
    /* convert type char value in query to the integer value in the db */
    method public override character ColumnSortSource(pcColumn as char):
        if pccolumn = "_tenant._Tenant-type" then
        do:
        end. 
        return ?.   
    end. 
    **/
        
    /* override to rename Type, which is not mapped 
       and default areas if not mapped  */
    method public override character ColumnSource (pcColumn as char):
        define variable cNew as character no-undo.
  
        if pccolumn = "ttTenant.Type" then
        do:
            return "_tenant._Tenant-type".      
        end.      
        else do:
            cNew = super:ColumnSource(pccolumn).
            if cNew <> pccolumn then
                 return cNew.       
        end.
        /* data types does not match - for access permissions 
           Attach maps with MapNoArea to avoid finding the area fields */
        if pccolumn = "ttTenant.DefaultDataAreaName" then
        do:
            return "_tenant._Tenant-DataArea-default".      
        end.
        if pccolumn = "ttTenant.DefaultIndexAreaName" then
        do:
            return "_tenant._Tenant-IndexArea-default".      
        end.
        else if pccolumn = "ttTenant.DefaultLobAreaName" then
        do:
            return "_tenant._Tenant-LobArea-default".      
        end.
     
        return pccolumn.
    end method.     
    
    method public override logical Attach(bufferHandle as handle).
        FieldMapping = FieldMapNoArea.
        return super:Attach(bufferHandle).
    end method.
    
end class.