 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Error handler 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Jul 31 09:08:23 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Error.DataAdminErrorHandler: 
    define private stream ErrorStream.     
    
    define public property ErrorFile   as char no-undo get. set.
    define public property UseAppend   as log no-undo get. set.
     define public property UseJSON     as log no-undo 
        init yes
        get. set.
    
    define public property MaxErrors as int no-undo 
        init 20
        get. 
        set.
    
    define protected property NewLine     as char no-undo 
        init "~r~n"
        get. 
    
    define temp-table tterror  no-undo serialize-name "error"
      field Id as integer serialize-hidden
      field Number as integer serialize-name "number"
      field Msg    as character serialize-name "text"
      field Source as character serialize-name "source" init "ABL"
      
      index idx as unique primary Id. 
    
    define temp-table ttChilderror  no-undo serialize-name "childErrors"
      field ParentId as integer serialize-hidden
      field Id as integer serialize-hidden
      field Number as integer serialize-name "number"
      field Msg    as character serialize-name "text"
      index idx as unique primary ParentId Id.     
        
    define temp-table ttstack no-undo serialize-name "stack"
      field Id        as integer serialize-hidden  
      field LineNumber as integer serialize-hidden
      field Msg        as character serialize-name "call"
      index idx        as unique primary Id Linenumber. 
    
    define dataset dsError serialize-name "root" for ttError, ttchildError , ttStack
        data-relation child for ttError,ttChildError 
            relation-fields(Id,ParentId) foreign-key-hidden nested  
        data-relation stackrel for ttError,ttStack 
           relation-fields(Id,Id) foreign-key-hidden nested.  
    define variable i as integer no-undo.
    
	constructor public DataAdminErrorHandler (  ):
		super ().
	end constructor.

    constructor public DataAdminErrorHandler (errFile as char  ):
        this-object(errFile,no).
    end constructor.
    
    constructor public DataAdminErrorHandler (errFile as char, apnd as log  ):
        super ().
        Errorfile = errfile.
        UseAppend = apnd.
    end constructor.
    
    method public void Error(e as Error):
        ShowError(e).
    end. 
    
    method private void ShowError(e as Error):
        if ErrorFile > "" then
        do:    
            if UseJSON then 
                PutErrorToWeb(e).
            else
                PutErrorToFile(e).
        end.
        else do:
            if session:batch-mode then
                MessageError(e). 
            else
                MessageErrorViewAs(e).
        end.            
    end method.
    
    method private void PutErrorToFile(e as Error):
        output to value(ErrorFile).           
        PutError(e).
        output close.
    end method.   
    
    method protected void PutError(e as Error):
        put unformatted GetErrorMessage(e,"!MESSAGE") skip.
        put unformatted GetStack(e,"!STACK"). 
    end method.   
    
    method protected void MessageError(e as Error):
        message GetErrorMessage(e,"!MESSAGE") skip
                GetStack(e,"!STACK"). 
    end method.   
    
    method protected void MessageErrorViewAs(e as Error):
        message GetErrorMessage(e,"") skip
                GetStack(e,"----------")
                view-as alert-box error.    
    end method.   
    
    method protected void PutErrorToWeb(e as Error):        
         output stream ErrorStream to value(ErrorFile).                    
         define variable iHttp as integer no-undo.
         
         if type-of(e,DataAdminError) then
         do:
             iHttp = cast(e,DataAdminError):HTTPErrorNum.
         end.
         if iHttp = 0 then       
             iHttp = 500.
             
         put stream ErrorStream unformatted GetHTTPHeader(iHttp).
         FillError(e).
         FillStack(e).
         dataset dsError:write-json ("stream","ErrorStream",yes).
         finally:
            output stream ErrorStream close.
         end.
    end method.   
    
    method protected final char GetHTTPHeader(i as int):
        return "HTTP/1.1 " + string(i) + " " + GetHTTPError(i) + NewLine + NewLine.
    end method.     
    
    method protected character GetErrorMessage(e as Error):
        return GetErrorMessage(e,"").
    end method.
    
    method protected character GetErrorMessage(e as Error,cmsg as char):
        define variable i as integer no-undo.
        define variable c as character no-undo.
        define variable cBuf as character no-undo.
        define variable lstop as logical no-undo.
        define variable istart as integer no-undo.
        define variable cRet as character no-undo.
        
        if cmsg > "" then
           c = cmsg + chr(10).
        
        iStart = 1.    
        
        /* if there is a return value then use that instead of getmessage*/ 
        if type-of(e,AppError) then
        do:
            cRet = cast(e,AppError):ReturnValue.
            if cret > "" then
            do:
                c = cRet + chr(10).           
                iStart = 2.
            end.     
        end.
        
        
        do i = iStart to e:NumMessages:
            lstop = true.
            /* this is a skeleton on how to avoid error 32k  
               not tested */
            do on stop undo,leave:
                cBuf = c
                     + e:GetMessage(i)
                     + chr(10).
                lstop = false.   
            end.
            if not lstop then
                c = cbuf. 
            if i = MaxErrors then 
            do:
                c = c +  "and " + string(e:NumMessages - i) + " more messages..." .
                leave.   
            end.
        end.
   
        return right-trim(c,chr(10)). 
    end method.
   
    method protected character GetStack(e as Error,cstack as char):
        define variable c as character no-undo.
        if cStack <> "" then
          c = c + cStack + chr(10).
        c = c + e:CallStack.
        return right-trim(c,chr(10)). 
    end method.
    
    method private void FillStack(e as Error ):
       define variable i as integer no-undo.
       if e:Callstack > "" then
       do i = 1 to num-entries(e:Callstack,chr(10)):
           create ttStack.
           assign
               ttStack.Id = 1
               ttStack.LineNumber = i
               ttStack.Msg = entry(i,e:Callstack,chr(10)).
       end.    
    end method.
    
    /* create temp-tables for errors for export */  
    method private void FillError(e as Error ):
        define variable cMsg   as character no-undo.
        create ttError.
        ttError.Id = 1.
        
        if type-of(e,AppError) then       
        do:               
            cMsg = cast(e,AppError):ReturnValue.     
            if cMsg > "" then
                ttError.Msg = cMsg.
            else 
                ttError.Msg = e:GetMessage(1).           
        end.
        else
            ttError.Msg = e:GetMessage(1).
            
        ttError.Number = e:GetMessageNum(1).    
        
        do i = 2 to e:NumMessages:
            create ttChildError.
            assign
                ttChildError.ParentId = 1
                ttChildError.Id = i.
        
            if i = MaxErrors then 
            do:
                ttChildError.Msg = "and " + string(e:NumMessages - i + 1) + " more messages..." .
                leave.   
            end.
            ttChildError.Msg = e:GetMessage(i).
            ttChildError.Number = e:GetMessageNum(i).    
        end.
    end method.
    
    method protected final character GetHTTPError(i as int):
        case i:
            when 200 then return "OK".
            when 201 then return "CREATED".
            when 400 then return "BAD REQUEST".
            when 401 then return "UNAUTHORIZED".
            when 403 then return "FORBIDDEN".
            when 404 then return "NOT FOUND".
            when 405 then return "METHOD NOT ALLOWED".
            when 409 then return "CONFLICT".
            when 500 then return "INTERNAL ERROR".
            when 501 then return "NOT IMPLEMENTED".
            otherwise return "ERROR".
        end case.
    end method.
    
end class.
