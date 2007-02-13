<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/security/ui/dmSec_TestPolicySetup.cfm,v 1.7 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
Shows the userdirectory and policy store setup.
Allows verification of setup.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

--->
<cfoutput>

<h3>#application.adminBundle[session.dmProfile.locale].securitySetup#</h3>

<cfif not IsDefined("Application.dmSec")>
	#application.adminBundle[session.dmProfile.locale].securityNotInit#
<cfelse>
	<cfscript>
		oAuthorisation = request.dmsec.oAuthorisation;
		oAuthentication = request.dmsec.oAuthentication;
		stPolicyStore = oAuthorisation.getPolicyStore();
	</cfscript>


<form action="" method="post" class="f-wrap-1 f-bg-medium wider">
<fieldset>
	<cfif isDefined("form.verify")>
		
	<h3>#application.adminBundle[session.dmProfile.locale].testingSetup#</h3>
	<h3>#application.adminBundle[session.dmProfile.locale].policyTests#</h3>

	<table cellspacing="0">
	<tr>
	<td>&nbsp;&nbsp;</td>
	<td>
		#application.adminBundle[session.dmProfile.locale].policyStoreExists#<br>
		
		<!--- Test the datasource parameter exists --->
		<cfif not isDefined("stPolicyStore.datasource")>
		
			#application.adminBundle[session.dmProfile.locale].policyStoreNotExists#<br>
			
		<cfelse>
		
			#application.adminBundle[session.dmProfile.locale].policyStoreOK#<br>
			
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
			
			#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].policyStoreDSconnectedOK,"#stPolicyStore.datasource#")#<br>
			
			<a href="?tag=CreatePolicyStoreTables" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmRecreatePolicyTables#');">#application.adminBundle[session.dmProfile.locale].createPolicyStoreTables#</a><br>
			<br>
			<!--- Test policy store tables --->
			<cfimport taglib="/farcry/core/tags/security/ui/" prefix="dmsec">
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

	<div class="f-submit-wrap">
	<input type="Submit" name="Verify" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].verifyPolicySetup#" />
	<input type="Submit" name="View" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].viewSetup#" />
	</div>
	
</fieldset>
</form>
</cfif>

</cfoutput>
<cfsetting enablecfoutputonly="No">