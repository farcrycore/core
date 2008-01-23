<cfsetting enablecfoutputonly="Yes">
<!--- 
This dumps out an object based on objectid [replacement for edittabDump.cfm]
 --->

<cfparam name="objectid" default="">
<cfparam name="errormessage" default="">

<cfif objectid EQ "">
	<cfset errormessage = errormessage & "Invalid ObjectID">
<cfelse>
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
</cfif>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<sec:CheckPermission error="true" permission="ObjectDumpTab">
	<cfif errormessage NEQ "">
		<cfoutput><p class="error">#errormessage#</p></cfoutput>
	<cfelse>
		<cfdump var="#stObj#" label="#stobj.label#">
	</cfif>
</sec:CheckPermission>

<cfsetting enablecfoutputonly="No">