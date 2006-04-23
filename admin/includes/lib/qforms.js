/******************************************************************************
 qForm JavaScript API

 Author: Dan G. Switzer, II
 Date:   December 10, 2000
 Build:  138

 Description:
 This library provides a API to forms on your page. This simplifies retrieval
 of field values by providing methods to retrieve the values from fields,
 without having to do complicate coding.

 To contribute money to further the development of the qForms API, see:
 http://www.pengoworks.com/qForms/donations/

 GNU License
 ---------------------------------------------------------------------------
 This library provides common methods for interacting with HTML forms
 Copyright (C) 2001  Dan G. Switzer, II

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for mser details.
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
******************************************************************************/
// find out which version of JavaScript the user has
var _jsver = 11;
for( var z=2; z < 6; z++ ) document.write("<scr"+"ipt language=\"JavaScript1." + z + "\">_jsver = 1" + z + ";</scr"+"ipt>");

/******************************************************************************
 qForm API Initialization
******************************************************************************/
// define _a object
function _a(){
	// qForm's Version info
	this.version = "138";

	// initialize the number of qForm instances
	this.instances = 0;
	// initialize an object to use for pointers
	this.objects = new Object();
	// the path where the external library components are found
	this.librarypath = "";
	// specifies whether the browser should autodetect the version of JavaScript being used
	this.autodetect = true;
	// this specifies the default modules to load when the wildcard ("*") is specified
	this.modules = new Array("field", "functions|12", "validation");
	// this is the name of the modules that have been loaded, libraries will not be loaded more then once
	this.packages = new Object();
	// this is a list of validators that has loaded
	this.validators = new Array();
	// this contains a list of the original contents of a container, when the setValue() method is used on a container, then the containers object is checked to see if the key exists
	this.containers = new Object();
	// this structure defines the version of JavaScript being used
	this.jsver = new Object();
	for( var z=1; z < 9; z++ ) this.jsver["1" + z] = "1." + z;

	// this is background color style to use when a form field validation error has occurred
	this.errorColor = "red";
	// the style attribute to adjust when throwing an error
	this.styleAttribute = "backgroundColor";
	// this specifies whether or not to use error color coding (by default browser that support it use it)
	this.useErrorColorCoding = (document.all || document.getElementById) ? true : false;
	// this specifies whether all qForm objects should be validated upon a form submission, or just the form being submitted. By default only the form being submitted is validated.
	this.validateAll = false;
	// this specifies whether or not a form can be submitted if validation errors occurred. If set to false, the user gets an alert box, if set to true, the user receives a confirm box.
	this.allowSubmitOnError = false;
	// the place holder for the number of custom validators that have been initialized
	this.customValidators = 0;
	// specify whether the reset method should be run when the form object is initialized
	this.resetOnInit = false;
	// determine whether to show status bar messages
	this.showStatusMsgs = true;

	// set the regular expression attributes
	this.reAttribs = "gi";
	return true;
}
qFormAPI = new _a();

// define _a setLibraryPath(); prototype
function _a_setLibraryPath(path){
	if( path.substring(path.length-1) != '/' ) path += '/';
	this.librarypath = path;
	return true;
}
_a.prototype.setLibraryPath = _a_setLibraryPath;

// define _a include(); prototype
function _a_include(src, path, ver){
	var source = src;
	if( !source ) return true;
	if( !path ) var path = this.librarypath + "qforms/";
	if( !ver ) var ver = "";

	if( source.substring(source.length-3) != ".js" ) source += ".js";
	var thisPackage = source.substring(0,source.length-3);

	var strJS = "<scr"+"ipt language=\"JavaScript";
	var strEJS = "\"></scr"+"ipt>";

	// if the package is already loaded, then kill method
	if( this.packages[thisPackage] ) return true;

	if( thisPackage == "*" ){
		for( var i=0; i < this.modules.length; i++ ){
			var source = this.modules[i];
			var ver = "99";
			if( source.indexOf("|") > -1 ){
				ver = source.substring(source.indexOf("|") + 1);
				source = source.substring(0, source.indexOf("|"));
			}
			if( _jsver > ver && this.autodetect ){
				document.write(strJS + this.jsver[ver] + "\" src=\"" + path + source + "_js" + ver + ".js" + strEJS);
			} else {
				document.write(strJS + "\" src=\"" + path + source + ".js" + strEJS);
			}
			this.packages[source] = true;
		}
	} else {
		if( !this.autodetect || _jsver < 12 || ver.length == 0 ){
			document.write(strJS + "\" src=\"" + path + source + strEJS);
		} else if( this.autodetect && (parseInt(_jsver, 10) >= parseInt(ver, 10)) ){
			source = source.substring(0,source.length-3) + "_js" + ver + source.substring(source.length-3);
			document.write(strJS + this.jsver[ver] + "\" src=\"" + path + source + strEJS);
		} else {
			document.write(strJS + "\" src=\"" + path + source + strEJS);
		}
	}

	this.packages[thisPackage] = true;
	return true;
}
_a.prototype.include = _a_include;

function _a_unload(){
	var isFramed = false;
	// loop through all the forms and reset the status of the form to idle
	for( obj in qFormAPI.objects ){
		qFormAPI.objects[obj]._status = "idle";
		if( !!qFormAPI.objects[obj]._frame ) isFramed = true;
	}
	// some psuedo garbage collection to destroy some of the pointers if in a framed environment
	if( isFramed ){
		// kill the objects if using frames
		this.objects = new Object();
		// kill the containers if using frames
		this.containers = new Object();
	}
	return true;
}
_a.prototype.unload = _a_unload;

