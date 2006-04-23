<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/overview.cfm,v 1.5.2.1 2004/08/19 06:44:10 brendan Exp $
$Author: brendan $
$Date: 2004/08/19 06:44:10 $
$Name: milestone_2-2-1 $
$Revision: 1.5.2.1 $

|| DESCRIPTION || 
$Description: Displays edit form for category tree $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfoutput><LINK href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css"></cfoutput>

<cfif isDefined("form.submit")>
	<cfquery name="q" datasource="#application.dsn#">
		UPDATE nested_tree_objects
		SET objectname = '#trim(form.objectname)#'
		WHERE objectID = '#url.objectid#'
	</cfquery>
	<cfquery name="q" datasource="#application.dsn#">
		UPDATE #application.dbowner#categories
		SET categoryLabel = '#form.objectname#'
		<cfif isDefined("form.alias")>
			,alias = '#reReplace(form.alias,"\W","","ALL")#'
		</cfif>
		WHERE categoryid = '#url.objectid#'
	</cfquery>	
	<cfscript>
		oCat = createObject("component", "#application.packagepath#.farcry.category");
		application.catid = oCat.getCatAliases();
	</cfscript>
	<script>
			parent.cattreeframe.document.location.reload();
	</script>
</cfif>


<cfif isDefined("url.objectid")>
<!--- 	Techincally this join is not necessary - but up intil b220, the category table
	was not updated when users edited a nodes label, but nested_tree_objects was. This join
	will save any unexpected label changes when editing category nodes. 
 --->	
 	<cfquery name="q" datasource="#application.dsn#">
		SELECT ntm.objectname,cat.alias
		FROM nested_tree_objects ntm,categories cat
		WHERE ntm.objectid = cat.categoryid and ntm.objectID = '#url.objectid#'
	</cfquery>
	<cfoutput>
	<form action="" method="post">
	<table>
		<tr>
			<td>Category Name:</td>
			<td><input name="objectname" type="Text" size="35" value="#q.objectname#"></td>
			<td><input type="Submit" value="Update" name="submit" class="normalbttnstyle"></td>
		</tr>
		<cfset bDev = request.dmsec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer")>
		<cfif bDev EQ 1>
			<td>
				Alias
			</td>
			<td colspan="2">
				<input name="alias" type="Text" size="35" value="#q.alias#">
			</td>
		</cfif>
		
	</table>
	</form>
	</cfoutput>
</cfif>