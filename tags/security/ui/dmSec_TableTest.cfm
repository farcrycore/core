<cfsetting enablecfoutputonly="Yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_TableTest.cfm,v 1.2 2003/04/17 06:11:33 brendan Exp $
$Author: brendan $
$Date: 2003/04/17 06:11:33 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: tests Security tables$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Matt Dawson (mad@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfparam name="attributes.table">
<cfparam name="attributes.fields">
<cfparam name="attributes.datasource">

<cfset hadErrors=0>

<cfset dmTableName="#application.dbowner##attributes.table#">
<cfset dmTableFields="#attributes.fields#">
<cftry>
	<cfquery name="testTable" datasource="#attributes.datasource#" dbtype="ODBC">
		SELECT #dmTableFields# FROM #dmTableName#
	</cfquery>
<cfcatch type="Database">
	<cfoutput><span style="color:red;">Error:</span> Error occured whilst trying to access the #dmTableName# table.<br>
	The error was: #cfcatch.message#
	<cfif cfcatch.message contains 'S0002'>The #dmTableName# table is not defined.<br></cfif>

	<cfif cfcatch.message contains 'S0022'>This is probably caused by an incorrect table definition.<br>
	One or more of the following fields is missing: #dmTableFields#.<br>
	</cfif>
	</cfoutput>
	<cfset hadErrors=1>
</cfcatch>
</cftry>

<cfif hadErrors eq 0>
	<cfoutput><span style="color:green;">OK:</span> Table #dmTableName# is correctly setup.<br></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="No">