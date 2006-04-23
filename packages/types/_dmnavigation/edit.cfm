<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmnavigation/edit.cfm,v 1.36 2003/12/08 05:28:38 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:28:38 $
$Name: milestone_2-2-1 $
$Revision: 1.36 $

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
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Saving Changes...<p></p></cfoutput><cfflush>
	
	<!--- perform the update --->
	<cfscript>
		stProperties = structNew();
		stProperties.objectid=stObj.objectId;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.externalLink = form.externalLink;
		stProperties.lNavIDAlias = form.lNavIDAlias;
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
		
		// update the OBJECT	
		this.setData(stProperties=stProperties);
	</cfscript>
		
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
				
		<!--- get current fu --->
		<cfset fuUrl = application.factory.oFU.getFU(objectid=stObj.objectid)>
		
		<!--- check for suffix --->
		<cfif listLen(application.config.fusettings.suffix,"/") gt 0 and not listContains(fuUrl,"objectid")>
			<cfset fuLen = listLen(fuURL,"/") - listLen(application.config.fusettings.suffix,"/")>
		<cfelse>
			<cfset fuLen = listLen(fuURL,"/")>
		</cfif>
		
		<!--- check if new object --->
		<cfif listContains(fuUrl,"objectid")>
			<!--- get ancestors --->
			<cfset qAncestors = request.factory.oTree.getAncestors(objectid=stobj.objectid,bIncludeSelf=false)>
			<!--- remove root & home --->
			<cfquery dbtype="query" name="qCrumb">
				SELECT objectName FROM qAncestors
				WHERE nLevel >= 2
				ORDER BY nLevel
			</cfquery>				
			<!--- join titles together --->
			<cfset breadCrumb = valueList(qCrumb.objectname)>
			<!--- change delimiter --->
			<cfset breadCrumb = listChangeDelims(breadCrumb,"/",",")>				
			<!--- append new title --->
			<cfset breadCrumb = listAppend(breadCrumb,form.title,"/")>				
			
			<!--- set new fu --->
			<cfset fuUrl = application.config.fusettings.urlpattern&breadcrumb&application.config.fusettings.suffix>
			<!--- set fu --->
			<cfset application.factory.oFU.setFU(objectid=stobj.objectid,alias=lcase(fuUrl))>
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
						<!--- get ancestors --->
						<cfset qAncestors = request.factory.oTree.getAncestors(objectid=qGetDescendants.objectid,bIncludeSelf=true)>
						<!--- remove root & home --->
						<cfquery dbtype="query" name="qCrumb">
							SELECT objectName FROM qAncestors
							WHERE nLevel >= 2
							ORDER BY nLevel
						</cfquery>
						<!--- join titles together --->
						<cfset breadCrumb = valueList(qCrumb.objectname)>
						<!--- change delimiter --->
						<cfset breadCrumb = listChangeDelims(breadCrumb,"/",",")>
						<!--- set new fu for descendant --->
						<cfset newFu = application.config.fusettings.urlpattern&breadcrumb&application.config.fusettings.suffix>
						<!--- set fu for descendant --->
						<cfset application.factory.oFU.setFU(objectid=qGetDescendants.objectid,alias=lcase(newFu))>
					<cfelse>
						<!--- delete current fu for descendant --->
						<cfset application.factory.oFU.deleteFu(descfuUrl)>
						<!--- work out new fu for descendant  --->
						<cfset newfu = listSetAt(descfuUrl,fuLen,form.title,"/")>
						<!--- set new fu  for descendant --->
						<cfset application.factory.oFU.setFu(objectid=qGetDescendants.objectid,alias=lcase(newfu))>
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- work out new fu for actual object--->
			<cfset newfu = listSetAt(fuUrl,fuLen,form.title,"/")>
			<!--- set fu for actual object --->
			<cfset application.factory.oFU.setFU(objectid=stobj.objectid,alias=lcase(newfu))>
		</cfif> 
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
								<cfset aNavalias = listToArray(listSort(structKeyList(application.navid),'textnocase'))>
								<cfloop from="1" to="#arraylen(aNavalias)#" index="i">
								<cfset key=aNavalias[i]>
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