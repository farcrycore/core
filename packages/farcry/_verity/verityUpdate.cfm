<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/verityUpdate.cfm,v 1.3 2003/09/24 02:26:55 brendan Exp $
$Author: brendan $
$Date: 2003/09/24 02:26:55 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: updates verity collection$
$TODO: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfset key = replaceNoCase(arguments.collection,"#application.applicationName#_","")>

<!--- check for existing collections with no app data --->
<cfif not structKeyExists(application.config.verity.contenttype,"#key#") and not structKeyExists(application.config.verity.contenttype[key],"lastUpdated")>
	<cfoutput>Please reset you verity config before trying to update.</cfoutput>
<cfelse>			
	<!--- work out collection type --->
	<cfif isArray(application.config.verity.contenttype[key].aprops)>
		<cfset collectionType = "type">
	<cfelse>
		<cfset collectionType = "file">
	</cfif>
	
	<!--- check collection type --->
	<cfif collectionType eq "type">
		<!--- build index from type table --->
		<cfquery datasource="#application.dsn#" name="q">
			SELECT *
			FROM #key#
			WHERE 1 = 1
			<cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated")>
				AND datetimelastupdated > #application.config.verity.contenttype[key].lastupdated#
			</cfif>
			<cfif structKeyExists(application.types[key].stProps, "status")>
				AND upper(status) = 'APPROVED'
			</cfif>
		</cfquery>
		
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating #q.recordCount# records for #key#...(#arrayToList(application.config.verity.contenttype[key].aprops)#)<br></cfoutput>
		<cfflush />
		
		<!--- update collection --->		
		<cfindex action="UPDATE" query="q" body="#arrayToList(application.config.verity.contenttype[key].aprops)#" custom1="#key#" key="objectid" title="label" collection="#application.applicationname#_#key#">
		
		<cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated") and structKeyExists(application.types[key].stProps, "status")>
			<!--- remove any objects that may have been sent back to draft or pending --->
			<cfquery datasource="#application.dsn#" name="q">
				SELECT objectid
				FROM #key#
				WHERE datetimelastupdated > #application.config.verity.contenttype[key].lastupdated#
					AND upper(status) IN ('DRAFT','PENDING')
			</cfquery>
	
			<cfoutput><span class="frameMenuBullet">&raquo;</span> Purging #q.recordCount# dead records for #key#...(#arrayToList(application.config.verity.contenttype[key].aprops)#)<p></cfoutput>
			<cfflush />
			
			<cfloop query="q">
				<cfindex action="DELETE" collection="#application.applicationname#_#key#" query="q" key="objectid">
			</cfloop>
		</cfif>
	
	<cfelse>
		<cfif len(application.config.verity.contenttype[key].aprops.uncPath)>
			<!--- build filter list --->
			<cfif listlen(application.config.verity.contenttype[key].aprops.fileTypes)>
				<cfset filter= application.config.verity.contenttype[key].aprops.fileTypes>
			<cfelse>
				<cfset filter= ".*">
			</cfif>
			
			<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating #key#...(#application.config.verity.contenttype[key].aprops.uncPath#)<p></cfoutput>
			<cfflush />
			
			<cfindex action="UPDATE" type="PATH" key="#application.config.verity.contenttype[key].aprops.uncPath#" collection="#application.applicationname#_#key#" recurse="#application.config.verity.contenttype[key].aprops.recursive#" extensions="#filter#">
		</cfif>
	</cfif>
	
	<!--- reset lastupdated timestamp --->
	<cfset application.config.verity.contenttype[replaceNoCase(arguments.collection,"#application.applicationName#_","")].lastUpdated = now()>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> <strong>#arguments.collection#</strong> updated.<p></p></cfoutput>
</cfif>