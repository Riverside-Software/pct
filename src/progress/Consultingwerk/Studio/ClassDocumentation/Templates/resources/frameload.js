/*------------------------------------------------------------------------
    File        : frameload.js
    Purpose     : Implements javascript functionality for the
     			  Consultingwerk Ltd. class documentation.
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Mon Sep 10 17:53:07 CEST 2012
    Notes       : The javascript code check if the content page is not loaded in the frameset
        	      
  ----------------------------------------------------------------------*/
 
if (!top.FrameAvailable){
	
	var url = window.location.pathname;
	var filename = url.substring(url.lastIndexOf('/')+1);
    var path = url.substring(0, url.lastIndexOf('/'));
	
    top.location.href = path + "/index.html?" + filename;  
}  