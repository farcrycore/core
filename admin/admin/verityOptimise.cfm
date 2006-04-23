<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/verityOptimise.cfm,v 1.8 2003/09/24 02:26:55 brendan Exp $
$Author: brendan $
$Date: 2003/09/24 02:26:55 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Optimise all Verity collections for the active application. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfsetting enablecfoutputonly="Yes">

<!--- check permissions --->
<cfscript>
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
</cfscript>

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header title="Verity: Build Indices">

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
				<cfoutput>#qCollections.name#: optimised...<br></cfoutput>
				<cfcatch><cfoutput>#qCollections.name#: error optimising...<br></cfoutput></cfcatch>
			</cftry>
			<cfflush>
		</cfif>
	</cfloop>
	
	<cfoutput><p>All done.</p></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">
