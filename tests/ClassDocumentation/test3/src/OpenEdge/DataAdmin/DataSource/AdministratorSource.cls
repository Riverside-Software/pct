 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AdministratorSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Jun 03 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.AdministratorSource: 
	/*------------------------------------------------------------------------------
			Purpose: Dataadministrator definition logic  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
    /* keep extent 7 - the number is used by prodict to ensure use of translated strings */ 
    define private variable ErrorStrings as char extent 7 init [
    /* 1*/ "This function only works on Progress databases.",
    /* 2*/ "You may not use this function with a blank userid.",
    /* 3*/ "You must be a Security Administrator to use this function.",
    /* 4*/ "You cannot change a security field to exclude yourself.",
    /* 5*/ "At least one security-administrator must be defined as a user.",
    /* 6*/ "Are you sure that you want to make this change?",
    /* 7*/ "The dictionary is in read-only mode - alterations not allowed."		
	].
    
	constructor public AdministratorSource (  ):
      	super (). 
	end constructor.
    
           /** keep intact for prodict **/
    method public logical CheckAccess():
        define variable msg-num as integer no-undo.
        IF transaction 
        OR PROGRESS = "Run-Time"
        OR CAN-DO("READ-ONLY",DBRESTRICTIONS("DICTDB")) THEN 
            msg-num = 6. /* r/o mode */
        
        IF NOT IsAdministrator() THEN 
            msg-num = 3. /* secu admin? */
        
        IF USERID("dictdb") = ""  THEN 
            msg-num = 2. /* userid set? */
            
        IF DBTYPE("DICTDB") <> "PROGRESS" THEN 
            msg-num = 1. /* dbtype okay */
               
        IF msg-num <> 0 THEN DO:          
            undo , throw  new AppError(ErrorStrings[msg-num],msg-num).
        end. 
    end.
        
    method private logical IsAdministrator():
        define variable ans as logical no-undo.
        RUN "prodict/_dctadmn.p" (INPUT USERID("dictdb"),OUTPUT ans).
        return ans.
    end.
    
    method public void Fill(hbuffer as handle):
        CheckAccess().
        hBuffer:buffer-create ( ).
        find DICTDB._File  "_User" no-lock.
        hBuffer::Administrators = _File._Can-create.
    end method.    
    
    method public void Save(phbuffer as handle):
        define variable hBeforeBuff as handle    no-undo.  
        define variable mass        as character no-undo.
        define variable user-exists as logical   no-undo.   
        
        hBeforeBuff = phBuffer:before-buffer.
        
        if hBeforeBuff:row-state = row-created then
            undo, throw new UnsupportedOperationError("Create Administrator"). 
        if hBeforeBuff:row-state = row-deleted then
            undo, throw new UnsupportedOperationError("Delete Administrator"). 
        phBuffer:find-first ().
        mass = phBuffer::Administrators. 
        IF NOT CAN-DO(mass,USERID("dictdb")) THEN 
        DO:
           
            /* 4 cannot exclude self */
            undo, throw new AppError(ErrorStrings[4],4).
        END.
        
        if int(dbversion("dictdb")) > 10 then
        do:
            if can-find(first DICTDB._User where DICTDB._User._sql-only-user = false) then
            do:
                FOR EACH DICTDB._User where DICTDB._User._sql-only-user = false:
                    user-exists = CAN-DO(mass,DICTDB._User._Userid + "@" + DICTDB._User._Domain-name).
                    IF user-exists THEN LEAVE.
                END.
                IF NOT user-exists THEN DO:
                    /* 5 Need at least one security admin as a user if user records exist. */
                    undo, throw new AppError(ErrorStrings[5],5).
                END.
            end.
        end.
        else do:  
            if can-find(first DICTDB._User) then
            do:
                FOR EACH DICTDB._User:
                   user-exists = CAN-DO(mass,DICTDB._User._Userid).
                   IF user-exists THEN LEAVE.
                END.
                IF NOT user-exists THEN DO:
                    /* 5 Need at least one security admin as a user if user records exist. */
                    undo, throw new AppError(ErrorStrings[5],5).
                END.
            end.
        end.
        
        FIND DICTDB._File  "_File".
        FIND DICTDB._Field "_Can-read"   OF DICTDB._File.
        DICTDB._Field._Can-write = mass.
        FIND DICTDB._Field "_Can-write"  OF DICTDB._File.
        DICTDB._Field._Can-write = mass.
        FIND DICTDB._Field "_Can-create" OF DICTDB._File.
        DICTDB._Field._Can-write = mass.
        FIND DICTDB._Field "_Can-delete" OF DICTDB._File.
        DICTDB._Field._Can-write = mass.
    
        FIND DICTDB._File  "_Field".
        FIND DICTDB._Field "_Can-read"   OF DICTDB._File.
        DICTDB._Field._Can-write = mass.
        FIND DICTDB._Field "_Can-write"  OF DICTDB._File.
        DICTDB._Field._Can-write = mass.
        
        /* OE00170630 - protect security tables. Note that they will not be 
           available in pre-10.1A databases that have not had their schemas updated.
        */
        FIND DICTDB._File "_Db-Option" NO-ERROR.
        IF AVAILABLE DICTDB._File THEN DO:
            ASSIGN DICTDB._File._Can-create = mass
                   DICTDB._File._Can-write = mass
                   DICTDB._File._Can-delete = mass.
        END. 
    
        FIND DICTDB._File "_Db-Detail" NO-ERROR.
        IF AVAILABLE DICTDB._File THEN DO:
            ASSIGN DICTDB._File._Can-create = mass
                   DICTDB._File._Can-write = mass
                   DICTDB._File._Can-delete = mass.
        END.
    
        FIND DICTDB._File "_Db".
        FIND DICTDB._Field "_Db-guid" OF DICTDB._File NO-ERROR.
        IF AVAILABLE DICTDB._Field THEN
             DICTDB._Field._Can-write = mass.
    
          /* user record */
        FIND DICTDB._File  "_User".
        DICTDB._File._Can-create = mass.
        DICTDB._File._Can-delete = mass.
        
		/* authentication system */
        FIND DICTDB._File  "_sec-authentication-system" NO-ERROR.
		IF AVAIL(DICTDB._File) THEN
           ASSIGN DICTDB._File._Can-create = mass
                  DICTDB._File._Can-write  = mass
                  DICTDB._File._Can-delete = mass.
        /* domain */
        FIND DICTDB._File  "_sec-authentication-domain" NO-ERROR.
        IF AVAIL(DICTDB._File) THEN
           ASSIGN DICTDB._File._Can-create = mass
                  DICTDB._File._Can-write  = mass
                  DICTDB._File._Can-delete = mass.
        /* thrown above - rethrow */
        catch e as AppError  :
            undo, throw  e.		
        end catch.
        
        catch e2 as Error  :
            undo, throw new DataAccessError(e2).
        end.
    end method.
    
end class.