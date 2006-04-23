<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="bFormSubmitted" default="no">
<!--- default all form variables --->
<cfparam name="lDeleteobjectID" default="">
<cfparam name="completionMessage" default=""> <!--- normal error [ie server side validation] --->

<cfset oAuthorisation = request.dmsec.oAuthorisation>

<cfif bFormSubmitted EQ "yes">
	<cfloop index="policyItem" list="#lDeleteobjectID#">
		<cfif ListLen(policyItem,"|") EQ 3>
			<cfset ipolicyGroupId = ListFirst(policyItem,"|")>
			<cfset iuserDirectory = ListGetAt(policyItem,2,"|")>
			<cfset igroupName = ListLast(policyItem,"|")>
		</cfif>
		<cfset returnstruct = oAuthorisation.deletePolicyGroupMapping(igroupName, iuserDirectory, ipolicyGroupId)>
		<cfif returnstruct.returncode EQ 1>
			<cfset completionMessage = completionMessage & "Policy Group [#igroupName# ] and User Directory [#iuserDirectory#] deleted successfully.<br />">
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif returnstruct.returncode EQ 0>
		<cfset errorMessage = returnstruct.returnmessage>
	</cfif>
</cfif>

<cfset aGroups = oAuthorisation.getMultiplePolicyGroupMappings()>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfoutput>
<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
<h3 id="fading1" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
<cfelse>
	<cfif errorMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
	<cfelseif completionMessage NEQ "">
<h3 id="fading2" class="fade"><span class="success">Success</span>: #completionMessage#</h3>
	</cfif>

<form name="frm" method="post" class="f-wrap-1 f-bg-medium wider" action="#cgi.script_name#">
<fieldset>
	<h3>#application.adminBundle[session.dmProfile.locale].showPolicyGroupMappings#</h3>
	
	<table class="table-2" cellspacing="0">
	<tr>
		<th scope="col" style="text-align:center">Select</th>
		<th scope="col">#application.adminBundle[session.dmProfile.locale].policyGroupName#</th>
		<th scope="col">#application.adminBundle[session.dmProfile.locale].userDirectory#</th>
		<th scope="col">#application.adminBundle[session.dmProfile.locale].externalGroupName#</th>
	</tr><cfloop index="i" from="1" to="#ArrayLen(aGroups)#">
	<tr<cfif i MOD 2 EQ 0> class="alt"</cfif>>
	<td style="text-align:center"><input class="f-checkbox" type="checkbox" name="lDeleteobjectID" value="#aGroups[i].policyGroupId#|#aGroups[i].externalGroupUserDirectory#|#aGroups[i].externalGroupName#" onclick="setRowBackground(this);"<cfif ListFindNoCase(lDeleteobjectID,"#aGroups[i].policyGroupId#|#aGroups[i].externalGroupUserDirectory#|#aGroups[i].externalGroupName#")> checked="checked"</cfif> /></td>
	<td>#aGroups[i].policyGroupName#</td>
	<td>#aGroups[i].externalGroupUserDirectory#</td>
	<td>#aGroups[i].externalGroupName#</td>
	</tr></cfloop>
	</table>
	<hr />
	<div class="f-submit-wrap">
		<input type="submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].deleteMappings#" />
	</div>
	
	<input type="hidden" name="bFormSubmitted" value="yes" />
	
</fieldset>
</form>
</cfif></cfoutput>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">