$j(function(){

	function switchDeviceType(deviceType) {
		setDeviceTypeCookie(deviceType);
		window.location = window.location;
	}

	function setDeviceTypeCookie(deviceType) {
		// set device type cookie to expire 30 days form now
		var date = new Date();
		date.setTime(date.getTime()+(30*24*60*60*1000));
		document.cookie = "FARCRYDEVICETYPE=" + deviceType + "; expires=" + date.toGMTString() + "; path=/;";
	}

	$j(".fc-switch-device-desktop").live("click", function(){
		switchDeviceType("desktop");
	});
	$j(".fc-switch-device-mobile").live("click", function(){
		switchDeviceType("mobile");
	});
	$j(".fc-switch-device-tablet").live("click", function(){
		switchDeviceType("tablet");
	});
	
});