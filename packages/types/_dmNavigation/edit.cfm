<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmnavigation/edit.cfm,v 1.46.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.46.2.1 $

|| DESCRIPTION || 
$Description: Navigation node edit method. Displays edit form and updates object on submission. $

$TODO: Needs to be refactored.. definitely must remove direct SQL calls from the method 20050802 GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfparam name="errormessage" default="">
<cfparam name="bFormSubmitted" default="no">
<cfparam name="title" default="">
<cfparam name="externalLink" default="">
<cfparam name="lNavIDAlias" default="">
<cfparam name="fu" default="">

<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4"> 
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">

<!--- editing from site tree --->
<cfset cancelCompleteURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#">

<cfif bFormSubmitted EQ "yes">
	<cfif isDefined("form.cancel")> <!--- cancel --->
		<cflocation url="#cancelCompleteURL#" addtoken="no">
		<cfabort>
	<cfelse> <!--- submit --->
		<cfset stProperties = structNew()>		
		<cfset stProperties.objectid=stObj.objectId>
		<cfset stProperties.title = form.title>
		<cfset stProperties.label = form.title>
		<cfset stProperties.externalLink = form.externalLink>
		<cfset stProperties.lNavIDAlias = form.lNavIDAlias>
		<cfset stProperties.datetimelastupdated = Now()>
		<cfset stProperties.lastupdatedby = session.dmSec.authentication.userlogin>
		<cfset stProperties.fu = form.fu>
		<!--- unlock object --->
		<cfset stProperties.locked = 0>
		<cfset stProperties.lockedBy = "">
		
		<cfif Trim(errormessage) EQ "">
			<!--- update the OBJECT --->
			<cfset oType = createobject("component", application.types.dmNavigation.typePath)>
			<cfset oType.setData(stProperties=stProperties)>			

			<cfif NOT (isdefined("url.ref") AND url.ref eq "typeadmin")> <!--- if not typeadmin edit (from site tree edit) --->
				<!--- get parent to update tree	 --->
				<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
				<!--- update tree --->
				<nj:updateTree objectId="#parentID#">
			</cfif>

			<cfquery datasource="#application.dsn#">
			UPDATE #application.dbowner#nested_tree_objects 
			SET objectName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#title#">
			WHERE objectID = '#stObj.ObjectID#'
			</cfquery>

			<!--- <cfif application.config.plugins.fu>
				<!--- get current fu --->
				<cfset fuUrl = application.factory.oFU.getFU(objectid=stObj.objectid)>

				<!--- check if new object --->
				<cfif not application.factory.oFU.hasFU(objectid=stObj.objectID)>
					<cfset application.factory.oFU.createAndSetFUAlias(objectid=stObj.objectID) />
				<cfelse>
					<!--- delete current fu --->
					<cfset application.factory.oFU.deleteFu(fuUrl)>
					<!--- get descendants --->
					<cfset qGetDescendants = request.factory.oTree.getDescendants(objectid=stObj.objectID)>
					<cfif qGetDescendants.recordCount>
						<cfloop query="qGetDescendants">
							<!--- get current fu --->
							<cfset descfuUrl = application.factory.oFU.getFU(objectid=qGetDescendants.objectid)>
							<!--- check if descendants have fus set --->
							<cfif listContains(descfuUrl,"objectid")>
								<!--- set fu for descendant --->
								<cfset application.factory.oFU.createAndSetFUAlias(objectid=qGetDescendants.objectid)>
							<cfelse>
								<!--- delete current fu for descendant --->
								<cfset application.factory.oFU.deleteFu(descfuUrl)>
								<cfset application.factory.oFU.createAndSetFUAlias(objectid=qGetDescendants.objectid)>
							</cfif>
						</cfloop>
					</cfif>
				
					<!--- set fu for actual object --->
					<cfset application.factory.oFU.createAndSetFUAlias(objectid=stobj.objectid)>
				</cfif>
			</cfif> --->
			<cfset application.navid = getNavAlias()>
<cfoutput><script type="text/javascript">
if(parent['sidebar'].frames['sideTree'])
	parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
parent['content'].location.href = "#cancelCompleteURL#"
</script></cfoutput>
<cfabort>
		</cfif>
	</cfif>
<cfelse>
	<cfset title = stObj.title>
	<cfset externalLink = stObj.externalLink>
	<cfset lNavIDAlias = stObj.lNavIDAlias>
	<cfset fu = stObj.fu>
</cfif>

<cfset aNavalias = listToArray(listSort(structKeyList(application.navid),'textnocase'))>

<cfsetting enablecfoutputonly="no"><cfoutput>

<!--- Show the form --->
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="editform" method="post">
<fieldset>
	<div class="req"><b>*</b>Required</div>
<h3>#application.adminBundle[session.dmProfile.locale].navigationNodeDetails#: <span class="highlight">#stObj.title#</span></h3>
<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p><br />
</cfif>
	<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
		<input type="text" name="title" id="title" value="#title#" maxlength="255" size="45" /><br />
	</label>
	<display:OpenLayer title="#application.adminBundle[session.dmProfile.locale].advancedOptions#" isClosed="Yes" border="no">
	<label for="externalLink"><b>#application.adminBundle[session.dmProfile.locale].symbolicLinkLabel#</b>
		<select name="externalLink">
			<option value=""<cfif externalLink EQ "">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].noneForSelect#</option><cfloop from="1" to="#arraylen(aNavalias)#" index="i">
			<option value="#application.navid[aNavalias[i]]#"<cfif externalLink EQ application.navid[aNavalias[i]]>selected="selected"</cfif>>#aNavalias[i]#</option></cfloop>
		</select>
	</label><br />

	<label for="lNavIDAlias"><b>#application.adminBundle[session.dmProfile.locale].navAliases#</b>
		<input type="text" name="lNavIDAlias" id="lNavIDAlias" value="#lNavIDAlias#" maxlength="255" size="45" /><br />
	</label><br />
	
	<label for="fu"><b>Friendly URL:</b>
		<input type="text" name="fu" id="fu" value="#fu#" maxlength="255" size="45" /><br />
	</label><br />
	</display:OpenLayer>
</fieldset>
	<div class="f-submit-wrap">
	<input type="submit" name="submit" value="OK" class="f-submit" />
	<input type="submit" name="cancel" value="Cancel" class="f-submit" />
	</div>
	<input type="hidden" name="bFormSubmitted" value="yes">
</form>

<script type="text/javascript">
	//bring focus to title
	document.editform.title.focus();
	qFormAPI.errorColor="##cc6633";
	objForm = new qForm("editform");
	objForm.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
</script>
</cfoutput>
