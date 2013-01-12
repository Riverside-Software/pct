 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : FieldContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.FieldImpl from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.Query.TableFieldQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope from propath. 
using OpenEdge.DataAdmin.Support.TableFieldSet from propath. 

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.FieldContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/field.i}
     
    define private dataset dsField serialize-name "root" for ttField.
    define buffer bField for ttField.
    define temp-table copyField reference-only like ttField .  
    define variable mpartitions as PartitionContext no-undo.
      
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsField:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttField:handle.
    	end get.
    
     define public override property KeyFields as character  no-undo  
        get():
            return "TableName,Name". 
        end.    
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bField for ttField.
            if Count = ? then
            do:
                Count = 0.
                for each bField:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public FieldContext ():
        super ("Field").
    end constructor.
    
    constructor public FieldContext (pscope as ISchemaScope):
        super ("Field",pscope).
        AddChild(pScope:PartitionContext).
    end constructor.
        
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy Schema").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create Schema row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "tables" then 
                 return "name,TableName".
        end.
        return "".
    end.
    
    /* override default tree to not include child (partitions) */
    method override public void AddTreeTo( input tree as OpenEdge.DataAdmin.Binding.IContextTree ):
        super:AddTableTo(input tree).
    end method.
     
	method public override logical CanFind(name as character):
        undo, throw new UnsupportedOperationError("CanFind with name in FieldContext").          
    end.    
     
    method public override logical Find(name as character):
        undo, throw new UnsupportedOperationError("Find with name in FieldContext").       
    end.   
    
    /** Find with unique key
         @param TableName  
         @param FieldName   */
    method public logical Find(ptablename as char,pname as character):
        find ttField where ttField.TableName = ptablename
                     and   ttField.Name = pname no-error.
        return avail ttField.             
    end.    
    
    /** CanFind on unique key
         @param TableName  
         @param FieldName   */
    method public logical CanFind(ptablename as char,pname as character):
        return can-find(ttField where ttField.TableName = ptablename
                                and   ttField.Name = pname).
    end.    
     
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in FieldContext").
        /* return new FieldSet(cntxt).*/
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new FieldImpl(cntxt).
    end method.

    method override protected FilteredContext CreateFilteredContext(pparent as char,pkey as char,pReq as IRequestInfo):     
         define variable cTable as character no-undo.
         
         case pparent:
             when "tables" then
             do:              
                 return new TableFieldQuery(this-object,pkey,pReq).
             end.              
             otherwise
                 return super:CreateFilteredContext(pparent,pkey,pReq).              
         end.        
    end method.
    
    method override protected IDataAdminCollection CreateCollection(pparent as char,pcntxt as FilteredContext):     
         
        case pparent:
            when "tables" then
            do:          
                return new TableFieldSet(cast(pcntxt,TableFieldQuery)).
            end.   
          
            otherwise 
                return super:CreateCollection(pparent,pcntxt).             
        end.        
    end method.

    
end class.
