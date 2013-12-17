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
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<!--- include function libraries 
	<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">
	<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
	--->
<cfif isDefined("url.method")>
	<cfset defMethod = url.method>
<cfelse>
	<cfset defMethod = "edit">
</cfif>
<!--- required environment parameters --->
<cfparam name="url.typename" default="" type="string">
<cfparam name="url.objectid" default="#application.fc.utils.createJavaUUID()#" type="string">
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
	<cfset method=form.method>
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
	<cfif structkeyexists(application.rules,typename) AND typename NEQ "container" AND method EQ "edit">
		<cfset method = "update" />
	</cfif>
</cfif>


<skin:view typename="dmHTML" webskin="webtopHeaderModal" />

<!--- 
	check method permissions for this content and user 
	worth noting that additional permission check should exist within the method being invoked
	this step at least provides some blanquet security to protect people from themselves ;)
	--->
<sec:CheckPermission permission="Edit" type="#typename#" objectid="#url.objectid#" error="true" errormessage="You do not have permission to edit this object">
	<!--- get object instance --->
	<cfset oType = createObject("component", PackagePath)>
	<cfif ListLen(url.objectid) GT 1>
		<cfset evaluate("oType.#method#(objectid='#objectid#')")>
	<cfelse>
		<cfset returnStruct = oType.getData(objectid=URL.objectid)>
		
		<!--- determine where the edit handler has been called from to provide the right return url --->
		<cfparam name="url.ref" default="sitetree" type="string">
		<!--- If the type uses workflow, then when we create the object, it needs to go directly to the overview page. --->
		<cfset lWorkflowTypenames = createObject("component", application.stcoapi.farWorkflow.packagepath).getWorkflowList(typename="#typename#") />
		<cfif listLen(lWorkflowTypenames) OR (StructKeyExists(returnStruct, "versionid") AND StructKeyExists(returnStruct, "status") AND ListContains("approved,pending",returnStruct.status) and method neq "copy")>
			<!--- any pending/approve items should go to overview --->
			<cflocation url="#application.url.farcry#/edittabOverview.cfm?typename=#typename#&objectid=#URL.objectid#&ref=#url.ref#">
			<cfabort>
		<cfelse>
			<!--- go to edit --->
			<cfset onExitProcess = StructNew() />
			<cfif url.ref eq "typeadmin" AND (isDefined("url.module") AND Len(url.module))>
				<!--- typeadmin redirect --->
				<cfset onExitProcess.Type = "URL" />
				<cfset onExitProcess.Content = "#application.url.farcry#/admin/customadmin.cfm?module=#url.module#&ref=#url.ref#" />
				<cfif isDefined("URL.plugin")>
					<cfset onExitProcess.Content = onExitProcess.Content & "&plugin=" & url.plugin />
				</cfif>
			<cfelseif url.ref eq "closewin">
				<!--- close win has no official redirector as it closes open window --->
				<cfset onExitProcess.Type = "HTML" />
				<cfsavecontent variable="onExitProcess.Content">
					<cfoutput>
					<script type="text/javascript">
						opener.location.href = opener.location.href;
						window.close();
					</script>
					</cfoutput>
					
				</cfsavecontent>
			<cfelseif url.ref eq "iframe">
				<!--- site tree redirect --->
				<cfset onExitProcess.Type = "HTML" />
				<cfsavecontent variable="onExitProcess.Content">
					<!--- Container don't have a webtopOverview.cfm... just close dialog --->
					<cfif returnStruct.typename eq "container">
						<cfoutput>
							<script type="text/javascript">
								$fc.closeBootstrapModal();
							</script>
						</cfoutput>
					<cfelse>
						<cfoutput>
							<script type="text/javascript">
								location.href = '#application.url.farcry#/edittabOverview.cfm?typename=#typename#&objectid=#returnStruct.ObjectID#&ref=#url.ref#';
							</script>
						</cfoutput>
					</cfif>
				</cfsavecontent>
			<cfelseif url.ref eq "dialogiframe">
				<!--- close the $fc.openDialogIFrame() --->
				<cfset onExitProcess.Type = "HTML" />
				<cfsavecontent variable="onExitProcess.Content">
					<cfoutput>
						<script type="text/javascript">
							$fc.closeBootstrapModal();
						</script>
					</cfoutput>
				</cfsavecontent>
			<cfelseif url.ref eq "refresh">
				<cfset onExitProcess.Type = "HTML" />
				<cfsavecontent variable="onExitProcess.Content">
					<cfoutput>
						<script type="text/javascript">
							if (parent.updateObject)
								parent.updateObject('#returnStruct.objectid#');
						</script>
					</cfoutput>
				</cfsavecontent>
			<cfelseif structKeyExists(url, "dialogID")>
				<cfset onExitProcess.type = "HTML">
				<cfsavecontent variable="onExitProcess.content">
					<cfoutput>
					<script type="text/javascript">
						$fc.closeBootstrapModal();
					</script>
					</cfoutput>
				</cfsavecontent>
			<cfelse>
				<!--- site tree redirect --->
				<cfset onExitProcess.Type = "HTML" />
				<cfsavecontent variable="onExitProcess.Content">
					<cfoutput>
					<script type="text/javascript">
						window.location.href = '#application.url.webtop#/edittabOverview.cfm?typename=#typename#&objectid=#returnStruct.ObjectID#&ref=#url.ref#';
					</script>
					</cfoutput>
				</cfsavecontent>
			</cfif>
			<cfset html = oType.getView(stObject=returnStruct, template="#method#", onExitProcess="#onExitProcess#", alternateHTML="") />
			<cfif len(html)>
				<cfoutput>
					#html#
				</cfoutput>
			<cfelse>
				<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
				<!--- <cfset evaluate("oType.#method#(objectid='#objectid#',onExitProcess=#onExitProcess#)")> --->
				<cfinvoke component="#PackagePath#" method="#method#">
					<cfinvokeargument name="objectId" value="#objectId#" />
					<cfinvokeargument name="onExitProcess" value="#onExitProcess#" />
				</cfinvoke>
			</cfif>
		</cfif>
	</cfif>
</sec:CheckPermission>


<skin:view typename="dmHTML" webskin="webtopFooterModal" />
<cfsetting enablecfoutputonly="No">
