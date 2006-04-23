<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<br>
<span class="FormTitle"><cfoutput>#application.adminBundle[session.dmProfile.locale].archive#</cfoutput></span>
<p></p>

<cfinvoke 
 component="#application.packagepath#.farcry.versioning"
 method="getArchiveDetail"
 returnvariable="getArchiveDetailRet">
	<cfinvokeargument name="objectID" value="#url.archiveid#"/>
</cfinvoke>

<cfdump var="#getArchiveDetailRet#" label="Archive">

<!--- setup footer --->
<admin:footer>