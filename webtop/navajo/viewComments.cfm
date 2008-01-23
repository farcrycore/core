<cfprocessingDirective pageencoding="utf-8">
<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfsetting enablecfoutputonly="Yes">

<cfif isdefined("URL.objectID")>
	<!--- get object details --->
	<q4:contentobjectget objectid="#listgetat(URL.objectID,1)#" r_stobject="stObj">

    <cfoutput>
    <table cellpadding="5" cellspacing="0" border="0" width="95%" align="center">
    <tr class="dataHeader">
		<td>
		<br />
		<!--- i18n: double check logic, geez i HATE compound rb string --->
		<cfif stObj.label eq "">
		#application.adminBundle[session.dmProfile.locale].comments#
		<cfelseif stObj.label neq "" AND (NOT isdefined("stObj.versionId") OR stObj.versionID eq "")>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].commentsFor,"#stObj.label#")#
		<cfelseif stObj.label neq "" AND (isdefined("stObj.versionId") AND stObj.versionID eq "")>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].draftCommentsFor,"#stObj.label#")#
		</cfif>
		</td>
		<td align="left"><a href="##" title="Close Window" onclick="window.close();">[X]</a></td>
	</tr>
    <tr>
    	<td colspan="2">
    <br />
	<cfif isdefined("stObj.status") AND trim(stObj.commentLog) neq "">
        <cfoutput>#wrap(paragraphFormat2(stObj.commentLog),70)#</cfoutput>
    <cfelse>
        <cfoutput><strong>#application.adminBundle[session.dmProfile.locale].noComments#</strong></cfoutput>
    </cfif>
		</td>
	</tr>
</table></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="No">

<!--- setup footer --->
<admin:footer>