function toggletree(parentnode) {
		Effect.toggle($(parentnode + '_wrap_content'),'slide', {duration:.3});

 		if (Element.visible($(parentnode + '_wrap_content')) == true) {
			$(parentnode + '_icon').src = '/farcry/images/treeimages/' + $(parentnode + '_icon').getAttribute('closedIcon') ;
		} else{
			$(parentnode + '_icon').src = '/farcry/images/treeimages/' + $(parentnode + '_icon').getAttribute('openIcon') ;
		}

	}
	
	function inittree(treeid) {
		
		var i = 0;			
		var treelistitems = $$("#" + treeid + " table")
		treelistitems.each(function(treelistitem) {	
			i++;
			
			var treelistitemiconlist = document.getElementsByClassName("nodeicon", $(treelistitem));
			var treelistitemicons = $A(treelistitemiconlist);
			treelistitemicons.each(function(treelistitemicon){
				
				Event.observe(treelistitemicon, 'click', function(event) {
					//alert(treelistitem.id + '_content');
					//var contentid = treelistitem.id + '_content';"
					toggletree(treelistitem.id); 
				});
			});
	
		 
	
		});	

	}
	
	function trimAll(sString) {
		while (sString.substring(0,1) == ' ') {
			sString = sString.substring(1, sString.length);
		}
		while (sString.substring(sString.length-1, sString.length) == ' ') {
			sString = sString.substring(0,sString.length-1);
		}
		return sString;
	}