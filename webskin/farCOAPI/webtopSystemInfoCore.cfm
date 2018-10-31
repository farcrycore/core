<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Core --->
<!--- @@seq: 100 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset coreLastModified = createdatetime(1970,1,1,0,0,0) />
<cfdirectory action="list" directory="#expandpath('/farcry/core')#" recurse="true" type="file" name="q" filter="*.cf?" />
<cfloop query="q">
	<cfif coreLastModified lt q.dateLastModified and q.dateLastModified lte now()>
		<cfset coreLastModified = q.dateLastModified />
	</cfif>
</cfloop>


<ft:field label="Version">
	<cfoutput>#application.sysInfo.farcryVersionTagLine#</cfoutput>
</ft:field>
<ft:field label="Last Modified">
	<cfoutput>#lcase(timeformat(coreLastModified,'hh:mmtt'))#, #dateformat(coreLastModified,'d mmm yyyy')#</cfoutput>
</ft:field>

<cfset stRepo = application.fapi.getContentType(typename="configRepositories").processRepository(expandpath("/farcry/core")) />
<ft:field label="Version Control"><cfoutput>
	<cfswitch expression="#stRepo.type#">
		<cfcase value="git">
			<cfif stRepo.success and stRepo.isDirty>
				<span style="color:##C09853;" title="There are #listlen(stRepo.dirtyFiles, chr(10))# file/s with unversioned changes">Git</span>
				#stRepo.origin# (#stRepo.branch# #stRepo.commit#)
			<cfelseif stRepo.success and not stRepo.isDirty>
				<span style="color:##468847;" title="No unversioned changes on the server">Git</span>
				#stRepo.origin# (#stRepo.branch# #stRepo.commit#)
			<cfelse>
				<span style="color:##B94A48;" title="There was an error inspecting the repository">#stRepo.error#</span>
			</cfif>
		</cfcase>
		<cfcase value="svn">
			<cfif stRepo.success and stRepo.isDirty>
				<span style="color:##C09853;" title="There are unversioned changes on the server">SVN</span>
				#stRepo.url# (r#stRepo.revision#)
			<cfelseif stRepo.success and not stRepo.isDirty>
				<span style="color:##468847;" title="No unversioned changes on the server">SVN</span>
				#stRepo.url# (r#stRepo.revision#)
			<cfelse>
				<span style="color:##B94A48;" title="There was an error inspecting the repository">#stRepo.error#</span>
			</cfif>
		</cfcase>
		<cfcase value="unversioned">
			<span style="color:##B94A48;">Unversioned</span>
		</cfcase>
	</cfswitch>
</cfoutput></ft:field>

<cfsetting enablecfoutputonly="false">