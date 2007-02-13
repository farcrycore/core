<cfsetting enablecfoutputonly="Yes">
<!--- 
This dumps out an object based on objectid [replacement for edittabDump.cfm]
 --->

<cfparam name="objectid" default="">
<cfparam name="errormessage" default="">

<cfif objectid EQ "">
	<cfset errormessage = errormessage & "Invalid ObjectID">
<cfelse>
	<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
</cfif>

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfset bPermission_DumpObject = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectDumpTab")>

<cfsetting enablecfoutputonly="No">
<!--- setup page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfif bPermission_DumpObject>
	<cfif errormessage NEQ ""><cfoutput>
<p class="error">#errormessage#</p></cfoutput>
	<cfelse>
		<cfdump var="#stObj#">
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>
<!--- setup page footer --->
<admin:footer>
