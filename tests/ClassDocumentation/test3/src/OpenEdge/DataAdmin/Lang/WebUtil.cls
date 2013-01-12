/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : WebUtil
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : from webspeed
    Created     : Wed Jul 14 22:48:06 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

class OpenEdge.DataAdmin.Lang.WebUtil: 
     
    /* Unsafe characters that must be encoded in URL's.  See RFC 1738 Sect 2.2. */
    define private variable url_unsafe   as character no-undo 
        initial " <>~"#%~{}|~\^~~[]`":U.
    
    /* Reserved characters that normally are not encoded in URL's */ 
    define private variable url_reserved as character no-undo 
        initial "~;/?:@=&":U.
    
    /****************************************************************************
    Description: Encodes unsafe characters in a URL as per RFC 1738 section 2.2.
      <URL:http://ds.internic.net/rfc/rfc1738.txt>, 2.2
    Input Parameters: Character string to encode, Encoding option where "query",
      "cookie", "default" or any specified string of characters are valid.
      In addition, all characters specified in the global variable url_unsafe
      plus ASCII values 0 <= x <= 31 and 127 <= x <= 255 are considered unsafe.
    Returns: Encoded string  (unkown value is returned as blank)
    Global Variables: url_unsafe, url_reserved
    ****************************************************************************/
    method public character UrlEncode (pValue as character) :
        return this-object:UrlEncode(pValue,"default").
    end method.
        
    method public character UrlEncode (pValue as character,pEnctype as character) :
        define variable hx          as character no-undo initial "0123456789ABCDEF":U.
        define variable encode-list as character no-undo.
        define variable i           as integer   no-undo.
        define variable c           as integer   no-undo.
     
        /* Don't bother with blank or unknown  */
        if length(pValue) = 0 or pValue = ? then 
            return "".
       
        /* What kind of encoding should be used? */
        case pEnctype:
            when "query":U then              /* QUERY_STRING name=value parts */
                encode-list = url_unsafe + url_reserved + "+":U.
            when "cookie":U then             /* Persistent Cookies */
                encode-list = url_unsafe + " ,~;":U.
            when "default":U or when "" then /* Standard URL encoding */
                encode-list = url_unsafe.
            otherwise
                encode-list = url_unsafe + pEnctype.   /* user specified ... */
        end case.
    
        /* Loop through entire input string */
        assign i = 0.
        do while true:
           assign
               i = i + 1
               /* ASCII value of character using single byte codepage */
               c = asc(substring(pValue, i, 1, "RAW":U), "1252":U, "1252":U).
           if c <= 31 or c >= 127 or index(encode-list, chr(c)) > 0 then 
           do:
               /* Replace character with %hh hexidecimal triplet */
               substring(pValue, i, 1, "RAW":U) =  "%":U 
               + substring(hx, integer(truncate(c / 16, 0)) + 1, 1, "RAW":U)   /* high */
               + substring(hx, c modulo 16 + 1, 1, "RAW":U).             /* low digit */
              assign i = i + 2.   /* skip over hex triplet just inserted */
           end.
           if i = LENGTH(pValue,"RAW":U) then 
               leave.
      end.
    
      return pValue.
    end method.  /* UrlEncode */
    
    method public character UrlDecode (pValue as character) :
        define variable i      as integer   no-undo.
        define variable cParse as character no-undo.
        cParse = pValue.
        do while true:
            i = index(cParse,"%").
            if i > 1 then  
            do:
               /* use two strings since %25 is % i.e.  % is still there after decode  */
               substr(pValue,i,3) = string(hex-decode(substr(pValue,i + 1,2))).
               substr(cParse,i,3) = "X".
            end.
            if i = 0 then 
               leave.
        end.   
        return pValue.
    end method.
 
end class.