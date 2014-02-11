 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : IndexContext
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
using OpenEdge.DataAdmin.IndexImpl from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.Query.TableIndexQuery from propath.
using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope from propath. 

using OpenEdge.DataAdmin.Support.TableIndexSet from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.IndexContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/index.i}
     
    define private dataset dsIndex serialize-name "root" for ttIndex.
    define buffer bIndex for ttIndex.
    define temp-table copyIndex reference-only like ttIndex .  
    define variable mpartitions as PartitionContext no-undo.
      
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsIndex:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttIndex:handle.
    	end get.
     
    define public override property KeyFields as character  no-undo  
        get():
            return "TableName,Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bIndex for ttIndex.
            if Count = ? then
            do:
                Count = 0.
                for each bIndex:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public IndexContext ():
        super ("Index").
    end constructor.
    
    constructor public IndexContext (pscope as ISchemaScope):
        super ("Index",pscope).   
        AddChild(pscope:PartitionContext).
    end constructor.    
		
	/* override default tree to not include child (partitions) */
	method override public void AddTreeTo( input tree as OpenEdge.DataAdmin.Binding.IContextTree ):
		super:AddTableTo(input tree).
	end method.

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
    
    method override public void WriteTo( input writer as OpenEdge.DataAdmin.Binding.IContextWriter ):
        super:WriteTo(input writer).
    end method.
   
    /** Find with unique key
         @param TableName  
         @param IndexName   */
    method public logical Find(ptablename as char,pname as character):
        find ttIndex where ttIndex.TableName = ptablename
                     and   ttIndex.Name = pname no-error.
        return avail ttIndex.             
    end.    
    
    /** CanFind with unique key
         @param TableName  
         @param IndexName   */
    method public logical CanFind(ptablename as char,pname as character):
        return can-find(ttIndex where ttIndex.TableName = ptablename
                                and   ttIndex.Name = pname).
    end.    
       
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in IndexContext").
/*        return new IndexSet(cntxt).*/
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
         return new IndexImpl(cntxt).
    end method.
    
    method override protected FilteredContext CreateFilteredContext(pparent as char,pkey as char,pReq as IRequestInfo):     
         define variable cTable as character no-undo.
         
         case pparent:
             when "tables" then
             do:              
                 return new TableIndexQuery(this-object,pkey,pReq).
             end.              
             otherwise
                 return super:CreateFilteredContext(pparent,pkey,pReq).              
         end.        
    end method.
    
    method override protected IDataAdminCollection CreateCollection(pparent as char,pcntxt as FilteredContext):     
         
        case pparent:
            when "tables" then
            do:          
                return new TableIndexSet(cast(pcntxt,TableIndexQuery)).
            end.   
          
            otherwise 
                return super:CreateCollection(pparent,pcntxt).             
        end.        
    end method.
    
end class.
