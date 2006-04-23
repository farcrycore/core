/******************************************************************************
 qForm JSAPI: Cookie Library

 Author: Dan G. Switzer, II
 Build:  105
******************************************************************************/
// initialize workspace variables
var _c_dToday = new Date();
var _c_iExpiresIn = 90;
var _c_strName = self.location.pathname;

/******************************************************************************
 Required Functions
******************************************************************************/
// retrieve a cookie from the browser
function _getCookie(name){
	var iStart = document.cookie.indexOf(name + "=");
	var iLength = iStart + name.length + 1;
	if( (iStart == -1) || (!iStart && (name == document.cookie.substring(0)) ) ) return null;
	var iEnd = document.cookie.indexOf(";", iLength);
	if( iEnd == -1 ) iEnd = document.cookie.length;
	return unescape(document.cookie.substring(iLength, iEnd));
}

// set a cookie to the browser
function _setCookie(name, value, expires, path, domain, secure){
	document.cookie = name + "=" + escape(value) + 
	( (expires) ? ";expires=" + expires.toGMTString() : "") +
	( (path) ? ";path=" + path : "") + 
	( (domain) ? ";domain=" + domain : "") +
	( (secure) ? ";secure" : "");
}

function _deleteCookie(name, path, domain){
	if (Get_Cookie(name)) document.cookie = name + "=" +
		( (path) ? ";path=" + path : "") +
		( (domain) ? ";domain=" + domain : "") +
 		";expires=Thu, 01-Jan-1970 00:00:01 GMT";
}

function _createCookiePackage(struct){
	var cookie = "";
	for( key in struct ){
		if( cookie.length > 0 ) cookie += "&";
		cookie += key + ":" + escape(struct[key]); 
	}
	return cookie;
}

function _readCookiePackage(pkg){
	struct = new Object();
	// break the package into key/value pairs
	var a = pkg.split("&");
	// loop through the array and seperate the key/value pairs
	for( var i=0; i < a.length; i++ ) a[i] = a[i].split(":");
	// convert the values into a structure
	for( var i=0; i < a.length; i++ ) struct[a[i][0]] = unescape(a[i][1]);
	// return the structure
	return struct;
}

/******************************************************************************
 qForm Methods
******************************************************************************/
// define qForm loadFields(); prototype
function _qForm_loadFields(){
	var strPackage = _getCookie("qForm_" + this._name + "_" + _c_strName);
	// there is no form saved
	if( strPackage == null ) return false;

	this.setFields(_readCookiePackage(strPackage), null, true);
}
qForm.prototype.loadFields = _qForm_loadFields;

// define qForm saveFields(); prototype
function _qForm_saveFields(){
	var expires = new Date(_c_dToday.getTime() + (_c_iExpiresIn * 86400000));
	var strPackage = _createCookiePackage(this.getFields());
	_setCookie("qForm_" + this._name + "_" + _c_strName, strPackage, expires);
}
qForm.prototype.saveFields = _qForm_saveFields;

// define qForm saveOnSubmit(); prototype
function _qForm_saveOnSubmit(){
	// grab the current onSubmit() method and append the saveFields() method to it
	var fn = _functionToString(this.onSubmit, "this.saveFields();");
	this.onSubmit = new Function(fn);
}
qForm.prototype.saveOnSubmit = _qForm_saveOnSubmit;
