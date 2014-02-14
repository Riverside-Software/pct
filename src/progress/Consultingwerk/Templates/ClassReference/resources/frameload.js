/* *********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 ********************************************************************* */
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
	
    top.location.href = "index.html?" + filename; 
}  