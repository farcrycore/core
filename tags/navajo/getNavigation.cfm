<cfsetting enablecfoutputonly="Yes">
<!--- import taglibraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<cfparam name="attributes.objectId" default="">
<cfparam name="attributes.stObject" default="#structNew()#">
<cfparam name="attributes.r_objectId" default="">
<cfparam name="attributes.r_stObject" default="">
<cfparam name="attributes.bInclusive" default="0">

<cfif isStruct(attributes.stObject) and not structIsEmpty(attributes.stObject)>
	<cfset stObject = attributes.stObject />
<cfelseif len(attributes.objectid)>
	<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stObject">
<cfelse>
	<cfabort showerror="object id must be passed to getNavigation" />
</cfif>

<cfscript>
	/*if we are trying to find the navigation node a version is in,
	then we need to find the object that this is a version of*/
	if (isDefined("stObject.versionId") and len(stObject.versionId))
			attributes.objectId=stObject.versionid;	
	oNav = createObject("component",application.types['dmNavigation'].typepath);
	typename = stObject.typename;
	if (attributes.bInclusive AND stObject.typename IS "dmNavigation") //not sure what or why anything would require this - included for legacy support, i suspect its redundant. PH
	{
		parentNav=stObject;
		lObjectIds=attributes.objectId;
	}
	else	
	{	
		
		q = oNav.getParent(objectid=stObject.objectid);
		if(NOT q.recordcount)  //this condition should never happen. Keeping in for legacy support only.
		{
			lObjectIds = '';
			parentNav = '';	
		}
		else
		{
			lObjectIds = q.parentid;
			if (len(attributes.r_stObject))  //get parent as object if required
				parentNav = oNav.getData(objectid=lObjectIds,dsn=application.dsn);
			
		}	
				
	}
</cfscript>

<cfif len(attributes.r_objectId)>
	<cfset "caller.#attributes.r_objectId#"=lObjectIds>
</cfif>

<cfif len(attributes.r_stObject)>
	<cfset "caller.#attributes.r_stObject#"=parentNav>
</cfif>

<cfsetting enablecfoutputonly="No">