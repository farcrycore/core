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
		  $j(element).parents("." + settings.holder_class).addClass(settings.focused_class);
		 
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