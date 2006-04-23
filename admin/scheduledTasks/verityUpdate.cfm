<!--- @@displayname: Verity Update --->

<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/scheduledTasks/verityUpdate.cfm,v 1.3 2003/11/05 00:03:17 brendan Exp $
$Author: brendan $
$Date: 2003/11/05 00:03:17 $
$Name: milestone_2-1-2 $
$Revision: 1.3 $

|| DESCRIPTION ||
$Description: Build and update FarCry related Verity collections. Manages
application specific collections by prefixing applicationname to the
front of collection names. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="Yes" requestTimeout="600">

<cfscript>
// get Verity config information
oConfig = createObject("component", "#application.packagepath#.farcry.config");
if (NOT isDefined("application.config.verity"))
	application.config.verity = oConfig.getConfig("verity");
// isolate the contenttypes to be indexed
stCollections = application.config.verity.contenttype;
</cfscript>

<!--- get system Verity information --->
<cfcollection action="LIST" name="qcollections">
<cfset stVerity=structNew()>
<cfloop query="qCollections">
	<cfscript>
	stTmp=structNew();
	stTmp.name=qCollections.name;
	stTmp.path=qCollections.path;
	stTmp.collection=qCollections.name;
	structInsert(stVerity, qCollections.name, stTmp);
	</cfscript>
</cfloop>

<!--- build indices... --->
<cfoutput><span class="FormTitle">Building Collections</span><p></p></cfoutput>

<!--- Empty aIndices Array --->
<cfset aIndices = ArrayNew(1)>

<cfloop collection="#stCollections#" item="key">

		<!--- work out correct case for type --->
		<cfloop collection="#application.types#" item="typeName">
			<cfif typeName eq key>
				<cfset key = typeName>
			</cfif>
		</cfloop>

		<!--- work out collection type --->
		<cfif isArray(application.config.verity.contenttype[key].aprops)>
			<cfset collectionType = "type">
		<cfelse>
			<cfset collectionType = "file">
		</cfif>

		<!---
		does the collection exist?
		 - all collections are prefixed with application.applicationname
		--->
		<cfif NOT structKeyExists(stVerity, "#application.applicationname#_#key#")>
			<!--- if not, create colection --->
			<cfoutput><span class="frameMenuBullet">&raquo;</span> Creating <strong>#key#</strong>...<br></cfoutput>
			<cfflush />
			<cfcollection action="CREATE" collection="#application.applicationname#_#key#" path="#application.config.general.verityStoragePath#" language="English">
			<!--- clear lastupdated, if it exists --->
			<cfset structDelete(stCollections[key], "lastupdated")>
		</cfif>

		<!--- check collection type --->
		<cfif collectionType eq "type">
			<!--- build index from type table --->
			<cfquery datasource="#application.dsn#" name="q">
				SELECT *
				FROM #key#
				WHERE 1 = 1
				<cfif structKeyExists(stCollections[key], "lastupdated")>
					AND datetimelastupdated > #stCollections[key].lastupdated#
				</cfif>
				<cfif structKeyExists(application.types[key].stProps, "status")>
					AND upper(status) = 'APPROVED'
				</cfif>
			</cfquery>

			<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating #q.recordCount# records for #key#...(#arrayToList(application.config.verity.contenttype[key].aprops)#)<br></cfoutput>
			<cfflush />

			<!--- update collection --->
			<cfindex action="UPDATE" query="q" body="#arrayToList(application.config.verity.contenttype[key].aprops)#" custom1="#key#" key="objectid" title="label" collection="#application.applicationname#_#key#">

			<!--- remove any objects that may have been sent back to draft or pending --->
			<cfquery datasource="#application.dsn#" name="q">
				SELECT objectid
				FROM #key#
				WHERE 1 = 1
				<cfif structKeyExists(stCollections[key], "lastupdated")>
					AND datetimelastupdated > #stCollections[key].lastupdated#
				</cfif>
				<cfif structKeyExists(application.types[key].stProps, "status")>
					AND upper(status) IN ('DRAFT','PENDING')
				</cfif>
			</cfquery>

			<cfoutput><span class="frameMenuBullet">&raquo;</span> Purging #q.recordCount# dead records for #key#...(#arrayToList(application.config.verity.contenttype[key].aprops)#)<p></cfoutput>
			<cfflush />

			<cfloop query="q">
				<cfindex action="DELETE" collection="#application.applicationname#_#key#" query="q" key="objectid">
			</cfloop>

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

		<!--- update config file with lastupdated --->
		<cfset stCollections[key].lastupdated = now()>
		<cfset ArrayAppend(aIndices,application.applicationname&"_"&key)>
</cfloop>

<cfscript>
	// update in-memory cache
	application.config.verity.contenttype = stCollections;
	application.config.verity.aIndices = aIndices;
	// update config entry in the database
	oConfig.setConfig(configName="verity",stConfig=application.config.verity);
</cfscript>

<cfoutput>
<p>Verity config updated.</p>
<p>All done.</p>
</cfoutput>

