<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabArchive.cfm,v 1.7 2003/09/11 01:26:52 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 01:26:52 $
$Name: b201 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: shows archived objects $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- check permissions --->
<cfscript>
	iArchiveTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectArchiveTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iArchiveTab eq 1>
	<br>
	<span class="FormTitle">Archive</span>
	<p></p>
	
	<!--- check if rollback is required --->
	<cfif isdefined("url.archiveid")>
		<cfinvoke component="#application.packagepath#.farcry.versioning" method="rollbackArchive" objectID="#url.objectid#" archiveId="#url.archiveid#" returnvariable="stRollback">
	</cfif>
	
	<!--- get archives --->
	<cfinvoke 
	 component="#application.packagepath#.farcry.versioning"
	 method="getArchives"
	 returnvariable="getArchivesRet">
		<cfinvokeargument name="objectID" value="#url.objectid#"/>
	</cfinvoke>
	
	<p></p>
	<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
	<cfif getArchivesRet.recordcount gt 0>
		<!--- setup table --->
		<tr>
			<td align="center"><strong>Date</strong></td>
			<td align="center"><strong>Label</strong></td>
			<td align="center"><strong>User</strong></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<!--- loop over archives --->
		<cfoutput query="getArchivesRet">
		<tr>
			<td>#dateformat(DATETIMELASTUPDATED, "dd-mmm-yyyy")# #timeformat(DATETIMELASTUPDATED)#</td>
			<td>#label#</td>
			<td>#lastupdatedby#</td>
			<td><a href="edittabArchiveDetail.cfm?archiveid=#objectid#">More Detail</a></td>
			<td>
				<a href="edittabArchive.cfm?objectid=#url.objectid#&archiveid=#objectid#">Rollback</a>
				<!--- check if archive has been rolled back successfully --->
				<cfif isdefined("url.archiveid") and stRollback.result and url.archiveId eq objectid>
					<span style="color:Red">Successfully Rolled Back</span>
				</cfif>
			</td>
		</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="5">No archive recorded.</td>
		</tr>
	</cfif>
	</table>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>