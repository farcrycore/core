(function($){
	$.fn.aqFloater = function($o) {
		var _opts = $.extend({
			offsetX: 0, offsetY: 0, attach: '', duration: 50, opacity: '.9'
		}, $o);

		var $obj = this;
		$obj.css({ position: 'absolute', opacity: _opts.opacity });

		var _show = function() {
			var _de = document.documentElement;

			var _y = (_opts.attach.match(/n/) ? 0 
				: (_opts.attach.match(/s/) 
					? (_de.clientHeight - $obj.outerHeight()-10)
					: Math.round((_de.clientHeight-$obj.height())/2)));

			var _x = (_opts.attach.match(/w/) ? 0
				: (_opts.attach.match(/e/)
					? (_de.clientWidth - $obj.outerWidth()-10)
					: Math.round((_de.clientWidth-$obj.width())/2)));

			$obj.animate({
				top:  (_y + $(document).scrollTop() + _opts.offsetY) + 'px',
				left: (_x + $(document).scrollLeft() + _opts.offsetX) + 'px'
			},{queue:false, duration:_opts.duration});
		};

		$(window).scroll(_show).resize(_show);

		$(window).trigger('scroll');
	};
})(jQuery);