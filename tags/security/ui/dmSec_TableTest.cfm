<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_TableTest.cfm,v 1.3 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

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
	<cfoutput>
	<cfif cfcatch.message contains 'S0002'>
		<cfset subS=listToArray('#dmTableName#,#cfcatch.message#,#dmTableFields#')>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].errorS0002,subS)#
		<br>
	</cfif>

	<cfif cfcatch.message contains 'S0022'>
		<cfset subS=listToArray('#dmTableName#,#cfcatch.message#,#dmTableFields#')>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].errorS0022,subS)#
		<br>
	</cfif>
	</cfoutput>
	<cfset hadErrors=1>
</cfcatch>
</cftry>

<cfif hadErrors eq 0>
	<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].tableSetupOK,"#dmTableName#")#<br></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="No">