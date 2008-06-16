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
$Header: /cvs/farcry/core/webtop/admin/diagTreeNodes.cfm,v 1.18 2005/08/17 06:50:52 pottery Exp $
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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
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
				AND parentid NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#ValueList(qOrphansTemp.objectid)#" />)
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
	
	<cfoutput><h3>#application.rb.getResource("diagOrphanNotes")#</h3></cfoutput>
	
	<!--- if requested, attach orphans to navnode in tree --->
	<cfif isDefined("form.objectid")>
	
		<cftry>
		<!--- exclusive lock tree.moveBranch() to prevent corruption --->
		<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
			<cfloop list="#form.objectid#" index="object">
				<cfscript>
					application.factory.oTree.moveBranch(parentid=form.navalias, objectid=object);
				</cfscript>
			</cfloop>
			<cfoutput>#listlen(form.objectid)# nav node orphan<cfif qOrphans.recordCount neq 1>s</cfif> attached to #form.navalias#.</cfoutput>
		</cflock>
			<cfcatch>
				<cfoutput><h2>#application.rb.getResource("moveBranchLockout")#</h2>
				<p>#application.rb.getResource("branchLockoutBlurb")#</p></cfoutput>
				<cfabort>
			</cfcatch>
		</cftry>
		
	<cfelse>
		<cfoutput>
			<p>#application.rb.getResource("noParentNestedTreeBlurb")#</p>
		</cfoutput>
		
		<cfif qOrphans.recordcount>
			<!--- show orphaned nodes --->
			<cfoutput><p>#application.rb.getResource("currentOrphanedNodes")#</p></cfoutput>
			<!--- <cfdump var="#qOrphans#" label="Orphaned Nodes"> --->
			<!--- show form to attach orphans to a known node --->
			<cfoutput>
			<form action="" method="post" class="f-wrap-1 f-bg-short wider">
			<fieldset>
				<table cellspacing="0">
				<tr>
					<th>&nbsp;</th>
					<!--- 18n: can these be localized?  --->
					<th>#application.rb.getResource("objID")#</th>
					<th>#application.rb.getResource("parentID")#</th>
					<th>#application.rb.getResource("title")#</th>
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
			<cfoutput>#application.rb.getResource("noOrphansNow")#</cfoutput>
		</cfif>
		
	</cfif>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">