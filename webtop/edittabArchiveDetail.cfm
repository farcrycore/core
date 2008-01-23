<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<!--- environment variables --->
<cfparam name="url.archiveid" type="uuid" />

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfoutput>
	<h3>#application.adminBundle[session.dmProfile.locale].archive#</h3>
</cfoutput>

<!--- todo: move this functionality to the dmArchive or auxillary component --->
<cfinvoke 
 component="#application.packagepath#.farcry.versioning"
 method="getArchiveDetail"
 returnvariable="getArchiveDetailRet">
	<cfinvokeargument name="objectID" value="#url.archiveid#"/>
</cfinvoke>

<cfdump var="#getArchiveDetailRet#" label="Archive" />

<!--- setup footer --->
<admin:footer>