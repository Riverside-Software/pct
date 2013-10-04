/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : FileUtil
    Purpose     : check 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Mar 31 17:50:38 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Core.FileUtil: 

    method public logical isRelativePath(pcPath as char):
        if pcPath = ? then
            undo, throw new IllegalArgumentError("Unknown value psssed to IsRelativePath()").
        return not (pcPath begins "/" or pcPath begins "~\" or index(pcPath,":") <> 0).
    end method.
    
    /** check of the directory exists - does NOT search propath for relative paths */  
    method public logical IsValidDirectory (pDirectory as char):
        if pDirectory <> "" then 
        do:
            if IsRelativePath(pDirectory) then
                pDirectory = "./" + pDirectory.          
            assign file-info:file-name = pDirectory. 
            return substring(file-info:file-type,1,1) = "D".
        end.
        return true.
    end method.  /* ValidDirectory */
    
    method public int CreateDirectoryIf ( pDirectory as char):
        define variable iStat as integer no-undo.
        if not IsValidDirectory(pDirectory) then
        do:
            os-create-dir value(pDirectory). 
            iStat = os-error. 
            if iStat <> 0 then
                 undo, throw new AppError("Cannot create directory " + pDirectory + ". System error:" + string(iStat),?).
        end.
        return 0.
    end method. /* CreateDirectoryIf */
    
    method public character GetValidDirectory(pcPath as char, pcchild as char):
        pcPath = GetValidDirectory(pcPath).
        return GetValidDirectory(pcPath + pcchild).
    end method.
    
    method public character GetValidDirectory(pcPath as char,pcChild as char,plMustExist as log):
        pcPath = GetValidDirectory(pcPath).
        return GetValidDirectory(pcPath + pcchild,plMustExist).  
    end method.
    
    method public character GetValidDirectory(pcPath as char):
        define variable cSlash as character no-undo init "/".
        if index(pcPath,"~\") > 0 then 
            cSlash = "~\".
        if pcPath = "" then pcPath = ".".
        pcPath = right-trim(pcPath,cSlash) + cSlash. 
        return pcPath.
    end method.
    
    method public character GetValidDirectory(pcPath as char,plMustExist as log):
        pcPath = GetValidDirectory(pcPath).
        if plMustExist and pcPath <> "." and not IsValidDirectory(pcPath) then 
        do:
            undo, throw new AppError("Directory " + pcPath + " does not exist",?).
        end.
        return pcPath.
    end method.
    
    method public char GetPath( pFullName as char):
        define variable cBase as character no-undo.
        define variable cPath as character no-undo.
        run prodict/misc/osprefix.p(pFullName,output cPath,output cBase).
        return cPath.
    end method.  
    
    method public char GetFileName( pFullName as char):
        define variable cBase as character no-undo.
        define variable cPath as character no-undo.
        run prodict/misc/osprefix.p(pFullName,output cPath,output cBase).
        return cBase.
    end method.  
    
    
 end class.