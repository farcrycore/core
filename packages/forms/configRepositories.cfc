<cfcomponent displayname="Repository Info Configuration" extends="forms" key="repo" output="false"
	hint="Configure paths for source control repository info integration">

	<cfproperty name="gitExecutable" type="string" default="C:\Program Files (x86)\Git\bin\git.exe" required="false"
		ftSeq="1" ftFieldset="Executable Paths" ftLabel="Git Executable"
		ftType="string"
		ftHint="e.g. git or C:\Program Files (x86)\Git\bin\git.exe">

	<cfproperty name="svnExecutable" type="string" default="C:\Program Files\TortoiseSVN\bin\svn.exe" required="false"
		ftSeq="2" ftFieldset="Executable Paths" ftLabel="SVN Executable"
		ftType="string"
		ftHint="e.g. svn or C:\Program Files\TortoiseSVN\bin\svn.exe">


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
		<cfset arrayAppend(aPaths, application.path.project)>	

		<cfreturn aPaths>
	</cffunction>

	<cffunction name="processRepositoryPaths" returntype="struct">
		<cfargument name="aPaths" required="true">

		<cfset var stResult = structNew()>
		<cfset var i = 0>
		<cfset var stRepo = structNew()>

		<!--- process paths --->
		<cfset stResult["git"] = arrayNew(1)>
		<cfset stResult["svn"] = arrayNew(1)>
		<cfset stResult["unversioned"] = arrayNew(1)>

		<cfloop from="1" to="#arrayLen(aPaths)#" index="i">

			<!--- get the repo data --->
			<cfset stRepo = processRepository(aPaths[i])>
			<!--- add the repository to the appropriate array --->
			<cfset arrayAppend(stResult[stRepo.type], stRepo)>

		</cfloop>

		<cfreturn stResult>
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

		<!--- check git remote service --->
		<cfset stCmdResult = executeGitCommand("remote -v", arguments.path)>
		<cfif stCmdResult.success>
			<cfif findNoCase("github.com", stCmdResult.output)>
				<cfset stResult["service"] = "github">
			<cfelseif findNoCase("bitbucket.org", stCmdResult.output)>
				<cfset stResult["service"] = "bitbucket">
			<cfelse>
				<cfset stResult["service"] = "other">
			</cfif>
		</cfif>
		<!--- check git origin url --->
		<cfset stCmdResult = executeGitCommand("config --get remote.origin.url", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["origin"] = stCmdResult.output>
		</cfif>
		<!--- check current git branch --->
		<cfset stCmdResult = executeGitCommand("branch", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["branch"] = reReplaceNoCase(stCmdResult.output, ".*\* (.*)\b.*", "\1")>
		</cfif>
		<!--- check current git commit hash --->
		<cfset stCmdResult = executeGitCommand("rev-parse --short HEAD", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["commit"] = stCmdResult.output>
		</cfif>
		<!--- check current git commit date --->
		<cfset stCmdResult = executeGitCommand("log --pretty=format:%ad --date=short -1", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["date"] = stCmdResult.output>
		</cfif>
		<!--- check for dirty git repo --->
		<cfset stCmdResult = executeGitCommand("ls-files -m -o --exclude-standard", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["isDirty"] = len(stCmdResult.output) ? true : false>
			<cfset stResult["dirtyFiles"] = stCmdResult.output>
		</cfif>

		<!--- check svn url --->
		<cfset stCmdResult = executeSVNCommand("info", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["url"] = reReplaceNoCase(stCmdResult.output, ".*URL: (.*?)[\s].*", "\1")>
			<cfset stResult["revision"] = reReplaceNoCase(stCmdResult.output, ".*Revision: (.*?)[\s].*", "\1")>
			<cfset stResult["date"] = reReplaceNoCase(stCmdResult.output, ".*Last Changed Date: (.*?)[\s].*", "\1")>
		</cfif>
		<!--- check for dirty svn repo --->
		<cfset stCmdResult = executeSVNCommand("diff --internal-diff", arguments.path)>
		<cfif stCmdResult.success>
			<cfset stResult["isDirty"] = len(stCmdResult.output) ? true : false>
		</cfif>

		<cfif bGitDirExists>
			<cfset stResult["type"] = "git">
		<cfelseif bSVNDirExists>
			<cfset stResult["type"] = "svn">
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
			<cfexecute name="#execName#" arguments="#execArgs#" timeout="15" variable="output" errorVariable="outputError" />
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
			<cfexecute name="#execName#" arguments="#execArgs#" timeout="15" variable="output" errorVariable="outputError" />
		</cfif>

		<cfset stResult["path"] = arguments.path>
		<cfset stResult["output"] = trim(output)>
		<cfset stResult["error"] = trim(outputError)>
		<cfset stResult["isSVN"] = bSVNDirExists ? true : false>
		<cfset stResult["success"] = bSVNDirExists AND NOT len(stResult.error) ? true : false>

		<cfreturn stResult>
	</cffunction>


</cfcomponent>