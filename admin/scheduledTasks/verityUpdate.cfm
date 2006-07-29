++<!--- @@displayname: Verity Update --->

<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/scheduledTasks/verityUpdate.cfm,v 1.5.2.1 2006/03/27 06:22:34 jason Exp $
$Author: jason $
$Date: 2006/03/27 06:22:34 $
$Name: milestone_3-0-1 $
$Revision: 1.5.2.1 $

|| DESCRIPTION ||
$Description: Build and update FarCry related Verity collections. Manages
application specific collections by prefixing applicationname to the
front of collection names. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="Yes" requestTimeout="600">

<cfprocessingDirective pageencoding="utf-8">

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
<cfoutput><span class="FormTitle">#application.adminBundle[application.config.general.locale].buildingCollections#</span><p></p></cfoutput>

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
			<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString(application.adminBundle[application.config.general.locale].creatingKey,"#key#")#<br></cfoutput>
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

			<cfoutput>
			<span class="frameMenuBullet">&raquo;</span> 
			<cfset subS=listToArray('#q.recordCount#,#key#,#arrayToList(application.config.verity.contenttype[key].aprops)#')>
			#application.rb.formatRBString(application.adminBundle[application.config.general.locale].updatingRecsFor,subS)#
			<br>
			</cfoutput>
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

			<cfoutput>
			<span class="frameMenuBullet">&raquo;</span> 
			<cfset subS=listToArray('#q.recordCount#, #key#, #arrayToList(application.config.verity.contenttype[key].aprops)#')>
			#application.rb.formatRBString(application.adminBundle[application.config.general.locale].purgingDeadRecsFor,subS)#
			<p>
			</cfoutput>
			<cfflush />

			<cfloop query="q">
				<cfindex action="DELETE" collection="#application.applicationname#_#key#" query="q" key="objectid">
			</cfloop>
			
		<!--- final catchall to ensure any deleted items are also removed from archive --->
		<cfquery datasource="#application.dsn#" name="qDelete">
		SELECT DISTINCT archiveID AS objectid
		FROM         dmArchive
		WHERE     (archiveID NOT IN
                          (SELECT     objectid
                            FROM          refObjects))
		</cfquery>
		
		<cflock name="verity" timeout="60">
			<cfindex 
				collection="#arguments.collection#" 
		    	action="delete"
				type="custom"
				query="qDelete"
    			key="objectid">
		</cflock>

				

		<cfelse>
			<cfif len(application.config.verity.contenttype[key].aprops.uncPath)>
				<!--- build filter list --->
				<cfif listlen(application.config.verity.contenttype[key].aprops.fileTypes)>
					<cfset filter= application.config.verity.contenttype[key].aprops.fileTypes>
				<cfelse>
					<cfset filter= ".*">
				</cfif>

				<cfoutput>
				<span class="frameMenuBullet">&raquo;</span> 
				<cfset subS=listToArray('#key#, #application.config.verity.contenttype[key].aprops.uncPath#')>
				#application.rb.formatRBString(application.adminBundle[application.config.general.locale].updatingKey,subS)#
				<p></cfoutput>
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
<p>#application.adminBundle[application.config.general.locale].verityConfigUpdated#</p>
<p>#application.adminBundle[application.config.general.locale].allDone#</p>
</cfoutput>

