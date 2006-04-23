<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmnavigation/edit.cfm,v 1.26 2003/07/18 05:44:54 paul Exp $
$Author: paul $
$Date: 2003/07/18 05:44:54 $
$Name: b131 $
$Revision: 1.26 $

|| DESCRIPTION || 
$Description: Navigation node edit method. Displays edit form and updates object on submission. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4"> 
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
	
</cfoutput>

<cfif isDefined("FORM.submit")> 
	<!--- perform the update --->
	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.externalLink = form.externalLink;
		stProperties.lNavIDAlias = form.lNavIDAlias;
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	</cfscript>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Saving Changes...<p></p></cfoutput><cfflush>
	
	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmNavigation"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Tree...<p></p></cfoutput><cfflush>
	<cfquery datasource="#application.dsn#">
		UPDATE #application.dbowner#nested_tree_objects 
		SET objectName = '#FORM.title#'
		WHERE objectID = '#stObj.ObjectID#'
	</cfquery>
	
	<!--- get parent to update tree	 --->
	<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<!--- update fu --->
	<cfif application.config.plugins.fu>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Friendly URLs...<p></p></cfoutput><cfflush>
		<cfobject component="#application.packagepath#.farcry.fu" name="fu">
		<cfobject component="#application.packagepath#.farcry.tree" name="tree">
		
		<!--- get current fu --->
		<cfset fuUrl = fu.getFU(objectid=stObj.objectid)>
		
		<!--- check if new object --->
		<cfif listContains(fuUrl,"objectid")>
			<!--- get descendants --->
			<cfset qAncestors = tree.getAncestors(objectid=stobj.objectid,bIncludeSelf=false)>
			<!--- remove root & home --->
			<cfquery dbtype="query" name="qCrumb">
				SELECT objectName FROM qAncestors
				WHERE nLevel >= 2
				ORDER BY nLevel
			</cfquery>				
			<!--- join titles together --->
			<cfset breadCrumb = lcase(valueList(qCrumb.objectname))>				
			<!--- change delimiter --->
			<cfset breadCrumb = listChangeDelims(breadCrumb,"/",",")>				
			<!--- append new title --->
			<cfset breadCrumb = listAppend(breadCrumb,form.title,"/")>				
			
			<!--- set new fu --->
			<cfset fuUrl = application.config.fusettings.urlpattern&breadcrumb>
		<cfelse>
			<!--- delete current fu --->
			<cfset fu.deleteFu(fuUrl)>
			<!--- get descendants --->
			<cfset qGetDescendants = tree.getDescendants(objectid=stObj.objectID)>
			<cfif qGetDescendants.recordCount>
				<cfloop query="qGetDescendants">
					<!--- get current fu --->
					<cfset descfuUrl = fu.getFU(objectid=objectid)>
					<!--- delete current fu --->
					<cfset fu.deleteFu(descfuUrl)>
					<!--- work out new fu --->
					<cfset newfu = listSetAt(descfuUrl,listLen(fuURL,"/"),form.title,"/")>
						
					<!--- set new fu --->
					<cfset fu.setFu(key=cgi.server_name & descfuUrl,objectid=objectid,alias=newfu)>
				</cfloop>
			</cfif>
		</cfif> 
		
		<!--- work out new fu --->
		<cfset newfu = listSetAt(fuUrl,listLen(fuURL,"/"),form.title,"/")>
		
		<!--- set fu --->
		<cfset fu.setFU(objectid=stobj.objectid,alias=newfu)>
	</cfif>
	
	
	<!--- Finally update Navids --->
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating Application Navids...<p></p></cfoutput><cfflush>
	<cfscript>
	application.navid = getNavAlias();
	</cfscript>
	
	<!--- reload overview page --->
	<cfoutput>
		<script language="JavaScript">
			parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>

<cfelse> 
	<!--- Show the form --->
	<cfoutput>
	<form action="#CGI.script_name#?#CGI.query_string#" method="post" name="editform">
	<br>
		<table class="FormTable">
			<tr>
				<td colspan="2" align="center"><span class="FormSubHeading">Navigation Node details</span></td>
			</tr>
			<tr>
				<td colspan="2">
					
					<!--- title --->
					<div class="FormTableClear" style="margin-bottom:0px;">
						<table width="100%">
						<tr>
							<td><span class="FormLabel">Title:</span></td>
							<td width="100%"><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
						</tr>
						</table>
					</div>
					
					<!--- extra details (hidden initially) --->
					<div class="FormTableClear" style="margin-top:0px;margin-bottom:0px">
						<display:OpenLayer width="100%" title="Advanced Options" isClosed="Yes" border="no">
						<table width="100%">
						<tr>
							<td><span class="FormLabel">Symbolic Link:</span></td>
							<td>
								<select name="externalLink">
									<option value="">-- None --
								<!--- loop over navid structure in memory -- populated on application init --->
								<cfset aNavalias = StructSort(application.navid, "textnocase", "ASC")>
								<cfloop from="1" to="#arraylen(aNavalias)#" index="i">
								<cfset key=aNavalias[i]>
								<!--- do not show root nav alias as already set above after permission check --->
								<cfif key neq "root">
									<option value="#application.navid[key]#" <cfif stObj.externalLink eq application.navid[key]>selected</cfif>>#key#</option>
								</cfif>
								
								</cfloop>
								</select>
							</td>
						</tr>
						<tr valign="top">
							<td nowrap><span class="FormLabel">Nav Aliases:</span></td>
							<td nowrap><input type="text" name="lNavIDAlias" value="#stObj.lNavIDAlias#" class="FormTextBox"></td>
						</tr>
						</table>
						</display:OpenLayer>
					</div>
					
					<!--- submit buttons --->
					<div class="FormTableClear" style="margin-top:0px;">
						<table width="100%">
						<tr>
							<td colspan="2" align="center">
								<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
								<input type="button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
								
							</td>
						</tr>
						</table>
					</div>
					
				</td>
			</tr>
		</table>
	</form>
	<script>
		//bring focus to title
		document.editform.title.focus();
	</script>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">