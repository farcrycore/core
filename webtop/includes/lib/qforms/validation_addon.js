/******************************************************************************
 qForm JSAPI: Add-on Validation Library

 Author: Dan G. Switzer, II
 Build:  100
******************************************************************************/
qFormAPI.packages.validation = true;

// [start] validation routine
function _f_isAtLeastOne(_f){
	var sFields = this.name + ((typeof _f == "string") ? "," + _removeSpaces(_f) : "");
	var aFields = sFields.split(","), v = new Array(), d = new Array(), x = ",";

	for( var i=0; i < aFields.length; i++ ){
		if( !this.qForm[aFields[i]] ) return alert("The field name \"" + aFields[i] + "\" does not exist.");
		// store the value in an array
		v[v.length] = this.qForm[aFields[i]].getValue();
		// if the field name is already in the list, don't add it
		if( x.indexOf("," + aFields[i] + ",") == -1 ){
			d[d.length] = this.qForm[aFields[i]].description;
			x += aFields[i] + ",";
		}
	}

	// if all of the form fields has empty lengths, then throw
	// an error message to the page
	if( v.join("").length == 0 ){
		this.error = "At least one of the following fields is required:\n   " + d.join(", ");
		for( i=0; i < aFields.length; i++ ){
			if( qFormAPI.useErrorColorCoding && this.qForm[aFields[i]].obj.style ) this.qForm[aFields[i]].obj.style[qFormAPI.styleAttribute] = qFormAPI.errorColor;
		}
	}
}
_addValidator("isAtLeastOne", _f_isAtLeastOne, true);
