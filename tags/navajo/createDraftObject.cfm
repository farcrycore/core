<cfsetting enablecfoutputonly="no" />
<!--- createDraftObject.cfm 
Creates a draft object
--->

<cfprocessingDirective pageencoding="utf-8" />

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfparam name="url.objectId" default="">
<cfparam name="url.method" default="edit">
<cfparam name="url.ref" default="">
<cfparam name="url.finishurl" default="">

<cfset lWorkflowDefIDs = "" />

<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/navajo/navajo_popup.css">
</cfoutput>

<cfif len(url.objectId)>

	<cfloop list="#url.objectid#" index="thisobjectid">
		<!--- Get this object so we can duplicate it --->
		<q4:contentobjectget objectid="#thisobjectid#" bactiveonly="False" r_stobject="stObject">
		
		<cfif structKeyExists(stObject, "versionID")>
			
			<!--- Check to see if a draft version already exists. If it does... simply use that one. --->
			<cfset qDraftExists = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stObject.objectid,type=stObject.typename)>
			
			<cfif qDraftExists.recordCount>
				<q4:contentobjectget objectid="#qDraftExists.objectid#" r_stobject="stProps">
			<cfelse>
			
				<cfset oType = createobject("component", application.types[stObject.TypeName].typePath) />
				<!--- copy live object content --->
				<cfset stProps = application.coapi.coapiUtilities.createCopy(objectid=thisobjectid) />
				<!--- override those properties unique to DRAFT at start --->
				<cfset stProps.status = "draft" />
				<cfset stProps.versionID = thisobjectid />
				<!--- create the new OBJECT  --->
				<cfset stResult = oType.createData(stProperties=stProps) />
				
				<farcry:logevent object="#url.objectid#" type="types" event="create" notes="Draft object created" />
				
				<!--- //this will copy containers and there rules from live object to draft --->
				<cfset oCon = createobject("component","#application.packagepath#.rules.container") />
				<cfset oCon.copyContainers(stObject.objectid,stProps.objectid) />
			
				<!------------------------------------ 
					IF WORKFLOW DEFINITION EXISTS, REDIRECT BACK TO THE OBJECT OVERVIEW PAGE
				 ------------------------------------>	 
				<cfset lWorkflowDefIDs = createObject("component", application.stcoapi.farWorkflow.packagePath).getWorkflowList(typename="#stObject.Typename#") />
				
				<!--- //this will copy categories from live object to draft --->
				<cfset oCategory = createobject("component","#application.packagepath#.farcry.category") />
				<cfset oCategory.copyCategories(stObject.objectid,stProps.objectid) />
			</cfif>
		</cfif>
	</cfloop>
		
	<cfif listLen(lWorkflowDefIDs) and listlen(url.objectid) eq 1><!--- If there is a workflow and only one object, go to the overview for that object --->
		<cfoutput>
		<script type="text/javascript">
			window.location="#application.url.farcry#/edittabOverview.cfm?objectid=#stObject.objectid#";
		</script>
		</cfoutput>
	<cfelseif listlen(url.objectid) gt 1 and not find(cgi.SCRIPT_NAME,cgi.http_referer)><!--- If there is more than one object and we know the previous page, go there --->
		<cfoutput>
		<script type="text/javascript">
			window.location="#cgi.http_referer#";
		</script>
		</cfoutput>
	<cfelseif listlen(url.objectid) gt 1><!--- If there was more than one object but we don't know where to go, just output a result message --->
		<cfoutput>
			<p class="success">Drafts created: #listlen(url.objectid)#</p>
		</cfoutput>
	<cfelse><!--- If there was one object, just go to edit it --->
		<cfoutput>
		<script type="text/javascript">
			<cfif stProps.status EQ "pending">
				window.location="#application.url.farcry#/edittabOverview.cfm?objectid=#stProps.objectid#";
			<cfelse>
				window.location="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stProps.objectid#&method=#url.method#&ref=#url.ref#&finishurl=#url.finishurl#";
			</cfif>
		</script>
		</cfoutput>
	</cfif>

</cfif>

