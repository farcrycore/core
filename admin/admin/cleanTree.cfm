<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/cleanTree.cfm,v 1.4 2003/12/08 05:22:18 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:22:18 $
$Name: milestone_2-1-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: tree cleaner. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes" requesttimeout="600">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iCOAPITab eq 1>	
	<cfif IsDefined("form.submit")><!--- process the form --->
	    <cfparam name="form.debug" default="0"><!--- if they ask for debug, this is overwritten--->
	    
		<!--- set up return query --->
		<cfset qRogue = queryNew("objectid,data,typename,removeFrom")>
		
		<!--- get tree data --->
		<cfset qTree = request.factory.oTree.getDescendants(objectid=application.navid.root)>
		
		<cffunction name="checkRogue">
			<cfargument name="typename" default="dmNavigation">
			<cfargument name="objectid" type="uuid">
			<cfset var qAssoc = "">
			
			<!--- check for associated objects --->
			<cfquery name="qAssoc" datasource="#application.dsn#">
				select type.data, type.objectid, ref.typename
				from #arguments.typename#_aObjectIDs type, refObjects ref
				where type.objectid = '#arguments.objectid#'
					AND ref.objectid = type.data
			</cfquery>	
			
			<cfif qAssoc.recordcount>
				<cfloop query="qAssoc">
					<!--- check associated object exists --->
					<cfquery name="qCheck" datasource="#application.dsn#">
						select objectid
						from #qAssoc.typename#
						where objectid = '#qAssoc.data#'
					</cfquery>
					
					<!--- add rogue objects to query object --->
					<cfif not qCheck.recordcount>
						<cfset queryAddRow(qRogue, 1)>
						<cfset querySetCell(qRogue, "objectid", qAssoc.objectid)>
						<cfset querySetCell(qRogue, "data", qAssoc.data)>
						<cfset querySetCell(qRogue, "typename", qAssoc.typename)>
						<cfset querySetCell(qRogue, "removeFrom", "#arguments.typename#_aObjectIds")>
					</cfif>		
						
					<!--- check if associated object has associated objects --->
					<cfif structKeyExists(application.types[qAssoc.typename].stProps,"aObjectIds")>
						<!--- check for associated objects --->
						<cfset checkRogue(objectid=qAssoc.data,typename=qAssoc.typename)>
					</cfif>
				</cfloop>
			</cfif>
		</cffunction>
		
		<!--- loop over tree --->
		<cfloop query="qTree">
			<!--- check for associated objects --->
			<cfset checkRogue(objectid=qTree.objectid)>
		</cfloop>
			
		<cfif form.debug eq 1>
			<!--- show debug only, don't fix tree --->
			<cfoutput>
			<div class="formtitle">Debug Complete</div>
	        These are the objects that would be removed if run out of debug mode:<p></cfoutput>
	       	
			<cfif qRogue.recordcount>
				<!--- show dump --->
	        	<cfdump var="#qRogue#" label="Rogue objects in tree"> 
				<cfoutput>
				<form action="cleanTree.cfm" method="post">
		            <input type="submit" name="submit" value="Remove these objects">
		        </form>
				</cfoutput>
			<cfelse>
				<!--- no rogue objects --->
				<cfoutput>There are no rogue objects in your tree</cfoutput>
			</cfif>	
	    <cfelse>                
		   	<!--- delete rogue objects --->
			<cfloop query="qRogue">
				<cfquery name="qCheck" datasource="#application.dsn#">
					delete
					from #qRogue.removeFrom#
					where objectid = '#qRogue.objectid#'
					and data = '#qRogue.data#'
				</cfquery>
			</cfloop>
	        <cfoutput>
			<div class="formtitle">Tree fixed</div>
			Rogue tree data has been removed.</cfoutput>
	    </cfif>
	<cfelse>
		<!--- show the form --->
	    <cfoutput>
	        <div class="formtitle">Clean a nested tree</div>
	        Use this function if your nested tree ever gets corrupted data.
	        It loops through all tree nodes and looks for associated objects that may no longer exist and removes them. 
			You may want to make a backup of your database before fixing the tree. 
			Please be patient, this process can take a few minutes!<p></p>
			
	        <form action="cleanTree.cfm" method="post">
	            <input type="checkbox" name="debug" value="1" checked>show debug only (don't fix the table)<p>
	            <input type="submit" name="submit" value="submit">
	        </form>
	    </cfoutput>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">