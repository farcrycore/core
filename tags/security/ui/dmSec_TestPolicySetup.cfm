<cfsetting enablecfoutputonly="Yes">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_TestPolicySetup.cfm,v 1.4 2004/06/16 23:25:24 brendan Exp $
$Author: brendan $
$Date: 2004/06/16 23:25:24 $
$Name: milestone_2-2-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
Shows the userdirectory and policy store setup.
Allows verification of setup.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

--->
<cfoutput>

<span class="formtitle">Security Setup</span><p></p>

<cfif not IsDefined("Application.dmSec")>
	<span style="color:red;">Error:</span> Security not initialised.<br>
	The structure 'dmsec' was not found in the security structure.<br>
	This structure is needed with the following attributes:<br>
	<li>PolicyStore: structure describing the policy store.<br>
	<li>UserDirectory: structure(s) describing userdirectories.<br>
<cfelse>
	<cfscript>
		oAuthorisation = request.dmsec.oAuthorisation;
		oAuthentication = request.dmsec.oAuthentication;
		stPolicyStore = oAuthorisation.getPolicyStore();
	</cfscript>


	<form action="" method="POST">

	<cfif isDefined("form.verify")>
		
	<h3>Testing setup</h3>
	<h4>Policy Tests</h4>
	<!--- Check the policy store configuration is set in the security structure --->
	<table border=0 cellpadding=0 cellspacing=0>
	<tr>
	<td>&nbsp;&nbsp;</td>
	<td>
		<span style="color:green;">OK:</span> PolicyStore attribute exists.<br>
		
		<!--- Test the datasource parameter exists --->
		<cfif not isDefined("stPolicyStore.datasource")>
		
			<span style="color:red;">Error:</span> Policy Store Datasource attribute not found.<br>
			The structure 'policyStore.datasource' was not found in the security structure.<br>
			
		<cfelse>
		
			<span style="color:green;">OK:</span> PolicyStore Datasource attribute exists.<br>
			
			<!--- Test the odbc connection works --->
			<cftry>
				<cfswitch expression="#application.dbType#">
					
					<cfcase value="ora">
						<cfquery name="testODBC" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
							SELECT 1 FROM DUAL
						</cfquery>
					</cfcase>
					
					<cfdefaultcase>
						<cfquery name="testODBC" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
							SELECT 1;
						</cfquery>
					</cfdefaultcase>
				
				</cfswitch>
			<cfcatch>
				<span style="color:red;">Error:</span> Cannot find datasource #stPolicyStore.datasource# in ODBC
				<cfabort>
			</cfcatch>
			
			</cftry>
			
			<span style="color:green;">OK:</span> PolicyStore Datasource '#stPolicyStore.datasource#' connection success.<br>
			
			<a href="?tag=CreatePolicyStoreTables" onClick="return confirm('Are you sure you wish to recreate you policy tables?');">Create PolicyStore Tables</a><br>
			<br>
			<!--- Test policy store tables --->
			<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
			<!--- Test for ExternalGroupToPolicyGroup table --->
			<dmsec:dmSec_TableTest table="dmExternalGroupToPolicyGroup"
								fields="PolicyGroupId,ExternalGroupUserDirectory,ExternalGroupName"
								datasource="#stPolicyStore.datasource#">
			
			<!--- Test for PolicyGroup table --->
			<dmsec:dmSec_TableTest table="dmPolicyGroup"
								fields="PolicyGroupId,PolicyGroupName,PolicyGroupNotes"
								datasource="#stPolicyStore.datasource#">
		
			<!--- Test for PermissionBarnacle table --->
			<dmsec:dmSec_TableTest table="dmPermission"
								fields="PermissionName,PermissionNotes,PermissionType"
								datasource="#stPolicyStore.datasource#">
			
			<!--- Test for PermissionBarnacle table --->
			<dmsec:dmSec_TableTest table="dmPermissionBarnacle"
								fields="PermissionId,PolicyGroupId,Reference1,Status"
								datasource="#stPolicyStore.datasource#">
		</cfif>
	</td>
	</tr>
	</table>
	<cfelse>
	
	<cfdump var="#stPolicyStore#">
		
	</cfif>

	<br>
	<input type="Submit" name="Verify" value="Verify Policy Setup">&nbsp;<input type="Submit" name="View" value="View Setup"><br>
	<br>
	</form>
</cfif>

</cfoutput>
<cfsetting enablecfoutputonly="No">