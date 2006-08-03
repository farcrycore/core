<!---
************************************************************************************
	Javascript to handle ordering, selecting rules in editcontainer.cfm
************************************************************************************
 --->
<cfoutput>
<script type="text/javascript">

<!-- Begin
sortitems = 1;  

function moveindex(index,to) {
	var list = document.forms[0].dest;
	var total = list.options.length-1;
	if (index == -1) return false;
	if (to == +1 && index == total)
		return false;
	if (to == -1 && index == 0)
		return false;

	var items = new Array;
	var values = new Array;

	for (i = total; i >= 0; i--) {
		items[i] = list.options[i].text;
		values[i] = list.options[i].value;
	}

	for (i = total; i >= 0; i--) {
		if (index == i) {
		list.options[i + to] = new Option(items[i],values[i], 0, 1);
		list.options[i] = new Option(items[i + to], values[i + to]);
		i--;
		}
		else {
			list.options[i] = new Option(items[i], values[i]);
   		}
	}

	list.focus();
}

function move(fbox,tbox)
{
	for(var i=0; i<fbox.options.length; i++) {
		if(fbox.options[i].selected && fbox.options[i].value != "") {
			var no = new Option();
			no.value = fbox.options[i].value;
			no.text = fbox.options[i].text;
			tbox.options[tbox.options.length] = no;
			//fbox.options[i].value = "";
			//fbox.options[i].text = "";
	   }
	}
	//BumpUp(fbox);
}

function takeoff(fbox,tbox)
{	//alert(tempcount);
	for(var i=0; i<fbox.options.length; i++) {
		if(fbox.options[i].selected && fbox.options[i].value != "") {
			var no = new Option();
			no.value = fbox.options[i].value;
			no.text = fbox.options[i].text;
			tbox.options[tbox.options.length] = no;
			fbox.options[i].value = "";
			fbox.options[i].text = "";
	   }
	}
	BumpUp(fbox);
}


function BumpUp(box)
{
	for(var i=0; i<box.options.length; i++)
	{
		if(box.options[i].value == "")
		{
			for(var j=i; j<box.options.length-1; j++) {
				box.options[j].value = box.options[j+1].value;
				box.options[j].text = box.options[j+1].text;
			}
		var ln = i;
		break;
   		}
	}
	if(ln < box.options.length)  {
		box.options.length -= 1;
		BumpUp(box);
   }
}

function confirmDelete(){
	var msg = "#application.adminBundle[session.dmProfile.locale].confirmDeletePackage#";
	if (confirm(msg))
		return true;
	else
		return false;
}				


function selectAll(dest){
	for (var i = 0; i < dest.options.length; i++) { 
		dest.options[i].selected = true;
	}
 }
 
 function deleteRule(fbox)
 {
 	if (confirm("#application.adminBundle[session.dmProfile.locale].confirmDeleteRuleInstance#"))
	{
		 for(var i=0; i<fbox.options.length; i++)
		 {
			if(fbox.options[i].selected)
			{
				fbox.options[i].value = "";
				fbox.options[i].text = "";
		   }
		}
		BumpUp(fbox);	
	}	
 }
 
// build rules structure
oRules = new Object;
<cfloop query="qRules">
	oRules['#qRules.rulename#'] = new Object;
	<cfif structKeyExists(application.rules['#qRules.rulename#'],'hint')>
		oRules['#qRules.rulename#'].hint = '#JSStringFormat(application.rules[qRules.rulename].hint)#';
	<cfelse>
		oRules['#qRules.rulename#'].hint = 	'';
	</cfif>
</cfloop>
 
function renderHint(rulename)
{	
	document.getElementById('rulehint').innerHTML = oRules[rulename].hint;
}	
 
// End -->
</script>
</cfoutput>