// define _a validate(); prototype
function _a_validate(qForm){
	// if just validate a single form, then validate now and exit
	if( !this.validateAll ) return qFormAPI.objects[qForm].validate();

	var aryErrors = new Array();

	// loop through all the forms
	for( obj in qFormAPI.objects ){
		// check the form for errors
		qFormAPI.objects[obj].checkForErrors();
		// add the errors from this form t adde queue
		for( var i=0; i < qFormAPI.objects[obj]._queue.errors.length; i++ ){
			aryErrors[aryErrors.length] = qFormAPI.objects[obj]._queue.errors[i];
		}
	}

	// if there are no errors then return true
	if( aryErrors.length == 0 ) return true;

	var strError = "The following error(s) occurred:\n";
	for( var i=0; i < aryErrors.length; i++ ) strError += " - " + aryErrors[i] + "\n";

	var result = false;
	// check to see if the user is allowed to submit the form even if an error occurred
	if( this._allowSubmitOnError && this._showAlerts ) result = confirm(strError + "\nAre you sure you want to continue?");
	// if the form can be submitted with errors and errors should not be alerted set a hidden field equal to the errors
	else if( this._allowSubmitOnError && !this._showAlerts ) result = true;
	// otherwise, just display the error
	else alert(strError);

	return result;
}
_a.prototype.validate = _a_validate;

function _a_reset(hardReset){
	// loop through all the forms and reset the properties
	for( obj in qFormAPI.objects ) qFormAPI.objects[obj].reset(hardReset);
	return true;
}
_a.prototype.reset = _a_reset;

// define _a getFields(); prototype
function _a_getFields(){
	stcAllData = new Object();

	// loop through all the forms
	for( obj in qFormAPI.objects ){
		// check the form for errors
		var tmpStruct = qFormAPI.objects[obj].getFields();
		// add the value from this form to the structure
		for( field in tmpStruct ){
			if( !stcAllData[field] ){
				stcAllData[field] = tmpStruct[field];
			} else {
				stcAllData[field] += "," + tmpStruct[field];
			}
		}
	}

	// return all the form data
	return stcAllData;
}
_a.prototype.getFields = _a_getFields;

// define _a setFields(); prototype
function _a_setFields(struct, rd, ra){
	// loop through each form and populate the fields
	for( obj in qFormAPI.objects ) qFormAPI.objects[obj].setFields(struct, rd, ra);
}
_a.prototype.setFields = _a_setFields;

// define _a dump(); prototype
function _a_dump(){
	var str = "";
	formData = this.getFields();
	for( field in formData ) str += field + " = " + formData[field] + "\n";
	alert(str);
}
_a.prototype.dump = _a_dump;


/******************************************************************************
 qForm Object
******************************************************************************/
// define qForm object
function qForm(name, parent, frame){
	if( name == null ) return true;
	if( !name ) return alert("No form specified.");
	// increase the instance counter
	qFormAPI.instances++;
	// make sure the unload event is called
	if( qFormAPI.instances ==  1 ) window.onunload = new Function(_functionToString(window.onunload, ";qFormAPI.unload();"));
	this._name = name;
	this._parent = (!!parent) ? parent : null;
	this._frame = (!!frame) ? frame : null;
	this._status = null;
	this._queue = new Object();
	this._queue.errorFields = ",";
	this._queue.errors = new Array();
	this._queue.validation = new Array();
	this._showAlerts = true;
	this._allowSubmitOnError = qFormAPI.allowSubmitOnError;
	this._locked = false;
	this._skipValidation = false;
	qFormAPI.objects[this._name] = this;
	// this is a string pointer to the qFormAPI object copy of this object
	this._pointer = "qFormAPI.objects['" + this._name + "']";
	this.init();
	return true;
}
// initialize dummy qForm object so that NS will initialize the prototype object
new qForm(null, null, null);

// define qForm init(); prototype
function _q_init(){
	if( !this._name ) return false;

	// if this is NS4 and the form is in a layer
	if( this._parent && document.layers ) this._form = this._parent + ".document." + this._name;
	// otherwise point to the form
	else this._form = "document." + this._name;

	// if the form is in a frame, then add path to the frame
	if( this._frame ) this._form = this._frame + "." + this._form;

	// create a pointer to the form object
	this.obj = eval(this._form);

	// if the object doesn't exist, thrown an error
	if( !this.obj ) return alert("The form \"" + this._name + "\" does not exist. This error \nwill occur if the Form object was initialized before the form \nhas been created or if it simply doesn't exist. Please make \nsure to initialize the Form object after page loads to avoid \npotential problems.");

	// set the onSubmit method equal to whatever the current onSubmit is
	// this function is then run whenever the submitCheck determines it's ok to submit the form
	this.onSubmit = new Function(_functionToString(this.obj.onsubmit, ""));
	// replace the form's onSubmit event and just run the submitCheck() method
	var strSubmitCheck = this._pointer + ".submitCheck();";
	if( this._frame )	strSubmitCheck = "top." + strSubmitCheck;
	this.obj.onsubmit = new Function("return " + strSubmitCheck);

	// loop through form elements
	this._fields = new Array();
	this._pointers = new Object();
	for( var j=0; j < this.obj.elements.length; j++ ) this.addField(this.obj.elements[j].name);
	this._status = "initialized";

	// reset the form
	if( qFormAPI.resetOnInit ) this.reset();

	return true;
}
qForm.prototype.init = _q_init;

