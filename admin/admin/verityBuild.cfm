<cfsetting enablecfoutputonly="Yes" requestTimeout="600">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/verityBuild.cfm,v 1.15.2.2 2006/04/26 12:26:03 geoff Exp $
$Author: geoff $
$Date: 2006/04/26 12:26:03 $
$Name: p300_b113 $
$Revision: 1.15.2.2 $

|| DESCRIPTION || 
$Description: Build and update FarCry related Verity collections. Manages 
application specific collections by prefixing applicationname to the 
front of collection names. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<!--- check permissions --->
<cfset iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab")>
<cfif iSearchTab neq 1>
	<admin:header><admin:permissionError><admin:footer>
</cfif>

<cfif structisEmpty(form)>
<!-----------------------------------
FORM VIEW:
------------------------------------->
<!--- get verity collection information for the application --->
<cfscript>
// get Verity config information
oConfig = createObject("component", "#application.packagepath#.farcry.config");
if (NOT isDefined("application.config.verity"))
	application.config.verity = oConfig.getConfig("verity");
// isolate the contenttypes to be indexed
stCollections = duplicate(application.config.verity.contenttype);
</cfscript>		

<!--- get system Verity information ---> 
<cfcollection action="LIST" name="qIndices">
<cfquery dbtype="query" name="qCollections">
SELECT * FROM qIndices
WHERE name LIKE '#application.applicationname#%'
</cfquery>


<admin:header title="#application.adminBundle[session.dmProfile.locale].buildVerityIndices#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>
<h1>#application.adminBundle[session.dmProfile.locale].buildVerityIndices#</h1>
</cfoutput>

<cfform name="veritybuild">
<input type="submit" name="update" value="Update &amp; Build Collections">

<table>
<tr>
	<th>&nbsp;</th>
	<th>Collection</th>
	<th>Properties</th>
	<th>Custom Fields</th>
	<th>File Field</th>
	<th>Built To</th>
	<th>Last Updated</th>
	<th>Doc Count</th>
</tr>
<tr>
	<td colspan="8"><strong>Managed Collections</strong></td>
</tr>
<cfoutput query="qCollections">
<cfset collection=replacenocase(qcollections.name,"#application.applicationname#_","","all")>
<tr>
	<td><input type="checkbox" name="lcollections" id="lcollections" value="#collection#"></td>
	<td>#collection#</td>
	<cfif structkeyexists(stcollections, collection) AND isArray(stcollections[collection].aprops)>
	<td>#arraytolist(stcollections[collection].aprops)#</td>
	<td>#stcollections[collection].custom3#, #stcollections[collection].custom4#</td>
	<!--- todo: remove.. temp repair for incomplete config files --->
	<cfparam name="stcollections[collection].FileCollectionProperty" default="" type="string" />
	<cfparam name="stcollections[collection].builttodate" default="" type="Any" />
	<td>#stcollections[collection].filecollectionproperty#</td>
	<td>#stcollections[collection].builttodate#</td>
	<cfelse>
	<td>-</td>
	<td>-</td>
	<td>-</td>
	<td>-</td>
	</cfif>
	<cfif isDefined("qcollections.lastmodified")>
	<td>#dateformat(qCollections.lastmodified)# #timeformat(qCollections.lastmodified)#</td>
	<cfelse>
	<td>-</td>
	</cfif>
	<cfif isDefined("qcollections.doccount")>
	<td>#qcollections.doccount#</td>
	<cfelse>
	<td>-</td>
	</cfif>
</tr>
<!--- remove key from collection; preps for collections to be built output --->
<cfset structdelete(stcollections, collection)>
</cfoutput>

<!-----------------------------------
Collections To Be Built
------------------------------------->
<cfif NOT structisempty(stcollections)>
	<tr>
		<td colspan="8"><strong>Type Collections To Be Created</strong></td>
	</tr>
	<cfloop collection="#stCollections#" item="key">
	<cfoutput>
	<tr>
		<td>
			<input type="checkbox" name="lcollections" id="lcollections" value="#key#">
			<input type="hidden" name="lcollectionstocreate" id="lcollectionstocreate" value="#key#">
		</td>
		<td>#key#</td>
		<cfif structKeyExists(stCollections[key], "aprops") AND isArray(stcollections[key].aprops)>
		<td>#arraytolist(stcollections[key].aprops)#</td>
		<td>#stcollections[key].custom3#, #stcollections[key].custom4#</td>
		<cfelse>
		<td>-</td>
		<td>-</td>
		</cfif>
		<td>-</td>
		<td>-</td>
	</tr>
	</cfoutput>
	</cfloop>
