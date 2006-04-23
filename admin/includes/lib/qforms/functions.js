/******************************************************************************
 qForm JSAPI: Functions Library

 Author: Dan G. Switzer, II
 Build:  108
******************************************************************************/
function _trim(s){ return _rtrim(_ltrim(s)); }

function _ltrim(s){
	var w = " \n\t\f";
	// remove all beginning white space
	while( w.indexOf(s.charAt(0)) != -1 && s.length != 0 ) s = s.substring(1);
	return s;
}

function _rtrim(s){
	var w = " \n\t\f";
	// remove all ending white space
	while( w.indexOf(s.charAt(s.length-1)) != -1 && s.length != 0 ) s = s.substring(0, s.length-1);
	return s;
}

function _listToArray(string,delim){
	var delim = _param(arguments[1], ",");
	tmp = string.split(delim);
	for( var i=0; i < tmp.length; i++ ) tmp[i] = _trim(tmp[i]);
	return tmp;
}

function _listSum(string,delim){
	var delim = _param(arguments[1], ",");
	tmp = _listToArray(string,delim);
	iValue = 0;
	for( var i=0; i < tmp.length; i++ ) iValue += parseInt(tmp[i], 10);
	return iValue;
}

function _stripInvalidChars(string, type){
	var string = _param(arguments[0]);
	var type = _param(arguments[1], "numeric").toLowerCase();
	var validchars = type;

	stcTypes = new Object();
	stcTypes.numeric = "1234567890";
	stcTypes.alpha = "abcdefghijklmnopqrstuvwxyz";
	stcTypes.alphnumeric = "abcdefghijklmnopqrstuvwxyz1234567890";

	if( stcTypes[type] ) validchars = stcTypes[type];

	var tmp = "";
	var lc = string.toLowerCase();
	// loop through the string an make sure each character is an alpha character
	for( var i=0;i < string.length;i++ ){
		if (validchars.indexOf(lc.charAt(i)) != -1) tmp += string.charAt(i);
  }
	return tmp;
}

function _isLength(string, len, type){
	var string = _param(arguments[0]);
	var len = parseInt(_param(arguments[1], 10, "number"), 10);
	var type = _param(arguments[2], "numeric");

	var tmp = _stripInvalidChars(string, type);
	return (tmp.length == len) ? true : false;
}

function _getState(abbr){
	var abbr = _param(arguments[0]).toLowerCase();
	_s = new Object(); _s.al = "Alabama"; _s.ak = "Alaska"; _s.as = "American Samoa"; _s.az = "Arizona"; _s.ar = "Arkansas"; _s.ca = "California"; _s.co = "Colorado"; _s.ct = "Connecticut"; _s.de = "Delaware"; _s.dc = "District of Columbia"; _s.fm = "Federal States of Micronesia"; _s.fl = "Florida"; _s.ga = "Georgia"; _s.gu = "Guam"; _s.hi = "Hawaii"; _s.id = "Idaho"; _s.il = "Illinois"; _s["in"] = "Indiana"; _s.ia = "Iowa"; _s.ks = "Kansas"; _s.ky = "Kentucky"; _s.la = "Louisana"; _s.me = "Maine"; _s.mh = "Marshall Islands"; _s.md = "Maryland"; _s.ma = "Massachusetts"; _s.mi = "Michigan"; _s.mn = "Minnesota"; _s.ms = "Mississippi"; _s.mo = "Missouri"; _s.mt = "Montana"; _s.ne = "Nebraska"; _s.nv = "Nevada"; _s.nh = "New Hampshire"; _s.nj = "New Jersey"; _s.nm = "New Mexico"; _s.ny = "New York"; _s.nc = "North Carolina"; _s.nd = "North Dakota"; _s.mp = "Northern Mariana Islands"; _s.oh = "Ohio"; _s.ok = "Oklahoma"; _s.or = "Oregon"; _s.pw = "Palau"; _s.pa = "Pennsylvania"; _s.pr = "Puerto Rico"; _s.ri = "Rhode Island"; _s.sc = "South Carolina"; _s.sd = "South Dakota"; _s.tn = "Tennessee"; _s.tx = "Texas"; _s.ut = "Utah"; _s.vt = "Vermont"; _s.vi = "Virgin Islands"; _s.va = "Virginia"; _s.wa = "Washington"; _s.wv = "West Virginia"; _s.wi = "Wisconsin"; _s.wy = "Wyoming"; _s.aa = "Armed Forces Americas"; _s.ae = "Armed Forces Africa/Europe/Middle East"; _s.ap = "Armed Forces Pacific";
	if( !_s[abbr] ){
		return null;
	} else {
		return _s[abbr];
	}
}

