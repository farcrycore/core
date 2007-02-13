<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/diagTreeNodes.cfm,v 1.18 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.18 $

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

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iCOAPITab eq 1>

	<!--- find orphans --->
	<cfswitch expression="#application.dbtype#">
		<cfcase value="mysql,mysql5">
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
	
	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].diagOrphanNotes#</h3></cfoutput>
	
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
				<cfoutput><h2>#application.adminBundle[session.dmProfile.locale].moveBranchLockout#</h2>
				<p>#application.adminBundle[session.dmProfile.locale].branchLockoutBlurb#</p></cfoutput>
				<cfabort>
			</cfcatch>
		</cftry>
		
	<cfelse>
		<cfoutput>
			<p>#application.adminBundle[session.dmProfile.locale].noParentNestedTreeBlurb#</p>
		</cfoutput>
		
		<cfif qOrphans.recordcount>
			<!--- show orphaned nodes --->
			<cfoutput><p>#application.adminBundle[session.dmProfile.locale].currentOrphanedNodes#</p></cfoutput>
			<!--- <cfdump var="#qOrphans#" label="Orphaned Nodes"> --->
			<!--- show form to attach orphans to a known node --->
			<cfoutput>
			<form action="" method="post" class="f-wrap-1 f-bg-short wider">
			<fieldset>
				<table cellspacing="0">
				<tr>
					<th>&nbsp;</th>
					<!--- 18n: can these be localized?  --->
					<th>#application.adminBundle[session.dmProfile.locale].objID#</th>
					<th>#application.adminBundle[session.dmProfile.locale].parentID#</th>
					<th>#application.adminBundle[session.dmProfile.locale].title#</th>
				</tr>
				<cfloop query="qOrphans">
					<tr class="#IIF(qOrphans.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td><input type="checkbox" class="f-checkbox" name="objectid" value="#objectid#" /></td>
						<td>#objectid#</td>
						<td>#parentid#</td>
						<td>#objectname#</td>
					</tr>
				</cfloop>
				</table>
				<hr />
				<select name="navalias" size="1">
				<cfloop collection="#application.navid#" item="key">
					<option value="#application.navid[key]#"> #key#
				</cfloop>
				</select>
				<input type="submit" name="action" value="Attach Orphans" class="f-submit" />
			</fieldset>
			</form>
			</cfoutput>
		<cfelse>
			<cfoutput>#application.adminBundle[session.dmProfile.locale].noOrphansNow#</cfoutput>
		</cfif>
		
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">