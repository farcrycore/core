<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/verityBuild.cfm,v 1.14 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: Build and update FarCry related Verity collections. Manages 
application specific collections by prefixing applicationname to the 
front of collection names. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfsetting enablecfoutputonly="Yes" requestTimeout="600">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
</cfscript>

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header title="#application.adminBundle[session.dmProfile.locale].buildVerityIndices#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSearchTab eq 1>
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
	<cfoutput><span class="FormTitle">#application.adminBundle[session.dmProfile.locale].buildingCollections#</span><p></p></cfoutput>
	
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
				<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].creatingKey,"#key#")#</cfoutput>
				<cfflush />
				<cftry>
					<cfset application.factory.oVerity.buildCollection("#application.applicationname#_#key#")>
					<cfoutput>#application.adminBundle[session.dmProfile.locale].done#<br></cfoutput>
					<cfcatch><cfoutput>#application.adminBundle[session.dmProfile.locale].error#<br></cfoutput></cfcatch>
				</cftry>
				
				<!--- clear lastupdated, if it exists --->
				<cfset structDelete(stCollections[key], "lastupdated")>
			</cfif>
			
			<!--- update collection --->
			<cfset application.factory.oVerity.updateCollection(key)>
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
	<p>#application.adminBundle[session.dmProfile.locale].verityConfigUpdated#</p>
	<p>#application.adminBundle[session.dmProfile.locale].allDone#</p>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">

