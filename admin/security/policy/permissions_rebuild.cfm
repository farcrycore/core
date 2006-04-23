<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->

<!--- default all form variables --->

<!--- rebuild permissions --->
<cfset editObject = request.dmsec.oAuthorisation>
<cfset returnstruct = editObject.reInitPermissionsCache()>
<cfset application.factory.oaudit.logActivity(auditType="dmsec.PermissionRebuild", username=session.dmprofile.username, location=cgi.remote_host, note="Permissions Rebuilt")>
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfoutput>
<cfif fatalErrorMessage NEQ ""> <!--- if fatal error occurs then show error and dont render the page --->
<h3 id="fading1" class="fade"><span class="error">Error</span>: #fatalErrorMessage#</h3>
<cfelse>
	<cfif errorMessage NEQ ""> <!--- display any non critical error [eg form validation] --->
<h3 id="fading2" class="fade"><span class="error">Error</span>: #errorMessage#</h3>
	</cfif> 
	<table class="table-4" cellspacing="0">
	<tr>
	<th scope="col" colspan="2">Permission Rebuild</th>
	</tr><cfset iCounter = 0><cfloop item="rItem" collection="#returnstruct#">
	<tr<cfif iCounter MOD 2> class="alt"</cfif>>
	<th scope="row" class="alt">#ritem#</th>
	<td>#returnstruct[ritem]#</td>
	</tr><cfset iCounter = iCounter + 1></cfloop>
	</table>
</cfif></cfoutput>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false">