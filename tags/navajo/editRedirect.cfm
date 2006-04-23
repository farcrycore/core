<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags" prefix="q4">
<cfimport taglib="/farcry/tags/navajo" prefix="nj">

<q4:contentobjectget objectid="#url.objectID#" r_stobject="stObj">
<!--- Futzing the typeid here --->
<cfscript>
	typename = stObj.typename;
</cfscript>

<cfif NOT stObj.typename IS "dmNavigation">
	<nj:getNavigation objectId="#stObj.objectId#" r_ObjectId="permObjectId">
<cfelse>
	<cfset permObjectId=stObj.objectId>
</cfif>

<cfif len(permObjectId)>

<cf_dmSec2_PermissionCheck
	permissionName="Edit"
	objectid="#permObjectId#"
	bThrowOnError="1"
	reference1="dmNavigation">
<cfelse>
<cf_dmSec2_PermissionCheck
	permissionName="RootNodeManagement"
	reference1="PolicyGroup"
	bThrowOnError="1"
>
</cfif>

<cfif structCount(stObj)>

<cfoutput>
	<script>
	window.location='#application.url.farcry#/Navajo/edit.cfm?objectId=#url.objectID#&usingnavajo=1&type=#typename#';
	</script>
</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="No">