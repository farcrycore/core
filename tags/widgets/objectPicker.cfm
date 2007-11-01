<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfparam name="attributes.typeName" default="">
<cfparam name="attributes.fieldName" default="">
<cfparam name="attributes.fieldlabel" default="#attributes.typeName#">
<cfparam name="attributes.fieldValue" default="">
<cfparam name="errormessage" default="">
<cfset strPreviewvalue = "">	
<cfif attributes.typeName EQ "">
	<cfset errormessage = errormessage & "Please pass in a typename attribute. <br />">
<cfelseif attributes.fieldValue NEQ "">
	<!--- default the preview on forst entry --->	
	<cfset objType = CreateObject("component","#application.types[attributes.typename].typepath#")>
	<cfset stObject = objType.getData(attributes.fieldValue)>
	<cfif NOT StructIsEmpty(stObject)>
		<cfswitch expression="#attributes.typename#">
			<cfcase value="dmImage">
				<cfset strPreviewvalue = objType.getURLImagePath(attributes.fieldValue,"thumb")>
			</cfcase>
		</cfswitch>
	<cfelse> <!--- delete association as object does not exist --->
		<cfset attributes.fieldValue = "">
	</cfif>
</cfif>


<cfoutput>
<label for="#attributes.fieldName#"><b>#attributes.fieldlabel#</b>
<input type="hidden" id="#attributes.fieldName#" name="#attributes.fieldName#" value="#attributes.fieldValue#">
<cfif errormessage NEQ "">
	#errormessage#
<cfelse>
	<cfif attributes.typeName EQ "dmImage">
<img id="disp_#attributes.fieldName#" src="../images/no_thumbnail.gif" alt="currently no thumbnail" style="display:block" />
	<cfelse>
<span id="disp_#attributes.fieldName#">[#attributes.selectedValue#]</span>
	</cfif>
	&nbsp;<a href="##" onclick="fObjectPicker_#attributes.fieldName#();">[pick]</a>
</cfif>
</label>
<script type="text/javascript">
function fObjectPicker_#attributes.fieldName#()
{
	var url = "#application.url.farcry#/includes/objectPicker.cfm?typeName=#attributes.typeName#&fieldName=#attributes.fieldName#";
	var options = "width="+680+",height="+530+",status=no,toolbar=no,directories=no,menubar=no,location=no,resizable=yes,left=20,top=20,scrollbars=yes";
	var hwnd = open(url, "_winObjectPicker", options);
}

function fObjectSelected_#attributes.fieldName#(str,previewvalue)
{
	if(!previewvalue)
		previewvalue = str;
		
	objField = document.getElementById('#attributes.fieldName#');
	objField.value = str;
	fUpdatePreview_#attributes.fieldName#(previewvalue);
}

function fUpdatePreview_#attributes.fieldName#(previewvalue)
{
	objDisplay = document.getElementById('disp_#attributes.fieldName#');
<cfif attributes.typeName EQ "dmImage">
	objDisplay.src = previewvalue;
<cfelse>
	objDisplay.innerHTML = previewvalue;
</cfif>	
}

<cfif strPreviewvalue NEQ "">
fUpdatePreview_#attributes.fieldName#('#strPreviewvalue#');
</cfif>
</script></cfoutput>
<cfsetting enablecfoutputonly="false">