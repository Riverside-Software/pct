 /*************************************************************/
 /* Copyright (c) 2011 by Progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Read the trail info of a .d 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Mar 29 16:39:15 EDT 2012
    Notes       : From prodict/dump/lodtrail.i
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Core.DataFileInfo: 
    define public property CodePage as char no-undo get. private set.
    define public property CodePageError as char no-undo 
        get():
            if  CodePage        <> "UNDEFINED" 
            and CodePage        <> ""          
            and session:charset <> ? then 
                return codepage-convert("a",session:charset,CodePage).
            else 
                return "no-convert".
        end. 
        
    define variable Numericformat as character no-undo.
    define variable TimeInfo as character no-undo.
    define public property TableName  as char no-undo   get. private set .
    define public property NumRecords as int64 no-undo init ? get. private set .
    define public property LogicalDatabaseName as char no-undo get. private set.
    define public property TimeStamp as datetime no-undo 
        init ?
        get():
            if TimeStamp = ? then    
               TimeStamp = datetime(int(substr(TimeInfo,6,2)),
                                    int(substr(TimeInfo,9,2)),
                                    int(substr(TimeInfo,1,4)),
                                    int(substr(TimeInfo,12,2)),
                                    int(substr(TimeInfo,15,2)),
                                    int(substr(TimeInfo,18,2))) no-error.   
             return TimeStamp.
        end. 
        private set.
    
    define public property DateFormat as char no-undo get. private set.
    define public property YearOffset as int  no-undo get. private set.
    define public property MapType    as char   no-undo get. private set.
    
    define public property NumericDecimalPoint as char  no-undo 
        init ?
        get():
            if NumericDecimalPoint = ? then
            do: 
                NumericDecimalPoint = "".
                extractNumericInfo(Numericformat).
            end.
            return NumericDecimalPoint.       
        end. 
        private set.
        
    define public property NumericSeparator as char  no-undo 
        init ?
        get():
            if NumericSeparator = ? then
            do: 
                NumericSeparator = "".
                extractNumericInfo(Numericformat).
            end.
            return NumericSeparator.       
        end. 
        private set.
    
    define public property NumericFormatError as log  no-undo  
        init ?
        get():
            if NumericFormatError = ? then
            do: 
                NumericFormatError = false.
                extractNumericInfo(Numericformat).
            end.
            return NumericFormatError.       
        end. 
        private set.
        
    define private property lvar as char extent 10 no-undo get. set .
    define stream readStream.
    
    constructor public DataFileInfo ( ):
		super ().
	    CodePage = session:stream.	
	end constructor.

    method public void ReadTrailer(pcFile as char):
        define variable tempi as decimal          no-undo.
        define variable j     as integer          no-undo.
        define variable iLoop as int  no-undo.
        define variable iSeek as int64 no-undo.
        assign
            Numericformat = ""
            TimeInfo = "" 
            TableName = ""
            DateFormat = ""
            YearOffset = ?
            NumRecords = ?
            NumericSeparator = ?
            NumericDecimalPoint = ?
            NumericFormatError = ?
            TimeStamp = ?
            MapType = ""
            lvar ="".
        
        input FROM VALUE(pcFile) NO-ECHO NO-MAP.
        seek input to end.
    
        iSeek = SEEK(INPUT) - 11.
        seek input to iSeek. /* position to possible beginning of last line */
    
        readkey pause 0.
    
         /* Now we need to deal with a large offset, which is a variable size
            value in the trailer, for large values.
            Now go back one character at a time until we find a new line or we have
            gone back too far.
            For the non-large offset format, the previous char will be a
            newline character, so we will  detect that right away and read the
            value as usual. Unless the file has CRLF (Windows), in which case
            we will go back 1 character to read the value properly - to
            account for the extra byte.
            For larger values, we will read as many digits as needed.
            The loop below could stop after 10 digits, but I am letting it go
            up to 50 to try to catch a bad value.
        */
        do while lastkey <> 13 and j <= 50:
            assign j = j + 1
                   iSeek = iSeek - 1.
            seek input to iSeek.
            readkey pause 0.
        end.
                       
        /* now we can start reading it */
        if lastkey eq 13 then
            readkey pause 0. 
    
        assign
            
            lvar  = ""
            iSeek = 0.
    
        do while lastkey <> 13 and iSeek <> ?: /* get byte count (last line) */
            if lastkey > 47 and lastkey < 58 then do:
                /* check if can fit the value into an int64 type. We need
                   to manipulate it with a decimal so that we don't get fooled
                   by a value that overflows. This is so that we catch a
                   bad offset in the file.
                 */
                 assign tempi = iSeek /* first move it to a decimal */
                        tempi = tempi * 10 + lastkey - 48. /* get new value */
                        iSeek = int64(tempi) no-error. /* see if it fits into an int64 */
              
                /* check if the value overflows becoming negative or an error happened. 
                   If so, something is wrong (too many digits or invalid values),
                   so forget this.
                 */
                 if  iSeek < 0 
                 or error-status:error or error-status:num-messages > 0 then 
                 do:
                     assign iSeek = 0.
                     leave. /* we are done with this */
                 end.
    
            end.
            else 
                assign iSeek = ?. /* bad character */
             
            readkey pause 0.
        end.
    
        if iSeek > 0 then GetPSC(iSeek). /* get it */
        else FindPSC(). /* look for it */
        input CLOSE.
        do iLoop = 1 to extent(lvar):
            if lvar[iLoop] begins "filename=" then 
                TableName     = substring(lvar[iLoop],10,-1,"character").
            else if lvar[iLoop] begins "timestamp=" then 
                TimeInfo      = substring(lvar[iLoop],11,-1,"character").
            else if lvar[iLoop] begins "records=" then 
                NumRecords     = int64(substring(lvar[iLoop],9,-1,"character")).
            else if lvar[iLoop] begins "ldbname=" then   
                LogicalDatabaseName = substring(lvar[iLoop],9,-1,"character").
            else if lvar[iLoop] begins "dateformat=" then
                assign
                    DateFormat = substring(lvar[iLoop],12,3,"character")
                    YearOffset = int(substring(lvar[iLoop],16,4,"character")).
            else if lvar[iLoop] begins "numformat=" then
                Numericformat = substring(lvar[iLoop],11,-1,"character").
            else if lvar[iLoop] begins "map=" then      
                MapType   = substring(lvar[iLoop],5,-1,"character").        
            else if lvar[iLoop] begins "cpstream=" or lvar[iLoop] begins "codepage=" then 
                CodePage = substring(lvar[iLoop],10).
        end. 
       
    end method.   
    
    method private void extractNumericInfo(numformat as char):
        define variable i as integer no-undo.
        if numformat <> "" then
        do:
            if length(numformat) = 1 then
            do:
                NumericDecimalPoint = numformat.
                NumericSeparator = if numformat = "." then "," else ".".
            end. /* Above deals with the old format, below handles the new */ 
            else
            do:  
                /* Test for existence of 2 numeric values, or at least something *
                 * translatable to numerics. */   
                assign i = integer(entry(1,numformat)) + INTEGER(entry(2,numformat))
                       NO-ERROR.
                if error-status:error then
                do: 
                    NumericFormatError = true.
                end.
                else if integer(entry(1,numformat)) + INTEGER(entry(2,numformat)) < 3 then
                do:  /* 0 is not allowed, and the characters must be different. */
                    NumericFormatError = true.
                end.
                else
                do:
                    NumericSeparator = chr(INT(entry(1,numformat)),session:cpinternal,CodePage). 
                    NumericDecimalPoint = chr(INT(entry(2,numformat)),session:cpinternal,CodePage).
                end. 
            end.
        end.
    end method.
    
    method private void GetPSC(piPos as int64):
        /* using the byte count, we scoot right down there and look for
         * the beginning of the trailer ("PSC"). If we don't find it, we
         * will go and look for it.
         */
        define variable rc as logical initial no no-undo.
        
        _psc:
        do on error undo,leave on endkey undo,leave:
            seek input to piPos. /* skip to beginning of "PSC" in file */
            readkey pause 0. 
            if lastkey <> ASC("P") then 
                leave _psc. /* not there!*/
            readkey pause 0. 
            if lastkey <> ASC("S") then 
                leave _psc.
            readkey pause 0. 
            if lastkey <> ASC("C") then 
                leave _psc.
            assign rc = yes. /* found it! */
            ReadBits(piPos). /* read trailer bits */
        end.
        
        if not rc then 
            FindPSC().  /* look for it */
    end method.
    
    method private void FindPSC():
        /* If the bytecount at the end of the file is wrong, we will jump
         * back the maximum number of bytes in a trailer and start looking
         * from there. If we still don't find it then tough luck.
         * NOTE: Variable p holds the number of bytes to roll back. AS of
         * 7/21/94, the max size of a trailer (.d) is 204 bytes, if you add
         * anything to this trailer, you must change this number to reflect
         * the number of bytes you added. I'll use 256 to add a little padding. (gfs)
         */
        define variable p as int64 initial 256. /* really 204, added extra just in case */
        define variable l as int64.             /* LAST char position */
          
        seek input to end.
        assign l = SEEK(INPUT). /* store off EOF */
        seek input to SEEK(INPUT) - MINIMUM(p,l). /* take p, or size of file */
        if SEEK(INPUT) = ? THEN RETURN.
        _scan:
        repeat on error undo,leave on endkey undo,leave:
            readkey pause 0.
            p = SEEK(INPUT). /* save off where we are looking */
            if lastkey = ASC("P") then do:
                readkey pause 0.
                if lastkey <> ASC("S") then next.
                else do: /* found "PS" */
                    readkey pause 0.
                    if lastkey <> ASC("C") then next.
                    else do: /* found "PSC"! */
                       ReadBits (p - 1).
                       leave.
                    end. /* IF "C" */
                 end. /* IF "S" */    
             end. /* IF "P" */
             else if p >= l then 
                 leave _scan. /* at EOF, so give up */
        end. /* repeat */
    end.
    
    /* reads trailer given a starting position */ 
    method private char extent ReadBits(pi as int64): 
        define variable i as integer no-undo.
        seek input to pi.
        repeat:                     
            i = i + 1.
            import lvar[i].
        end.
    end method.  
end class.

