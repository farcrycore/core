<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Internet 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- This tag determines the correct location for the application.cfm of the project for which the webtop or library is related to. $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: url -- the url portion that we are searching for in the script_name. eg. /farcry or /plugin $
--->


<cfif thistag.executionMode eq "Start">
	<cfif not isDefined("attributes.plugin")>
		<cfabort showerror="attributes.URL not passed correctly." />
	</cfif>

	<cfset scriptName = cgi.SCRIPT_NAME />
	
	<cfset pos = findNoCase("/#attributes.plugin#/", scriptName) />
	
	<cfif pos GT 1>
		<cfset projectName = mid(scriptName, 1, pos - 1) />
		<cfset loc = trim("/farcry/projects/#projectName#/www/Application.cfm") />
	<cfelse>
		<cfset loc = "/Application.cfm" />
	</cfif>
	
	<cftry>
		<cfinclude template="#loc#">
		
		<cfcatch type="missinginclude">
			<cfthrow type="Application" message="Could not find project application." detail="Check that your mappings are correctly setup.">	
		</cfcatch>
	
	</cftry>

</cfif>

<!---
<cfif thistag.executionMode eq "End">

</cfif> --->

<cfsetting enablecfoutputonly="no">


