<cfsetting enablecfoutputonly="true">
<cfparam name="reportType" default="filesWithOutContentItem">
<cfset lTypeNames = "dmFile,dmFlash,dmImage">
<cfset stFiles = StructNew()>
<cfswitch expression="#reportType#">
	<cfcase value="filesWithOutContentItem">
		<cfset displayReportName = "Files Without Content Items">	
		<cfloop list="#lTypeNames#" index="typename">
			<cfset objType = CreateObject("component","#Application.packagepath#.types.#typename#")>
			<cfswitch expression="#typename#">
				<cfcase value="dmImage">
					<cfset fileDirectory = application.path.defaultImagePath>
					<cfset fileFilter = "">
					<cfset sqlSelectItem = "imagefile as image_default, thumbnail as image_thumbnail, optimisedimage as image_optimised">
				</cfcase>

				<cfcase value="dmFlash">
					<cfset fileDirectory = application.path.defaultFilePath>
					<cfset fileFilter = "swf">
					<cfset sqlSelectItem = "flashmovie as file_name">
				</cfcase>
				
				<cfdefaultcase>
					<cfset fileDirectory = application.path.defaultFilePath>
					<cfset fileFilter = "">
					<cfset sqlSelectItem = "filename as file_name">
				</cfdefaultcase>
			</cfswitch>

			<cfdirectory action="list" directory="#fileDirectory#" name="qListPhysical" filter="#fileFilter#">
			<cfset aFileNamePhysical = ListToArray(ValueList(qListPhysical.name))>

			<cfquery datasource="#application.dsn#" name="qList">
			SELECT	#sqlSelectItem#
			FROM	#typename#
			</cfquery>

			<cfset lFileNameLogical = "">
			<cfif typename EQ "dmImage">
				<cfset lFileNameLogical = ListAppend(lFileNameLogical,ValueList(qList.image_default))>
				<cfset lFileNameLogical = ListAppend(lFileNameLogical,ValueList(qList.image_thumbnail))>
				<cfset lFileNameLogical = ListAppend(lFileNameLogical,ValueList(qList.image_optimised))>
			<cfelse>
				<cfset lFileNameLogical = ListAppend(lFileNameLogical,ValueList(qList.file_name))>			
			</cfif>

			<cfset stFiles[typename] = ArrayNew(1)>
			<cfset iCounter = 0>
			<cfloop index="i" from="1" to="#ArrayLen(aFileNamePhysical)#">
				<cfif NOT ListContainsNoCase(lFileNameLogical,aFileNamePhysical[i])>
					<cfset iCounter = iCounter + 1>
					<cfset stFiles[typename][iCounter] = StructNew()>
					<cfset stFiles[typename][iCounter].title = aFileNamePhysical[i]>
					<cfset stFiles[typename][iCounter].file_name = aFileNamePhysical[i]>
				</cfif>
			</cfloop>

		</cfloop>
	</cfcase>

	<cfdefaultcase>
		<cfset displayReportName = "">	
	</cfdefaultcase>>
</cfswitch>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<cfsetting enablecfoutputonly="no">
<!--- set up page header --->
<admin:header title="Library Maintenance: #displayReportName#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#"><cfoutput>
<h3>#displayReportName#</h3>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
	<th>Types</th>
	<th>Title</th>
	<th>File Name</th>
</tr><cfloop item="key" collection="#stFiles#">
<tr>
	<td class="alt">#key#</td>
	<td colspan="2"></td>
</tr><cfloop index="i" from="1" to="#ArrayLen(stFiles[key])#">
<tr>
	<td>#i#</td>
	<td>#stFiles[key][i].title#</td>
	<td>#stFiles[key][i].file_name#</td>
</tr></cfloop></cfloop>
</table></cfoutput>
<admin:footer>