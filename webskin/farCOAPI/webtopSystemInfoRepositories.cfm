<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Repositories --->
<!--- @@seq: 500 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfset oRepo = application.fapi.getContentType(typename="configRepositories")>

<!--- get repository data --->
<cfset aPaths = oRepo.getAllRepositoryPaths()>
<cfset stRepoData = oRepo.processRepositoryPaths(aPaths, true)>


<cfoutput>

	<cfif structKeyExists(stRepoData, "git") AND arrayLen(stRepoData.git)>
		<table class="table">
		<thead>
		<tr>
			<th style="width: 220px">Git Repository</th>
			<th>URL (branch commit) Date</th>
		</tr>
		</thead>
		<tbody>
		<cfloop from="1" to="#arrayLen(stRepoData["git"])#" index="i">
			<cfset stRepo = stRepoData["git"][i]>
			<cfif stRepo.success>
				<tr>
					<td nowrap="nowrap">
						<span <cfif stRepo.isDirty>style="color: red"<cfelse>style="color: green"</cfif>>
						<i class="fa fa-#stRepo.service# fa-fw"></i> 
						#stRepo.name#
						</span>
					</td>
					<td>
						#stRepo.origin# (#stRepo.branch# #stRepo.commit#) #stRepo.date#<br>
						<cfif stRepo.isUnpushed>
							<strong><span class="label label-warning">#len(reReplace(stRepo.unpushedFiles, "[^\n]+", "", "all"))+1# Unpushed</span></strong><br>
							#replace(stRepo.unpushedFiles, chr(10), "<br>", "all")#<br>
						</cfif>
						<cfif stRepo.isDirty>
							<strong><span class="label label-important">#len(reReplace(stRepo.dirtyFiles, "[^\n]+", "", "all"))+1# Uncommitted</span></strong><br>
							#replace(stRepo.dirtyFiles, chr(10), "<br>", "all")#<br>
						</cfif>
					</td>
				</tr>
			<cfelse>
				<tr>
					<td nowrap="nowrap">#stRepo.name#</td>
					<td>#stRepo.error#</td>
				</tr>				
			</cfif>
		</cfloop>
		</tbody>
		</table>
	</cfif>

	<cfif structKeyExists(stRepoData, "svn") AND arrayLen(stRepoData.svn)>
		<table class="table">
		<thead>
		<tr>
			<th style="width: 220px">SVN Repository</th>
			<th>URL (revision) Date</th>
		</tr>
		</thead>
		<tbody>
		<cfloop from="1" to="#arrayLen(stRepoData["svn"])#" index="i">
			<cfset stRepo = stRepoData["svn"][i]>
			<cfif stRepo.success>
				<tr>
					<td nowrap="nowrap">
						<span <cfif stRepo.isDirty>style="color: red"<cfelse>style="color: green"</cfif>>
						<i class="fa fa-book fa-fw"></i> 
						#stRepo.name#
						</span>
					</td>
					<td>#stRepo.url# (r#stRepo.revision#) #stRepo.date#</td>
				</tr>
			<cfelse>
				<tr>
					<td nowrap="nowrap">#stRepo.name#</td>
					<td>#stRepo.error#</td>
				</tr>	
			</cfif>
		</cfloop>
		</tbody>
		</table>
	</cfif>

	<cfif structKeyExists(stRepoData, "unversioned") AND arrayLen(stRepoData.unversioned)>
		<table class="table">
		<thead>
		<tr>
			<th style="width: 220px">Unversioned</th>
			<th></th>
		</tr>
		</thead>
		<tbody>
		<cfloop from="1" to="#arrayLen(stRepoData["unversioned"])#" index="i">
			<cfset stRepo = stRepoData["unversioned"][i]>
			<tr>
				<td nowrap="nowrap">
					<i class="fa fa-folder fa-fw"></i> 
					#stRepo.name#
				</td>
				<td nowrap="nowrap"></td>
			</tr>
		</cfloop>
		</tbody>
		</table>
	</cfif>

</cfoutput>


<cfsetting enablecfoutputonly="false">