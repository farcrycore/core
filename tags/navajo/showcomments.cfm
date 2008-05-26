<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Lists comments attached to specified object --->

<cfimport taglib="/farcry/core/packages/fourq/tags" prefix="q4" />

<cfparam name="attributes.objectid" />
<cfparam name="attributes.typename" default="#application.coapi.coapiadmin.findtype(objectid=attributes.objectid)#" />

<cfif thistag.ExecutionMode eq "start">
	<cfset qComments = createobject("component",application.stCOAPI.farLog.packagepath).filterLog(objectid=attributes.objectid,event='comment,topending,toapproved,todraft') />
	
	<cfset oType = createobject("component",application.stCOAPI[attributes.typename].packagepath) />
	<cfset oProfile = createobject("component",application.stCOAPI['dmProfile'].packagepath) />
	
	<cfif qComments.recordcount>
		<cfoutput><dl class="logsummary"></cfoutput>
		
		<cfloop query="qComments">
			<cfset stObj = oType.getData(objectid=qComments.object) />
			<cfset stProfile = oProfile.getProfile(username=qComments.userid) />
			
			<cfoutput><dt></cfoutput>
			
			<cfif listlen(attributes.objectid) gt 1>
				<cfoutput>#stObj.label# </cfoutput>
			</cfif>
			
			<cfoutput>#dateformat(qComments.datetimecreated,"yyyy-mm-dd")# #timeformat(qComments.datetimecreated,"hh:mm tt")# - #qComments.event# </cfoutput>
			
			<cfif len(stProfile.firstname) or len(stProfile.lastname)>
				<cfoutput>(#stProfile.firstname# #stProfile.lastname#)</dt></cfoutput>
			<cfelse>
				<cfoutput>(#listfirst(qComments.userid,'_')#)</dt></cfoutput>
			</cfif>
			
			<cfif len(qComments.notes)>
				<cfoutput><dd>#qComments.notes#</dd></cfoutput>
			</cfif>
		</cfloop>
		
		<cfoutput></dl></cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />