<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfparam name="attributes.objectId">
<cfparam name="attributes.r_objectId" default="">
<cfparam name="attributes.r_stObject" default="">
<cfparam name="attributes.bInclusive" default="0">

<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObject">

<cfscript>
	typename = stObject.typename;
</cfscript>

<cfif attributes.bInclusive and stObject.typename IS "dmNavigation">
	<cfset parentNav=stObject>
	<cfset lObjectIds=attributes.objectId>
<cfelse>

	<!--- if we are trying to find the navigation node a version is in,
		then we need to find the object that this is a version of --->
	<cfif isDefined("stObject.versionId") and len(stObject.versionId)>
		<cfset attributes.objectId=stObject.versionid>
	</cfif>
	
	<!--- loop over parents 'till we hit a navigation node --->
	<cfset isNav=0>
	<cfset parentId=attributes.objectId>
	<q4:contentobjectGetMultiple bActive="0" lObjectIds="#attributes.ObjectId#" r_stObjects="stType">
	<cfloop condition="isNav neq -1">
		<nj:treeGetRelations 
			typename="#stType[attributes.objectID].typename#"
			objectId="#parentId#"
			get="parents"
			r_lObjectIds="lObjectIds"
			r_stObjects="parentNav"
			bInclusive="1">
			
	
		<!--- something is really wrong if we have gone up more than 20 nodes looking for the nav parent --->
		<cfif isNav gte 20><cfthrow errorcode="navajo" message="possible infinite loop condition in getParent"></cfif>
		
		<cfif not isStruct( parentNav ) OR structIsEmpty( parentNav )><cfset isNav=-2><cfbreak></cfif>
		<cfscript>
			typename = parentNav[lObjectIds].typename;
		</cfscript>
		<!--- <cfdump var="#parentNav#"> --->
		<cfif parentNav[lObjectIds].typename IS "dmNavigation">
			<cfset isNav=-1>
		<cfelse>
			<cfset parentId = lObjectIds>
		</cfif>
	</cfloop>
	
	<cfif isNav neq -2>
		<cfset parentNav=parentNav[lObjectIds]>
	<cfelse>
		<cfset parentNav="">
		<cfset lObjectIds="">
	</cfif>
</cfif>

<cfif len(attributes.r_objectId)>
	<cfset "caller.#attributes.r_objectId#"=lObjectIds>
</cfif>

<cfif len(attributes.r_stObject)>
	<cfset "caller.#attributes.r_stObject#"=parentNav>
</cfif>

<cfsetting enablecfoutputonly="No">