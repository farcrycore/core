<cfsetting enablecfoutputonly="Yes">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_TestPolicySetup.cfm,v 1.2 2003/04/09 08:04:59 spike Exp $
$Author: spike $
$Date: 2003/04/09 08:04:59 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
Shows the userdirectory and policy store setup.
Allows verification of setup.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSec_TestPolicySetup.cfm,v $
Revision 1.2  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.2  2002/09/12 01:15:47  geoff
no message

Revision 1.1.1.1  2002/08/22 07:18:17  geoff
no message

Revision 1.1  2001/11/18 16:15:22  matson
moved all files to custom tags daemon_security/UI (dmSecUI)

Revision 1.1  2001/11/15 11:09:56  matson
no message

Revision 1.2  2001/09/26 22:09:53  matson
no message

Revision 1.1  2001/09/20 17:34:57  matson
first import

|| END FUSEDOC ||
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
				<cfquery name="testODBC" datasource="#stPolicyStore.datasource#" dbtype="ODBC">
					SELECT 1;
				</cfquery>
			<cfcatch>
				<span style="color:red;">Error:</span> Cannot find datasource #stPolicyStore.datasource# in ODBC
				<cfabort>
			</cfcatch>
			
			</cftry>
			
			<span style="color:green;">OK:</span> PolicyStore Datasource '#stPolicyStore.datasource#' connection success.<br>
			
			<a href="?tag=CreatePolicyStoreTables">Create PolicyStore Tables</a><br>
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