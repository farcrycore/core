<cfsetting enablecfoutputonly="true">

<cfif isDefined("caller.output")>
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
	<cfparam name="attributes.fieldLabel" default="#application.adminBundle[session.dmProfile.locale].relatedObjects#">
	<!--- this is mutually exclusive of the output.arelatedids ie. the value is not stored into the mainContentType_arelatedids table but instead in a list field --->
	<cfparam name="attributes.fieldName" default="aRelatedIDs">
	<cfparam name="attributes.bPLPStorage" default="yes">
	<cfparam name="attributes.bAllowReposition" default="1">

	<cfset output = caller.output>
	<cfif IsArray(output[attributes.fieldName])>
		<cfset bStoreInArray = true>
	<cfelse>
		<cfset bStoreInArray = false>
	</cfif>
	
	<cfif bStoreInArray>
		<cfset lRelatedObjectID = ArrayToList(output[attributes.fieldName])>
	<cfelse>
		<cfset lRelatedObjectID = output[attributes.fieldName]>
	</cfif>

	<cfset primaryObjectID = output.objectid>
	<cfset lRelatedTypeName = attributes.lRelatedTypeName><cfoutput>
	<script language="javascript">
	function showWindowRelatedItems_#attributes.fieldName#()
	{
		var url = "#application.url.farcry#/includes/relatedlist.cfm?lRelatedTypeName=#lRelatedTypeName#&primaryObjectID=#primaryObjectID#&fieldName=#attributes.fieldName#&bPLPStorage=#attributes.bPLPStorage#";
		var options = "width="+680+",height="+530+",status=no,toolbar=no,directories=no,menubar=no,location=no,resizable=yes,left=20,top=20,scrollbars=yes";
		var hwnd = open(url, "_winrelated", options);
	}

	function processReqChange_#attributes.fieldName#(data, obj) 
	{
		var arItems = JSON.parse(data);
		doUpdateRelated_#attributes.fieldName#(arItems);
	}

	function doUpdateRelated_#attributes.fieldName#(arItems){

		objSelect = document.getElementById("lRelatedObjectID_#attributes.fieldName#");
		objSelectValue = document.getElementById("#attributes.fieldName#");
		objSelectValue.value = "";
		objSelect.length = 0;
		if (arItems.length == 0)
			objSelect.options[0] = new Option("Currently no Related Items","");
	
		for(i=0;i<arItems.length;i++){
			objSelectValue.value = objSelectValue.value + ',' + arItems[i]["objectid"]; 
			objSelect.options[i] = new Option(arItems[i]["text"],arItems[i]["objectid"]);
		}
	}

	function fDeleteItem_#attributes.fieldName#(){
		objSelect = document.getElementById("lRelatedObjectID_#attributes.fieldName#");
		if(objSelect.options[objSelect.selectedIndex].value == "")
			alert("Please select a related Item to delete.")
		else if(confirm("Are you sure you want to delete this selected Related Item")){
			strVal = objSelect.options[objSelect.selectedIndex].value;
			strURL = "#application.url.farcry#/includes/generateLibraryXML.cfm";

			var req = new DataRequestor();
			req.addArg(_GET,"action","delete");
			req.addArg(_GET,"primaryObjectID","#primaryObjectID#");
			req.addArg(_GET,"libraryType","#lRelatedTypeName#");
			req.addArg(_GET,"lObjectID",strVal);
			req.addArg(_GET,"plpArrayPropertieName","#attributes.fieldName#");
			req.addArg(_GET,"bPLPStorage","#attributes.bPLPStorage#");
//strURL = strURL + "?action=delete&primaryObjectID=#primaryObjectID#&libraryType=#lRelatedTypeName#&lObjectID="+strVal+"&plpArrayPropertieName=#attributes.fieldName#&bPLPStorage=#attributes.bPLPStorage#";
//window.open(strURL);
			req.onload = processReqChange_#attributes.fieldName#;
			req.onfail = function (status){alert("Sorry and error occured while retrieving data [" + status + "]")};
			req.getURL(strURL,_RETURN_AS_TEXT);
		}
		return false;
	}

	function fUpdatePosition_#attributes.fieldName#(dir){
		objSelect = document.getElementById("lRelatedObjectID_#attributes.fieldName#");
		if(objSelect.length < 2)
			return false;
			
		var iPos1 = objSelect.selectedIndex;
		if(dir == "up" && objSelect.selectedIndex > 0)
			var iPos2 = objSelect.selectedIndex - 1;
		else if(dir == "down" && objSelect.selectedIndex < (objSelect.length))
			var iPos2 = objSelect.selectedIndex + 1;
		else {
			alert("Please select a valid Related Item to move.");
			return false;
		}
		iCurrentPos = iPos2;				
		objectid1 = objSelect.options[iPos1].value;
		objectid2 = objSelect.options[iPos2].value;
		strURL = "#application.url.farcry#/includes/generateLibraryXML.cfm";
		
		var req = new DataRequestor();
		req.addArg(_GET,"action","reposition");
		req.addArg(_GET,"primaryObjectID","#primaryObjectID#");
		req.addArg(_GET,"libraryType","#lRelatedTypeName#");
		req.addArg(_GET,"lObjectID",objectid1+","+objectid2);
		req.addArg(_GET,"plpArrayPropertieName","#attributes.fieldName#");
		req.addArg(_GET,"bPLPStorage","#attributes.bPLPStorage#");

		req.onload = processReqChange_#attributes.fieldName#;
		req.onfail = function (status){alert("Sorry and error occured while retrieving data [" + status + "]")};
		req.getURL(strURL,_RETURN_AS_TEXT);
	}
	</script>
	<div class="relateditems-wrap" style="padding-right:70px">
	<h2><small><a href="##" onclick="showWindowRelatedItems_#attributes.fieldName#();">Add Item</a></small>#attributes.fieldLabel#:</h2>
	<label for="lRelatedObjectID_#attributes.fieldName#">
		<select name="lRelatedObjectID_#attributes.fieldName#" id="lRelatedObjectID_#attributes.fieldName#" size="5"><cfif lRelatedObjectID EQ "">
			<option value="">No #attributes.fieldLabel#</option></cfif><cfloop list="#lRelatedObjectID#" index="id"><cfsilent><q4:contentobjectget objectid="#id#" r_stobject="stItem"></cfsilent><cfif NOT structisEmpty(stItem)>
			<option value="#stItem.objectID#">#stItem.label#</option></cfif></cfloop>
		</select><cfif attributes.bAllowReposition>
		<a href="##" onclick="return fUpdatePosition_#attributes.fieldName#('up');" class="moveup"><strong>Move Up</strong></a>
		<a href="##" onclick="return fUpdatePosition_#attributes.fieldName#('down');" class="movedown"><strong>Move Down</strong></a></cfif>
		<div class="f-submit-wrap">
		<input type="button" name="buttonFileDelete" value="Delete" class="f-submit" onclick="return fDeleteItem_#attributes.fieldName#();" />
		<input  type="hidden" name="#attributes.fieldname#" id="#attributes.fieldname#" value="#lRelatedObjectID#">
		
		</div><br />
	</label>
</div></cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">