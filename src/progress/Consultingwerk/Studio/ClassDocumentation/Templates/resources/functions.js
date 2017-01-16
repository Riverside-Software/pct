/*------------------------------------------------------------------------
    File        : functions.js
    Purpose     : Implements javascript functionality for the
     			  Consultingwerk Ltd. class documentation.
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Mon Sep 10 17:53:07 CEST 2012
    Notes       : The javascript library creates all primary design features for the 
        	      Consultingwerk Ltd. class documentation. 
        	      The following javascript functionality is embedded here:
        	      - Create the navigation tree from a sourcetable 
        	      - Functionality for the navigation tree
        	      - Searchbar for the navigation tree
        	      - Summery images in the detail overview
        	      - Collapse / expand buttons in the detail view 
        	      The functions.js is referenced in the Templates/Document.template and 
        	      Templates/DocumentList.template files in the "HEAD" section.
  ----------------------------------------------------------------------*/
jQuery.expr[':'].Contains = function(a, i, m) { 
  return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase()) >= 0; 
};

(function($){
	/*------------------------------------------------------------------------------
		Purpose: Implements the Expand button hooks in the detail view 
		Notes:   
	------------------------------------------------------------------------------*/
 	$.fn.extend({
 	    expandButton:function(params){
 	        var conf = {};
		  $.extend(conf, params);
		  return $(this).each(function(){
		  								$(this).removeClass("expandButtonHidden");
		  								$(this).addClass("expandButtonShow");
		  								$(this).bind("click", function(){
		  									var btnID = "." + $(this).attr("id");
									      	if ($(this).hasClass("expandButtonHidden")){
										      	$(this).removeClass("expandButtonHidden")
										      		   .addClass("expandButtonShow");
										      		   $(btnID).show();
										      		   
										    }else{
										    	$(this).removeClass("expandButtonShow")
										      		   .addClass("expandButtonHidden");
										      		   $(btnID).hide();
										    }
									    });
                						
             					});
	    }
	});
 	
 	/*------------------------------------------------------------------------------
		Purpose: Implements the tree search text field
		Notes:   
	------------------------------------------------------------------------------*/
	$.fn.extend({
	 	    search:function(params){
	 	        var conf = {};
			  $.extend(conf, params);
			  return $(this).each(function(){
								$(this).bind("keyup", function(){
										  $("div").css('background-color','transparent');
									          if ($(this).val() != ""){
									          	$(".parent_node").hide();
									          	$(".child_node").hide();
									          	$("a:Contains('" + $(this).val() + "')").each(function(){
															$(this).parents("table").show()
															$($(this).parents("div")[0]).css('background-color','#CEE3F6');
														      });
									          }else{
									          	$(".parent_node").show();
									          	$(".child_node").hide();
									          	
									          }
								});
	                						
	             					});
		    }
	});
	
	/*------------------------------------------------------------------------------
		Purpose: Implements the tree search delete button 
		Notes:   
	------------------------------------------------------------------------------*/
	$.fn.extend({
	 	    searchClear:function(params){
		 	    var conf = {};
		 	    $.extend(conf, params);
			  	return $(this).each(function(){
			  		$(this).click(function(){
			  			$("#treesearch").val("");
			  			$("div").css('background-color','transparent');
				        if ($("#treesearch").val() != ""){
				        	$(".parent_node").hide();
				        	$(".child_node").hide();
				        	$("a:Contains('" + $("#treesearch").val() + "')").each(function(){
										$("#treesearch").parents("table").show()
										$($("#treesearch").parents("div")[0]).css('background-color','#CEE3F6');
									      });
				        }else{
				        	$(".tree_link_visit").remove("tree_link_visit");
				        	$(".show").removeClass("show").addClass("hide");
				        	$(".parent_node").show();
				        	$(".child_node").hide();
				        	
				        }
			  			
			  		});
			  	});  
			}  
	});

	/*------------------------------------------------------------------------------
		Purpose: Build a child tree node and bind the click event handler 
		Notes:   
	------------------------------------------------------------------------------*/
	$.fn.extend({
 	    treeNode:function(params){
 	        var conf = {};
		  $.extend(conf, params);
		  return $(this).each(function(){
		  							$(this).addClass("hide");
		  							$(this).removeClass("show");
		  							$(this).find(".child_node").hide();
		  							$(this).find("a").unbind("click");	
                					$(this).find("a").bind("click", function(){
                						 
                						 $(".tree_link_visit").css("color", "")
                						 $(".tree_link_visit").css("font-weight", "normal")
                						 $(".tree_link_visit").removeClass("tree_link_visit")
                						 $(this).addClass("tree_link_visit")
                						 $(this).css("color", "#E66A38");
                						 $(this).css("font-weight", "bold");
                						 
                						 var targetShow = ""

                						 targetShow = ".parent" + $(this).attr("Name");

                						 if ($($(this).parents("table")[0]).hasClass("show")){
                							$(targetShow).hide();
            						 		$($(this).parents("table")[0]).removeClass("show");
            						 		$($(this).parents("table")[0]).addClass("hide");
                						 }else{
                						 	$(targetShow).show();
            						 		$($(this).parents("table")[0]).removeClass("hide");
            						 		$($(this).parents("table")[0]).addClass("show");		
                						 }
                					});	
             					});
	    }
	});
	
	/*------------------------------------------------------------------------------
		Purpose: Create the summary images container in the detail overview 
		Notes:   
	------------------------------------------------------------------------------*/
	$.fn.extend({
 	    imgsetter:function(params){
 	      var conf = {};
		  $.extend(conf, params);
		  return $(this).each(function(){
			  $(".method_summary .table_content").each (function(){
				  if ($(this).find("td:first").hasClass ("STATIC")){
					  $(this).find("td:first").append("<div class='method_img_static'></div>");
				  }else{
					  $(this).find("td:first").append("<div class='method_img'></div>");
				  }
			  });
			  
			  $(".property_summary .table_content").each (function(){
				  if ($(this).find("td:first").hasClass ("STATIC")){
					  $(this).find("td:first").append("<div class='property_img_static'></div>");
				  }else{
					  $(this).find("td:first").append("<div class='property_img'></div>");
				  }
			  });
			  
			  $(".event_summary .table_content").each (function(){
				  if ($(this).find("td:first").hasClass ("STATIC")){
					  $(this).find("td:first").append("<div class='event_img_static'></div>");
				  }else{
					  $(this).find("td:first").append("<div class='event_img'></div>");
				  }
			  });
			  
			  $(".constructor_summary .table_content").each (function(){
				  if ($(this).find("td:first").hasClass ("STATIC")){
					  $(this).find("td:first").append("<div class='method_img_static'></div>");
				  }else{
					  $(this).find("td:first").append("<div class='method_img'></div>");
				  }
			  });
	    });
	  }
	});
})(jQuery);


/*------------------------------------------------------------------------------
	Purpose: Bind javascript functionality  to the HTML Objects 
	Notes:   
------------------------------------------------------------------------------*/
function onLoad(){
	$("BODY").imgsetter();
	$(".expand_arrow").expandButton();
	$("#treesearch").search();
	$(".parent_node").treeNode();
	$(".child_node").treeNode();
	$("#treesearchclear").searchClear();
};