// define qForm addField prototype
function _q_addField(field){
	if( typeof field == "undefined" || field.length == 0 ) return false;
	o = this.obj[field];
	if( typeof o == "undefined" ) return false;
	// if the field is an array
	if( typeof o.type == "undefined" ) o = o[0];
	if( (!!o.type) && (typeof this[field] == "undefined") && (field.length > 0) ){
		this[field] = new Field(o, field, this._name);
		this._fields[this._fields.length] = field;
		this._pointers[field.toLowerCase()] = this[field];
	}
	return true;
}
qForm.prototype.addField = _q_addField;

// define qForm removeField prototype
function _q_removeField(field){
	// this function requires a JS1.2 browser

	// currently, events attached to a form field are not
	// deleted. this means you'll need to manually remove
	// the field from the DOM, or errors will occur
	if( typeof this[field] == "undefined" ) return false;

	var f = this._fields;
	// find the field in the fields array and remove it
	for( var i=0; i < f.length; i++ ){
		if( f[i] == field ){
			var fp = i;
			break;
		}
	}

	if( _jsver >= 12 ){
		delete this[field];
		f.splice(fp,1);
		delete this._pointers[field.toLowerCase()];

		var q = this._queue.validation;
		// loop through validation queue, and remove references of
		for( var j=0; j < q.length; j++ ){
			if( q[j][0] == field ){
				q.splice(j,1);
				j--;
			}
		}
	}
	return true;
}
qForm.prototype.removeField = _q_removeField;


// define qForm submitCheck prototype
function _q_submitCheck(){
	// make sure the form is submitted more then once
	if( this._status == "submitting" || this._status == "validating" ) return false;
	this._status = "submitting";

	// validate the form
	var result = qFormAPI.validate(this._name);
	// if no errors occurred, run the onSubmit() method
	if( result ){
		// run the custom onSubmit method
		var x = this.onSubmit();
		// if a boolean value was passed back, then update the result value
		if( typeof x == "boolean" ) result = x;
	}

	// if the form shouldn't be submitted, then reset the form's status
	if( !result ){
		// if any validation errors occur or the form is not to be submitted because the
		// onSubmit() event return false, then set the reset the form's status
		this._status = "idle";
	// run any processing that should be done before submitting the form
	} else {
		// make sure to select all "container" objects so the values are included when submitted
		_setContainerValues(this);
	}
	return result;
}
qForm.prototype.submitCheck = _q_submitCheck;

// define qForm onSubmit(); prototype
qForm.prototype.onSubmit = new Function("");


// define qForm addMethod(); prototype
function _q_addMethod(name, fn, type){
	if( arguments.length < 2 ) return alert("To create a new method, you must specify \nboth a name and function to run: \n  obj.addMethod(\"checkTime\", _isTime);");
	var type = _param(arguments[2], "from").toLowerCase();

	// set the object to attach the prototype method to
	if( type == "field" ) type = "Field";
	else type = "qForm";

 // if adding a predefined function, then add it now
	if( typeof fn == "function" ){
		strFN = fn.toString();
		strFN = strFN.substring(strFN.indexOf(" "), strFN.indexOf("("));
		eval(type + ".prototype." + name + " = " + strFN);

 // if creating a new function, then add it now
	} else {
		var fnTemp = new Function(fn);
		eval(type + ".prototype." + name + " = fnTemp;");
	}
	return true;
}
qForm.prototype.addMethod = _q_addMethod;

// define qForm addEvent(); prototype
function _q_addEvent(event, cmd, append){
	if( arguments.length < 2 ) return alert("Invalid arguments. Please use the format \naddEvent(event, command, [append]).");
	var append = _param(arguments[2], true, "boolean");
	_addEvent(this._pointer + ".obj", arguments[0], arguments[1], append);
	return true;
}
qForm.prototype.addEvent = _q_addEvent;

// define qForm required(); prototype
function _q_required(fields, value){
	var value = _param(arguments[1], true, "boolean");
	aryField = _removeSpaces(fields).split(",");

	for( var i=0; i < aryField.length; i++ ){
		if( !this[aryField[i]] ) return alert("The form field \"" + aryField[i] + "\" does not exist.");
		this[aryField[i]].required = value;
	}
	return true;
}
qForm.prototype.required = _q_required;

// define qForm optional(); prototype
function _q_optional(fields){
	// turn the fields off
	this.required(fields, false);
	return true;
}
qForm.prototype.optional = _q_optional;


// define qForm forceValidation(); prototype
function _q_forceValidation(fields, value){
	var value = _param(arguments[1], true, "boolean");
	aryField = _removeSpaces(fields).split(",");

	for( var i=0; i < aryField.length; i++ ){
		if( !this[aryField[i]] ) return alert("The form field \"" + aryField[i] + "\" does not exist.");
		this[aryField[i]].validate = value;
	}
	return true;
}
qForm.prototype.forceValidation = _q_forceValidation;


