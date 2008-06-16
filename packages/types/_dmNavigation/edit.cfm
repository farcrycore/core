<cfsetting enablecfoutputonly="yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmnavigation/edit.cfm,v 1.46.2.1 2006/03/21 05:03:26 jason Exp $
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

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4"> 
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

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
					<cfset qGetDescendants = application.factory.oTree.getDescendants(objectid=stObj.objectID)>
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
<h3>#application.rb.getResource("navigationNodeDetails")#: <span class="highlight">#stObj.title#</span></h3>
<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p><br />
</cfif>
	<label for="title"><b>#application.rb.getResource("titleLabel")#<span class="req">*</span></b>
		<input type="text" name="title" id="title" value="#title#" maxlength="255" size="45" /><br />
	</label>

	<label for="externalLink"><b>#application.rb.getResource("symbolicLinkLabel")#</b>
		<select name="externalLink">
			<option value=""<cfif externalLink EQ "">selected="selected"</cfif>>#application.rb.getResource("noneForSelect")#</option><cfloop from="1" to="#arraylen(aNavalias)#" index="i">
			<option value="#application.navid[aNavalias[i]]#"<cfif externalLink EQ application.navid[aNavalias[i]]>selected="selected"</cfif>>#aNavalias[i]#</option></cfloop>
		</select>
	</label><br />

	<label for="lNavIDAlias"><b>#application.rb.getResource("navAliases")#</b>
		<input type="text" name="lNavIDAlias" id="lNavIDAlias" value="#lNavIDAlias#" maxlength="255" size="45" /><br />
	</label><br />
	
	<label for="fu"><b>Friendly URL:</b>
		<input type="text" name="fu" id="fu" value="#fu#" maxlength="255" size="45" /><br />
	</label><br />

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
	objForm.title.validateNotNull("#application.rb.getResource("pleaseEnterTitle")#");
</script>
</cfoutput>
