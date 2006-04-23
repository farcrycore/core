<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/verityOptimise.cfm,v 1.9 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Optimise all Verity collections for the active application. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
</cfscript>

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header title="#application.adminBundle[session.dmProfile.locale].buildVerityIndices#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSearchTab eq 1>
	<!--------------------------------------------------------------------
	Optimisation Routine For CFMX 
	--------------------------------------------------------------------->
	<cfoutput><span class="FormTitle">Optimising Collections</span><p></p></cfoutput>
	
	<!--- get system Verity information ---> 
	<cfcollection action="LIST" name="qcollections">
	
	<!--- optimising collections --->
	<h3>Optimising Collections</h3>
	<cfloop query="qCollections">
		<cfif findNoCase(application.applicationname, qCollections.name)>
			<cftry>
				<cfset application.factory.oVerity.optimiseCollection(qCollections.name)>
				<cfoutput>#qCollections.name#: #application.adminBundle[session.dmProfile.locale].optimized#...<br></cfoutput>
				<cfcatch><cfoutput>#qCollections.name#: #application.adminBundle[session.dmProfile.locale].errorOptimizing#<br></cfoutput></cfcatch>
			</cftry>
			<cfflush>
		</cfif>
	</cfloop>
	
	<cfoutput><p>#application.adminBundle[session.dmProfile.locale].allDone#</p></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">
