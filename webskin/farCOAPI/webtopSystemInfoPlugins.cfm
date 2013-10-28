<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Plugins --->
<!--- @@seq: 200 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset coreLastModified = createdatetime(1970,1,1,0,0,0) />
<cfdirectory action="list" directory="#expandpath('/farcry/core')#" recurse="true" type="file" name="q" />
<cfloop query="q">
	<cfif coreLastModified lt q.dateLastModified and q.dateLastModified lte now()>
		<cfset coreLastModified = q.dateLastModified />
	</cfif>
</cfloop>


<cfloop list="#application.plugins#" index="thisplugin">
	<cfif directoryExists(expandpath("/farcry/plugins/#thisplugin#"))>
		<cfset pluginName = thisplugin />
		<cfset pluginStatus = "Unknown Status" />
		<cfif fileexists(expandpath("/farcry/plugins/#thisplugin#/install/manifest.cfc"))>
			<cfset o = createobject("component","farcry.plugins.#thisplugin#.install.manifest") />
			<cfset pluginName = o.name />
			<cfif structkeyexists(o,"getStatus")>
				<cfset pluginStatus = o.getStatus() />
			</cfif>
		</cfif>

		<cfset pluginLastModified = createdatetime(1970,1,1,0,0,0) />
		<cfdirectory action="list" directory="#expandpath('/farcry/plugins/#thisplugin#')#" recurse="true" type="file" name="q" />
		<cfloop query="q">
			<cfif pluginLastModified lt q.dateLastModified>
				<cfset pluginLastModified = q.dateLastModified />
			</cfif>
		</cfloop>

		<cfset stRepo = application.fapi.getContentType(typename="configRepositories").processRepository(expandpath("/farcry/plugins/#thisplugin#")) />
		
		<ft:field label="#pluginName#">
			<cfoutput>
				<div class="span3" style="color:<cfif pluginStatus eq 'Unknown Status'>##C09853<cfelseif pluginStatus eq 'Good'>##468847<cfelse>##B94A48</cfif>">#pluginStatus#</div>
				<div class="span3">last modified: #lcase(timeformat(pluginLastModified,'hh:mmtt'))#, #dateformat(pluginLastModified,'d mmm yyyy')#</div>
				<div class="span3">
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
				</div>
			</cfoutput>
		</ft:field>
	</cfif>
</cfloop>

<cfsetting enablecfoutputonly="false">