<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmInclude/edit.cfm,v 1.11 2003/07/15 07:04:15 brendan Exp $
$Author: brendan $
$Date: 2003/07/15 07:04:15 $
$Name: b131 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: edit handler$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	
	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.teaser = form.teaser;
		stProperties.include = form.include;
		stProperties.displayMethod = form.displayMethod;
		//TODO MUST sort out this date stuff. Can't just keep overwriting datetime created
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	</cfscript>

	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmInclude"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<!--- get parent to update tree --->	
	<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	
	<!--- update tree --->
	<nj:updateTree objectId="#parentID#">
	
	<!--- reload overview page --->
	<cfoutput>
		<script language="JavaScript">
			parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>
	
<cfelse> <!--- Show the form --->
	<cfoutput>
	<br>
	<span class="FormTitle">#stObj.title#</span><p></p>

	
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table class="FormTable">
	<tr>
  		<td><span class="FormLabel">Title:</span></td>
   	 	<td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	<cfinvoke component="#application.packagepath#.types.dmInclude" method="getIncludes" returnvariable="qGetIncludes"/>
 	<tr>	
		<td><span class="FormLabel">Include:</span></td>
   		<td width="100%" class="FormLabel">
		</cfoutput>
			<cfif qGetIncludes.recordCount>
			<cfoutput><select name="include"></cfoutput>
			<cfoutput query="qGetIncludes">
				<option value="#include#" <cfif qGetIncludes.include eq stObj.include>SELECTED</cfif>>#include#</option>
			</cfoutput>
			</select>
			<cfelse>
				<cfoutput>NO INCLUDE FILES AVAILABLE</cfoutput>
			</cfif>
			<cfoutput>
		</td>
	</tr>
	<nj:listTemplates typename="dmInclude" prefix="display" r_qMethods="qMethods">
	<tr>
		<td nowrap class="FormLabel">Display Method:</td>
		<td width="100%" class="FormLabel">
		<select name="DisplayMethod" size="1">
		</cfoutput>
		<cfoutput query="qMethods">
		<option value="#qMethods.methodname#" <cfif qMethods.methodname eq stObj.displaymethod>SELECTED</cfif>>#qMethods.displayname#</option>
		</cfoutput>
		<cfoutput>
		</select>
		</td>
	</tr>	
	
	<tr>
  		<td valign="top"><span class="FormLabel">Teaser:</span></td>
	   	<td>
			<textarea cols="30" rows="4" name="teaser" class="FormTextArea">#stObj.teaser#</textarea>
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
		</td>
	</tr>		
	</table>
	
	</form>
	<script>
		//bring focus to title
		document.fileForm.title.focus();
	</script>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">