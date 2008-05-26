<cfprocessingDirective pageencoding="utf-8">
<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

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
		#application.rb.getResource("comments")#
		<cfelseif stObj.label neq "" AND (NOT isdefined("stObj.versionId") OR stObj.versionID eq "")>
		#application.rb.formatRBString("commentsFor","#stObj.label#")#
		<cfelseif stObj.label neq "" AND (isdefined("stObj.versionId") AND stObj.versionID eq "")>
		#application.rb.formatRBString("draftCommentsFor","#stObj.label#")#
		</cfif>
		</td>
		<td align="left"><a href="##" title="Close Window" onclick="window.close();">[X]</a></td>
	</tr>
    <tr>
    	<td colspan="2">
    <br />
	<nj:showcomments objectid="#stObj.objectid#" typename="#stObj.typename#" />
		</td>
	</tr>
</table></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="No">

<!--- setup footer --->
<admin:footer>