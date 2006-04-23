<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfsetting enablecfoutputonly="Yes">

<cfif isdefined("URL.objectID")>
	<!--- get object details --->
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectid="#listgetat(URL.objectID,1)#" r_stobject="stObj">

    <cfoutput>
    <table cellpadding="5" cellspacing="0" border="1" style="margin-top:15px;margin-bottom:15px" width="95%" align="center">
    <tr class="dataHeader"><td><br>COMMENTS<cfif stObj.title neq ""> FOR <strong>#stObj.title#</strong></cfif><cfif isdefined("stObj.versionId") and stObj.versionID neq ""> <strong>(DRAFT)</strong></cfif></td></tr>
    <tr><td>
    <br>
    </cfoutput>

	<cfif isdefined("stObj.status") AND trim(stObj.commentLog) neq "">
        <cfoutput>#htmlCodeFormat(stObj.commentLog)#</cfoutput>
    <cfelse>
        <cfoutput><strong>There are no comments available.</strong></cfoutput>
    </cfif>
</cfif>

<cfoutput>
</td></tr>
</table>
</cfoutput>

<cfsetting enablecfoutputonly="No">

<!--- setup footer --->
<admin:footer>