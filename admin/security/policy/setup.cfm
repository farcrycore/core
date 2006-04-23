<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errorMessage" default="">
<cfparam name="action" default="">

<cfif IsDefined("Application.dmSec")>
	<cfset securityObj = CreateObject("component","#application.packagepath#.security.security")>
	<cfset oAuthorisation = request.dmsec.oAuthorisation>
	<cfset oAuthentication = request.dmsec.oAuthentication>
	<cfset stPolicyStore = oAuthorisation.getPolicyStore()>
	<!--- if form is submitted --->
	<cfif isDefined("form.verify")>
		<cfif NOT isDefined("stPolicyStore.datasource")>
			<cfset errorMessage = errorMessage & application.adminBundle[session.dmProfile.locale].policyStoreNotExists>
		</cfif>
	</cfif>
<cfelse>
	<cfset errorMessage = errorMessage & application.adminBundle[session.dmProfile.locale].securityNotInit>
</cfif>


<!--- check permissions --->
<cfset iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSecurityTab EQ 0>
	<admin:permissionError>
<cfelse><cfoutput>

	<cfif errorMessage NEQ "">
	<span class="error">#errorMessage#</span>
	<cfelse>
	<form name="frmPolicySetup" action="#cgi.script_name#" method="post" class="f-wrap-1 f-bg-medium wider">
	<fieldset>
		<h3>#application.adminBundle[session.dmProfile.locale].securitySetup#</h3>
		
		
		<cfif isDefined("form.verify")>
			<h5>#application.adminBundle[session.dmProfile.locale].testingSetup#, 
			#application.adminBundle[session.dmProfile.locale].policyTests#</h5>
			<!--- Check the policy store configuration is set in the security structure --->
			#application.adminBundle[session.dmProfile.locale].policyStoreOK#<br />
<cfset returnstruct = securityObj.fValidDatasource(stPolicyStore.datasource)>
			<cfif returnstruct.returncode EQ 0> <!--- error --->
#returnstruct.returnmessage#
			<cfelse>
#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].policyStoreDSconnectedOK,"#stPolicyStore.datasource#")#<br />
			<!--- Test policy store tables --->
			<!--- Test for ExternalGroupToPolicyGroup table --->
<cfset returnstruct = securityObj.fValidateTable(stPolicyStore.datasource,"dmExternalGroupToPolicyGroup","PolicyGroupId,ExternalGroupUserDirectory,ExternalGroupName")>
#returnstruct.returnmessage#<br />
			
			<!--- Test for PolicyGroup table --->
<cfset returnstruct = securityObj.fValidateTable(stPolicyStore.datasource,"dmPolicyGroup","PolicyGroupId,PolicyGroupName,PolicyGroupNotes")>
#returnstruct.returnmessage#<br />
		
			<!--- Test for PermissionBarnacle table --->
<cfset returnstruct = securityObj.fValidateTable(stPolicyStore.datasource,"dmPermission","PermissionName,PermissionNotes,PermissionType")>
#returnstruct.returnmessage#<br />
			
			<!--- Test for PermissionBarnacle table --->
<cfset returnstruct = securityObj.fValidateTable(stPolicyStore.datasource,"dmPermissionBarnacle","PermissionId,PolicyGroupId,Reference1,Status")>
#returnstruct.returnmessage#<br />
			</cfif>
		<cfelse>		
			<table class="table-4" cellspacing="0">
			<tr>
				<th scope="col" colspan="2">Struct</th>
			</tr><cfset iCounter = 1><cfloop item="key" collection="#stPolicyStore#">
			<tr<cfif (iCounter MOD 2) EQ 0> class="alt"</cfif>>
				<th scope="row" class="alt">#key#</th>
				<td>#stPolicyStore[key]#</td>
			</tr><cfset iCounter = iCounter + 1>
			</cfloop>
			</table>
		</cfif>
		
		<div class="f-submit-wrap" style="padding-left:0;padding-top:15px">
		<input type="submit" name="Verify" class="f-submit" style="margin-left:0" value="#application.adminBundle[session.dmProfile.locale].verifyPolicySetup#" />
		<input type="submit" name="View" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].viewSetup#" />
		</div>
		
		</fieldset>
		
	</form>
	<hr />
	</cfif></cfoutput>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">