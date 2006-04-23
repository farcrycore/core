<cfsetting enablecfoutputonly="yes">
<!--- 
Central template for admin object invocation
 - midway refactoring

invocation n.
   1. The act or an instance of invoking, especially an appeal to a higher power for assistance.
   2. A prayer or other formula used in invoking, as at the opening of a religious service.
   3.    a. The act of conjuring up a spirit by incantation.
         b. An incantation used in conjuring.

Pseudo:
 - check enough paramters passed in to execute
 - check permissions
 - run method
 - content locking should be managed in the individual edit method as required (general change from 2.3)
 - versioning (should this be managed in content type also?)
 --->
<cfprocessingDirective pageencoding="utf-8">
<!--- include tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- include function libraries 
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
--->

<cfif isDefined("url.method")>
	<cfset defMethod = url.method>
<cfelse>
	<cfset defMethod = "edit">
</cfif>

<!--- required environment parameters --->
<cfparam name="url.typename" default="" type="string">

<cfif structIsEmpty(form)>
	<cfparam name="url.objectid" type="string">
	<cfparam name="url.method" default="#variables.defMethod#" type="string">
	
	<cfset typename=url.typename>
	<cfset objectid=url.objectid>
	<cfset method=url.method>
<cfelse>
	<!--- note: some forms carry url and form params --->
	<cfparam name="form.typename" default="#url.typename#" type="string">
	<cfparam name="form.objectid" default="#url.objectid#" type="string">
	<cfparam name="form.method" default="#variables.defMethod#" type="string">
	
	<cfset typename=form.typename>
	<cfset objectid=form.objectid>
	<cfset method=form.method>
</cfif>

<!--- auto-typename lookup if required --->
<cfif NOT len(typename)>
	<cfset q4 = createObject("component", "farcry.fourq.fourq")>
	<cfset typename = q4.findType(objectid=url.objectid)>
	<!--- stop now if we can't get typename --->
	<cfif NOT len(typename)>
		<cfabort showerror="<strong>Error:</strong> TYPENAME cannot be found for OBJECTID (objectid).">
	</cfif>
</cfif>

<!--- 
	check method permissions for this content and user 
	worth noting that additional permission check should exist within the method being invoked
	this step at least provides some blanquet security to protect people from themselves ;)
--->
<cfif structKeyExists(application.types[typename], "BUSEINTREE") AND application.types[typename].BUSEINTREE>
	<!--- determine inherited tree based permissions --->
	<cfset bHasPermission = request.dmsec.oAuthorisation.checkInheritedPermission(permissionName='edit',objectid=URL.objectid)>
	<cfif NOT bHasPermission GTE 0>
		<cfabort showerror="<strong>Error:</strong> #application.adminBundle[session.dmProfile.locale].noEditPermissions#">
	</cfif>
<cfelse>
	<!--- determine standard permissions for typename --->
	<!--- 
		TODO: 	Nice in theory but current permission sets do not relate to permissionset/method
				perhaps we could match types.cfc methods to current permissionset syntax and define
				as a bonafide standard.
				Currently works well for EDIT which is the only requirement at present.
		 --->
	<cfif structKeyExists(application.types[typename], "permissionset")>
		<!--- grab permission set from component metadata --->
		<cfset permissionset=application.types[typename].permissionset>
	<cfelse>
		<!--- if no permission set specified default to news --->
		<cfset permissionset="news">
		<cftrace category="permissions" type="warning" text="No permission set specified for #typename#. Default permission set NEWS applied.">
		<!--- TODO: should really log this somewhere as a warning --->
	</cfif>
	<cfset bHasPermission = request.dmsec.oAuthorisation.checkPermission(permissionName="#permissionset##method#",reference="PolicyGroup")>
	<cfif NOT bHasPermission GTE 0>
		<cfabort showerror="<strong>Error:</strong> #application.adminBundle[session.dmProfile.locale].noEditPermissions#">
	</cfif>
</cfif>

<!--- get object instance --->
<cfset oType = createObject("component", application.types[typename].typePath)>
<cfset returnStruct = oType.getData(objectid=URL.objectid)>

<cfif StructKeyExists(returnStruct, "versionid") AND StructKeyExists(returnStruct, "status") AND ListContains("approved,pending",returnStruct.status)>
	<!--- any pending/approve items should go to overview --->
	<cflocation url="#application.url.farcry#/edittaboverview.cfm?objectid=#URL.objectid#">
	<cfabort>
<cfelse>
	<!--- go to edit --->
<admin:header>
	<cfset evaluate("oType.#method#(objectid='#objectid#')")>
<admin:footer>
</cfif>

<cfsetting enablecfoutputonly="No">
