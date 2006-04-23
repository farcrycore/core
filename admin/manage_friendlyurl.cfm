<cfsetting enablecfoutputonly="true">
<!--- 
manage friednly urls for a particular object id
 --->

<cfparam name="objectid" default="">
<cfparam name="fatalerrormessage" default="">
<cfparam name="errormessage" default="">
<cfparam name="bFormSubmitted" default="no">
<cfparam name="friendly_url" default="#application.config.fusettings.urlpattern#">
<cfparam name="additional_params" default="">
<cfparam name="lDeleteObjectid" default="">
<cfparam name="status" default="2">

<cfif trim(objectid) EQ "">
	<cfset fatalerrormessage = "Invalid ObjectID.">
<cfelse>
	<cfset objFU = CreateObject("component","#application.packagepath#.farcry.fu")>

	<!--- form submission check --->
	<cfif bFormSubmitted EQ "yes">
		<cfif buttonSubmit EQ "delete">
			<cfset stForm = StructNew()>		
			<cfset stForm.lDeleteObjectid = trim(lDeleteObjectid)>
			<cfset returnstruct = objFU.fDelete(stForm)>
			<cfif returnstruct.bSuccess EQ 0>
				<cfset errormessage = errormessage & returnstruct.message>
			</cfif>
		<cfelseif buttonSubmit EQ "add">
			<cfif Trim(friendly_url) NEQ application.config.fusettings.urlpattern>
				<cfset stForm = StructNew()>
				<cfset stForm.refobjectid = objectid>
				<cfset stForm.friendlyUrl = trim(friendly_url)>
				<cfset stForm.querystring = trim(additional_params)>
				<cfset stForm.status = status>
				<cfset returnstruct = objFU.fInsert(stForm)>
				<cfif returnstruct.bSuccess>
					<cfset friendly_url = application.config.fusettings.urlpattern>
					<cfset additional_params = "">
					<cfset status = 1>
				<cfelse>
					<cfset errormessage = errormessage & returnstruct.message>
				</cfif>
			</cfif>
		</cfif>
	</cfif>

	<cfset returnstruct = objFU.fListFriendlyURL(objectid,"all")>
	<cfif returnstruct.bSuccess>
		<cfset qList = returnstruct.queryObject>
	<cfelse>
		<cfset fatalerrormessage = fatalerrormessage & returnstruct.returnmessage>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry</title><cfoutput>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/main.css);</style>
