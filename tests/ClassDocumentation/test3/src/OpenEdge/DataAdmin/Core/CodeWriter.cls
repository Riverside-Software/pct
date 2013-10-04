/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
/*------------------------------------------------------------------------
    File        : CodeWriter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:18:09 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath. 
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Core.DataAdminWriter from propath. 
using OpenEdge.DataAdmin.Core.IDataAdminWriter from propath. 
class OpenEdge.DataAdmin.Core.CodeWriter inherits DataAdminWriter  implements IDataAdminExporter:  
    define stream script. 
    define private variable mfile as character no-undo.
    define private variable mCannotSetImmediate as logical no-undo.
    
/*    define private variable mParentCreated as logical no-undo.*/
    
	constructor public CodeWriter (  ):
		super ().
    end constructor.
      
    method public void WriteToFile(serializable as IDataAdminSerializable,pcFile as char,pcMode as char):
        define variable h as handle no-undo.
        h = this-object:Write(serializable,pcMode).
       
        mfile = pcfile.
        WriteCode(h).
        
    end method.
    
    method private void WriteCode(h as handle):
        output stream script to value(mfile).
        WriteHeader(h).
        WriteDefs(h).
        WriteInit().
        WriteQuery(h:top-nav-query(1)).
        WriteErrorHandler ().
        output stream script close.
    end method.
    
    method private void WriteInit():
         put stream script unformatted
             "/* Start a service for the " quoter(ldbname("dictdb")) " database. */" skip.
         put stream script unformatted 
             "service = new DataAdminService(" + quoter(ldbname("dictdb"))  + ")." skip(1).
    end method.
    
    method private char GetDate():  
        define variable mweekdays as char init "Sun,Mon,Tue,Wed,Thu,Fri,Sat" no-undo.
        define variable myears as char init "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec" no-undo.
        return entry(weekday(today),mWeekdays)
            + ' ' 
            + entry(month(today),myears)
            + ' '
            + string(day(today))
            + ' '
            + string(time,"hh:mm:ss")
            + ' '
            + string(year(today)).    
    end.
    
    
    method private char GetComment(pcfile as char,pcpurpose as char):
         /* Sun Oct 17 15:10:33 EDT 2010 */
        return
     '/*' +  fill("-",78) + chr(10)
   + '  Purpose: '  + pcpurpose  + chr(10)
   + '  Created: ' + GetDate() + " by dataadmin code writer." + chr(10)
   + '    Notes: '  + chr(10)
   +  fill("-",78) + '*/'
      .
    end method.    
    
    
    method private void WriteHeader(hDs as handle):
        define variable i as integer no-undo.
        define variable hbuf as handle no-undo.
        define variable cPurpose as character no-undo.
        if valid-handle(hds:get-buffer-handle ("ttTenant")) then  
            cPurpose =  "Create tenant".
        else
            cPurpose =  "Create partition group".
            
        put stream script unformatted 
           GetComment(mfile,cPurpose) skip(1).
        put stream script unformatted 
           "routine-level on error undo, throw." skip
           "using Progress.Lang.Error from propath." skip   
           "using OpenEdge.DataAdmin.DataAdminService from propath." skip 
           "using OpenEdge.DataAdmin.Error.DataAdminErrorHandler from propath." skip.   
        do i = 1 to hDs:num-buffers:
            hbuf = hDs:get-buffer-handle (i).
            put stream script unformatted "using OpenEdge.DataAdmin." + GetEntityInterface(hbuf:name) + " from propath."  skip.     
