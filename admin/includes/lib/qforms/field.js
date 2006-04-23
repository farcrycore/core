/******************************************************************************
 qForm JSAPI: Field Extensions Library

 Author: Dan G. Switzer, II
 Build:  109
******************************************************************************/
// define Field makeContainer(); prototype
function _Field_makeContainer(bindTo){
	lstContainers = (arguments.length == 0) ? this.name : this.name + "," + arguments[0];
	this.container = true;
	this.defaultValue = this.getValue();
	this.lastValue = this.defaultValue;
	this.dummyContainer = false;
	this.boundContainers = _listToArray(lstContainers.toLowerCase());
	var thisKey = this.qForm._name + "_" + this.name.toLowerCase();

	// copy objects from the select box into the container object
	qFormAPI.containers[thisKey] = new Object();
	for( var i=0; i < this.obj.options.length; i++ ){
		qFormAPI.containers[thisKey][this.obj.options[i].value] = this.obj.options[i].text;
	}
}
Field.prototype.makeContainer = _Field_makeContainer;

// define Field resetLast(); prototype
function _Field_resetLast(){
	this.setValue(this.lastValue, null, false);
	return true;
}
Field.prototype.resetLast = _Field_resetLast;

// define Field toUpperCase(); prototype
function _Field_toUpperCase(){
	this.setValue(this.getValue().toUpperCase(), null, false);
	return true;
}
Field.prototype.toUpperCase = _Field_toUpperCase;

// define Field toLowerCase(); prototype
function _Field_toLowerCase(){
	this.setValue(this.getValue().toLowerCase(), null, false);
	return true;
}
Field.prototype.toLowerCase = _Field_toLowerCase;

// define Field ltrim(); prototype
function _Field_ltrim(){
	this.setValue(_ltrim(this.getValue()), null, false);
	return true;
}
Field.prototype.ltrim = _Field_ltrim;

// define Field rtrim(); prototype
function _Field_rtrim(){
	this.setValue(_rtrim(this.getValue()), null, false);
	return true;
}
Field.prototype.rtrim = _Field_rtrim;

// define Field trim(); prototype
function _Field_trim(){
	this.setValue(_trim(this.getValue()), null, false);
	return true;
}
Field.prototype.trim = _Field_trim;

// define Field compare(); prototype
function _Field_compare(field){
	if( this.getValue() == this.qForm[field].getValue() ){
		return true;
	} else {
		return false;
	}
	return true;
}
Field.prototype.compare = _Field_compare;

// define Field mirrorTo(); prototype
function _Field_mirrorTo(objName){
	// test to see if the object is qForm object
	isQForm = ( objName.indexOf(".") > -1 ) ? !eval("!objName.substring(0,objName.indexOf('.'))") : false;

	// if it's a qForm object, then set the value of the field to the current field when updated
	if( isQForm ){
		var strCommand = objName  + ".setValue(" + this.pointer + ".getValue()" + ", null, false);";
	// otherwise, set the local variable
	} else {
		var strCommand = objName  + " = " + this.pointer + ".getValue();";
	}

	// add an onblur event so that when the field is updated, the requested field
	// is updated with the value
	this.addEvent(_getEventType(this.type), strCommand, false);
}
Field.prototype.mirrorTo = _Field_mirrorTo;

// define Field createDependencyTo(); prototype
function _Field_createDependencyTo(field, condition){
	var condition = (arguments.length > 1) ? "\"" + arguments[1] + "\"" : null;
	var otherField = this.qForm._pointer + "['" + field + "']";
	if( !eval(otherField) ) return alert("The " + field + " field does not exist. The dependency \nto " + this.name + " can not be created.");
	// add an onblur event so that when the field is updated, the requested field
	// is updated with the value
	if( this.qForm[field]._queue.dependencies.length == 0 ) this.qForm[field].addEvent(_getEventType(this.qForm[field].type), otherField + ".enforceDependency();", false);
	this.qForm[field]._queue.dependencies[this.qForm[field]._queue.dependencies.length] = otherField + ".isDependent('" + this.name + "', " + condition + ");";
	return true;
}
Field.prototype.createDependencyTo = _Field_createDependencyTo;

// *this is an internal method that should only be used by the API*
// define Field isDependent(); prototype
function _Field_isDependent(field, condition){
	var condition = _param(arguments[1], null);
	this.value = this.getValue();

	// if the current field is empty or not equal to the specified value, then the
	// dependent field is not required, otherwise the dependency is enforced
	if( condition == null ){
		var result = (this.isNotEmpty() || this.required);
	} else {
		// if there's a space in the condition, assume you're to evaluate the string
		if( condition.indexOf("this.") > -1 || condition == "true" || condition == "false" ){
			var result = eval(condition);
		// otherwise, you're doing a simple value compare
		} else {
			var result = (this.value == condition);
		}
	}
	// return both the field and the result
	var o = null;
	o = new Object();
	o.field = field;
	o.result = result;
	return o;
}
Field.prototype.isDependent = _Field_isDependent;

