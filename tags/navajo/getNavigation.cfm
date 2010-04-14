<cfsetting enablecfoutputonly="Yes">
<!--- import taglibraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<!--- run once only --->
<cfif thistag.executionmode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>

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

<!--- Make sure we have an attributes.objectid --->
<cfset attributes.objectid = stObject.objectid />

<cfscript>
	
	oNav = createObject("component",application.types['dmNavigation'].typepath);
	typename = stObject.typename;

	lObjectIds = '';
	parentNav = '';	
		
	/*if we are trying to find the navigation node a version is in,
	then we need to find the object that this is a version of*/
	if (isDefined("stObject.versionId") and len(stObject.versionId)) {
		attributes.objectId=stObject.versionid;	
		
		/* If a user has extended dmNavigation and added versions to it, then a draft objects navid is its approved version. */
		if (stObject.typename IS "dmNavigation"){
			stObject = oNav.getData(objectid=attributes.objectId);
		}	
	}
	
	
	// MJB Removed check for attributes.bInclusive. 
	if (stObject.typename IS "dmNavigation") //not sure what or why anything would require this - included for legacy support, i suspect its redundant. PH
	{
		parentNav=stObject;		
		lObjectIds=attributes.objectId;
	}
	else	
	{	
		
		q = oNav.getParent(objectid=attributes.objectid);
		if(NOT q.recordcount) 
		{
			 //this condition should never happen. Keeping in for legacy support only.
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