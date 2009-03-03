<cfsetting enablecfoutputonly="Yes">
<!--- 
This dumps out an object based on objectid [replacement for edittabDump.cfm]
 --->

<cfparam name="objectid" default="">
<cfparam name="errormessage" default="">

<cfparam name="url.typename" default="" />

<cfif objectid EQ "">
	<cfset errormessage = errormessage & "Invalid ObjectID">
<cfelse>
	<cfset stObj = application.fapi.getContentObject(typename="#url.typename#", objectid="#url.objectid#") />
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