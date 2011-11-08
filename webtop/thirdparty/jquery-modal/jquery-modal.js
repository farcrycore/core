// minimalist modal window
(function(fc,$){
	fc.openModal = function startOverlay(html,width,height,backgroundclose,addchrome) {
		var newContent = $(html);
		width = width || 425;
		height = height || 355;
		
		if (addchrome){
			html = '<div style="border: 1px solid #c8c8c8\9;background-color:#FFFFFF;padding:15px;-webkit-box-shadow: 0 0 8px rgba(128,128,128,0.75);-moz-box-shadow: 0 0 8px rgba(128,128,128,0.75);box-shadow: 0 0 8px rgba(128,128,128,0.75);">' + html + '</div>';
		}
		
		//add the elements to the dom
		$("body")
			.append('<div class="fc-overlay" style="height:'+$(document).height()+'px;'+(backgroundclose>0?'cursor:pointer;':'')+'"></div>')
			.append('<div class="fc-overlaycontainer"></div>')
			.css({"overflow-y":"hidden"});
		
		//animate the semitransparant layer
		var overlay = $(".fc-overlay").animate({"opacity":"0.6"}, 400, "linear");
		if (backgroundclose>0) overlay.bind("click",function(){ fc.closeModal(); });
		
		//add the lightbox image to the DOM
		$(".fc-overlaycontainer")
			.html(html)
			.css({
				"top":        $(document).scrollTop()+$(window).height()/2,
				"left":       "50%",				
				"width":      width,
				"height":     height
			})
			.css({
				"margin-top": -($(".fc-overlaycontainer").height()/2),
				"margin-left": -($(".fc-overlaycontainer").width()/2) //to position it in the middle
			})
			.animate({"opacity":"1"}, 400, "linear")
			.find(".closeModal").bind("click",function(){ fc.closeModal();return false; });
		fc.Container = $(".fc-overlaycontainer");
	};
	
	fc.closeModal = function removeOverlay() {
		// allow users to be able to close the lightbox
		$(".fc-overlaycontainer, .fc-overlay").animate({"opacity":"0"}, 200, "linear", function(){
			$(".fc-overlaycontainer, .fc-overlay").remove();
			$("body").css({"overflow-y":""});
		});
	};
	
	fc.updateModal = function(html){
		$(".fc-overlaycontainer").html(html);
	};
})($fc,jQuery);