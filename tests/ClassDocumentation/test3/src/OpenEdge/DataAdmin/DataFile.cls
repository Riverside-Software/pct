/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Mar 30 21:56:15 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.IDataFile from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
class OpenEdge.DataAdmin.DataFile inherits Entity implements IDataFile:  
    
    define public property TableSequence      as integer       no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::TableSequence.
            else
                return TableSequence. 
        end.
    
    define public property FileName           as character     no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::FileName.
            else
                return FileName. 
        end.
    
    define public property Table              as ITable        no-undo   
         get():
            if not valid-object(this-object:Table) and valid-handle(mBuffer) and valid-object(Service) then
            do:
                 return service:GetTable(mBuffer::Tablename). 
            end.
            return this-object:Table. 
        end.
         
    define public property Type               as character     no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Type.
            else
                return Type. 
        end.
        
    define public property Tenant             as ITenant       no-undo   
        get():
             if not valid-object(Tenant) then
             do:
                 if valid-handle(mBuffer) and mBuffer::TenantName > "" 
                 and valid-object(Service) then
                     return Service:GetTenant(mBuffer::TenantName).            
             end.
             return Tenant.
        end.     
   
    define public property TenantGroup        as ITenantGroup  no-undo   
        get():
             if not valid-object(TenantGroup) then
             do:
                 if valid-handle(mBuffer) and mBuffer::TenantGroupName > "" 
                 and valid-object(Service) then
                     return Service:GetTenantGroup(mBuffer::TenantGroupName).            
             end.
             return TenantGroup.
        end.     
        
    define public property StartTime          as datetime-tz   no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::StartTime.
            else
                return StartTime. 
        end.
        
    define public property EndTime            as datetime-tz   no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::EndTime.
            else
                return EndTime. 
        end.
        
    define public property ExpectedNumRows    as int64         no-undo    
        get():
            if valid-handle(mBuffer) then
                return mBuffer::ExpectedNumRows.
            else
                return ExpectedNumRows. 
        end.
        
    define public property ProcessedNumRows   as int64         no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::ProcessedNumRows.
            else
                return ProcessedNumRows. 
        end.
        
    define public property IsComplete         as logical       no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsComplete.
            else
                return IsComplete. 
        end.
        
    define public property AnyError           as logical       no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::AnyError.
            else
                return AnyError. 
        end.
    
    define public property ErrorMessage       as character     no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::ErrorMessage.
            else
                return ErrorMessage. 
        end.
        
    define public property Bailed             as logical       no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Bailed.
            else
                return Bailed. 
        end.
    
    define property IsAvailable        as logical       no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsAvailable.
            else
                return this-object:IsAvailable. 
        end.
    
    define property CanImport          as logical       no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanImport.
            else
                return this-object:CanImport. 
        end.
    
    define property CanExport          as logical       no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanExport.
            else
                return this-object:CanExport. 
        end.
      
    constructor public DataFile(pcntxt as IDataAdminContext):
        super (pcntxt).     
    end constructor.
    
     /**   local context needed - has child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
/*        return new AreaContext().*/
    end method.
     
    
end class.