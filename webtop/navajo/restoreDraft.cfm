<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfset resultmsg = "#application.rb.getResource("liveObjRestoredOK")#">
<cftry>
	<!--- Get draft object --->
	<q4:contentobjectget objectId="#URL.objectId#" r_stObject="stObj">

	<sec:CheckPermission permission="Edit" type="#stObj.typename#" objectid="#url.objectid#" error="true" errormessage="'You do not have permission to edit this object'">
	
		<!--- get live object --->
		<cfif structKeyExists(stObj,'versionID') AND len(trim(stObj.versionID)) EQ 35>
			<q4:contentobjectget objectId="#stObj.versionid#" r_stObject="stLiveObj">			
			<cfset lExcludeKeys = 'objectid,versionid,datetimecreated,createdby,datetimelastupdated,lastupdatedby,lockedBy,locked,status'>
			<cfloop item="key" collection="#stObj#">
				<cfif NOT listFindNoCase(lExcludeKeys,key)>
					<cfset stObj[key] = stLiveObj[key]>
				<cfelseif key NEQ "objectID">
					<cfset structDelete(stObj,key)>
				</cfif>
			</cfloop>			
			<cfset stObj.datetimelastupdated = createODBCDateTime(now())>
			<cfset o = createObject('component',application.types[stobj.typename].typepath)>
			<cfset o.setData(stProperties=stObj,auditNote='Live object data restored to draft',bAudit=true)>
		</cfif>
		
		<!--- Need to try and delete the PLP if it exists - relies on people sticking to this naming convention though so not rock solid. --->
		<cftry>
			<cffile action="DELETE" file="#application.path.plpstorage#/#application.security.getCurrentUserID()#_#stObj.objectID#.plp">
			<cfcatch><!--- dont do anything ---></cfcatch>
		</cftry>
	
	</sec:CheckPermission>

	<cfcatch>
		<!--- do nothing --->
		<cfoutput>'#application.rb.getResource("draftObjRestoreFailed")#'</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />