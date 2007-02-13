<cfsetting enablecfoutputonly="Yes">

<cfparam name="url.filepath" default="" type="string">
<cfparam name="url.directory" default="" type="string">

<cfif len(url.directory)>

	<cfset subdir = url.directory>
	
<cfelseif len(url.filepath)>

	<cfset thefile = getFileFromPath(url.filepath)>
	<cfset subdir = replace(url.filepath,'\#thefile#','')>
</cfif>


<cfoutput><a href="index.cfm?subdir=#variables.subdir#">Back to file browser</a><br><br></cfoutput>


<cffunction name="dirlist" output="Yes">
	<cfargument name="dir" type="string" required="yes">
	<cfargument name="bRecurse" type="boolean" required="no" default="no">
	<cfset var qDir = "">

	<cfparam name="request.stFiles" type="struct" default="#structNew()#">
	<cfdirectory action="LIST" directory="#arguments.dir#" name="qDir">
	<cfloop from="1" to="#qDir.recordcount#" index="i">
		<cfif qDir.type[i] is 'dir' and arguments.bRecurse>
			<cfset dirlist(arguments.dir&'\'&qDir.name[i])>
		<cfelse>
			<cfset request.stFiles["#arguments.dir#\#qDir.name[i]#"] = structNew()>
			<cfloop list="#qDir.columnlist#" index="j">
			<cfset request.stFiles["#arguments.dir#\#qDir.name[i]#"][j] = qDir[j][i]>
			</cfloop>
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="generateXML">
	<cfargument name="str" type="string" required="Yes">
	<cfargument name="taglist" type="string" required="no" default="header,author,log,note,desc,date,name,revision">
	<cfset result = "<document>">

		<cfloop list="#arguments.taglist#" index="i">
			<cfset start = 1>
			<cfloop from="1" to="#len(arguments.str)#" index="j">
				<cfset stEntries = reFindNoCase('(\$#i#:[^\$]+\$)',arguments.str,start,true)>
				<cfif stEntries.len[1]>
					<cfset start = stEntries.pos[1] + stEntries.len[1]>
					<cfset substr = mid(str,stEntries.pos[1],stEntries.len[1])>
					<cfset result = result & "<" & i & ">" & reReplaceNoCase(substr,'(\$#i#:)([^\$]+)(\$)','\2') & "</" & i & ">">
				<cfelse>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfloop>
		<cfset result = result & "</document>">
<cfxml variable="docs"><cfoutput>#result#</cfoutput></cfxml>
	<cfreturn docs>
</cffunction>


<cfif len(url.directory)>

	<cfif NOT directoryExists(fsroot & url.directory)>
	<cfoutput>
	The directory passed to the autoc parser does not appear to be a valid directory.<br>
	<br>
	The directory is: <strong>#url.directory#</strong>
	</cfoutput>
	<cfabort>
	</cfif>
	
	
	<cfset dirlist(fsroot & url.directory,true)>
	
	<cfloop collection="#request.stFiles#" item="thisfile">
		<cfif listFindNoCase('.cfm,.cfc',right(thisfile,4))>
			<cflock type="READONLY" name="fsaccess" timeout="5">
				<cffile action="read" file="#thisfile#" variable="filedata">
				<cfset output = generateXML(filedata)>
				<cfdump var="#output#" label="#thisfile#">
			</cflock>
		</cfif>
	</cfloop>
	
<cfelseif len(url.filepath)>
	
	<cfif NOT fileExists(fsroot & url.filepath)>
		<cfoutput>
			The file path passed to the autoc parser does not appear to be valid.<br>
			<br>
			The file path is: <strong>#url.filepath#</strong>
		</cfoutput>
		<cfabort>
	</cfif>
	
	<cffile action="READ" file="#fsroot##url.filepath#" variable="filedata">
	<cfset output = generateXML(filedata)>

	<cfdump var="#output#">
</cfif>