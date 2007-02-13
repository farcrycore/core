<cfprocessingDirective pageencoding="utf-8">

<cfsetting enablecfoutputonly="true" showdebugoutput="false">

<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
<cfset resultmsg = "#application.adminBundle[session.dmProfile.locale].liveObjRestoredOK#">
<cftry>
	<!--- check permissions on objects nav parent --->
	<cfset bEdit = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#URL.navid#",permissionName="edit")>

	<!--- Get draft object --->
	<cfif bEdit>
		<q4:contentobjectget objectId="#URL.objectId#" r_stObject="stObj">

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
	</cfif>

	<cfcatch>
		<!--- do nothing --->
		<cfset resultmsg = '#application.adminBundle[session.dmProfile.locale].draftObjRestoreFailed#'>
	</cfcatch>
</cftry>

<!--- Need to try and delete the PLP if it exists - relies on people sticking to this naming convention though so not rock solid. --->
<cftry>
	<cffile action="DELETE" file="#application.path.plpstorage#/#session.dmSec.authentication.userlogin#_#stObj.objectID#.plp">
	<cfcatch><!--- dont do anything ---></cfcatch>
</cftry>

<cfinclude template="/farcry/farcry_core/admin/includes/json.cfm">
<cfsetting enablecfoutputonly="false">
<cfcontent type="text/plain"><cfoutput>
#jsonencode(resultmsg)#</cfoutput>