// define qForm submit(); prototype
function _q_submit(){
	var x = false;
	// do not submit the form more then once
	if( this._status == "submitting" ) return false;
	if( this.obj.onsubmit() )	x = this.obj.submit();
	return (typeof x == "undefined") ? true : x;
}
qForm.prototype.submit = _q_submit;

// define qForm disabled(); prototype
function _q_disabled(status){
	var objExists = (typeof this.obj.disabled == "boolean") ? true : false;
	if( arguments.length == 0 ) var status = (this.obj.disabled) ? false : true;
	// if the "disabled" var doesn't exist, then use the build in "locked" feature
	if( !objExists ) this._locked = status;
	// switch the status of the disabled property
	else this.obj.disabled = status;
	return true;
}
qForm.prototype.disabled = _q_disabled;

// define qForm reset(); prototype
function _q_reset(hardReset){
	if( this._status == null ) return false;
	// loop through form elements
	for( var j=0; j < this._fields.length; j++ ){
		// reset the value for this field
		this[this._fields[j]].setValue(((!!hardReset) ? null : this[this._fields[j]].defaultValue), true, false);
		// enforce any depencies of the current field
		if( this[this._fields[j]]._queue.dependencies.length > 0 ) this[this._fields[j]].enforceDependency();
	}
	return true;
}
qForm.prototype.reset = _q_reset;

// define qForm getFields(); prototype
function _q_getFields(){
	if( this._status == null ) return false;
	struct = new Object();
	// loop through form elements
	for( var j=0; j < this._fields.length; j++ ) struct[this._fields[j]] = this[this._fields[j]].getValue();
	return struct;
}
qForm.prototype.getFields = _q_getFields;

// define qForm setFields(); prototype
function _q_setFields(struct, rd, ra){
	if( this._status == null ) return false;
	// if you need to reset the default values of the fields
	var resetDefault = _param(arguments[1], false, "boolean");
	var resetAll = _param(arguments[2], true, "boolean");
	// reset the form
	if( resetAll ) this.reset();
	// loop through form elements
	for( key in struct ){
		var obj = this._pointers[key.toLowerCase()];
		if( obj ){
			obj.setValue(struct[key], true, false);
			if(resetDefault) obj.defaultValue = struct[key];
		}
	}
	return true;
}
qForm.prototype.setFields = _q_setFields;

// define qForm hasChanged(); prototype
function _q_hasChanged(){
	if( this._status == null ) return false;
	var b = false;
	// loop through form elements
	for( var j=0; j < this._fields.length; j++ ){
		if( this[this._fields[j]].getValue() != this[this._fields[j]].defaultValue ){
			b = true;
			break;
		}
	}
	return b;
}
qForm.prototype.hasChanged = _q_hasChanged;

// define qForm changedFields(); prototype
function _q_changedFields(){
	if( this._status == null ) return false;
	struct = new Object();
	// loop through form elements
	for( var j=0; j < this._fields.length; j++ ){
		if( this[this._fields[j]].getValue() != this[this._fields[j]].defaultValue ){
			struct[this._fields[j]] = this[this._fields[j]].getValue();
		}
	}
	return struct;
}
qForm.prototype.changedFields = _q_changedFields;

// define qForm dump(); prototype
function _q_dump(){
	var str = "";
	var f = this.getFields();
	for( fld in f ) str += fld + " = " + f[fld] + "\n";
	alert(str);
}
qForm.prototype.dump = _q_dump;

/******************************************************************************
 Field Object
******************************************************************************/
// define Field object
function Field(form, field, formName, init){
	if( arguments.length > 3 ) return true;
	this._queue = new Object();
	this._queue.dependencies = new Array();
	this._queue.validation = new Array();
	this.qForm = qFormAPI.objects[formName];
	this.name = field;
	this.path = this.qForm._form + "['" + field + "']";
	this.pointer = this.qForm._pointer + "['" + field + "']";
	this.obj = eval(this.path);
	this.locked = false;
	this.description = field.toLowerCase();
	this.required = false;
	this.validate = false;
	this.container = false;
	this.type = (!this.obj.type && !!this.obj[0]) ? this.obj[0].type : this.obj.type;
	this.validatorAttached = false;

	var value = this.getValue();
	this.defaultValue = value;
	this.lastValue = value;

	// initialize the field object
	this.init();

	return true;
}
new Field(null, null, null, true);

// define Field init(); prototype
function _f_init(){
	if( qFormAPI.useErrorColorCoding && this.obj.style ) this.styleValue = (!!this.obj.style[qFormAPI.styleAttribute]) ? this.obj.style[qFormAPI.styleAttribute].toLowerCase() : "";

	if( document.layers && (this.type == "radio" || this.type == "checkbox") && !!this.obj[0] ){
		this.addEvent("onclick", "return " + this.pointer + ".allowFocus();");
	} else {
		this.addEvent("onfocus", "return " + this.pointer + ".allowFocus();");
	}
}
Field.prototype.init = _f_init;

// define Field allowFocus(); prototype
function _f_allowFocus(){
	// if the background color equals the error color, then reset the style to the original background
	if( qFormAPI.useErrorColorCoding && this.obj.style ){
		if( this.qForm._queue.errorFields.indexOf(","+this.name+",") > -1 ) this.obj.style[qFormAPI.styleAttribute] = this.styleValue;
	}
	// store the current value in the lastValue property
	this.lastValue = this.getValue();
	// check to see if the field is locked
	var result = this.checkIfLocked();

	// if the field is locked, and we have a select box, we need to reset the value of the field
	// and call the onblur method to remove focus
	if( (this.type.indexOf("select") > -1) && !result ){
		this.resetLast();
		this.blur();
	}

	// if the field isn't locked, run the onFocus event
	if( !result ) this.onFocus();
	// return the result of the checkIfLocked() method
	return result;
}
Field.prototype.allowFocus = _f_allowFocus;

// define qForm onFocus(); prototype
Field.prototype.onFocus = new Function("");

// define Field addEvent(); prototype
function _f_addEvent(event, cmd, append){
	if( arguments.length < 2 ) return alert("Invalid arguments. Please use the format \naddEvent(event, command, [append]).");
	var append = _param(arguments[2], true, "boolean");

	// if the field is a multi-array element, then apply the event to all items in the array
	if( (this.type == "radio" || this.type == "checkbox") && !!this.obj[0] ){
		for( var i=0; i < this.obj.length; i++ ) _addEvent(this.path + "[" + i + "]", arguments[0], arguments[1], append);
	} else {
		_addEvent(this.path, arguments[0], arguments[1], append);
	}
	return true;
}
Field.prototype.addEvent = _f_addEvent;

// define Field disabled(); prototype
function _f_disabled(s){
	var status = arguments[0];
	var oField = (this.type == "radio") ? this.obj[0] : this.obj;
	var objExists = (typeof oField.disabled == "boolean") ? true : false;
	if( arguments.length == 0 ) var status = (oField.disabled) ? false : true;
	// if the "disabled" var doesn't exist, then use the build in "locked" feature
	if( !objExists ) this.locked = status;
	// switch the status of the disabled property
	else {
		if( !!this.obj[0] && this.type.indexOf("select") == -1 ) for( var i=0; i < this.obj.length; i++ ) this.obj[i].disabled = status;
		else this.obj.disabled = status;
	}
	return true;
}
Field.prototype.disabled = _f_disabled;

// define Field checkIfLocked(); prototype
function _f_checkIfLocked(showMsg){
	var bShowMsg = _param(arguments[0], this.qForm._showAlerts);
	// if the value isn't equal to the key, then don't relocate the user
	if( this.isLocked() ){
		this.blur();
		if( bShowMsg ) alert("This field is disabled.");
		return false;
	}
	return true;
}
Field.prototype.checkIfLocked = _f_checkIfLocked;

// define Field isLocked(); prototype
function _f_isLocked(){
	var isLocked = this.locked;
	if( this.qForm._locked ) isLocked = true; // if the entire form is locked
	return isLocked;
}
Field.prototype.isLocked = _f_isLocked;

// define Field isDisabled(); prototype
function _f_isDisabled(){
	// if the disabled object exists, then get its status
	if( typeof this.obj.disabled == "boolean" ){
		var isDisabled = this.obj.disabled;
		if( this.qForm.obj.disabled ) isDisabled = true; // if the entire form is locked
		return isDisabled;
	// otherwise, return false (saying it's not disabled)
	} else {
		return false;
	}
}
Field.prototype.isDisabled = _f_isDisabled;

// define Field focus(); prototype
function _f_focus(){
	if( !!this.obj.focus ) this.obj.focus();
}
Field.prototype.focus = _f_focus;

// define Field blur(); prototype
function _f_blur(){
	if( !!this.obj.blur ) this.obj.blur();
}
Field.prototype.blur = _f_blur;

// define Field select(); prototype
function _f_select(){
	if( !!this.obj.select ) this.obj.select();
}
Field.prototype.select = _f_select;

// define Field reset(); prototype
function _f_reset(){
	this.setValue(this.defaultValue, true, false);
}
Field.prototype.reset = _f_reset;

// define Field getValue(); prototype
function _f_getValue(){
	var type = (this.type.substring(0,6) == "select") ? "select" : this.type;
	var value = new Array();

	if( type == "select" ){
		if( this.type == "select-one" && !this.container ){
			value[value.length] = (this.obj.selectedIndex == -1) ? "" : this.obj[this.obj.selectedIndex].value;
		} else {
			// loop through all element in the array for this field
			for( var i=0; i < this.obj.length; i++ ){
				// if the element is selected, get the selected values (unless it's a dummy container)
				if( (this.obj[i].selected || this.container) && (!this.dummyContainer) ){
					// append the selected value, if the value property doesn't exist, use the text
					value[value.length] = this.obj[i].value;
				}
			}
		}
	} else if( (type == "checkbox") || (type == "radio") ){
		// if more then one checkbox
		if( !!this.obj[0] && !this.obj.value ){
			// loop through all checkbox elements, and if a checkbox is checked, grab the value
			for( var i=0; i < this.obj.length; i++ ) if( this.obj[i].checked  ) value[value.length] = this.obj[i].value;
		// otherwise, store the value of the field (if checkmarked) into the list
		} else if( this.obj.checked ){
			value[value.length] = this.obj.value;
		}
	} else {
		value[value.length] = this.obj.value;
	}
	return value.join(",");
}
Field.prototype.getValue = _f_getValue;

// define Field setValue(); prototype
function _f_setValue(value, bReset, doEvents){
	this.lastValue = this.getValue();
	var reset = _param(arguments[1], true, "boolean");
	var doEvents = _param(arguments[2], true, "boolean");
	var type = (this.type.substring(0,6) == "select") ? "select" : this.type;
	var v;

	if( type == "select" ){
		var bSelectOne = (this.type == "select-one") ? true : false;
		var orig = value;
		value = "," + value + ",";
		bLookForFirst = true; // if select-one type, then only select the first value found
		// if the select box is not a container
		if( !this.container ){
			// loop through all element in the array for this field
			for( var i=0; i < this.obj.length; i++ ){
				v = this.obj[i].value;
				bSelectItem = (value.indexOf("," + v + ",") > -1) ? true : false;
				if( bSelectItem && (bLookForFirst || !bSelectOne) ) this.obj[i].selected = true;
				else if( reset || bSelectOne) this.obj[i].selected = false;
				if( bSelectItem && bLookForFirst ) bLookForFirst = false;
			}
			// if a select-one box and nothing selected, then try to select the default value
			if( bSelectOne && bLookForFirst ){
				if( this.defaultValue == orig ) if( this.obj.length > 0 ) this.obj[0].selected = true;
				else this.setValue(this.defaultValue);
			}
		// if the select box is a container, then search through the container's original contents
		} else {
			newValues = new Object();
			for( var i=0; i < this.boundContainers.length; i++ ){
				var sCName = this.qForm._name + "_" + this.boundContainers[i];
				// check to see if the container exists, if it does check for the value
				if( qFormAPI.containers[sCName] ){
					// loop through all the container objects
					for( key in qFormAPI.containers[sCName] ){
						// if the key is in the container, then make sure to add the value
						if( value.indexOf("," + key + ",") > -1 ){
							newValues[key] = qFormAPI.containers[sCName][key];
						}
					}
				}
			}
			// populate the container values
			this.populate(newValues, reset)
		}

	} else if( (type == "checkbox") || (type == "radio") ){
		// if more then one checkbox
		if( !!this.obj[0] && !this.obj.value ){
			// surround the value by commas for detection
			value = "," + value + ",";
			// loop through all checkbox elements, and if a checkbox is checked, grab the value
			for( var i=0; i < this.obj.length; i++ ){
				if( value.indexOf("," + this.obj[i].value + ",") > -1 ) this.obj[i].checked = true;
				else if( reset ) this.obj[i].checked = false;
			}
		// otherwise, store the value of the field (if checkmarked) into the list
		} else if( this.obj.value == value ){
			this.obj.checked = true;
		} else if( reset ){
			this.obj.checked = false;
		}

	} else {
		this.obj.value = (!value) ? "" : value;
	}

	// run the trigger events
	if( doEvents ){
		this.triggerEvent("onblur");
		// run the onchange event if the value has changed
		if( this.lastValue != value ) this.triggerEvent("onchange");
	}
	// run the onSetValue method
	this.onSetValue();

	return true;
}
Field.prototype.setValue = _f_setValue;

// define Field onSetValue(); prototype
Field.prototype.onSetValue = new Function("");

// define Field triggerEvent(); prototype
function _f_triggerEvent(event){
	oEvent = eval("this.obj." + event);
	if( (this.obj.type == "checkbox") || (this.obj.type == "radio") && !!this.obj[0] ){
		for( var k=0; k < this.obj.length; k++ ){
			oEvent = eval("this.obj[k]." + event);
			if( typeof oEvent == "function" ) oEvent();
		}
	} else if( typeof oEvent == "function" ){
		oEvent();
	}
}
Field.prototype.triggerEvent = _f_triggerEvent;

/******************************************************************************
 Validation Object
******************************************************************************/
// define qForm addValidator(); prototype
function _q_addValidator(name, fn){
	if( arguments.length < 2 ) return alert("To create a new validation object, you must specify \nboth a name and function to run: \n  obj.addValidator(\"isTime\", __isTime);");
	if( typeof fn == "string" ){
		var _func = new Function(fn);
		_addValidator(name, _func);
	} else {
		_addValidator(name, fn);
	}
	return true;
}
qForm.prototype.addValidator = _q_addValidator;

// define Field validateExp(); prototype
function _f_validateExp(expression, error, cmd){
	var expression = _param(arguments[0], "false");
	var error = _param(arguments[1], "An error occurred on the field '\" + this.description + \"'.");
	var cmd = _param(arguments[2]);

	var strFn = "if( " + expression + " ){ this.error = \"" + error + "\";}";
	if( cmd.length > 0 ) strFn += cmd;
	strValidateExp = "_validateExp" + qFormAPI.customValidators;
	_addValidator(strValidateExp, new Function(strFn));
	eval(this.pointer + ".validate" + strValidateExp + "();");
	qFormAPI.customValidators++;
}
Field.prototype.validateExp = _f_validateExp;

