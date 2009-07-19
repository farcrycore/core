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
	      
	      while(typeof(parent) == 'object') {
	        if(parent) {
	          if(parent[0] && (parent[0].className.indexOf(settings.holder_class) >= 0)) {
	            parent.addClass(settings.focused_class);
	            return;
	          } // if
	        } // if
	        parent = $(parent.parent());
	      } // while
	    };
	    
	    // Select form fields and attach them higlighter functionality
	    form.find(settings.field_selector).focus(function() {
	      form.find('.' + settings.focused_class).removeClass(settings.focused_class);
	      focusControlHolder($(this));
	    }).blur(function() {
	      form.find('.' + settings.focused_class).removeClass(settings.focused_class);
	    });
	  });
	};
	
	// Auto set on page load...
	$(document).ready(function() {
	  $('form.uniForm').uniform();
	});


})(jQuery);