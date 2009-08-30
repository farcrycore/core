<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: library summary --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfparam name="url.property" type="string" />

<!--- DETERMINE METADATA --->
<cfif stobj.typename EQ "farFilterProperty">
	<cfset stFilter = application.fapi.getContentObject(objectid="#stobj.filterID#", typename="farFilter") />
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stFilter.filterTypename#", property="#stobj.property#") />
<cfelse>
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
</cfif>

<!--- DETERMINE THE SELECTED ITEMS --->
<cfif isWDDX(stobj.wddxDefinition)>
	<cfwddx	action="wddx2cfml" 
		input="#stobj.wddxDefinition#" 
		output="stProps" />
<cfelse>
	<cfset stProps = structNew() />
</cfif>
<cfparam name="stProps.relatedTo" default="">

<cfif isArray(stProps.relatedTo)>
	<cfset lSelected = arrayToList(stProps.relatedTo) />
<cfelse>
	<cfset lSelected = stProps.relatedTo />
</cfif>


<cfoutput><p>#listLen(lSelected)# items selected.</p></cfoutput>


<cfsetting enablecfoutputonly="false">