function _addValidator(name, fn, alwaysRun){
	var alwaysRun = _param(arguments[2], false, "boolean");

	if( arguments.length < 2 ) return alert("To create a new validation object, you must specify \nboth a name and function to run: \n  _addValidator(\"isTime\", __isTime);");
	// strip "is" out of name if present
	if( name.substring(0,2).toLowerCase() == "is" ) name = name.substring(2);

	// if the validator has already been loaded, do not load it
	for( var a=0; a < qFormAPI.validators.length; a++ ) if( qFormAPI.validators[a] == name ) return alert("The " + name + " validator has already been loaded.");

	// add the validator to the array of validators
	qFormAPI.validators[qFormAPI.validators.length] = name;

	// if not registering a simple expression evaluator, then update the status bar
	if( qFormAPI.showStatusMsgs && name.substring(0,12) != "_validateExp" ){
		// update the status bar with the initialization request
		window.status = "Initializing the validate" + name + "() and is" + name + "() validation scripts...";
		// clear the status bar
		setTimeout("window.status = ''", 100);
	}

	var strFN = fn.toString();
	var strName = strFN.substring(strFN.indexOf(" "), strFN.indexOf("("));
	var strArguments = strFN.substring( strFN.indexOf("(")+1, strFN.indexOf(")") );
	// remove spaces from the arguments
	while( strArguments.indexOf(" ") > -1 ) strArguments = strArguments.substring( 0, strArguments.indexOf(" ") ) + strArguments.substring( strArguments.indexOf(" ")+1 );

	// add rountine to check to see if the validation method should be processed
	// if displaying errors, but the field is locked then return false immediately
	var strBody = "var display = (this.qForm._status == 'validating') ? false : true;\n";
	strBody += "if( (display && this.isLocked()) || this.qForm._status.substring(0,5) == 'error') return false;\n this.value = this.getValue();";
	if( !alwaysRun ) strBody += "if( !display && this.value.length == 0 && !this.required ) return false;\n";
	strBody += "this.error = '';\n";

	// get the body of the custom function
	strBody += strFN.substring( strFN.indexOf("{")+1, strFN.lastIndexOf("}") );

	// if alerting the user to the error
	strBody += "if( this.error.length > 0 && !!errorMsg) this.error = errorMsg;\n";
	strBody += "if( display && this.error.length > 0 ){\n";
	strBody += "if( this.qForm._status.indexOf('_ShowError') > -1 ){\n";
	strBody += "this.qForm._status = 'error';\n";
	// if the user has specified an error message, then display the custom message
	strBody += "alert(this.error);\n";
	strBody += "setTimeout(this.pointer + \".focus();\", 1);\n";
	strBody += "setTimeout(this.pointer + \".qForm._status = 'idle';\", 100);\n";
	strBody += "} return false;\n";
	strBody += "} else if ( display ){ return true; } return this.error;\n";

	// start build a string to create the new function
	var strNewFN = "new Function(";
	var aryArguments = strArguments.split(",");
	for( var i=0; i < aryArguments.length; i++ ){
		if(aryArguments[i] != "") strNewFN += "\"" + aryArguments[i] + "\",";
	}
	var strRuleFN = strNewFN;

	strNewFN += "\"errorMsg\",strBody);";

	// create the Field prototype for validation
	eval("Field.prototype.is" + name + " = " + strNewFN);

	// create validation rule, the validation rule must loop through the arguments provided
	// and create a string to stick in the validation queue. This string will be eval() later
	// on to check for errors
	var strRule = "var cmd = this.pointer + '.is" + name + "';\n";
	strRule += "cmd += '( ';\n";
	strRule += "for( i=0; i < arguments.length; i++ ){ \n";
	strRule += "if( typeof arguments[i] == 'string' ) cmd += '\"' + arguments[i] + '\",';\n";
	strRule += "else cmd += arguments[i] + ',';\n";
	strRule += "}\n";
	strRule += "cmd = cmd.substring(0, cmd.length-1);\n";
	strRule += "cmd += ')';\n";
	strRule += "this.qForm._queue.validation[this.qForm._queue.validation.length] = new Array(this.name, cmd);\n";
	strRule += "this._queue.validation[this._queue.validation.length] = cmd;\n";
	strRule += "if( !this.validatorAttached ){ this.addEvent('onblur', this.pointer + '.checkForErrors()');";
	strRule += "this.validatorAttached = true;}\n";
	strRule += "return true;\n";
	strRuleFN += "\"errorMsg\",strRule);";
	eval("Field.prototype.validate" + name + " = " + strRuleFN);

	return true;
}

// define Field checkForErrors(); prototype
function _f_checkForErrors(){
	if( !this.validate || this.qForms._skipValidation ) return true;
	// change the status of the form
	this.qForm._status += "_ShowError";
	// loop through the validation queue and validation each item, if the item has already been validated, don't validate again
	for( var i=0; i < this._queue.validation.length; i++ ) if( !eval(this._queue.validation[i]) ) break;
	// reset the status to idle
	setTimeout(this.pointer + ".qForm._status = 'idle';", 100);
	return true;
}
Field.prototype.checkForErrors = _f_checkForErrors;

// define qForm validate(); prototype
function _q_validate(){
	// if validation library hasn't been loaded, then return true
	if( !qFormAPI.packages.validation || this._skipValidation ) return true;

	// check the form for errors
	this.checkForErrors();

	// if there are no errors then return true
	if( this._queue.errors.length == 0 ) return true;

	// run the custom onError event, if it returns false, cancel request
	var result = this.onError();
	if( result == false ) return true;

	var strError = "The following error(s) occurred:\n";
	for( var i=0; i < this._queue.errors.length; i++ ) strError += " - " + this._queue.errors[i] + "\n";

	var result = false;
	// check to see if the user is allowed to submit the form even if an error occurred
	if( this._allowSubmitOnError && this._showAlerts ) result = confirm(strError + "\nAre you sure you want to continue?");
	// if the form can be submitted with errors and errors should not be alerted set a hidden field equal to the errors
	else if( this._allowSubmitOnError && !this._showAlerts ) result = true;
	// otherwise, just display the error
	else alert(strError);

	return result;
}
qForm.prototype.validate = _q_validate;

