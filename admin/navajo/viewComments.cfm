<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfsetting enablecfoutputonly="Yes">

<cfif isdefined("URL.objectID")>
	<!--- get object details --->
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectid="#listgetat(URL.objectID,1)#" r_stobject="stObj">

    <cfoutput>
    <table cellpadding="5" cellspacing="0" border="1" style="margin-top:15px;margin-bottom:15px" width="95%" align="center">
    <tr class="dataHeader">
	<td>
	<br>
	<!--- i18n: double check logic, geez i HATE compound rb string --->
	<cfif stObj.label eq "">
	#application.adminBundle[session.dmProfile.locale].comments#
	<cfelseif stObj.label neq "" AND (NOT isdefined("stObj.versionId") OR stObj.versionID eq "")>
	#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].commentsFor,"#stObj.label#")#
	<cfelseif stObj.label neq "" AND (isdefined("stObj.versionId") AND stObj.versionID eq "")>
	#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].draftCommentsFor,"#stObj.label#")#
	</cfif>
	</td>
	</tr>
    <tr><td>
    <br>
    </cfoutput>
	
	<cfif isdefined("stObj.status") AND trim(stObj.commentLog) neq "">
        <cfoutput>#wrap(paragraphFormat2(stObj.commentLog),70)#</cfoutput>
    <cfelse>
        <cfoutput><strong>#application.adminBundle[session.dmProfile.locale].noComments#</strong></cfoutput>
    </cfif>
</cfif>

<cfoutput>
</td></tr>
</table>
</cfoutput>

<cfsetting enablecfoutputonly="No">

<!--- setup footer --->
<admin:footer>