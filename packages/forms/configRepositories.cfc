<cfcomponent displayname="Repository Info Configuration" extends="forms" key="repo" output="false"
	hint="Configure paths for source control repository info integration">

	<cfproperty name="gitExecutable" type="string" default="C:\Program Files\Git\bin\git.exe" required="false"
		ftSeq="1" ftFieldset="Executable Paths" ftLabel="Git Executable"
		ftType="string"
		ftHint="e.g. /usr/bin/git or C:\Program Files\Git\bin\git.exe">

	<cfproperty name="svnExecutable" type="string" default="C:\Program Files\TortoiseSVN\bin\svn.exe" required="false"
		ftSeq="2" ftFieldset="Executable Paths" ftLabel="SVN Executable"
		ftType="string"
		ftHint="e.g. /usr/bin/svn or C:\Program Files\TortoiseSVN\bin\svn.exe">


	<!--- repository methods --->

	<cffunction name="getAllRepositoryPaths" returntype="array">

		<cfset var aPaths = arrayNew(1)>
		<cfset var lPlugins = "">
		<cfset var i = 0>
		<cfset var plugin = "">
		<cfset var path = "">

		<!--- core --->
		<cfset arrayAppend(aPaths, application.path.core)>
		<!--- plugins --->
		<cfset lPlugins = listSort(application.plugins, "textnocase")>
		<cfloop from="1" to="#listLen(lPlugins)#" index="i">
			<cfset plugin = listGetAt(lPlugins, i)>
			<cfset path = expandPath("/farcry/plugins/" & plugin)>
			<cfset arrayAppend(aPaths, path)>
		</cfloop>
		<!--- project --->
		<cfif listLast(application.path.webroot, "\/") eq "www">
			<cfset arrayAppend(aPaths, application.path.project)>
		<cfelse>
			<cfset arrayAppend(aPaths, application.path.webroot)>
		</cfif>

		<cfreturn aPaths>
	</cffunction>

	<cffunction name="processRepositoryPaths" returntype="any">
		<cfargument name="aPaths" required="true">
		<cfargument name="nestedResults" required="false" default="false">

		<cfset var result = arrayNew(1)>
		<cfset var i = 0>
		<cfset var stRepo = structNew()>

		<cfif arguments.nestedResults>
			<cfset result = structNew()>
			<cfset result["git"] = arrayNew(1)>
			<cfset result["svn"] = arrayNew(1)>
			<cfset result["unversioned"] = arrayNew(1)>
		</cfif>

		<!--- process paths --->
		<cfloop from="1" to="#arrayLen(aPaths)#" index="i">
			<!--- get the repo data --->
			<cfset stRepo = processRepository(aPaths[i])>
			<!--- add the repository to the array --->
			<cfif arguments.nestedResults>
				<cfset arrayAppend(result[stRepo.type], stRepo)>
			<cfelse>
				<cfset arrayAppend(result, stRepo)>
			</cfif>
		</cfloop>

		<cfreturn result>
	</cffunction>

	<cffunction name="processRepository" returntype="struct">
		<cfargument name="path" required="true">

		<cfset var stResult = structNew()>
		<cfset var pathGitDir = "">
		<cfset var bGitDirExists = false>
		<cfset var pathSVNDir = "">
		<cfset var bSVNDirExists = false>
		<cfset var stCmdResult = structNew()>

		<cfset stResult["name"] = listLast(arguments.path, "\/")>
		<cfset stResult["path"] = arguments.path>

		<!--- check for repository types --->
		<cfset pathGitDir = arguments.path & "/.git">
		<cfset bGitDirExists = directoryExists(pathGitDir)>
		<cfset pathSVNDir = arguments.path & "/.svn">
		<cfset bSVNDirExists = directoryExists(pathSVNDir)>

		<cfif bGitDirExists>
			<cfset stResult["type"] = "git">

			<!--- check git origin url --->
			<cfset stCmdResult = executeGitCommand("config --get remote.origin.url", arguments.path)>
			<cfset stResult["success"] = false>
			<cfset stResult["error"] = "">
			<cfset stResult["origin"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["origin"] = stCmdResult.output>
				<cfset stResult["success"] = true>
			<cfelse>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check git remote service --->
			<cfset stCmdResult = executeGitCommand("remote -v", arguments.path)>
			<cfset stResult["service"] = "other">
			<cfif stCmdResult.success>
				<cfif findNoCase("github.com", stCmdResult.output)>
					<cfset stResult["service"] = "github">
				<cfelseif findNoCase("bitbucket.org", stCmdResult.output)>
					<cfset stResult["service"] = "bitbucket">
				</cfif>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check current git branch --->
			<cfset stCmdResult = executeGitCommand("branch", arguments.path)>
			<cfset stResult["branch"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["branch"] = reReplaceNoCase(stCmdResult.output, ".*\* (.*)\b.*", "\1")>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check current git commit hash --->
			<cfset stCmdResult = executeGitCommand("rev-parse --short HEAD", arguments.path)>
			<cfset stResult["commit"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["commit"] = stCmdResult.output>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check current git commit date --->
			<cfset stCmdResult = executeGitCommand("log --pretty=format:%ad --date=short -1", arguments.path)>
			<cfset stResult["date"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["date"] = stCmdResult.output>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check for dirty git repo --->
			<cfset stCmdResult = executeGitCommand("ls-files -m -o --exclude-standard", arguments.path)>
			<cfset stResult["isDirty"] = false>
			<cfset stResult["dirtyFiles"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["isDirty"] = len(stCmdResult.output) ? true : false>
				<cfset stResult["dirtyFiles"] = stCmdResult.output>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check for unpushed commits --->
			<cfset stCmdResult = executeGitCommand("log --pretty=oneline --abbrev-commit @{u}..HEAD", arguments.path)>
			<cfset stResult["isUnpushed"] = false>
			<cfset stResult["unpushedFiles"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["isUnpushed"] = len(stCmdResult.output) ? true : false>
				<cfset stResult["unpushedFiles"] = stCmdResult.output>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>


		<cfelseif bSVNDirExists>
			<cfset stResult["type"] = "svn">

			<!--- check svn url --->
			<cfset stCmdResult = executeSVNCommand("info", arguments.path)>
			<cfset stResult["success"] = false>
			<cfset stResult["error"] = "">
			<cfset stResult["url"] = "">
			<cfset stResult["revision"] = "">
			<cfset stResult["date"] = "">
			<cfif stCmdResult.success>
				<cfset stResult["url"] = reReplaceNoCase(stCmdResult.output, ".*URL: (.*?)[\s].*", "\1")>
				<cfset stResult["revision"] = reReplaceNoCase(stCmdResult.output, ".*Revision: (.*?)[\s].*", "\1")>
				<cfset stResult["date"] = reReplaceNoCase(stCmdResult.output, ".*Last Changed Date: (.*?)[\s].*", "\1")>
				<cfset stResult["success"] = true>
			<cfelse>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>
			<!--- check for dirty svn repo --->
			<cfset stCmdResult = executeSVNCommand("diff --internal-diff", arguments.path)>
			<cfset stResult["isDirty"] = false>
			<cfif stCmdResult.success>
				<cfset stResult["isDirty"] = len(stCmdResult.output) ? true : false>
			<cfelse>
				<cfset stResult["success"] = false>
				<cfset stResult["error"] = appendError(stResult["error"], stCmdResult.error)>
			</cfif>

		<cfelse>
			<cfset stResult["type"] = "unversioned">
		</cfif>

		<cfreturn stResult>
	</cffunction>

	<cffunction name="executeGitCommand" returntype="struct">
		<cfargument name="command" required="true">
		<cfargument name="path" required="true">

		<cfset var stResult = structNew()>
		<cfset var output = "">
		<cfset var outputError = "">
		<cfset var pathWorkTree = arguments.path>
		<cfset var pathGitDir = arguments.path & "/.git">
		<cfset var bGitDirExists = directoryExists(pathGitDir)>
		<cfset var gitExecutable = "">
		<cfset var execName = "">
		<cfset var execArgs = "">
		<cfset var stAttributes = structNew()>

		<!--- only execute the command on git repositories --->
		<cfif bGitDirExists>
			<cfif findNoCase("windows", server.os.name)>
				<!--- for windows --->
				<cfset gitExecutable = application.fapi.getConfig("repo", "gitExecutable")>
				<cfset execName = "C:\windows\system32\cmd.exe">
				<cfset execArgs = '/c """#gitExecutable#""" --git-dir """#pathGitDir#""" --work-tree """#pathWorkTree#""" #arguments.command#'>
			<cfelse>
				<!--- for nix --->
				<cfset gitExecutable = application.fapi.getConfig("repo", "gitExecutable")>
				<cfset execName = gitExecutable>
				<cfset execArgs = '--git-dir "#pathGitDir#" --work-tree "#pathWorkTree#" #arguments.command#'>
			</cfif>

			<!--- execute the git command --->
			<cfif len(gitExecutable)>
				<cfset stAttributes.errorVariable = "outputError">
				<cftry>
					<cfexecute name="#execName#" arguments="#execArgs#" timeout="15" variable="output" attributeCollection="#stAttributes#" />
					<cfparam name="outputError" default="">
					<cfcatch>
						<cfset outputError = "#cfcatch.message# #cfcatch.detail#">
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset outputError = "Git executable path not configured">
			</cfif>
		</cfif>

		<cfset stResult["path"] = arguments.path>
		<cfset stResult["output"] = trim(output)>
		<cfset stResult["error"] = trim(outputError)>
		<cfset stResult["isGit"] = bGitDirExists ? true : false>
		<cfset stResult["success"] = bGitDirExists AND NOT len(stResult.error) ? true : false>

		<cfreturn stResult>
	</cffunction>

	<cffunction name="executeSVNCommand" returntype="struct">
		<cfargument name="command" required="true">
		<cfargument name="path" required="true">

		<cfset var stResult = structNew()>
		<cfset var output = "">
		<cfset var outputError = "">
		<cfset var pathSVNDir = arguments.path & "/.svn">
		<cfset var bSVNDirExists = directoryExists(pathSVNDir)>
		<cfset var svnExecutable = "">
		<cfset var execName = "">
		<cfset var execArgs = "">
		<cfset var stAttributes = structNew()>

		<!--- only execute the command on svn repositories --->
		<cfif bSVNDirExists>
			<cfif findNoCase("windows", server.os.name)>
				<!--- for windows --->
				<cfset svnExecutable = application.fapi.getConfig("repo", "svnExecutable")>
				<cfset execName = "C:\windows\system32\cmd.exe">
				<cfset execArgs = '/c """#svnExecutable#""" #arguments.command# """#arguments.path#"""'>
			<cfelse>
				<!--- for nix --->
				<cfset svnExecutable = application.fapi.getConfig("repo", "svnExecutable")>
				<cfset execName = svnExecutable>
				<cfset execArgs = '#arguments.command# "#arguments.path#"'>
			</cfif>

			<!--- execute the svn command --->
			<cfif len(svnExecutable)>
				<cfset stAttributes.errorVariable = "outputError">
				<cftry>
					<cfexecute name="#execName#" arguments="#execArgs#" timeout="15" variable="output" attributeCollection="#stAttributes#" />
					<cfparam name="outputError" default="">
					<cfcatch>
						<cfset outputError = "#cfcatch.message# #cfcatch.detail#">
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset outputError = "SVN executable path not configured">
			</cfif>
		</cfif>

		<cfset stResult["path"] = arguments.path>
		<cfset stResult["output"] = trim(output)>
		<cfset stResult["error"] = trim(outputError)>
		<cfset stResult["isSVN"] = bSVNDirExists ? true : false>
		<cfset stResult["success"] = bSVNDirExists AND NOT len(stResult.error) ? true : false>

		<cfreturn stResult>
	</cffunction>

	<cffunction name="appendError" returntype="string">
		<cfargument name="currentError" required="true">
		<cfargument name="newError" required="true">

		<cfset var result = currentError>
		<cfif NOT findNoCase(newError, currentError)>
			<cfset result = result & newError>
		</cfif>

		<cfreturn result>
	</cffunction>

</cfcomponent>