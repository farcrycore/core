$j(document).ready(function(){
	$j('textarea.autoresize').autoResize({
	    // On resize:
	    onResize : function() {
	        $j(this).css({opacity:0.8});
	    },
	    
	    // After resize:
	    animateCallback : function() {
	        $j(this).css({opacity:1});
	    },
	    
	    // Quite slow animation:
	    animateDuration :300,
	    
	    // More extra space:
	    extraSpace : 10,
	    
	    // Max Height	
	    limit : 300
	});
	
	$j('textarea.autoresize').trigger('keyup');
});
		