// define the default properties for the sort
qFormAPI.sortOptions = new Object();
qFormAPI.sortOptions.order = "asc";
qFormAPI.sortOptions.byText = true;
function _sortOptions(obj, order, byText){
	var order = _param(arguments[1], qFormAPI.sortOptions.order);
	if( order != "asc" && order != "desc" ) order = "asc";
	var byText = _param(arguments[2], qFormAPI.sortOptions.byText, "boolean");
	var orderAsc = (order == "asc") ? true : false;

	// loop through all the options and sort them asc
	for( var i=0; i < obj.options.length; i++ ){
		for( var j=0; j < obj.options.length-1; j++ ){
			// if an option is greater than the next option, swap them
			if( orderAsc && (byText && obj.options[j].text > obj.options[j+1].text) || (!byText && obj.options[j].value > obj.options[j+1].value) ){
				tmpTxt = obj.options[j].text;
				tmpVal = obj.options[j].value;
				tmpSel = obj.options[j].selected;
				obj.options[j].text = obj.options[j+1].text ;
				obj.options[j].value = obj.options[j+1].value;
				obj.options[j].selected = obj.options[j+1].selected;
				obj.options[j+1].text = tmpTxt ;
				obj.options[j+1].value = tmpVal;
				obj.options[j+1].selected = tmpSel;
			} else if( !orderAsc && (byText && obj.options[j].text < obj.options[j+1].text) || (!byText && obj.options[j].value < obj.options[j+1].value) ){
				tmpTxt = obj.options[j].text;
				tmpVal = obj.options[j].value;
				tmpSel = obj.options[j].selected;
				obj.options[j].text = obj.options[j+1].text ;
				obj.options[j].value = obj.options[j+1].value;
				obj.options[j].selected = obj.options[j+1].selected;
				obj.options[j+1].text = tmpTxt ;
				obj.options[j+1].value = tmpVal;
				obj.options[j+1].selected = tmpSel;
			}
		}
	}
	return true;
}

function _transferOptions(field1, field2, sort, type, selectItems, reset){
	var sort = _param(arguments[2], true, "boolean");
	var type = _param(arguments[3].toLowerCase(), "selected");
	if( type != "all" && type != "selected" ) type = "selected";
	var selectItems = _param(arguments[4], true, "boolean");
	var reset = _param(arguments[5], false, "boolean");
	var doAll = (type == "all") ? true : false;

	if( field1.type.substring(0,6) != "select" ) return alert("This method is only available to select boxes. \nThe field \"" + field1.name + "\" is not a select box.");
	if( field2.type.substring(0,6) != "select" ) return alert("This method is only available to select boxes. \nThe field \"" + field2.name + "\" is not a select box.");

	// clear the select box
	if( reset ) field2.length = 0;

	for( var i=0; i < field1.length; i++ ){
		// if the current option is selected, move it
		if( doAll || field1.options[i].selected ){
			field2.options[field2.length] = new Option(field1.options[i].text, field1.options[i].value, false, selectItems);
			field1.options[i] = null;
			i--; // since you just deleted a option, redo this array position next loop
		}
	}

	// if sorting the fields
	if( sort ) _sortOptions(field2);
	return true;
}


function _getURLParams(){
	struct = new Object();
	var strURL = document.location.href;
	var iPOS = strURL.indexOf("?");
	// if there are some query string params, split them into an array
	if( iPOS != -1 ){
		var strQS = strURL.substring(iPOS + 1);
		var aryQS = strQS.split("&");

	// otherwise, return the empty structure
	} else {
	 return struct;
	}

	// loop through the array
	for( var i=0; i < aryQS.length; i++ ){
		iPOS = aryQS[i].indexOf("=");
		// if no equal sign is found, then the value is null
		if( iPOS == -1 ){
			struct[aryQS[i]] = null;
		// otherwise grab the variable name and it's value and stick it in structure
		} else {
			var key = aryQS[i].substring(0, iPOS);
			var value = unescape(aryQS[i].substring(iPOS+1));
			// if the value doesn't exist, then create a new key
			if( !struct[key] ) struct[key] = value;
			// otherwise, append the value
			else struct[key] += "," + value;
		}
	}

 return struct;
}

function _createFields(struct, type){
	var type = _param(arguments[1], "hidden");
	if( this.status == null ) return false;
	// loop through form elements
	for( key in struct ){
		document.write("<INPUT TYPE=\"" + type + "\" NAME=\"" + key + "\" VALUE=\"" + struct[key] + "\">");
	}
	return true;
}

function _getEventType(type){
	// the default event type
	var strEvent = "onblur";
	// if this is a checkbox & radio button, then mirror value on click
	if( type == "checkbox" || type == "radio" ) strEvent = "onclick";
	// if this is a select box, then mirror value when the value changes
	else if( type.substring(0,6) == "select" ) strEvent = "onchange";
	return strEvent;
}

