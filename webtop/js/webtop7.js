/* Favouriting */
// toggle favourite on this page
$j(document).delegate(".favourited","click",function(){
	var self = $j(this);
	
	if (self.is(".active"))
		$fc.removeFavourite(self.data("remove"),self.data("this"));
	else
		$fc.addFavourite(self.data("add"),self.data("this"),$j("h1").first().text());
	
	return false;
});

$j(document).delegate(".undo-delete","click",function(){
	var href = this.href + (this.href.indexOf("?")>-1 ? "&" : "?") + "view=webtopPageModal";
	
	$fc.objectAdminAction('Undelete', href);
	
	return false;
});

$fc = window.$fc || {}

// add this page to favourites
$fc.addFavourite = function(api,url,label){
	$j.getJSON(api+(api.indexOf("?")>-1?"&":"?")+"favURL="+encodeURIComponent(url)+"&favLabel="+encodeURIComponent(label),function(result){
		if (result.success){
			$j(".favourites-menu li:nth-child("+result.position+")").before("<li><a href='"+url+"'>"+label+"</a></li>");
			$j(".favourites-menu li.none").hide();
			$j(".favourited").addClass("active");
			$j(".favourited i").removeClass("fa-star-o").addClass("fa-star");
		}
	});
};

// remove this page from favourites
$fc.removeFavourite = function(api,url){
	$j.getJSON(api+(api.indexOf("?")>-1?"&":"?")+"favURL="+encodeURIComponent(url),function(result){
		if (result.success){
			$j(".favourites-menu li:nth-child("+result.position+")").remove();
			if ($j(".favourites-menu > li").size()===1){
				$j(".favourites-menu li.none").show();
			}
			$j(".favourited").removeClass("active");
			$j(".favourited i").removeClass("fa-star").addClass("fa-star-o");
		}
	});
};