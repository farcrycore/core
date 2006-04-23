// ====== Mutliple Text Applicator =======
// Gregory Narain (c)2005
// http://sparkcasting.com
// If you use this code please keep this credit intact.
// A link or email would be nice, but is not required.
// Version 0.1 - June 5, 2005

function getElementsByClass(className){
	var inc = 0
	var customcollection = [];
	var alltags = (document.all) ? document.all : document.getElementsByTagName("*");
	
	for (i=0; i<alltags.length; i++){
		if (alltags[i].className.indexOf(className)>=0)
		customcollection[inc++]=alltags[i]
	}
	
	return customcollection;
}

function MTA(varName, maxItemLength, itemClass, delClass, addClass) {
	this.varName   = varName;
	this.maxItemLength = maxItemLength;

	// Style properties
	this.itemClass = (itemClass) ? itemClass : '';
	this.delClass  = (delClass) ? delClass : '';
	this.addClass  = (addClass) ? addClass : '';
	
	this.init = function () {
		// Locate the items with the mta className
		var mtas = getElementsByClass('mta');

		for (var x=0; x<mtas.length; x++) {
			// Extract the id and delimiter
			var id    = mtas[x].id;
			var delim = ((!document.all && mtas[x].hasAttribute('delim')) || (document.all && mtas[x].delim != undefined)) ? mtas[x].getAttribute('delim') : ',';

			// Locate the object
			var fld = document.getElementById(id);
			
			// Hide the textarea
			fld.style.display = 'none';
		
			// Create the new text fields
			var list = document.createElement('ol');
			list.className = 'addList';
			list.id = 'mta_' + id;
			list.delim = delim;

			/* BUG: Passing in 'newline' for \n arrays - How to fix? */
			if (delim == 'newline') delim = /\n/g;
			var vals = fld.value.split(delim);

			for (var y=0; y<vals.length; y++) {;
				list.appendChild(this.buildItem(vals[y],this.itemClass, this.maxItemLength));
			}
			// Append the list to the container
			fld.parentNode.insertBefore(list,fld);
		
			// Create the field to add a new entry
			var addGroup = document.createElement('div');
				addGroup.className  = 'addGroup';				
                addGroup.innerHTML  = '<input type="text" class="' + this.itemClass + '" maxlength="' + ((this.maxItemLength) ? this.maxItemLength : '') + '" id="mta_' + id + '_' + 'add" onkeypress="return ' + this.varName + '.quickAdd(this,event)" />';
				addGroup.innerHTML += '<input type="button" value="Add" class="' + this.addClass + '" onClick="' + this.varName + '.addItem(\'' + id + '\',\'' + itemClass + '\')" />';

				fld.parentNode.insertBefore(addGroup,fld);
		}
	}

	/**
     *   Enables the enter key on the add input field
     *   @param     fld     object for field that fired the event
     *	 @param		event	object for the event
     *	 @return    boolean 0 if enter key was pressed, 1 otherwise
    **/
	this.quickAdd = function(fld,event) {
		if ((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13)) {
			if (fld.value.length) fld.nextSibling.click();
            return false;
        } else {
        	return true;
		}
	}
	
	/**
     *   Updates the original element's value
     *   @param     mta     object or string referring to the MTA
    **/
	this.updateMainValue = function(mta) {
		if (typeof(mta) == 'string') mta = document.getElementById('mta_' + mta);
		var id = mta.id.split('_')[1];
	
		// Loop through to get the final value
		var f = [];
		for (var x=0; x<mta.childNodes.length; x++) {
			f[f.length] = mta.childNodes[x].childNodes[1].value;
		}
		document.getElementById(id).value = f.join((mta.delim == 'newline') ? '\n' : mta.delim);
	}

	/**
     *   Removes an item from the applicator
     *   @param     mta     string id of the MTA
    **/
	this.removeItem = function (item) {
		var mta = item.parentNode;
		item.parentNode.removeChild(item);

		// Update the value
		this.updateMainValue(mta);
	}

	/**
     *   Adds an item to the applicator
     *   @param     mtaID     string identifier for the MTA
    **/
	this.addItem = function(mtaID,itemClass) {
		// Retrieve the mta
		var mta    = document.getElementById('mta_' + mtaID);
		var addFld = document.getElementById('mta_' + mtaID + '_add');
	
		// Add the item
		mta.appendChild(this.buildItem(addFld.value,itemClass));
	
		// Clear the item and focus
		addFld.value = '';
		addFld.focus();
	
		// Update the value
		this.updateMainValue(mta);
	}

	/**
     *   Removes an item from the applicator
     *   @param     mta     string id of the MTA
     *	 @return	object	generated <li> item
    **/
	this.buildItem = function (val, itemClass) {
		var ipt   = document.createElement('input');
			ipt.type = 'text';
			ipt.value = val;
			if (this.maxItemLength != undefined && this.maxItemLength != null) ipt.maxLength = this.maxItemLength;
			if (itemClass) ipt.className = itemClass;
	
		var li    = document.createElement('li');
			li.innerHTML = '<input type="button" class="' + this.delClass + '" value="DEL" onBlur="' + this.varName + '.updateMainValue(this.parentNode.parentNode)" onClick="' + this.varName + '.removeItem(this.parentNode)" />';
			li.appendChild(ipt);

		return li;
	}
	
	// Init the object
	this.init();
}