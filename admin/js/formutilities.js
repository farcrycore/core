function fShowHide(elementid,bShow){
	var elem = document.getElementById(elementid);
	if(bShow)
		elem.style.display = "inline";
	else
		elem.style.display = "none";
}