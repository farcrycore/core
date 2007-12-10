<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

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

<cfif structCount(stObj)>
	<sec:CheckPermission generalpermission="RootNodeManagement" typepermission="Edit" type="#typename#" objectpermission="Edit" objectid="#permObjectID#">
		<cfoutput>
			<script>
			window.location='#application.url.farcry#/Navajo/edit.cfm?objectId=#url.objectID#&usingnavajo=1&type=#typename#';
			</script>
		</cfoutput>
	</sec:CheckPermission>
</cfif>

<cfsetting enablecfoutputonly="No">