<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/overview.cfm,v 1.7 2004/08/19 06:43:13 brendan Exp $
$Author: brendan $
$Date: 2004/08/19 06:43:13 $
$Name: milestone_2-3-2 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Displays edit form for category tree $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

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
 	<cftry>	
 	<cfquery name="q" datasource="#application.dsn#">
		SELECT ntm.objectname,cat.alias
		FROM nested_tree_objects ntm, categories cat
		WHERE ntm.objectid = cat.categoryid and ntm.objectID = '#url.objectid#'
	</cfquery>
	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
	</cftry>
	<cfoutput>
	<form action="" method="post">
	<table>
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].categoryName#</td>
			<td><input name="objectname" type="Text" size="35" value="#q.objectname#"></td>
			<td><input type="Submit" value="#application.adminBundle[session.dmProfile.locale].update#" name="submit" class="normalbttnstyle"></td>
		</tr>
		<cfset bDev = request.dmsec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer")>
		<cfif bDev EQ 1>
			<td>
				#application.adminBundle[session.dmProfile.locale].alias#
			</td>
			<td colspan="2">
				<input name="alias" type="Text" size="35" value="#q.alias#">
			</td>
		</cfif>
		
	</table>
	</form>
	</cfoutput>
</cfif>