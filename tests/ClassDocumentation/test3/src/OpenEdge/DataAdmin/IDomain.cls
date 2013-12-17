/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Security Domain interface  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:01:21 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IAuthenticationSystem from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.IUserSet from propath.
 
interface OpenEdge.DataAdmin.IDomain inherits IDataAdminElement: 

    /** The name and unique idnetifier of a single Authentication System (domain) that 
        can be used to authenticate or validate the authentication of a user account.
        The 4GL or SQL will refer to this name when it begins a user authentication 
        process or it is validating the CLIENT-PRINCIPAL object that was produced by 
        an authentication operation performed in this domain.
        The domain name may be used to fully qualify a user's identity by suffixing it to 
        the user's id using a "@" delimiter (ex: fred@ldap).  */ 
    define public property Name            as character no-undo get. set.
    
    define public property Id              as integer no-undo get.
        
    /** The Authentication System of the domain  _oeusertable, LDAP, RSA, KERBOS, KEON, internal etc*/
    define public property AuthenticationSystem      as IAuthenticationSystem no-undo get. set.
    
    /** A free text description of the domain primarily for reporting purposes */   
    define public property Description     as char      no-undo get. set.
    
    /** Comments about the domain - can hold custom specific authentication details */   
    define public property Comments        as char      no-undo get. set.
    /** The Tenant of the Domain */
    define public property Tenant          as ITenant   no-undo get. set.
    /** This logical property facilitates disabling of the Domian without deleting it.
        If set to NO then authentication for this domain will be disabled. 
        The default is YES to enable authentication for this domain. */ 
    define public property IsEnabled       as logical   no-undo get. set.
    
    /** Returns true if the Domain is builtin  */ 
    define public property IsBuiltin       as logical   no-undo get.  
    
    /** This text will provide the Audit record context value when a _client-session record 
        is recorded to the database.  It should describe the domain's Authentication System,
        location, and any other identifying characteristics.  
        While this value is optional for auditing, it is recommended that a value be filled in. */
    define public property AuditingContext as char      no-undo get. set.
    
    /** This is an encrypted access-code-phrase that is used to validate the identity and 
        integrity of any CLIENT-PRINCIPLE issued by the Authentication System represented 
        by this domain.         
        The access-code-phrase is an encrypted string consisting of printable characters 
        with a null terminator (including embedded spaces and tabs).  
        The pass phrase is case sensitive and will be used to generate and validate 
        [MD5] MAC seals in CLIENT-PRINCIPAL objects.
        Note that this field is encrypted for security purposes and the encryption 
        method used must be understood by the 4GL / PVM as it must know how to decrypt 
        the access code to validate it. */
    define public property AccessCode      as char      no-undo get. set.
    
    /** Defines SystemOptions (PAM options) applicable to the Authentication System */
    define public property SystemOptions  as char      no-undo get. set.
    
    /** Used to define a comma delimited list of Run time options for the ABL runtime. 
        The valid runtime options will depend on the Authentication System */
    define public property RuntimeOptions  as char      no-undo get. set.
    
    /** Collection of OpenEdge Users of the Domain  */
    define public property Users           as IUserSet no-undo get.     
     
   
      
end interface.
