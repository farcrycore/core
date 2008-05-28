<!--- @@displayname: Verity Update --->
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/scheduledTasks/verityUpdate.cfm,v 1.5.2.1 2006/03/27 06:22:34 jason Exp $
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
<cfoutput><span class="FormTitle">#application.rb.getResource("buildingCollections")#</span><p></p></cfoutput>

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
			<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString("creatingKey","#key#")#<br></cfoutput>
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
			#application.rb.formatRBString("updatingRecsFor",subS)#
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
			#application.rb.formatRBString("purgingDeadRecsFor",subS)#
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
				collection="#application.applicationname#_#key#" 
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
				#application.rb.formatRBString("updatingKey",subS)#
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
<p>#application.rb.getResource("verityConfigUpdated")#</p>
<p>#application.rb.getResource("allDone")#</p>
</cfoutput>