// define qForm checkForErrors(); prototype
function _q_checkForErrors(){
	var status = this._status; // copy the current form's status
	this._status = "validating"; // set form's status to validating
	this._queue.errors = new Array(); // clear the current error queue
	aryQueue = new Array(); // create a local queue for the required fields
	this._queue.errorFields = ",";


	// loop through form elements
	for( var j=0; j < this._fields.length; j++ ){
		// if the current field is required, then check to make sure it's value isn't blank
		if( this[this._fields[j]].required ) aryQueue[aryQueue.length] = new Array(this._fields[j], this._pointer + "['" + this._fields[j] + "'].isNotEmpty('The " + this[this._fields[j]].description + " field is required.');");
		// reset the CSS settings on the field
		if( qFormAPI.useErrorColorCoding && this[this._fields[j]].obj.style ) this[this._fields[j]].obj.style[qFormAPI.styleAttribute] = this[this._fields[j]].styleValue;
	}

	// loop through the required fields queue, if the field throws an error, don't validate later
	for( var i=0; i < aryQueue.length; i++ ) this[aryQueue[i][0]].throwError(eval(aryQueue[i][1]));

	// loop through the validation queue and validation each item, if the item has already been validated, don't validate again
	for( var i=0; i < this._queue.validation.length; i++ ) this[this._queue.validation[i][0]].throwError(eval(this._queue.validation[i][1]));

	// run the custom validation routine
	this.onValidate();

	// set form's status back to it's last status
	this._status = status;

	return true;
}
qForm.prototype.checkForErrors = _q_checkForErrors;

// define qForm onValidate(); prototype
qForm.prototype.onValidate = new Function("");

// define qForm onError(); prototype
qForm.prototype.onError = new Function("");

// define Field throwError() prototype
function _f_throwError(error){
	var q = this.qForm;
	// if the error msg is a valid string and this field hasn't errored already, then queue msg
	if( (typeof error == "string") && (error.length > 0) && (q._queue.errorFields.indexOf("," + this.name + ",") == -1) ){
		q._queue.errors[q._queue.errors.length] = error;
		q._queue.errorFields += this.name + ",";
		// change the background color of failed validation fields to red
		if( qFormAPI.useErrorColorCoding && this.obj.style ) this.obj.style[qFormAPI.styleAttribute] = qFormAPI.errorColor;
		return true;
	}
	return false;
}
Field.prototype.throwError = _f_throwError;

/******************************************************************************
 Required Functions
******************************************************************************/
// define the addEvent() function
function _addEvent(obj, event, cmd, append){
	if( arguments.length < 3 ) return alert("Invalid arguments. Please use the format \n_addEvent(object, event, command, [append]).");
	var append = _param(arguments[3], true, "boolean");
	var event = arguments[0] + "." + arguments[1].toLowerCase();
	var objEvent = eval(event);
	var strEvent = (objEvent) ? objEvent.toString() : "";
	// strip out the body of the function
	strEvent = strEvent.substring(strEvent.indexOf("{")+1, strEvent.lastIndexOf("}"));
	strEvent = (append) ? (strEvent + cmd) : (cmd + strEvent);
	strEvent += "\n";
	eval(event + " = new Function(strEvent)");
	return true;
}

// define the _functionToString() function
function _functionToString(fn, cmd, append){
	if( arguments.length < 1 ) return alert("Invalid arguments. Please use the format \n_functionToString(function, [command], [append]).");
	var append = _param(arguments[2], true, "boolean");
	var strFunction = (!fn) ? "" : fn.toString();
	// strip out the body of the function
	strFunction = strFunction.substring(strFunction.indexOf("{")+1, strFunction.lastIndexOf("}"));
	if( cmd ) strFunction = (append) ? (strFunction + cmd + "\n") : (cmd + strFunction + "\n");
	return strFunction;
}

// define the _param(value, default, type) function
function _param(v, d, t){
	// if no default value is present, use an empty string
	if( typeof d == "undefined" ) d = "";
	// if no type value is present, use "string"
	if( typeof t == "undefined" ) t = "string";
	// if datatype should be a number and it's a string, convert it to a number
	if( t == "number" && typeof v == "string" ) var v = parseFloat(arguments[0]);
	// get the value to return, if the v param is not equal to the type, use default value
	var value = (typeof v != "undefined" && typeof v == t.toLowerCase()) ? v : d;
	return value;
}

// define the _removeSpaces(value) function
function _removeSpaces(v){
	// remove all spaces
	while( v.indexOf(" ") > -1 ) v = v.substring( 0, v.indexOf(" ") ) + v.substring( v.indexOf(" ")+1 );
	return v;
}

// defined the _setContainerValues(obj) function
function _setContainerValues(obj){
	// loop through form elements
	for( var i=0; i < obj._fields.length; i++ ){
		if( obj[obj._fields[i]].container && obj[obj._fields[i]].type.substring(0,6) == "select" ){
			for( var x=0; x < obj[obj._fields[i]].obj.length; x++ ){
				obj[obj._fields[i]].obj[x].selected = (!obj[obj._fields[i]].dummyContainer);
			}
		}
	}
}
