<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

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
		oAuthorisation = request.dmSec.oAuthorisation;
		iObjectCreatePermission = oAuthorisation.checkInheritedPermission(permissionName="Edit",objectID=permObjectID,bThrowOnError=1);
	</cfscript>

<cfelse>
	<cfscript>
		oAuthorisation = request.dmSec.oAuthorisation;
		iObjectCreatePermission = oAuthorisation.checkPermission(permissionName="RootNodeManagement",reference="PolicyGroup",bThrowOnError=1);
	</cfscript>
</cfif>

<cfif structCount(stObj)>

<cfoutput>
	<script>
	window.location='#application.url.farcry#/Navajo/edit.cfm?objectId=#url.objectID#&usingnavajo=1&type=#typename#';
	</script>
</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="No">