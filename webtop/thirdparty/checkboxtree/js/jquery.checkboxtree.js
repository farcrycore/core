(function(jQuery) {
	jQuery.fn.checkboxTree = function(settings) {

		settings = jQuery.extend({
			collapsedarrow: "img-arrow-collapsed.gif",
			expandedarrow: "img-arrow-expanded.gif",
			blankarrow: "img-arrow-blank.gif",
			activeClass: "checkboxtreeactive",
			hoverClass: "over",
			checkchildren: false,
			checkparents: true,
			collapsed: true,
			hidecbwithjs:false,
			checkedClass: "checked"
		}, settings);

		var $group = this;
		var $labels = jQuery(":checkbox + label",$group)
		var $checkboxes = jQuery(":checkbox",$group)

		//set up the tree
		jQuery("li",$group).each(function(){

			var $this = jQuery(this)
			var $collapseImage;

			if(settings.checkparents){
				var checkedchildren = jQuery("ul li input:checked",$this).length
				var $firstcheckbox = $this.children("input:checkbox:first")
				
				if((!$this.children("input:checkbox:first").is(":checked")) && (checkedchildren>0)){
					$firstcheckbox.attr("checked","checked")
				}
			}

			if($this.is(":has(ul)")){
				if($this.find("ul").attr("ft:expanded") == 'expanded') {
					$collapseImage = jQuery('<img class="checkboxtreeimage" src="' + settings.expandedarrow + '" / >')
					$collapseImage.data("collapsedstate",1)
				} else {
					$this.find("ul").hide();
					$collapseImage = jQuery('<img class="checkboxtreeimage" src="' + settings.collapsedarrow + '" / >')
					$collapseImage.data("collapsedstate",0)
				}
				
				//if(settings.collapsed){
				//	$this.find("ul").hide();
				//	$collapseImage = jQuery('<img class="checkboxtreeimage" src="' + settings.collapsedarrow + '" / >')
				//	$collapseImage.data("collapsedstate",0)
				//}else{
				//	$collapseImage = jQuery('<img class="checkboxtreeimage" src="' + settings.expandedarrow + '" / >')
				//	$collapseImage.data("collapsedstate",1)
				//}
			}else{
				$collapseImage = jQuery('<img src="' + settings.blankarrow + '" / >')
			}
			$this.prepend($collapseImage);
			
		})

		//add class signifying the tree has been setup
		$group.addClass(settings.activeClass);

		$group.bind("click.checkboxtree",function(e,a){
			var $clicked = jQuery(e.target)
			var $clickedcheck = $clicked.prev()
			var $currrow = $clicked.parents("li:first")
			var $clickedparent = $currrow.parents("li:first").find(":checkbox:first");
			var $clickedparentlabel = $clickedparent.next("label");
			var clickedlabel = false;
			var clickedimage = false;
			if($clicked.is(":checkbox + label")){
				clickedlabel=true;
			}
			if($clicked.is("img.checkboxtreeimage")){
				clickedimage=true;
			}
			//when the label is clicked, set the checkbox to the opposite clicked state, and toggle the checked class
			if(clickedlabel){
				$clicked.prev().attr({checked: !$clickedcheck.attr("checked")}).end().toggleClass(settings.checkedClass);
				//check parents if that option is set
				if(settings.checkparents){
					var checkedchildren = jQuery("input:checked",$currrow).length
					
					if((!$clickedparent.is(":checked")) && (checkedchildren>0)){
						$clickedparentlabel.trigger("click.checkboxtree",["checkparents"])
					}
				}
				//check child checkboxes if settings say so
				if(settings.checkchildren&&a!=="checkparents"){
					$currrow.find(":checkbox + label").prev().attr({checked: $clickedcheck.attr("checked")?"checked":""})
					.next()
					.addClass($clicked.hasClass(settings.checkedClass)?settings.checkedClass:"")
					.removeClass($clicked.hasClass(settings.checkedClass)?"":settings.checkedClass)
				}
			}
			//handle expanding of levels
			if(clickedimage){
				var clickstate=$clicked.data("collapsedstate")
				if(clickstate===0){
					$currrow.children("ul").show();
					$currrow.children("img").attr("src",settings.expandedarrow);
					$clicked.data("collapsedstate",1)
				}else if(clickstate===1){
					$currrow.children("ul").hide();
					$currrow.children("img").attr("src",settings.collapsedarrow);
					$clicked.data("collapsedstate",0)
				}
			}
		})
		
		//set the class correctly for the labels that contain checked checkboxes
		jQuery("input:checked + label",$group).addClass(settings.checkedClass)

		//add hover class for labels if is ie 6
		if(jQuery.browser.msie&&jQuery.browser.version<7){
			$labels.hover( 
				function(){jQuery(this).addClass(settings.hoverClass)},
				function(){jQuery(this).removeClass(settings.hoverClass); }
			)
		}		

		//hide the checkboxes with js if set option set to true
		if(settings.hidecbwithjs){
			$checkboxes.hide();
		}

/*
		jQuery("li",$group).each(function(){
			var $currentLi = jQuery(this);
			if($currentLi.is(":has(ul)")){
//				//check the parent boxes if a child is selected
//				if((!$currentLi.children("input:checkbox:first").is(":checked")) && (jQuery("ul li input:checked",$currentLi).length>0)){
//					$currentLi.find("label:first").trigger("click");
//				}
this done				$currentLi.children("ul").hide();
//				var $collapseImage = jQuery('<img src="' + settings.collapsedarrow + '" / >')
//				$collapseImage.toggle(function(){
//					$currentLi.children("ul").show();
//					$currentLi.children("img").attr("src",settings.expandedarrow);
//				},function(){
//					$currentLi.children("ul").hide();
//					$currentLi.children("img").attr("src",settings.collapsedarrow);
//				})
				jQuery("ul li input:checkbox",$currentLi).next().click(function(){
					if((!$currentLi.children("input:checkbox:first").is(":checked")) && (jQuery("ul li input:checked",$currentLi).length>0)){
						$currentLi.find("label:first").addClass("checked").prev().attr("checked","checked")
					}
				});
				jQuery("input:checkbox",$currentLi).next().click(function(){
					if(jQuery("ul li input:checked",jQuery(this).parent("li")).length>0){
						jQuery(this).addClass("checked").prev().attr("checked","checked");
					}
				});
				$currentLi.prepend($collapseImage);
			}else{
				var $collapseImage = jQuery('<img src="' + settings.blankarrow + '" / >')
				$currentLi.prepend($collapseImage);
			}
		})
*/
		
		return $group;
	};
})(jQuery);