/*            if valid-handle(hbuf:parent-relation) then                                                                            */
/*               put stream script unformatted "using OpenEdge.DataAdmin." + GetCollectionClass(hbuf:name) + " from propath."  skip.*/
        end.
        put stream script unformatted skip(1).
    end method.    
    
    method private void WriteDefs(hDs as handle):
        define variable i as integer no-undo.
        define variable hbuf as handle no-undo.
        put stream script unformatted 
            "define variable service as DataAdminService no-undo." skip   
            "define variable errorHandler as DataAdminErrorHandler no-undo." skip.     
               
        do i = 1 to hDs:num-buffers:
            hbuf = hDs:get-buffer-handle (i).
            put stream script unformatted 
               "define variable " + GetEntityInstance(hbuf:name) + " as " GetEntityInterface(hbuf:name) + " no-undo." skip.     
            if hbuf:name = "ttUser" then
               put stream script unformatted 
                "/* Default user password - can only be changed by the user after creation */" skip
                "define variable cPassword as character init ~"password~" no-undo." skip.     
            if hbuf:name = "ttDomain" then
               put stream script unformatted 
               "/* Default domain AccessCode   */" skip
               "define variable cAccessCode as character init ~"accesscode~" no-undo." skip.     
       
            /*
            if valid-handle(hbuf:parent-relation) then
               put stream script unformatted "define variable " + GetCollectionInstance(hbuf:name) + " as " GetCollectionClass(hbuf:name) + " no-undo." skip.      
            */
        end.
        put stream script unformatted skip(1).
    end method.    
    
    method private void WritePartitionBuffer(hparent as handle,hbuffer as handle):
       
       put stream script unformatted 
               "assign " skip
               GetEntityInstance(hbuffer:name) at 5 
               " = " 
               GetEntityInstance(hParent:name) 
               ":Partitions:" .    
       if hbuffer::Objecttype = "table" then
           put stream script unformatted 
              "FindTable(" quoter(hBuffer::Tablename) ") "  skip.
       else if hbuffer::Objecttype = "field" then
           put stream script unformatted 
              "FindField(" quoter(hBuffer::Tablename) "," quoter(hBuffer::FieldName) ")" skip.
       else if hbuffer::Objecttype = "index" then
           put stream script unformatted 
              "FindIndex(" quoter(hBuffer::Tablename) "," quoter(hBuffer::IndexName) "," quoter(hBuffer::Collation) ")" skip.
      
       put stream script unformatted 
          GetEntityInstance(hBuffer:name) at 5 ":Area = " GetArea(hbuffer::Areaname)  skip. 
       
       if hbuffer::Objecttype = "table" then
          put stream script unformatted 
             GetEntityInstance(hBuffer:name) at 5 ":AllocationState = " quoter(hbuffer::AllocationState)  skip. 
       
       if hBuffer::BufferPool <> "Primary" then
          put stream script unformatted 
            GetEntityInstance(hBuffer:name) at 5 ":BufferPool = " quoter(hbuffer::BufferPool)  skip. 
       
       put stream script unformatted "    ." skip(1).
        
    end.

    /** NOTE : this is actually generating code for the Tenants and TenantGroups collections 
       and not the tenantGroupMembers 
       (it's the same data just different collections - see implementations)*/ 
    method private void WriteTenantGroupMembersBuffer(hparent as handle,hbuffer as handle):
       
       if hParent:name = "ttTenant" then
       do:
           put stream script unformatted 
              "/* Add a group to the tenantgroups collection */" skip.
           put stream script unformatted  
                   GetEntityInstance(hParent:name) 
                   ":TenantGroups:Add(service:GetTenantGroup(" quoter(hBuffer::TenantGroupName) ")). "  skip .    
           put stream script unformatted skip(1).
       end.
       else do:
           put stream script unformatted 
              "/* Add a tenant to the tenants collection */" skip.
           put stream script unformatted  
                   GetEntityInstance(hParent:name) 
                   ":Tenants:Add(service:GetTenant(" quoter(hBuffer::TenantName) ")). "  skip .    
           put stream script unformatted skip(1).
       
       end.     
     end.
    
    method private void WriteBuffer(hbuffer as handle):
        define variable i as integer no-undo.
        
            put stream script unformatted 
               "/* Instantiate a new "  GetEntityInterface(hbuffer:name)    " */" skip.
            put stream script unformatted 
               GetEntityInstance(hbuffer:name) " = service:New"  GetEntityClass(hbuffer:name)  "(" + quoter(hBuffer::name) ")." skip.
        
            put stream script unformatted "assign" skip.
            do i = 1 to hbuffer:num-fields:
                WriteField(hBuffer:buffer-field (i)).
            end.
            put stream script unformatted "    ." skip.
