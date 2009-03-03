/**
 * jqUploader (http://www.pixeline.be/experiments/jqUploader/)
 * A jQuery plugin to replace html-based file upload input fields with richer flash-based upload progress bar UI.
 *
 * Version 1.0.2.2
 * September 2007
 *
 * Copyright (c) 2007 Alexandre Plennevaux (http://www.pixeline.be)
 * Dual licensed under the MIT and GPL licenses.
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/gpl-license.php
 *
 * using plugin "Flash" by Luke Lutman (http://jquery.lukelutman.com/plugins/flash)
 *
 * IMPORTANT:
 * The packed version of jQuery breaks ActiveX control
 * activation in Internet Explorer. Use JSMin to minifiy
 * jQuery (see: http://jquery.lukelutman.com/plugins/flash#activex).
 *
 **/
 jQ121.fn.jqUploader = function(options) {
    return this.each(function(index) {
        var $this = jQ121(this);
		// fetch label value if any, otherwise set a default one
		var $thisForm =  $this.parents("form");
		var $thisInput = jQ121("input[@type='file']",$this);
		var $thisLabel = jQ121("label",$this);
		var containerId = $this.attr("id") || 'jqUploader-'+index;
		var startMessage = ($thisLabel.text() =='') ? 'Please select a file' : $thisLabel.text();
		// get form action attribute value as upload script, appending to it a variable telling the script that this is an upload only functionality
		var actionURL = $thisForm.attr("action");
		// adds a var setting jqUploader to 1, so you can use it for serverside processing
		var prepender = (actionURL.lastIndexOf("?") != -1) ? "&": "?";
		actionURL = actionURL+prepender+'jqUploader=1';
		// check if max file size is set in html form
		var maxFileSize = jQ121("input[@name='MAX_FILE_SIZE']", jQ121(this.form)).val();
		var opts = jQ121.extend({
				width:320,
				height:100,
				version: 8, // version 8+ of flash player required to run jqUploader
				background: 'E5E5E5', // background color of flash file
				src:    'jqUploader.swf',
				uploadScript:     actionURL,
				afterScript:      null, // if this is empty, jqUploader will replace the upload swf by a hidden input element
				varName:	        $thisInput.attr("name"),  //this holds the variable name of the file input field in your html form
				allowedExt:	      '*.jpg; *.jpeg; *.png', // allowed extensions
				allowedExtDescr:  'Images (*.jpg; *.jpeg; *.png)',
				params:           {menu:false},
				flashvars:        {},
				hideSubmit:       true,
				barColor:		      '0000CC',
				maxFileSize:      maxFileSize,
				startMessage:     startMessage,
				errorSizeMessage: 'File is too big!',
				validFileMessage: 'now click Upload to proceed',
				progressMessage: 'Please wait, uploading ',
				endMessage:    'You\'re all done'
		}, options || {}
		);
		// disable form submit button
		if (opts.hideSubmit==true) {
			jQ121("*[@type='submit']",this.form).hide();
		}
		// THIS WILL BE EXECUTED IN THE USECASE THAT THERE IS NO REDIRECTION TO BE DONE AFTER UPLOAD
		TerminateJQUploader = function(containerId,filename,varname){
			$this= jQ121('#'+containerId).empty();
			$this.text('').append('<input name="'+varname+'" type="hidden" id="'+varname+'" value="'+filename+'"/>');
			jQ121("*[@type='submit']",myForm).show();
			if (typeof opts.afterFunction == "function") {
				opts.afterFunction(containerId, filename, varname);
			} else {
				var myForm = $this.parents("form");
				myForm.submit(function(){return true});
			}
		}
		var myParams = '';
		for (var p in opts.params){
				myParams += p+'='+opts.params[p]+',';
		}
		myParams = myParams.substring(0, myParams.length-1);
		// this function interfaces with the jquery flash plugin
		jQ121(this).flash(
		{
			src: opts.src,
			width: opts.width,
			height: opts.height,
			id:'movie_player-'+index,
			bgcolor:'#'+opts.background,
			flashvars: {
				containerId: containerId,
				uploadScript: opts.uploadScript,
				afterScript: opts.afterScript,
				allowedExt: opts.allowedExt,
				allowedExtDescr: opts.allowedExtDescr,
				varName :  opts.varName,
				barColor : opts.barColor,
				maxFileSize :opts.maxFileSize,
				startMessage : opts.startMessage,
				errorSizeMessage : opts.errorSizeMessage,
				validFileMessage : opts.validFileMessage,
				progressMessage : opts.progressMessage,
				endMessage: opts.endMessage
			},
			params: myParams
		},
		{
			version: opts.version,
			update: false
		},
			function(htmlOptions){
				var $el = jQ121('<div id="'+containerId+'" class="flash-replaced"><div class="alt">'+this.innerHTML+'</div></div>');
					 $el.prepend(jQ121.fn.flash.transform(htmlOptions));
					 jQ121('div.alt',$el).remove();
					 jQ121(this).after($el).remove();
			}
		);
	});
};