// *this is an internal method that should only be used by the API*
// define Field enforceDependency(); prototype
function _Field_enforceDependency(e){
	var lstExcludeFields = _param(arguments[0], ",");
	var lstFieldsChecked = ",";
	var lstFieldsRequired = ",";
	// loop through all the dependency and run each one
	for( var i=0; i < this._queue.dependencies.length; i++ ){
		var s = eval(this._queue.dependencies[i]);
		// keep a unique list of field checked
		if( lstFieldsChecked.indexOf("," + s.field + ",") == -1 ) lstFieldsChecked += s.field + ",";
		// keep a unique list of fields that now should be required
		if( s.result && lstFieldsRequired.indexOf("," + s.field + ",") == -1 ) lstFieldsRequired += s.field + ",";
	}
	// create an array of the field checked
	aryFieldsChecked = lstFieldsChecked.split(",");
	// loop through the array skipping the first and last elements
	for( var j=1; j < aryFieldsChecked.length-1; j++ ){
		// determine if the field is required
		var result = (lstFieldsRequired.indexOf("," + aryFieldsChecked[j] + ",") > -1);
		// update it's status
		this.qForm[aryFieldsChecked[j]].required = result;
		// now go check the dependencies for the field whose required status was changed
		// if the dependency rules for the field have already been run, then don't run
		// them again
		if( lstExcludeFields.indexOf("," + aryFieldsChecked[j] + ",") == -1 ) setTimeout(this.qForm._pointer + "." + aryFieldsChecked[j] + ".enforceDependency('" + lstExcludeFields + this.name + ",')", 1);
	}
}
Field.prototype.enforceDependency = _Field_enforceDependency;


// define Field location(); prototype
function _Field_location(target, key){
	var target = _param(arguments[0], "self");
	var key = _param(arguments[1]);
	// if the current field is disabled or locked, then kill the method
	if( this.isLocked() || this.isDisabled() ) return this.setValue(key, null, false);

	var value = this.getValue();
	this.setValue(key, null, false);
	// if the value isn't equal to the key, then don't relocate the user
	if( value != key ) eval(target + ".location = value");

	return true;
}
Field.prototype.location = _Field_location;

// define Field format(); prototype
function _Field_format(mask, type){
	var type = _param(arguments[1], "numeric").toLowerCase();
	this.validate = true;
	this.validateFormat(mask, type);
}
Field.prototype.format = _Field_format;


// define Field populate(); prototype
function _Field_populate(struct, reset, sort, prefix){
	// if the current field is disabled or locked, then kill the method
	if( this.isLocked() || this.isDisabled() ) return false;

	var reset = _param(arguments[1], true, "boolean");
	var sort = _param(arguments[2], false, "boolean");
	var prefix = _param(arguments[3], null, "object");

	if( this.type.substring(0,6) != "select" ) return alert("This method is only available to select boxes.");

	// clear the select box
	if( reset ) this.obj.length = 0;

	// if prefixing options
	if( !!prefix ) for( key in prefix ) this.obj.options[this.obj.length] = new Option(prefix[key], key);

	// populate the select box
	for( key in struct ) this.obj.options[this.obj.length] = new Option(struct[key], key);

	// if the user wishes to sort the options in the select box
	if( sort ) _sortOptions(this.obj);
	return true;
}
Field.prototype.populate = _Field_populate;

// define Field transferTo(); prototype
function _Field_transferTo(field, sort, type, selectItems, reset){
	// if the current field is disabled or locked, then kill the method
	if( this.isLocked() || this.isDisabled() ) return false;
	var sort = _param(arguments[1], true, "boolean");
	var type = _param(arguments[2], "selected");
	var selectItems = _param(arguments[3], true, "boolean");
	var reset = _param(arguments[4], false, "boolean");

	_transferOptions(this.obj, this.qForm[field].obj, sort, type, selectItems, reset);
	return true;
}
Field.prototype.transferTo = _Field_transferTo;

// define Field transferFrom(); prototype
function _Field_transferFrom(field, sort, type, selectItems, reset){
	// if the current field is disabled or locked, then kill the method
	if( this.isLocked() || this.isDisabled() ) return false;
	var sort = _param(arguments[1], true, "boolean");
	var type = _param(arguments[2], "selected");
	var selectItems = _param(arguments[3], true, "boolean");
	var reset = _param(arguments[4], false, "boolean");

	_transferOptions(this.qForm[field].obj, this.obj, sort, type, selectItems, reset);
	return true;
}
Field.prototype.transferFrom = _Field_transferFrom;

// define Field moveUp(); prototype
function _Field_moveUp(){
	// if the current field is disabled or locked, then kill the method
	if( this.isLocked() || this.isDisabled() || this.type.substring(0,6) != "select" ) return false;

	var oOptions = this.obj.options;
	// rearrange
	for( var i=1; i < oOptions.length; i++ ){
		// swap options
		if( oOptions[i].selected ){
			_swapOptions(oOptions[i], oOptions[i-1]);
		}
	}
	return true;
}
Field.prototype.moveUp = _Field_moveUp;

// define Field moveDown(); prototype
function _Field_moveDown(){
	// if the current field is disabled or locked, then kill the method
	if( this.isLocked() || this.isDisabled() || this.type.substring(0,6) != "select" ) return false;

	var oOptions = this.obj.options;
	// rearrange
	for( var i=oOptions.length-2; i > -1; i-- ){
		// swap options
		if( oOptions[i].selected ){
			_swapOptions(oOptions[i+1], oOptions[i]);
		}
	}
	return true;
}
Field.prototype.moveDown = _Field_moveDown;

