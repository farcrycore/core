<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/overview.cfm,v 1.2 2003/05/16 01:47:32 brendan Exp $
$Author: brendan $
$Date: 2003/05/16 01:47:32 $
$Name: b131 $
$Revision: 1.2 $

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
	<script>
			parent.cattreeframe.document.location.reload();
	</script>

</cfif>


<cfif isDefined("url.objectid")>
	<cfquery name="q" datasource="#application.dsn#">
		SELECT objectname FROM nested_tree_objects WHERE objectID = '#url.objectid#'
	</cfquery>
	<cfoutput>
	<form action="" method="post">
	<table>
		<tr>
			<td>Category Name:</td>
			<td><input name="objectname" type="Text" value="#q.objectname#"></td>
			<td><input type="Submit" value="Update" name="submit" class="normalbttnstyle"></td>
		</tr>
	</table>
	</form>
	</cfoutput>
</cfif>