<style type="text/css" title="default" media="screen">@import url(#application.url.farcry#/css/tabs.css);</style></cfoutput>
<!--- 
todo: maybe use javascript remoting

<script type="text/javascript">
function add_friendlyUrl(fu_status)
{
	var mytable = document.getElementById('table_friendlyurl');	
	var mytbody = document.getElementById('tbody_friendlyurl_'+ fu_status);
	var docFragment = document.createDocumentFragment();
	var trElem, tdElem, txtNode;
	/**********************************************************************/
	/*** CREATE TR ***/
	trElem = document.createElement("tr");
	trElem.setAttribute('class','alt');
	
	/*** CREATE & SET TD TEXT ***/
	tdElem = td_CreateSetText(' ');
	trElem.appendChild(tdElem);

	/*** CREATE & SET TD TEXT ***/
	tdElem = td_CreateSetFormElement("text", "friendlyurl_" + fu_status, "/go/")
	trElem.appendChild(tdElem);
	
	/*** CREATE & SET TD TEXT ***/
	tdElem = td_CreateSetFormElement("text", "qstring_" + fu_status, "")
	trElem.appendChild(tdElem);
	
	/*** CREATE & SET TD TEXT ***/
	tdElem = td_CreateSetFormElement("submit", "buttonSubmit", fu_status)
	trElem.appendChild(tdElem);
	
	docFragment.appendChild(trElem);
	/**********************************************************************/
	mytbody.appendChild(docFragment);
}

function td_CreateSetText(str)
{
	/*** CREATE & SET TD TEXT ***/
	tdElem = document.createElement("td");
	tdElem.setAttribute('style','text-align: left;');
	txtNode = document.createTextNode(str);
	tdElem.appendChild(txtNode);
	return tdElem;
}

function td_CreateSetFormElement(element_type, element_name, element_value)
{		
	form_element = document.createElement("input");
	form_element.type = element_type;
	form_element.setAttribute('id',element_name);
	form_element.setAttribute('name',element_name);
	form_element.value = element_value;
	if(element_type == 'submit')
		form_element.setAttribute('onclick', "alert('guy');");		
		
	/*** CREATE & SET TD TEXT ***/
	tdElem = document.createElement("td");
	tdElem.setAttribute('style','text-align: left;');
	tdElem.appendChild(form_element);
	return tdElem;
}

function doSubmit(objForm)
{
	alert(objForm.buttonSubmit.value);
	return false;
}
</script>
 --->
</head>
<body class="iframed-content"
<h3>Friendly URLs Management</h3>
	<cfif fatalerrormessage NEQ "">
<span class="error"><cfoutput>#fatalerrormessage#</cfoutput></span><cfelse><cfif errormessage NEQ "">
<span class="error"><cfoutput>#errormessage#</cfoutput></span></cfif>
<form name="frm" id="frm" method="post">
<table cellpadding="0" cellspacing="0" border="0">
<tr>
	<td><label for="friendly_url"><b>Friendly URL:</b> <input type="text" name="friendly_url" id="friendly_url" value="<cfoutput>#friendly_url#</cfoutput>"></label></td>
	<td><label for="additional_params"><b>Additional Parameters:</b> <input type="text" name="additional_params" id="additional_params" value="<cfoutput>#additional_params#</cfoutput>"></label></td>
	<td><label for="status"><b>Status:</b> 
		<select name="status" id="status">
			<!--- <option value="1"<cfif status EQ 1> selected="selected"</cfif>>Active</option> --->
			<option value="2"<cfif status EQ 2> selected="selected"</cfif>>Permanent</option>
			<option value="0"<cfif status EQ 0> selected="selected"</cfif>>Archived</option>			
		</select>	
	</label></td>
	<td><input type="submit" name="buttonSubmit" value="Add"></td>
</tr>
<input type="hidden" name="objectid" value="<cfoutput>#objectid#</cfoutput>">
<input type="hidden" name="bFormSubmitted" value="yes">
</form>
<form name="frm_friendly_url" id="frm_friendly_url" method="post">
<table class="table-2" cellspacing="0" id="table_friendlyurl">
<tr>
	<th>&nbsp;</th>
	<th>FRIENDLY URL</th>
	<th>QUERYSTRING</th>
	<th>LAST UPDATED</th>
</tr><cfoutput query="qList" group="status">
<tr>
	<td><strong><cfif qList.status EQ 2>Permanent<cfelseif qList.status EQ 1>Active<cfelseif qList.status EQ 0>Archived</cfif></strong></td>
	<td></td>
	<td></td>
	<td></td>	
</tr><cfoutput>
<tr class="alt">
	<td><input type="checkbox" name="lDeleteObjectID" value="#qList.objectid#"></td>
	<td>#qList.friendlyurl#</td>
	<td>#qList.query_string#</td>
	<td>#DateFormat(qList.datetimelastupdated,"dddd dd mmmm yyyy")#</td>
</tr></cfoutput></cfoutput><br />
<input type="hidden" name="objectid" value="<cfoutput>#objectid#</cfoutput>">
</table>
<input type="hidden" name="bFormSubmitted" value="yes">
<input type="submit" name="buttonSubmit" value="Delete">&nbsp;<input type="button" name="buttonClose" value="Close" onclick="window.close();"></form>
</cfif>
</body>
</html>
<!--- <tbody id="tbody_friendlyurl_permanent"><cfoutput query="qList_permanent">
<tr class="alt">
	<td></td>
	<td>#qList_permanent.friendlyurl#</td>
	<td>#qList_permanent.query_string#</td>
	<td>#DateFormat(qList_permanent.datetimelastupdated,"dddd dd mmmm yyyy")#</td>
</tr></cfoutput></tbody>
<tr><!--- active urls --->
	<td><strong>Active</strong> <a href="##" onclick="add_friendlyUrl('active');">[+]</a></td>
	<td></td>
	<td></td>
	<td></td>	
</tr><tbody id="tbody_friendlyurl_active"><cfoutput query="qList_active">
<tr class="alt">
	<td></td>
	<td>#qList_active.friendlyurl#</td>
	<td>#qList_active.query_string#</td>
	<td>#DateFormat(qList_active.datetimelastupdated,"dddd dd mmmm yyyy")#</td>
</tr></cfoutput></tbody>
<tr><!--- archived urls --->
	<td><strong>Archived</strong></td>
	<td></td>
	<td></td>
	<td></td>	
</tr><tbody id="tbody_friendlyurl_archived"><cfoutput query="qList_archived">
<tr class="alt">
	<td></td>
	<td>#qList_archived.friendlyurl#</td>
	<td>#qList_archived.query_string#</td>
	<td>#DateFormat(qList_archived.datetimelastupdated,"dddd dd mmmm yyyy")#</td>
</tr></cfoutput></tbody> --->