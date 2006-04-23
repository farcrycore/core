/******************************************************************************
 qForm JSAPI: Bits Extensions Library

 Author: Dan G. Switzer, II
 Build:  101
******************************************************************************/
// define Field getBits(); prototype
function _Field_getBits(useValue){
	var isCheckbox = (this.type == "checkbox") ? true : false;
	var isSelect = (this.type == "select-multiple") ? true : false;

	if( !isCheckbox && !isSelect && (this.obj.length > 0) ) return alert("This method is only available to checkboxes or select boxes with multiple options.");
	var useValue = _param(arguments[0], false, "boolean");

	var iBit = 0;
	// loop through all checkbox elements, and if a checkbox is checked, grab the value
	for( var i=0; i < this.obj.length; i++ ){
		// if the option is checked, then add the 2 ^ i to the existing value
		if( isCheckbox && this.obj[i].checked ){
			// append the selected value
			iBit += (useValue) ? parseInt(this.obj[i].value) : Math.pow(2, i);
		} else if( isSelect && this.obj.options[i].selected ){
			iBit += (useValue) ? parseInt(this.obj[i].value) : Math.pow(2, i);
		}
	}
	return iBit;
}
Field.prototype.getBits = _Field_getBits;

// define Field setBits(); prototype
function _Field_setBits(value, useValue){
	var isCheckbox = (this.type == "checkbox") ? true : false;
	var isSelect = (this.type == "select-multiple") ? true : false;

	if( !isCheckbox && !isSelect && (this.obj.length > 0) ) return alert("This method is only available to checkboxes or select boxes with multiple options.");
	var value = _param(arguments[0], "0");
	var useValue = _param(arguments[1], false, "boolean");

	var value = parseInt(value);
	// loop through all checkbox elements, and if a checkbox is checked, grab the value
	for( var i=0; i < this.obj.length; i++ ){
		// if the bitand returns the same as the value being checked, then the current 
		// checkbox should be checked
		var j = (useValue) ? parseInt(this.obj[i].value) : Math.pow(2, i);
		var result = ( (value & j) ==  j) ? true : false;
		if( isCheckbox ) this.obj[i].checked = result;
		else if( isSelect ) this.obj.options[i].selected = result;
	}
	// if the value provided is greater then the last bit value, return false to indicate an error
	// otherwise return true to say everything is ok
	return (value < Math.pow(2, i)) ? true : false;
}
Field.prototype.setBits = _Field_setBits;

