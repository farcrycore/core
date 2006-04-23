/******************************************************************************
 qForm JSAPI: WDDX Mod Library

 Author: Dan G. Switzer, II
 Build:  101
******************************************************************************/

/******************************************************************************
 Required Functions
******************************************************************************/
function __serializeStruct(struct){
	// open packet
	var aWDDX = new Array("<wddxPacket version='1.0'><header/><data><struct>");
	for( var key in struct ) aWDDX[aWDDX.length] = "<var name='" + key.toLowerCase() + "'><string>" + __wddxValue(struct[key]) + "</string></var>";
	// close packet
	aWDDX[aWDDX.length] = "</struct></data></wddxPacket>";
	return aWDDX.join("");
}


function __wddxValue(str){
	var aValue = new Array();
	for( var i=0; i < str.length; ++i) aValue[aValue.length] = _encoding.table[str.charAt(i)];
	return aValue.join("");
}

function _wddx_Encoding(){
	// Encoding table for strings (CDATA)
	var et = new Array();

	// numbers to characters table
	var n2c = new Array();

	for( var i=0; i < 256; ++i ){
		// build a character from octal code
		var d1 = Math.floor(i/64);
		var d2 = Math.floor((i%64)/8);
		var d3 = i%8;
 		var c = eval("\"\\" + d1.toString(10) + d2.toString(10) + d3.toString(10) + "\"");

		// modify character-code conversion tables
		n2c[i] = c;

		// modify encoding table
		if( i < 32 && i != 9 && i != 10 && i != 13 ){
			// control characters that are not tabs, newlines, and carriage returns

			// create a two-character hex code representation
			var hex = i.toString(16);
			if( hex.length == 1 ) hex = "0" + hex;

			et[n2c[i]] = "<char code='" + hex + "'/>";

		} else if( i < 128 ){
			// low characters that are not special control characters
			et[n2c[i]] = n2c[i];
		} else {
			// high characters
			et[n2c[i]] = "&#x" + i.toString(16) + ";";
		}
	}

	// special escapes for CDATA encoding
	et["<"] = "&lt;";
	et[">"] = "&gt;";
	et["&"] = "&amp;";
	
	this.table = et;
}
_encoding = new _wddx_Encoding();


/******************************************************************************
 qForm Methods
******************************************************************************/
function _a_serialize(exclude){
	// if you need to reset the default values of the fields
	var lstExclude = (arguments.length > 0) ? "," + _removeSpaces(arguments[0]) + "," : "";
	struct = new Object();
	stcAllFields = qFormAPI.getFields();
	// loop through form elements
	for( key in stcAllFields ){
		if( lstExclude.indexOf("," + key + ",") == -1 ) struct[key] = stcAllFields[key]; 
	}
	// create & return the serialized object
	return __serializeStruct(struct);
}
_a.prototype.serialize = _a_serialize;

// define qForm serialize(); prototype
function _q_serialize(exclude){
	// if you need to reset the default values of the fields
	var lstExclude = (arguments.length > 0) ? "," + _removeSpaces(arguments[0]) + "," : "";
	struct = new Object();
	// loop through form elements
	for( var j=0; j < this._fields.length; j++ ){
		if( lstExclude.indexOf("," + this._fields[j] + ",") == -1 ) struct[this._fields[j]] = this[this._fields[j]].getValue(); 
	}
	// create & return the serialized object
	return __serializeStruct(struct);
}
qForm.prototype.serialize = _q_serialize;
