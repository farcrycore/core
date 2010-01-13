(function($) {

	$.fn.uniform = function(settings) {
	  settings = $.extend({
	    valid_class    : 'valid',
	    invalid_class  : 'invalid',
	    focused_class  : 'focused',
	    holder_class   : 'ctrlHolder',
	    field_selector : 'input, select, textarea'
	  }, settings);
	  
	  return this.each(function() {
	    var form = $(this);
	    
	    // Focus specific control holder
	    var focusControlHolder = function(element) {
	      var parent = element.parent();
	      
	      while(typeof(parent) == 'object' && parent && parent[0] && parent[0].className) {
	        if(parent[0].className.indexOf(settings.holder_class) >= 0) {
				parent.addClass(settings.focused_class);
				return;
	        } // if
	        parent = $(parent.parent());
	      } // while
	    };
		
		form.find(settings.field_selector).each(function() {
			if ( $(this).hasClass("focus") ){
				$(this).focus();
				focusControlHolder($(this));
			}
		});
		
	    // Select form fields and attach them higlighter functionality
	    form.find(settings.field_selector).focus(function() {
	      form.find('.' + settings.focused_class).removeClass(settings.focused_class);
	      focusControlHolder($(this));
	    });
		
		
		form.find(settings.field_selector).blur(function() {
	      form.find('.' + settings.focused_class).removeClass(settings.focused_class);
	    });
	  });
	};
	

})(jQuery);