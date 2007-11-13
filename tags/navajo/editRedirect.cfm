<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

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
	<cfscript>
		iObjectCreatePermission = application.security.checkPermission(permission="Edit",object=permObjectID);
	</cfscript>

<cfelse>
	<cfscript>
		iObjectCreatePermission = application.security.checkPermission(permission="RootNodeManagement");
	</cfscript>
</cfif>

<cfif structCount(stObj) and iObjectCreatePermission>

<cfoutput>
	<script>
	window.location='#application.url.farcry#/Navajo/edit.cfm?objectId=#url.objectID#&usingnavajo=1&type=#typename#';
	</script>
</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="No">