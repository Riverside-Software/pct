/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TenantGroupMember
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.Error from propath.
using Progress.Lang.Object from propath.

using OpenEdge.DataAdmin.DataAdminService from propath. 
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.TenantGroup from propath.
using OpenEdge.DataAdmin.TenantGroupMember from propath.
using OpenEdge.DataAdmin.IPartitionCollection from propath.
 

using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.IUserSet from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminExporter from propath.
using OpenEdge.DataAdmin.IDataAdminSerializable from propath. 
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupContext from propath. 

using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath. 
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath. 
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath. 

using OpenEdge.DataAdmin.Core.JSONWriter from propath.  
using OpenEdge.DataAdmin.Core.CodeWriter from propath.  

class OpenEdge.DataAdmin.TenantGroupMember inherits Entity implements ITenantGroupMember:
    
    /* implements ITenant, IDataAdminElement, IDataAdminSerializable */  
    define private property ValidTypeList as char 
       init "Regular,Super"
       get.
         
        
    
    define private variable mChild as logical no-undo. 

             
    define public property TenantGroup as ITenantGroup no-undo                 
        get():
            if not valid-object(TenantGroup) then
            do:
                if valid-handle(mBuffer) then
                    this-object:TenantGroup = Service:GetTenantGroup(mBuffer::TenantGroupName).
            
            end.
            return TenantGroup. 
            
        end.
        set(pGroup as ITenantGroup):
            if not valid-object(pGroup) then 
                undo, throw new UnknownValueError("TenantGroup").
/*            if valid-object(TenantGroup) then                                          */
/*                undo, throw new ReadOnlyPropertyError("TenantGroupMember","","Tenant").*/
/*                                                                                          */
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TenantGroupName = pGroup:Name.
            end.
            TenantGroup = pGroup.
        end. 
    
     define public property Tenant as ITenant no-undo 
        get():
             if not valid-object(Tenant) then
             do:
                 if valid-handle(mBuffer) and mBuffer::TenantName > "" 
                 and valid-object(Service) then
                     Tenant = Service:GetTenant(mBuffer::TenantName).            
             end.
             return tenant.
        end.     
        set(pTenant as ITenant ):
/*            if valid-object(Tenant) then                                                                   */
/*                undo, throw new ReadOnlyPropertyError("TenantGroupMember",TenantGroup:name,"Tenant").*/
            /*
            if valid-object(Service) then 
                undo, throw new ReadOnlyPropertyError("Domain",name,"Tenant").     
            */
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::TenantName = pTenant:name.
            end.
            Tenant = pTenant.    
        end.
        
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    constructor public TenantGroupMember (pGroup as ITenantGroup,pTenant as ITenant  ):
        super (pGroup:name + chr(1) + pTenant:name).
        if not valid-object(pTenant) then
            undo, throw new UnknownValueError("TenantGroupMember constructor","tenant").   
        Tenant = pTenant.
        TenantGroup = pGroup.    
        
    end constructor.   
    
    constructor public TenantGroupMember ():
        super ("").   
    end constructor.
       
    constructor public TenantGroupMember (pcntxt as IDataAdminContext ):
        super (pcntxt).   
    end constructor.
        
     /* No local context needed - currently not used to create    */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
    
/*    method override logical Equals(obj as Object):            */
/*        define variable tnt as TenantGroupMember no-undo.     */
/*        if super:Equals(obj) then                             */
/*            return true.                                      */
/*        else do:                                              */
/*            tnt = cast(obj,TenantGroupMember).                */
/*            if  this-object:ContextId = tnt:ContextId         */
/*            and this-object:Tenant = tnt:Tenant               */
/*            and this-object:TenantGroup = tnt:TenantGroup then*/
/*                return true.                                  */
/*        end.                                                  */
/*        return false.                                         */
/*        catch e as Error :                                    */
/*            return false.                                     */
/*        end catch.                                            */
/*    end method.                                               */
    
    method public override void Export():
        Export("tenantgroupmember.json").
    end method.          
    
    method protected character GetCreateError():
        return "TenantGroupMember was not " 
               + (if valid-object(Service) 
                  then "created in service " + quoter(Service:Name) 
                  else "added to TenantGroupMemberSet")
               + ".". 
    end method.
    
    method public override void WriteTree(tree as IContextTree):
        tree:SetHandle(SerializeName,mDefaultBuffer,mDefaultBuffer:rowid).                
    end method.
   
      /* write specified collections (default all) */
    method public override  void WriteTree(tree as IContextTree,pcCollections as char):
        WriteTree(tree).  
    end method.
     
    method public override void ExportTree(pcfile as char):
        define variable writer as IDataAdminExporter no-undo.
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,"All").
    end method.     
    
    method public override void ExportTree(pcfile as char,pcCollectionlist as char):
        define variable writer as IDataAdminExporter no-undo.
        writer = GetExporter(pcfile).
        writer:WriteToFile(this-object,pcfile,pcCollectionlist).
    end method.     
     
    method private char GetFileExtension(pcFile as char):
       define variable i as integer no-undo.
       i = num-entries(pcfile,".").
       if i > 1 then
           return entry(i,pcfile,".").
       else return "".    
    end method.   
    
    method protected IDataAdminExporter GetExporter(pcFile as char):
        define variable i as integer no-undo.
        define variable fileext as character no-undo.
        fileExt = GetFileExtension(pcFile).
        case fileExt:
            when "p" then
                return new CodeWriter().
            when "json" then  
                return new JSONWriter().
            otherwise 
                undo, throw new IllegalArgumentError("Export to file with extension " + quoter(fileext)). 
        end.
    end method.
    
   
end class.
