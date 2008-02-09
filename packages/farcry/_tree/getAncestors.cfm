<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/getAncestors.cfm,v 1.15.2.1 2006/02/24 04:50:20 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/24 04:50:20 $
$Name: milestone_3-0-1 $
$Revision: 1.15.2.1 $

|| DESCRIPTION || 
$Description: getAncestors Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">


	<!--- 
	/*sql = "select nlevel, parentid from nested_tree_objects 
	where objectid  = '#arguments.objectid#'";*/
	 --->
	
	<cfset qNode = getNode(objectid=arguments.objectid,dsn=arguments.dsn) />
	<cfif qNode.recordCount EQ 1 AND isDefined('qNode.nlevel')>
		<cfset rowindex=1 />
		<cfset parentID = qNode.parentID />	
		<cfset nlev = qNode.nlevel />
		<!--- //new query object to hold the parentIDs of ancestors --->
		<cfset qParentIDs = queryNew('parentID') />
		<cfset queryAddRow(qParentIDs,1) />
		<cfset querySetCell(qParentIDs,"parentID",parentID,rowindex) />
		<cfif len(qParentIDs.parentID[1])>
			<cfset objID = qParentIDs.parentID[1] />
		</cfif>	
		<cfloop condition="nLev GT 0">
				
					
			<cfquery datasource="#arguments.dsn#" name="q">
			select parentid from #arguments.dbowner#nested_tree_objects where objectid = '#objID#'
			</cfquery>

			<cfif q.recordCount EQ 1>
				<cfset rowindex = rowindex + 1 />
				<cfset queryAddRow(qParentIDs,1) />
				<cfset querySetCell(qParentIDs,'parentID',q.parentID,rowindex) />
			</cfif>	
			<cfset nLev = nLev - 1 />
			<cfset objID = q.parentID />
		</cfloop>

		<cfquery datasource="#arguments.dsn#" name="ancestors">
		select objectid, objectname, nlevel 
		from #arguments.dbowner#nested_tree_objects 
		where objectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#ValueList(qParentIDs.parentID)#" />)
		<cfif isdefined("arguments.nLevel") and isNumeric(arguments.nLevel)>
			and nLevel = #arguments.nLevel#
		</cfif>
		</cfquery>
	<cfelse> 
		<cfset ancestors = queryNew("objectid, objectname, nlevel") />'
	</cfif>

<cfif arguments.bIncludeSelf>
	<cfquery datasource="#arguments.dsn#" name="qSelf">
	SELECT nlevel, objectid, objectname FROM #application.dbowner#nested_tree_objects
	WHERE objectid = '#arguments.objectid#'
	</cfquery>
	<cfif qSelf.recordCount>
		<cfset queryAddRow(ancestors, 1)>
		<cfset querySetCell(ancestors, "nlevel", qSelf.nlevel)>
		<cfset querySetCell(ancestors, "objectid", qSelf.objectid)>
		<cfset querySetCell(ancestors, "objectname", qSelf.objectname)>
	</cfif>
</cfif>	

<!--- reorder, to put this at the front of the query --->
<cfquery dbtype="query" name="q">
SELECT * FROM ancestors
ORDER BY nlevel
</cfquery> 

<cfset ancestors = q>

<!--- set return variable --->
<cfset qReturn=ancestors>

<cfsetting enablecfoutputonly="no">