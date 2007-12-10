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
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- include function libraries 
<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">
--->

<cfif isDefined("url.method")>
	<cfset defMethod = url.method>
<cfelse>
	<cfset defMethod = "edit">
</cfif>

<!--- required environment parameters --->
<cfparam name="url.typename" default="" type="string">
<cfparam name="url.objectid" default="#createuuid()#" type="string">

<cfif structIsEmpty(form)>
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
	<cfset method=form.method>85///7
</cfif>

<!--- auto-typename lookup if required --->
<cfif NOT len(typename)>
	<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
	<cfset typename = q4.findType(objectid=url.objectid)>
	<!--- stop now if we can't get typename --->
	<cfif NOT len(typename)>
		<cfabort showerror="<strong>Error:</strong> TYPENAME cannot be found for OBJECTID (objectid).">
	</cfif>
</cfif>


<cfif structKeyExists(application.stCOAPI, typename)>
	<cfset stPackage = application.stCOAPI[typename] />
	<cfset packagePath = application.stCOAPI[typename].packagepath />
	<cfif structkeyexists(application.rules,typename) and method EQ "edit">
		<cfset method = "update" />
	</cfif>
</cfif>

<admin:header>

<!--- 
	check method permissions for this content and user 
	worth noting that additional permission check should exist within the method being invoked
	this step at least provides some blanquet security to protect people from themselves ;)
--->
<sec:CheckPermission permission="Edit" type="#typename#" objectid="#url.objectid#" error="true" errormessage="You do not have permission to edit this object">
	<!--- get object instance --->
	<cfset oType = createObject("component", PackagePath)>
	<cfif ListLen(url.objectid) GT 1>
		<admin:header>
			<cfset evaluate("oType.#method#(objectid='#objectid#')")>
		<admin:footer> 
	<cfelse>
		<cfset returnStruct = oType.getData(objectid=URL.objectid)>
		<cfif StructKeyExists(returnStruct, "versionid") AND StructKeyExists(returnStruct, "status") AND ListContains("approved,pending",returnStruct.status)>
			<!--- any pending/approve items should go to overview --->
			<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#URL.objectid#">
			<cfabort>
		<cfelse>
			<!--- go to edit --->
	
			<!--- determine where the edit handler has been called from to provide the right return url --->
			<cfparam name="url.ref" default="sitetree" type="string">
			
			<cfset stOnExit = StructNew() />
			<cfif url.ref eq "typeadmin" AND (isDefined("url.module") AND Len(url.module))>
				<!--- typeadmin redirect --->
				<cfset stOnExit.Type = "URL" />
				<cfset stOnExit.Content = "#application.url.farcry#/admin/customadmin.cfm?module=#url.module#" />
				<cfif isDefined("URL.plugin")>
					<cfset stOnExit.Content = stOnExit.Content & "&plugin=" & url.plugin />
				</cfif>
			<cfelseif url.ref eq "closewin"> 
				<!--- close win has no official redirector as it closes open window --->
				<cfset stOnExit.Type = "HTML" />
				<cfsavecontent variable="stOnExit.Content">
					<cfoutput>
					<script type="text/javascript">
						opener.location.href = opener.location.href;
						window.close();
					</script>
					</cfoutput>
				</cfsavecontent>
			<cfelse> 
				<!--- site tree redirect --->
				<cfset stOnExit.Type = "HTML" />
				<cfsavecontent variable="stOnExit.Content">
					<!--- get parent to update tree --->
					<nj:treeGetRelations typename="#returnStruct.typename#" objectId="#returnStruct.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
					<!--- update tree --->
					<nj:updateTree objectId="#parentID#">
					<cfoutput>
					<script type="text/javascript">
						parent['content'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#returnStruct.ObjectID#';
					</script>
					</cfoutput>
				</cfsavecontent>
			</cfif>
							
   			<cfset html = oType.getView(stObject=returnStruct, template="#method#", OnExit="#stOnExit#", alternateHTML="") />
			
			<cfif len(html)>
			    <cfoutput>#html#</cfoutput>
			<cfelse>
				<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
			    <!--- <cfset evaluate("oType.#method#(objectid='#objectid#',OnExit=#stOnExit#)")> --->
			    <cfinvoke component="#PackagePath#" method="#method#">
			        <cfinvokeargument name="objectId" value="#objectId#" />
			        <cfinvokeargument name="onExit" value="#stOnExit#" />
			    </cfinvoke>
			</cfif>
	
		</cfif> 
	</cfif>
</sec:CheckPermission>
	
<admin:footer> 

<cfsetting enablecfoutputonly="No">