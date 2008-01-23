<!--- @@displayname: Export Project to Skeleton  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

<cfsetting enablecfoutputonly="yes">

<!--- tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft">



<!--- FORM PROCESSING --->

<!--- <ft:serverSideValidation typename="farSkeleton" /> --->


<ft:processForm action="Create Skeleton">
	
	
	<ft:processFormObjects typename="farSkeleton" r_stProperties="stProperties">


		<!--- SETUP PATHS FOR LATER USE --->
		<cfset skeletonPath = expandPath("/farcry/skeletons") />
		<cfset installPath = expandPath("/farcry/core/admin/install") />

		<cfif not directoryExists("#skeletonPath#")>
			<cfdirectory action="create" directory="#skeletonPath#" mode="777" />
		</cfif>
	
		<cfset bCreateSkeleton = true />

	
		<cfif len(stProperties.name)>
			<cfif directoryExists("#skeletonPath#/#stProperties.name#")>
				<cfoutput><p>This skeleton already exists. Please choose another name.</p></cfoutput>
				<cfset bCreateSkeleton = false />
			</cfif>
		<cfelse>
			<cfoutput><p>You must select a name for your skeleton.</p></cfoutput>
			<cfset bCreateSkeleton = false />
		</cfif>
		
		<cfif bCreateSkeleton>
			

			
			<!--- SETUP COMPONENTS FOR LATER USE --->
			<cfset oTree = createObject("component", "farcry.core.packages.farcry.tree")>
			<cfset oNav = createObject("component", application.stcoapi["dmNavigation"].packagePath)>
			<cfset oCOAPI = createObject("component", "farcry.core.packages.coapi.coapiadmin") />
			
				
			<cfset oZip = createObject("component", "farcry.core.packages.farcry.zip") />
			<cfset oZip.AddFiles(zipFilePath="#skeletonPath#/#stProperties.name#.zip", directory="#application.path.project#", recurse="true", compression=0, savePaths="false") />
			<cfset oZip.Extract(zipFilePath="#skeletonPath#/#stProperties.name#.zip", extractPath="#skeletonPath#/#stProperties.name#", overwriteFiles="true") />
			<cffile action="delete" file="#skeletonPath#/#stProperties.name#.zip" />
			
			
			<cfif NOT directoryExists("#skeletonPath#/#stProperties.name#/www")>
				<cfset webrootPath = expandPath('/') />
				<cfif directoryExists("#webrootPath#/#application.applicationName#")>
					<cfset oZip.AddFiles(zipFilePath="#skeletonPath#/#stProperties.name#/webroot.zip", directory="#webrootPath#/#application.applicationName#", recurse="true", compression=0, savePaths="false") />
					<cfset oZip.Extract(zipFilePath="#skeletonPath#/#stProperties.name#/webroot.zip", extractPath="#skeletonPath#/#stProperties.name#/www", overwriteFiles="true") />
					<cffile action="delete" file="#skeletonPath#/#stProperties.name#/webroot.zip" />
				<cfelse>
					<cfoutput><p>Cannot find the webroot of your project. You will not be able to create a skeleton from this project.</p></cfoutput>
					<cfset bCreateSkeleton = false />
				</cfif>
			</cfif>	
			
			<cfif directoryExists("#skeletonPath#/#stProperties.name#/wwwCopiedToFolderUnderWebroot")>
				<cfdirectory action="delete" directory="#skeletonPath#/#stProperties.name#/wwwCopiedToFolderUnderWebroot" recurse="true" />
			</cfif>
	
			<!--- read the master manifest template file --->
			<cfset manifestLoc = "#installPath#/config_files/manifest.cfc" />
			<cffile action="read" file="#manifestLoc#" variable="manifestContent" />
		
			<!--- Get rid of newlines --->
			<cfset stProperties.description = replaceNoCase(stProperties.description, chr(10), "", "all") />
			<cfset stProperties.description = replaceNoCase(stProperties.description, chr(13), "", "all") />
			
			<cfset manifestContent = replaceNoCase(manifestContent, "@@applicationName@@", "#stProperties.name#", "all") />
			<cfset manifestContent = replaceNoCase(manifestContent, "@@description@@", "#stProperties.description#", "all") />
			<cfset manifestContent = replaceNoCase(manifestContent, "@@plugins@@", "#application.plugins#", "all") />			
			
			<cftry>
				<cfdirectory action="create" directory="#skeletonPath#/#stProperties.name#/install" mode="777" />
				<cfcatch type="any"><!--- ignore ---></cfcatch>
			</cftry>
			<cffile action="write" file="#skeletonPath#/#stProperties.name#/install/manifest.cfc" output="#manifestContent#" addnewline="false" mode="777" />	


			<cfset directoryRemoveSVN(source="#skeletonPath#/#stProperties.name#") />

			
			<cfset wddxLoc = "#skeletonPath#/#stProperties.name#/install" />
						
			
			<!--- ADD NESTED TREE TABLE --->
			<cfquery datasource="#application.dsn#" name="qTree">
			SELECT *
			FROM #application.dbowner#nested_tree_objects
			ORDER BY nLeft
			</cfquery>
			<cfwddx action="cfml2wddx" input="#qTree#" output="wddxTree">			
			<cffile action="write" file="#wddxLoc#/nested_tree_objects.wddx" output="#wddxTree#" addnewline="false" mode="777" >
	

			<cfset lTypenamesToExport = structKeyList(application.stCoapi) />
			<cfif not stProperties.bIncludeLog>
				<cfset lTypenamesToExport = listDeleteAt(lTypenamesToExport, listFindNoCase(lTypenamesToExport, "farLog")) />
			</cfif>
			<cfif not stProperties.bIncludeArchive>
				<cfset lTypenamesToExport = listDeleteAt(lTypenamesToExport, listFindNoCase(lTypenamesToExport, "dmArchive")) />
			</cfif>
			
			<cfloop list="#lTypenamesToExport#" index="typename" >
				<cfset aContent = arrayNew(1) />
				<cftry>
					
					
					<cfquery datasource="#application.dsn#" name="q">
					SELECT *
					FROM #application.dbowner##typeName#
					</cfquery>
					
					<cfset o = createObject("component", application.stcoapi["#typeName#"].packagePath)>
					
					<cfloop query="q">
						
						<cfset st = o.getData(objectid="#q.objectid#", bArraysAsStructs="true") />
					
						<cfset arrayAppend(aContent, st) />
						
					</cfloop>
					
					<cfif arrayLen(aContent)>
						<cfwddx action="cfml2wddx" input="#aContent#" output="wddxContent">
						<cffile action="write" file="#wddxLoc#/#typename#.wddx" output="#wddxContent#" addnewline="false" mode="777" >
					</cfif>
				
								
					<cfcatch type="database"><!--- ignore ---></cfcatch>
					<cfcatch type="any"><cfdump var="#cfcatch#" label="typename: #typename#"><cfabort></cfcatch>
				</cftry>
				
			</cfloop>

			
			<!--- 
			<!--- ADD SECURITY CONTENT ITEMS --->
			<cfset typeNames = "farBarnacle,farGroup,farPermission,farRole,farUser" />
			
			<cfloop list="#typeNames#" index="typename" >
				<cfquery datasource="#application.dsn#" name="q">
				SELECT *
				FROM #application.dbowner##typeName#
				</cfquery>
				
				<cfset o = createObject("component", application.stcoapi["#typeName#"].packagePath)>
				
				<cfloop query="q">
					
					<cfset st = o.getData(objectid="#q.objectid#", bArraysAsStructs="true") />
				
					<cfset arrayAppend(aSecurity, st) />
					
				</cfloop>
				
			</cfloop>
			
			<cfwddx action="cfml2wddx" input="#aSecurity#" output="wddxSecurity">
			<cffile action="write" file="#wddxLoc#/security.wddx" output="#wddxSecurity#" addnewline="false" mode="777" >
			 --->
			
			<!--- COMPLETE --->
			<cfoutput><h1>DONE</h1></cfoutput>
			
		</cfif>
	
	</ft:processFormObjects>

	
</ft:processForm>



<!--- FORM --->
<cfparam name="session.skeletonID" default="#createUUID()#" />
<ft:form>
	<ft:object typename="farSkeleton" objectid="#session.skeletonID#" legend="Skeleton Details" />
	
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Create Skeleton" />
	</ft:farcryButtonPanel>
</ft:form>



<!--- REMOVE .SVN FOLDERS FROM ENTIRE DIRECTORY --->
<cffunction name="directoryRemoveSVN" output="true">
	<cfargument name="source" required="true" type="string">

	<cfset var contents = "" />
		
		<cfdirectory action="list" directory="#arguments.source#" name="contents">
		
		<cfloop query="contents">
			<cfif contents.type eq "dir">
				<cfif contents.name eq ".svn">
					<cfdirectory action="delete" directory="#arguments.source#/#contents.name#" recurse="true" />
				<cfelse>
					<cfset directoryRemoveSVN(arguments.source & "/" & contents.name) />
				</cfif>
				
			</cfif>
		</cfloop>
</cffunction>	
	