/*            if valid-handle(hbuffer:parent-relation) then                                                */
/*            do:                                                                                          */
/*                put stream script unformatted                                                            */
/*                 GetEntityInstance(hbuffer:parent-relation:parent-buffer:name)                           */
/*                ":" GetCollectionName(hBuffer:name) ":Add("  GetEntityInstance(hbuffer:name)   ")." skip.*/
/*            end.                                                                                         */
        
    end method.    
    
    method private char GetArea(cvalue as char): 
        return "service:GetArea(" + quoter(cValue) + ")" .
    end method.
    
    method private char GetAuthenticationSystem(cvalue as char): 
        return "service:GetAuthenticationSystem(" + quoter(cValue) + ")" .
    end method.
    
    method private char GetTable(cvalue as char): 
        return "service:GetTable(" + quoter(cValue) + ")" .
    end method.
    
    method private char GetTenantGroup(cvalue as char): 
        return "service:GetTenantGroup(" + quoter(cValue) + ")" .
    end method.
    
    method private void WriteField(hField as handle):
        if hfield:name matches "AuthenticationSystemName" then
           put stream script unformatted 
             GetEntityInstance(hfield:Table) at 5 ":"  
             replace(hfield:name,"name","") 
             " = " 
             GetAuthenticationSystem(hField:buffer-value) skip.
        else
        if hfield:name matches "*AreaName" then
        do: 
            if hField:buffer-value > "" then
            do:   
              put stream script unformatted 
                 GetEntityInstance(hfield:Table) at 5 ":"  
                 replace(hfield:name,"name","") 
                 " = " 
                 GetArea(hField:buffer-value) skip.
            end. 
        end.
        else
        if hfield:name matches "TableName" then
        do: 
            if hField:buffer-value > "" then
            do:   
              put stream script unformatted 
                 GetEntityInstance(hfield:Table) at 5 ":"  
                 replace(hfield:name,"name","") 
                 " = " 
                 GetTable(hField:buffer-value) skip.
            end. 
        end.
        else if hField:name = "isbuiltin" then
        do:
        end.
        else if hField:name = "schemaname" then
        do: 
           /** TODO check parent and write service:GetTenant("<value>") if not tenant **/  
        end.    
        else if hField:name = "tenantname" then
        do: 
           /** TODO check parent and write service:GetTenant("<value>") if not tenant **/  
        end.
        else if hField:name = "domainname" then
        do: 
           /** TODO check parent and write service:GetDomain("<value>") if not domain **/         
        end.
 /*       else if hfield:name matches "PartitionsURL" then do:
          /** TODO check parent, also check TenantGroupMembersURL and write something **/
             put stream script unformatted 
             GetEntityInstance(hfield:Table) at 5 ":"
              replace(hfield:name,"name","")
              "TenantGroups:"   
             " = Add(service:GetTenantGroup(" 
             GetTenantGroup(hField:buffer-value) skip. 
        end.         */
        else if hField:name = "DefaultAllocation" then
        do:
           if hField:buffer-value > "" then 
               put stream script unformatted 
                   GetEntityInstance(hfield:Table) at 5 ":"  
                   hfield:name " = " 
                   quoter(hField:buffer-value ()) skip.
            
        end.    
        else if hField:name = "IsAllocated" then
        do:
           /*
           if hField:buffer-value = true then 
               put stream script unformatted 
                  GetEntityInstance(hfield:Table) at 5 ":"  
                  hfield:name " = " 
                  hField:buffer-value () skip.
            */
        end.    
        else if not hfield:serialize-hidden 
        and hfield:name <> "name"
        and hfield:name <> "id"
        and hField:buffer-value <> ?
        and not hField:name matches "*url" then
           put stream script unformatted 
               GetEntityInstance(hfield:Table) at 5 ":"  
               hfield:name " = " 
               (if hfield:name = "password" then "cPassword"
                else if hfield:name = "AccessCode" then "cAccessCode"
                else if hfield:data-type = "character" then quoter(hField:buffer-value ())
                else hField:buffer-value ()) skip.
    end method.    
    
    method private char GetEntityInterface(pcBuffername as char): 
        return "I" + GetEntityClass(pcBuffername). 
    end.
    
    method private char GetEntityClass(pcBuffername as char): 
        return caps(substr(pcBufferName,3,1))
               + substr(pcBufferName,4). 
    end.
    
    method private char GetCollectionClass(pcBuffername as char): 
        return  
              caps(substr(pcBufferName,3,1))
               + substr(pcBufferName,4)
               + if pcBuffername = "ttpartition" 
                 then "SchemaMap"
                 else "Set". 
    end.
    
    method private char GetEntityInstance(pcBuffername as char): 
        if pcBuffername = 'ttuser' then 
            return "myUser".
        return 
               lc(substr(pcBufferName,3,1))
              + substr(pcBufferName,4). 
    end.
    
    method private char GetCollectionInstance(pcBuffername as char): 
        return  lc(substr(pcBufferName,3,1))
               + substr(pcBufferName,4)
               + if pcBuffername = "ttpartition" 
                 then "Map"
                 else "Set". 
    end.
    
    method private char GetCollectionName(pcBuffername as char): 
        return  caps(substr(pcBufferName,3,1))
               + substr(pcBufferName,4)
               + "s". 
    end.
    
    method private void WritePartitions(phbuffer as handle): 
        define variable hquery        as handle no-undo.
        define variable hparent       as handle no-undo.
        define variable hparentBuffer as handle no-undo.
        define variable hPartition    as handle no-undo.     
        define variable cQuery        as char no-undo.
        define variable cparentname   as character no-undo.

        create query hquery.
        
        create buffer hPartition for table phbuffer.
       
        cquery = "for each ttPartition".
        if valid-handle(phbuffer:parent-relation) then
        do:
            hparent = phbuffer:parent-relation:parent-buffer.
            if hParent:name = "ttTenant" or hparent:name = "ttTenantGroup" then
            do:
               cParentname = lc(substr(hParent:name,3,1)) + substr(hParent:name,4).
               create buffer hParentBuffer for table hParent. 
               hquery:add-buffer(hParentBuffer).
               cquery = "for each " + hParent:name + " where " + hParent:name + ".name =" + quoter(hParent::name) + ", " 
                      + " each ttPartition where ttPartition." + cParentname + "name = " + hParent:name + ".name "
                      + "and ("
                      + " (ttPartition.ObjectType = 'table' and ttPartition.Areaname <> " + hParent:name + ".DefaultDataAreaName)"
                      + " or "            
                      + " (ttPartition.ObjectType = 'field' and ttPartition.Areaname <> " + hParent:name + ".DefaultLobAreaName)"
                      + " or "            
                      + " (ttPartition.ObjectType = 'index' and ttPartition.Areaname <> " + hParent:name + ".DefaultIndexAreaName)"
                      + " or "
                      + " (ttPartition.AllocationState <> " 
                         + "( if " + hParent:name + ".DefaultAllocation = 'Immediate' then 'Allocated' else " + hParent:name + ".DefaultAllocation )"
                      + ")"
                      + " or "
                      + " ttPartition.BufferPool <> 'Primary'"
                       + ")".
            
            end.                  
        end.
        hquery:add-buffer(hPartition).
        hquery:query-prepare(cquery).
        hquery:query-open ().
        hquery:get-first ( ).
        if hPartition:avail then
        do:
            
            if valid-handle(hParent) and (hParent:name = "tttenant" or hparent:name = "tttenantgroup") then 
            do:
                /* set flag for parent to deal with this inconsistency and change the query to 
                   write all partitions that are not delayed (which will be used for create<parent> )*/
                if hParent::DefaultAllocation = "immediate" then
                do:
                   mCannotSetImmediate = TRUE.
                   cquery = "for each " + hParent:name + " where " + hParent:name + ".name =" + quoter(hParent::name) + ", " 
                          + " each ttPartition where ttPartition." + cParentname + "name = " + hParent:name + ".name "
                          + "and ("
                          + " (ttPartition.ObjectType = 'table' and ttPartition.Areaname <> " + hParent:name + ".DefaultDataAreaName)"
                          + " or "            
                          + " (ttPartition.ObjectType = 'field' and ttPartition.Areaname <> " + hParent:name + ".DefaultLobAreaName)"
                          + " or "            
                          + " (ttPartition.ObjectType = 'index' and ttPartition.Areaname <> " + hParent:name + ".DefaultIndexAreaName)"
                          + " or "
                          + " (ttPartition.AllocationState <> 'Delayed')" 
                          + " or "
                          + " ttPartition.BufferPool <> 'Primary'"
                       + ")".
                   hquery:query-prepare(cquery).
                   hquery:query-open ().
                   hquery:get-first ( ).
                end.
            end.
            put stream script unformatted 
                  skip(1) "/* Edit the partitions that have non default settings */" skip.
            
            if mCannotSetImmediate then      
                put stream script unformatted 
                    "/************************************************************************" SKIP   
                     " WARNING: The " + GetEntityClass(hparent:name) + " needs two transactions." skip
                     " The " + GetEntityInstance(hparent:name) +  " DefaultAllocation is ~"Immediate~", but the Partitions " skip 
                     " have properties that does not match the defaults." skip
                     " The DefaultAllocation will be set to ~"Delayed~" before create to " skip 
                     " allow changes to partitions. The generated partition changes below " skip
                     " takes this into account and includes 'Allocated' partitions." skip 
                     " The DefaultAllocation is set back to ~"Immediate~" in a separate " skip
                     " transaction after the create." skip 
                     "*********************************************************************** */" SKIP   
                . 
               
            do while hPartition:avail:
                WritePartitionBuffer(hparent,hPartition).
                hquery:get-next ().
            end.
        end.       
        delete object hPartition no-error.
        delete object hParentBuffer no-error.
        delete object hQuery no-error.
    end method.
    
    method private void WriteQuery(pquery as handle):
        define variable hBuff as handle no-undo.
        define variable iChild as integer no-undo.
        define variable hrel as handle no-undo.
        hbuff = pQuery:get-buffer-handle (1).
        
        if hbuff:name = "ttPartition" then
        do:
            WritePartitions( hbuff).
        end. 
        else if hbuff:name = "ttTenantGroupMember" then
        do:
            WriteTenantGroupMembers( hbuff).
        end.    
        else do:
            pQuery:query-open () .
            pquery:get-first ( ).
            do while hbuff:avail:
                WriteBuffer(hbuff).             
                do iChild = 1 to hbuff:num-child-relations:
                   hrel = hbuff:get-child-relation (iChild).   
                   WriteQuery(hRel:query). 
                end.
                if  valid-handle(hbuff:parent-relation) then
                do:
                    put stream script unformatted 
                       "/* Add the new "  GetEntityInstance(hbuff:name) 
                       " to the " GetEntityInstance(hbuff:parent-relation:parent-buffer:name)
                       "'s " GetCollectionName(hBuff:name) 
                       " collection. "
                        "*/" skip. 
                    put stream script unformatted 
                       GetEntityInstance(hbuff:parent-relation:parent-buffer:name) 
                       ":" 
                       GetCollectionName(hBuff:name) 
                       ":Add("  GetEntityInstance(hbuff:name)   ")." skip.
                end.
                else do:
                    if mCannotSetImmediate and (hbuff:name = "ttTenant" or hbuff:name = "ttTenantGroup") then
                    do:
                          put stream script unformatted 
                     "/************************************************************************" SKIP   
                     " WARNING: The " + GetEntityClass(hBuff:name) + " needs two transactions." skip
                     " The " + GetEntityInstance(hBuff:name) +  " DefaultAllocation is ~"Immediate~", but the Partitions " skip 
                     " have properties that does not match the defaults." skip
                     " The DefaultAllocation is set to ~"Delayed~" before create to allow " skip 
                     " changes to partitions. The generated partition changes above " skip
                     " takes this into account and includes 'Allocated' partitions." skip 
                     " The DefaultAllocation is set back to ~"Immediate~" in a separate " skip
                     " transaction below." skip 
                     "*********************************************************************** */" SKIP   
                       GetEntityInstance(hBuff:name) + ":DefaultAllocation = " quoter("Delayed") "." skip.  
                    
                    end.
                    WriteCreateInService(hBuff).
                    if mCannotSetImmediate and (hbuff:name = "ttTenant" or hbuff:name = "ttTenantGroup") then
                    do:
                        put stream script unformatted 
                        "/** Set default allocation back to 'immediate'  */" skip 
                        GetEntityInstance(hBuff:name) + ":DefaultAllocation = " quoter(hbuff::DefaultAllocation) "." skip.  
               
                        put stream script unformatted

                        "/* Update (commit) the " GetEntityClass(hBuff:name)
                         " with the DefaultAllocation. */ " skip

                         "service:Update" GetEntityClass(hBuff:name)
                              "(" GetEntityInstance(hBuff:name)  ")." skip(1).
                        
                        mCannotSetImmediate = false.               
                    end.
                end.
                pquery:get-next ().
               
            end.  
        end.
    end.
    
    method private void WriteCreateInService (phBuff as handle):
   
        put stream script unformatted
             "/* Create (commit) the " GetEntityInstance(phBuff:name) " in the service */" skip.

        put stream script unformatted
             'service:Create' GetEntityClass(phBuff:name)
                "(" GetEntityInstance(phBuff:name)  ")." skip(1).

          
    end method.

    method private void WriteTenantGroupMembers (phBuffer as handle):
        define variable hquery        as handle no-undo.
        define variable hparent       as handle no-undo.
        define variable hparentBuffer as handle no-undo.
        define variable hPartitionDetail    as handle no-undo.     
        define variable cQuery        as char no-undo.
        
        create query hquery.
        create buffer hPartitionDetail for table phbuffer.
       
        cquery = "for each ttTenantGroupMember".
        hquery:add-buffer(hPartitionDetail).
        if valid-handle(phbuffer:parent-relation) then
        do:
            hparent = phbuffer:parent-relation:parent-buffer.
            if hParent:name = "ttTenant" then
            do:
               cquery = "for each ttTenantGroupMember where ttTenantGroupMember.TenantName = " + quoter(hparent::name).
            end.                  
            if hParent:name = "ttTenantGroup" then
            do:
               cquery = "for each ttTenantGroupMember where ttTenantGroupMember.TenantGroupName = " + quoter(hparent::name).
            end.                  
        end.
        
        hquery:query-prepare(cquery).
        hquery:query-open ().
        hquery:get-first ( ).
        if hPartitionDetail:avail then
        do:
            
            if valid-handle(hParent) 
            and (hParent:name = "tttenant" or hParent:name = "tttenantGroup") then 
            do while hPartitionDetail:avail:
                WriteTenantGroupMembersBuffer(hparent,hPartitionDetail).
                hquery:get-next ().
            end.
                    
        end.       
        delete object hPartitionDetail.
        delete object hParentBuffer NO-ERROR.
        delete object hQuery.
    
    end method.
    
    method private void WriteErrorHandler ():
        put stream script unformatted 
            skip(1)
            "catch e as Error:" skip
            "    errorHandler = new DataAdminErrorHandler()." skip
            "    errorHandler:Error(e)." skip      
            "end catch." skip.
    end method.
    
    method public longchar WriteToLongchar(serializable as IDataAdminSerializable,pcMode as char):
        define variable h as handle no-undo.
        define variable cl as longchar no-undo.
        h = this-object:Write(serializable,pcMode).
    end method.
    
    method public void WriteToMemptr(serializable as IDataAdminSerializable,m as memptr,pcMode as char):
        define variable h as handle no-undo.
      
        h = this-object:Write(serializable,pcMode).
    end method.
    
    method public void WriteToStream(serializable as IDataAdminSerializable,phStream as handle,pcMode as char):
        define variable h as handle no-undo.
        
        h = this-object:Write(serializable,pcMode).
    end method.
    
end class.
