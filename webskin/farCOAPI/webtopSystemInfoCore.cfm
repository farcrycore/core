<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Core --->
<!--- @@seq: 100 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset coreLastModified = createdatetime(1970,1,1,0,0,0) />
<cfdirectory action="list" directory="#expandpath('/farcry/core')#" recurse="true" type="file" name="q" />
<cfloop query="q">
	<cfif coreLastModified lt q.dateLastModified>
		<cfset coreLastModified = q.dateLastModified />
	</cfif>
</cfloop>


<ft:field label="Version">
	<cfoutput>#application.sysInfo.farcryVersionTagLine#</cfoutput>
</ft:field>
<ft:field label="Last Modified">
	<cfoutput>#lcase(timeformat(coreLastModified,'hh:mmtt'))#, #dateformat(coreLastModified,'d mmm yyyy')#</cfoutput>
</ft:field>

<cfsetting enablecfoutputonly="false">