</cfif>

<!-------------------------------------
Associated File Collections To Be Built
--------------------------------------->
	<tr>
		<td colspan="8"><strong>File Collections To Be Created</strong></td>
	</tr>

<!--- isolate the contenttypes to be indexed --->
<cfset stCollections = duplicate(application.config.verity.contenttype)>
<cfset lcollectionscomplete=valuelist(qCollections.name)>
<cfloop collection="#stcollections#" item="typename">
	<cfparam name="stcollections[typename].filecollectionproperty" default="" type="string" />
	<cfif len(stcollections[typename].filecollectionproperty)
			  AND NOT listfindnocase(lcollectionscomplete,"#application.applicationname#_#typename#_files")>
	<cfoutput>
	<tr>
		<td>
			<input type="checkbox" name="lcollections" id="lcollections" value="#typename#_files">
			<input type="hidden" name="lfilecollectionstocreate" id="lcollectionstocreate" value="#typename#_files">
		</td>
		<td>#typename#_files</td>
		<td>-</td>
		<td>-</td>
		<td>#stcollections[typename].filecollectionproperty#</td>
		<td>-</td>
		<td>-</td>
		<td>-</td>
	</tr>
	</cfoutput>
	</cfif>
</cfloop>

</table>

<input type="submit" name="update" value="Update &amp; Build Collections">
</cfform>

<admin:footer>

<cfelse>
<cfparam name="form.lcollectionstocreate" default="">
<cfparam name="form.lfilecollectionstocreate" default="">
<cfparam name="form.lcollections" default="">


<!-----------------------------------
ACTION:
------------------------------------->
<admin:header title="#application.adminBundle[session.dmProfile.locale].buildVerityIndices#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfoutput>
<h1>#application.adminBundle[session.dmProfile.locale].buildVerityIndices#</h1>
</cfoutput>

	
	<!--- build indices... --->
	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].buildingCollections#</h3></cfoutput>
	
	<cfloop list="#form.lcollectionstocreate#" index="collection">
		<!--- if not, create colection --->
		<cfoutput>
		<ul>
		<li>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].creatingKey,"#collection#")#</li></cfoutput>
		<cfflush />
		<cftry>
			<cfset application.factory.oVerity.buildCollection("#application.applicationname#_#collection#")>
			<cfoutput><li>#application.adminBundle[session.dmProfile.locale].done#</li></cfoutput>
			<cfcatch><cfoutput><li>#application.adminBundle[session.dmProfile.locale].error#</li></cfoutput></cfcatch>
		</cftry>
		<cfoutput></ul></cfoutput>
	</cfloop>

	<cfloop list="#form.lfilecollectionstocreate#" index="collection">
		<!--- if not, create colection --->
		<cfoutput>
		<ul>
		<li>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].creatingKey,"#collection#")#</li></cfoutput>
		<cfflush />
		<cftry>
			<cfset application.factory.oVerity.buildCollection("#application.applicationname#_#collection#")>
			<cfoutput><li>#application.adminBundle[session.dmProfile.locale].done#</li></cfoutput>
			<cfcatch><cfoutput><li>#application.adminBundle[session.dmProfile.locale].error#: #cfcatch.Message#</li></cfoutput></cfcatch>
		</cftry>
		<cfoutput></ul></cfoutput>
	</cfloop>
	
	<!----------------------------- 
		update collections 
	------------------------------>
	<cfset oVerity=createObject("component", "#application.packagepath#.farcry.verity") />
	<cfloop list="#form.lcollections#" index="collection">
		<cfif findnocase("_files",collection)>
			<cfset oVerity.updateFileCollection(collection)>
		<cfelse>
			<cfset oVerity.updateCollection(collection)>
		</cfif>
	</cfloop>
	
	<cfoutput>
	<p><strong class="success fade" id="fader1">#application.adminBundle[session.dmProfile.locale].verityConfigUpdated# #application.adminBundle[session.dmProfile.locale].allDone#</strong></p>
	</cfoutput>

<!--- setup footer --->
<admin:footer>

</cfif>

<cfsetting enablecfoutputonly="no">

