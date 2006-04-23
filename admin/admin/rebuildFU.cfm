<cfsetting enablecfoutputonly="true">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/Attic/rebuildFU.cfm,v 1.1.2.3 2006/01/23 22:28:00 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:28:00 $
$Name: milestone_3-0-1 $
$Revision: 1.1.2.3 $

|| DESCRIPTION || 
$Description: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: attribute -- description $
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<!--- environment variables --->
<cfparam name="form.bFormSubmitted" default="false">
<cfparam name="form.content_types" default="">
<cfparam name="successmessage" default="">
<cfparam name="errormessage" default="">

<!--- permission check: AdminGeneralTab --->
<cfif NOT request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab")>
	<admin:permissionError>
	<cfabort>
</cfif>

<!--- ENGAGE: make it happen --->
<cfif form.bFormSubmitted EQ "true">
	<cfloop index="currentType" list="#content_types#">
		<cfset objType = CreateObject("component", application.types[currentType].typepath)>
		<cfset returnstruct = objType.fRebuildFriendlyURLs(currentType)>
		<cfif returnstruct.bSuccess>
			<cfset successmessage = successmessage & returnstruct.message>
		<cfelse>
			<cfset errormessage = errormessage & returnstruct.message>
		</cfif>
	</cfloop>
</cfif>

<!--- build an array of content types that have friendly URLs enabled --->
<cfset aFUTypes = ArrayNew(1)>
<cfloop item="currentType" collection="#application.types#">
	<cfif structKeyExists(application.types[currentType],"bFriendly") AND application.types[currentType].bFriendly>
		<cfset ArrayAppend(aFUTypes,currentType)>
	</cfif>
</cfloop>

<!--- JS library for select toggles --->
<cfsavecontent variable="jsContent">
<cfoutput>
<script type="text/javascript">
function fSelectSelection(selectionType){
	aCheckBoxes = document.frm.content_types;
	if(selectionType == "all"){
		for(i=0;i<aCheckBoxes.length;i++)
			aCheckBoxes[i].checked = true;
	}
	else if (selectionType == "none"){
		for(i=0;i<aCheckBoxes.length;i++)
			aCheckBoxes[i].checked = false;
	}
	else{
		for(i=0;i<aCheckBoxes.length;i++)
			aCheckBoxes[i].checked = !aCheckBoxes[i].checked;
	}
	return false;
}
</script>
</cfoutput>
</cfsavecontent>

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfhtmlhead text="#jsContent#">

<cfoutput>
	<cfif successmessage NEQ ""><p class="success">#successmessage#</p></cfif>
	<cfif errormessage NEQ ""><p class="error">#errormessage#</p></cfif>
	
	<form name="frm" id="frm" action="#cgi.script_name#" method="post" class="f-wrap-1 f-bg-long">
		<h3>Rebuild Friendly URLs</h3>

		<a href="##" onclick="return fSelectSelection('all');">[SELECT ALL]</a> 
		<a href="##" onclick="return fSelectSelection('none');">[DESELECT ALL]</a> 
		<a href="##" onclick="return fSelectSelection('inverse');">[INVERSE SELECTION]</a>

		<div class="imageWrap">
			<ul><cfloop index="i" from="1" to="#ArrayLen(aFUTypes)#">
				<li><label for="content_types_#i#"><input type="checkbox" name="content_types" id="content_types_#i#" value="#aFUTypes[i]#">#aFUTypes[i]#</label></li></cfloop>
			</ul>
		</div>

		<input type="submit" name="buttonSubmit" value="Rebuild">
		<input type="hidden" name="bFormSubmitted" value="yes">
	</form>
</cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">
