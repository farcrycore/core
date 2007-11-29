<cfsetting enablecfoutputonly="no" />
<!--- createDraftObject.cfm 
Creates a draft object
--->

<cfprocessingDirective pageencoding="utf-8" />

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />

<cfparam name="url.objectId" default="">
<cfparam name="url.method" default="edit">
<cfparam name="url.ref" default="">
<cfparam name="url.finishurl" default="">

<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>

<cfif len(url.objectId)>
	<!--- Get this object so we can duplicate it --->
	<q4:contentobjectget objectid="#url.objectId#" bactiveonly="False" r_stobject="stObject">
	
	<cfset oType = createobject("component", application.types[stObject.TypeName].typePath) />
	<!--- copy live object content --->
	<cfset stProps = application.coapi.coapiUtilities.createCopy(objectid=stObject.objectid) />
	<!--- override those properties unique to DRAFT at start --->
	<cfset stProps.status = "draft" />
	<cfset stProps.versionID = URL.objectID />
	<!--- create the new OBJECT  --->
	<cfset stResult = oType.createData(stProperties=stProps) />
	
	<farcry:logevent object="#url.objectid#" type="types" event="create" notes="Draft object created" />
	
	<!--- //this will copy containers and there rules from live object to draft --->
	<cfset oCon = createobject("component","#application.packagepath#.rules.container") />
	<cfset oCon.copyContainers(stObject.objectid,stProps.objectid) />
	
	<!--- //this will copy categories from live object to draft --->
	<cfset oCategory = createobject("component","#application.packagepath#.farcry.category") />
	<cfset oCategory.copyCategories(stObject.objectid,stProps.objectid) />
		
	<cfoutput>
	<script type="text/javascript">
		window.location="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stProps.objectid#&method=#url.method#&ref=#url.ref#&finishurl=#url.finishurl#";
	</script>
	</cfoutput>
</cfif>

