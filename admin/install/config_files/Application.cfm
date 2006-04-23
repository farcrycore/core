<cfsetting enablecfoutputonly="Yes">

<cfapplication name="farcry_pliant" sessionmanagement="Yes" sessiontimeout="#createTimeSpan(0,1,0,0)#">

<!--- Application Initialise --->
<cfif NOT IsDefined("application.bInit") OR IsDefined("url.updateapp")>
	<!--- Project Specific Initialisation --->
	<cfinclude template="../config/_applicationInit.cfm">
	<!--- Farcry Core Initialisation --->
	<cfinclude template="/farcry/farcry_core/tags/farcry/_farcryApplicationInit.cfm">
	<!--- $TODO: must have project vars set AFTER core vars! GB$ --->
</cfif>

<!--- general application code --->
<cfinclude template="/farcry/farcry_core/tags/farcry/_farcryApplication.cfm">

<cfsetting enablecfoutputonly="no">