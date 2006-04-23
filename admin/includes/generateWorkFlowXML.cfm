<cfparam name="content_status" default="pending">
<cfparam name="lcontent_type" default="All">
<cfparam name="maxReturnRecords" default="5">
<cfsetting showdebugoutput="false">

<cfif content_status NEQ "">
	<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
	<cfinclude template="/farcry/farcry_core/admin/includes/json.cfm">
	<cfset stForm = StructNew()>
	<cfset stForm.lcontent_type = lcontent_type>
	<cfset stForm.content_status = content_status>
	<cfset stForm.maxReturnRecords = maxReturnRecords>
	<!--- we will filter by user if content_status is 'draft' --->
	<cfif content_status IS 'draft'>
		<cfset stForm.lastupdatedby = session.dmProfile.username>
	</cfif>
	<cfset oWorkflow = createObject("component","#application.packagepath#.farcry.workflow")>
	<cfset returnstruct = structNew()> 
	<cfset returnstruct = oWorkFlow.getObjectsPendingApproval(stForm)>

	<cfset jsonstruct = structNew()>
	<cfset jsonstruct.bsuccess = returnstruct.bSuccess>
	<cfset jsonstruct.message = JSStringFormat(returnstruct.message)>
	<cfset jsonstruct.content_status = JSStringFormat(content_status)>
 	<cfif returnstruct.bSuccess>
		<cfset jsonstruct.aItems = ArrayNew(1)>
		<cfset iCounter = 1>
		<cfloop query="returnstruct.qList">
			<cfset jsonstruct.aItems[iCounter] = StructNew()>
			<cfset jsonstruct.aItems[iCounter]['objectid'] = JSStringFormat(returnstruct.qList.objectid)>
			<cfset jsonstruct.aItems[iCounter]['text'] = JSStringFormat(returnstruct.qList.title)>
			<cfset jsonstruct.aItems[iCounter]['value'] = JSStringFormat(returnstruct.qList.objectid)>
			<cfset jsonstruct.aItems[iCounter]['createdby'] = JSStringFormat(returnstruct.qList.createdby)>
			<cfset jsonstruct.aItems[iCounter]['datetimelastupdated'] = JSStringFormat(DateFormat(returnstruct.qList.datetimelastupdated,"dddd dd mmmm yyyy")& " " & TimeFormat(returnstruct.qList.datetimelastupdated,"full"))>
			<cfset jsonstruct.aItems[iCounter]['createdby_email'] = JSStringFormat(returnstruct.qList.createdby_email)>
			<!--- <cfset jsonstruct.aItems[iCounter]['editurl'] = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#returnstruct.qList.objectid#&typename=#returnstruct.qList.typename#&method=renderobjectoverview"> --->
			
			<cfset jsonstruct.aItems[iCounter]['editurl'] = "#application.url.farcry#/edittabOverview.cfm?objectid=#returnstruct.qList.objectid#">
			
			<cfset iCounter = iCounter + 1>
		</cfloop>
	</cfif>
	<cfcontent type="text/plain"><cfoutput>
	#jsonencode(jsonstruct)#</cfoutput>
</cfif>