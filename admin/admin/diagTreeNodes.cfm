<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/diagTreeNodes.cfm,v 1.14 2003/12/08 05:28:38 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:28:38 $
$Name: milestone_2-1-2 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: Looks for orphaned nodes in the nested tree table and they gives option to attach them to nav node in tree$
$TODO: Only working for dmNavigation items at the moment$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- set long timeout for template to prevent data-corruption on incomplete tree.moveBranch() --->
<cfsetting enablecfoutputonly="Yes" requesttimeout="90">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iCOAPITab eq 1>

	<!--- find orphans --->
	<cfswitch expression="#application.dbtype#">
		<cfcase value="mysql">
			<cfquery datasource="#application.dsn#" name="qOrphansTemp">
				SELECT objectid FROM #application.dbowner#nested_tree_objects
			</cfquery>
			
			<cfquery datasource="#application.dsn#" name="qOrphans">
				SELECT * FROM #application.dbowner#nested_tree_objects
				WHERE
				typename = 'dmNavigation'
				AND     objectid <> '#application.navid.root#'
				AND parentid NOT IN (#quotedValueList(qOrphansTemp.objectid)#)
				and parentid is not null
			</cfquery>
		</cfcase>
		
		<cfdefaultcase>
			<cfquery datasource="#application.dsn#" name="qOrphans">
				SELECT * FROM #application.dbowner#Nested_Tree_Objects
				WHERE
				typename = 'dmNavigation'
				AND     objectid <> '#application.navid.root#'
				AND parentid NOT IN (select objectid from Nested_Tree_Objects)
				and parentid is not null
			</cfquery>
		</cfdefaultcase>
	</cfswitch>
	
	<cfoutput><span class="formtitle">Diagnostics :: Orphaned Nodes</span><p></p></cfoutput>
	
	<!--- if requested, attach orphans to navnode in tree --->
	<cfif isDefined("form.objectid")>
	
		<cftry>
		<!--- exclusive lock tree.moveBranch() to prevent corruption --->
		<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
			<cfloop list="#form.objectid#" index="object">
				<cfscript>
					request.factory.oTree.moveBranch(parentid=form.navalias, objectid=object);
				</cfscript>
			</cfloop>
			<cfoutput>#listlen(form.objectid)# nav node orphan<cfif qOrphans.recordCount neq 1>s</cfif> attached to #form.navalias#.</cfoutput>
		</cflock>
			<cfcatch>
				<h2>moveBranch Lockout</h2>
				<p>Another editor is currently modifying the hierarchy.  Please refresh the site overview tree and try again.</p>
				<cfabort>
			</cfcatch>
		</cftry>
		
	<cfelse>
		<cfoutput>
			Use this function if your nested tree ever gets objects with no parents.
	        It will give all your orphaned objects parents again. 
			You may want to make a backup of your database before fixing the tree. 
			<p></p>
		</cfoutput>
		
		<cfif qOrphans.recordcount>
			<!--- show orphaned nodes --->
			<cfoutput>Current Orphaned Nodes:<p></p></cfoutput>
			<!--- <cfdump var="#qOrphans#" label="Orphaned Nodes"> --->
			<!--- show form to attach orphans to a known node --->
			<cfoutput><p></p>
			<form action="" method="post">
				<table cellpadding="5" cellspacing="0" border="1">
				<tr class="dataheader">
					<td>&nbsp;</td>
					<td align="center"><strong>Object ID</strong></td>
					<td align="center"><strong>Parent ID</strong></td>
					<td align="center"><strong>Title</strong></td>
				</tr>
				<cfloop query="qOrphans">
					<tr class="#IIF(qOrphans.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td><input type="checkbox" name="objectid" value="#objectid#"></td>
						<td>#objectid#</td>
						<td>#parentid#</td>
						<td>#objectname#</td>
					</tr>
				</cfloop>
				</table>
				<p></p>
				<select name="navalias" size="1">
				<cfloop collection="#application.navid#" item="key">
					<option value="#application.navid[key]#"> #key#
				</cfloop>
				</select>
				<input type="submit" name="action" value="Attach Orphans">
			</form>
			</cfoutput>
		<cfelse>
			<cfoutput>There are no orphans at the moment.</cfoutput>
		</cfif>
		
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">